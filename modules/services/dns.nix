{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ nextdns ];

  services.nextdns = {
    enable = false;
    arguments = [ 
      "-config-file"
      config.sops.secrets.nextdns_config.path
      "-cache-size"
      "10MB" 
    ];
  };

  # DNS Configuration - AdGuard Home with fallbacks
  services.resolved = {
    enable = true;
    dnssec = "false";
    # fallbackDns = [ "100.100.100.100" "1.1.1.1" "9.9.9.9" ];
    extraConfig = ''
      DNS=192.168.1.229
      Domains=~.
      DNSOverTLS=no
      MulticastDNS=no
      LLMNR=no
      ResolveUnicastSingleLabel=no
    '';
  };

  networking.networkmanager = {
    dns = "systemd-resolved";
    connectionConfig = {
      "ipv4.ignore-auto-dns" = true;
      "ipv6.ignore-auto-dns" = true;
    };
  };

  # Firewall: allow DNS only to approved servers
  networking.firewall = {
    enable = true;
    extraCommands = ''
      # Allow DNS to AdGuard Home (primary)
      iptables -I OUTPUT -p udp --dport 53 -d 192.168.1.229 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 192.168.1.229 -j ACCEPT

      # Allow DNS to Tailscale MagicDNS (fallback 1)
      iptables -I OUTPUT -p udp --dport 53 -d 100.100.100.100 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 100.100.100.100 -j ACCEPT

      # Allow DNS to Cloudflare and Quad9 (fallback 2)
      iptables -I OUTPUT -p udp --dport 53 -d 1.1.1.1 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 1.1.1.1 -j ACCEPT
      iptables -I OUTPUT -p udp --dport 53 -d 9.9.9.9 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 9.9.9.9 -j ACCEPT

      # Allow local stub resolver
      iptables -I OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 127.0.0.0/8 -j ACCEPT

      # Allow Mullvad internal DNS
      iptables -I OUTPUT -p udp --dport 53 -d 10.64.0.1 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 10.64.0.1 -j ACCEPT

      # Block all other IPv4 DNS
      iptables -A OUTPUT -p udp --dport 53 -j REJECT
      iptables -A OUTPUT -p tcp --dport 53 -j REJECT

      # Block ALL IPv6 DNS (leak prevention)
      ip6tables -A OUTPUT -p udp --dport 53 -j REJECT
      ip6tables -A OUTPUT -p tcp --dport 53 -j REJECT
    '';
    extraStopCommands = ''
      iptables -D OUTPUT -p udp --dport 53 -d 192.168.1.229 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 192.168.1.229 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -d 100.100.100.100 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 100.100.100.100 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -d 1.1.1.1 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 1.1.1.1 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -d 9.9.9.9 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 9.9.9.9 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 127.0.0.0/8 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -j REJECT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -j REJECT 2>/dev/null || true
      ip6tables -D OUTPUT -p udp --dport 53 -j REJECT 2>/dev/null || true
      ip6tables -D OUTPUT -p tcp --dport 53 -j REJECT 2>/dev/null || true
      # Mullvad Configuration
      iptables -D OUTPUT -p udp --dport 53 -d 10.64.0.1 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 10.64.0.1 -j ACCEPT 2>/dev/null || true

    '';
  };

  # Configure search domain at runtime from secret
  systemd.services.configure-search-domain = {
    description = "Configure systemd-resolved search domain from secret";
    wantedBy = [ "multi-user.target" ];
    before = [ "systemd-resolved.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      SEARCH_DOMAIN=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.search_domain.path})
      ${pkgs.coreutils}/bin/mkdir -p /etc/systemd/resolved.conf.d
      ${pkgs.coreutils}/bin/cat > /etc/systemd/resolved.conf.d/90-search-domain.conf << EOF
      [Resolve]
      Domains=$SEARCH_DOMAIN
      EOF
    '';
  };
}
