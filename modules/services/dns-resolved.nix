{ ... }:

{
  # DNS via systemd-resolved, pointing all queries to AdGuard Home.
  # Does not include the nextdns or search-domain-from-secret services
  # (those require sops and live in dns.nix for hosts that have it).
  services.resolved = {
    enable = true;
    dnssec = "false";
    fallbackDns = [];
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

  # Firewall: allow DNS only to approved resolvers
  #
  # Approved resolvers:
  # - Local stub (127.0.0.0/8) so apps can talk to systemd-resolved
  # - AdGuard Home (192.168.1.229) for your LAN DNS
  # - Tailscale MagicDNS (100.100.100.100) for *.ts.net resolution
  # - Mullvad DNS (10.64.0.1) ONLY when egressing wg0-mullvad
  # - Optional: Mullvad "all filters" DNS (100.64.0.31) ONLY on wg0-mullvad
  networking.firewall = {
    enable = true;

    extraCommands = ''
      set -euo pipefail

      add_ipt_rule() {
        # Usage: add_ipt_rule <iptables|ip6tables> <insert|append> <chain> <rule...>
        local bin="$1"; shift
        local mode="$1"; shift
        local chain="$1"; shift

        if $bin -C "$chain" "$@" 2>/dev/null; then
          return 0
        fi

        if [ "$mode" = "insert" ]; then
          $bin -I "$chain" 1 "$@"
        else
          $bin -A "$chain" "$@"
        fi
      }

      # --- Allow list (IPv4) ---

      # Allow local stub resolver (systemd-resolved)
      add_ipt_rule iptables insert OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT
      add_ipt_rule iptables insert OUTPUT -p tcp --dport 53 -d 127.0.0.0/8 -j ACCEPT

      # Allow DNS to AdGuard Home (LAN)
      add_ipt_rule iptables insert OUTPUT -p udp --dport 53 -d 192.168.1.229 -j ACCEPT
      add_ipt_rule iptables insert OUTPUT -p tcp --dport 53 -d 192.168.1.229 -j ACCEPT

      # Allow DNS to Tailscale MagicDNS
      add_ipt_rule iptables insert OUTPUT -p udp --dport 53 -d 100.100.100.100 -j ACCEPT
      add_ipt_rule iptables insert OUTPUT -p tcp --dport 53 -d 100.100.100.100 -j ACCEPT

      # Allow Mullvad DNS ONLY when going out the Mullvad interface
      add_ipt_rule iptables insert OUTPUT -o wg0-mullvad -p udp --dport 53 -d 10.64.0.1 -j ACCEPT
      add_ipt_rule iptables insert OUTPUT -o wg0-mullvad -p tcp --dport 53 -d 10.64.0.1 -j ACCEPT

      # Optional: Mullvad DNS with "all filters" (content blocking), also only on wg0-mullvad
      add_ipt_rule iptables insert OUTPUT -o wg0-mullvad -p udp --dport 53 -d 100.64.0.31 -j ACCEPT
      add_ipt_rule iptables insert OUTPUT -o wg0-mullvad -p tcp --dport 53 -d 100.64.0.31 -j ACCEPT

      # --- Deny list (IPv4 / IPv6) ---

      # Block all other IPv4 DNS
      add_ipt_rule iptables append OUTPUT -p udp --dport 53 -j REJECT
      add_ipt_rule iptables append OUTPUT -p tcp --dport 53 -j REJECT

      # Block ALL IPv6 DNS (leak prevention)
      add_ipt_rule ip6tables append OUTPUT -p udp --dport 53 -j REJECT
      add_ipt_rule ip6tables append OUTPUT -p tcp --dport 53 -j REJECT
    '';

    extraStopCommands = ''
      del_ipt_rule() {
        local bin="$1"; shift
        local chain="$1"; shift
        while $bin -C "$chain" "$@" 2>/dev/null; do
          $bin -D "$chain" "$@" 2>/dev/null || break
        done
      }

      del_ipt_rule iptables OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT
      del_ipt_rule iptables OUTPUT -p tcp --dport 53 -d 127.0.0.0/8 -j ACCEPT

      del_ipt_rule iptables OUTPUT -p udp --dport 53 -d 192.168.1.229 -j ACCEPT
      del_ipt_rule iptables OUTPUT -p tcp --dport 53 -d 192.168.1.229 -j ACCEPT

      del_ipt_rule iptables OUTPUT -p udp --dport 53 -d 100.100.100.100 -j ACCEPT
      del_ipt_rule iptables OUTPUT -p tcp --dport 53 -d 100.100.100.100 -j ACCEPT

      del_ipt_rule iptables OUTPUT -o wg0-mullvad -p udp --dport 53 -d 10.64.0.1 -j ACCEPT
      del_ipt_rule iptables OUTPUT -o wg0-mullvad -p tcp --dport 53 -d 10.64.0.1 -j ACCEPT

      del_ipt_rule iptables OUTPUT -o wg0-mullvad -p udp --dport 53 -d 100.64.0.31 -j ACCEPT
      del_ipt_rule iptables OUTPUT -o wg0-mullvad -p tcp --dport 53 -d 100.64.0.31 -j ACCEPT

      del_ipt_rule iptables OUTPUT -p udp --dport 53 -j REJECT
      del_ipt_rule iptables OUTPUT -p tcp --dport 53 -j REJECT

      del_ipt_rule ip6tables OUTPUT -p udp --dport 53 -j REJECT
      del_ipt_rule ip6tables OUTPUT -p tcp --dport 53 -j REJECT
    '';
  };
}
