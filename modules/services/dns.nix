{ config, pkgs, ... }:

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

  # DNS Configuration - AdGuard Home
  services.resolved = {
    enable = true;
    dnssec = "false";
    fallbackDns = [];
    extraConfig = ''
      DNS=192.168.1.181
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

  # Firewall: block all DNS except to AdGuard
  networking.firewall = {
    enable = true;
    extraCommands = ''
      # Allow DNS to AdGuard Home only (IPv4)
      iptables -I OUTPUT -p udp --dport 53 -d 192.168.1.181 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 192.168.1.181 -j ACCEPT
      
      # Allow local stub resolver
      iptables -I OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT
      iptables -I OUTPUT -p tcp --dport 53 -d 127.0.0.0/8 -j ACCEPT
      
      # Block all other IPv4 DNS
      iptables -A OUTPUT -p udp --dport 53 -j REJECT
      iptables -A OUTPUT -p tcp --dport 53 -j REJECT
      
      # Block ALL IPv6 DNS (leak prevention)
      ip6tables -A OUTPUT -p udp --dport 53 -j REJECT
      ip6tables -A OUTPUT -p tcp --dport 53 -j REJECT
    '';
    extraStopCommands = ''
      iptables -D OUTPUT -p udp --dport 53 -d 192.168.1.181 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 192.168.1.181 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -d 127.0.0.0/8 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -j REJECT 2>/dev/null || true
      iptables -D OUTPUT -p tcp --dport 53 -j REJECT 2>/dev/null || true
      ip6tables -D OUTPUT -p udp --dport 53 -j REJECT 2>/dev/null || true
      ip6tables -D OUTPUT -p tcp --dport 53 -j REJECT 2>/dev/null || true
    '';
  };
}
