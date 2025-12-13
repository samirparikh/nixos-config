{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ nextdns ];

  services.nextdns = {
    # Set this back to true to enable NextDNS
    enable = false;
    arguments = [ 
      "-config-file"
      config.sops.secrets.nextdns_config.path
      "-cache-size"
      "10MB" 
    ];
  };

# Uncomment these lines to enable NextDNS
#  networking = {
#    nameservers = [
#      "45.90.28.110"
#      "45.90.30.110"
#    ];
#  };

# Comment out these lines to disable AdGuard Home
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    fallbackDns = [ "1.1.1.1" "9.9.9.9" ];
    extraConfig = ''
      DNS=192.168.1.229
    '';
  };

  networking.networkmanager = {
    dns = "systemd-resolved";
    connectionConfig = {
      "ipv4.ignore-auto-dns" = true;
      "ipv6.ignore-auto-dns" = true;
    };
  };
# End AdGuard Home configuration
}
