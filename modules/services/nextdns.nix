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
  networking = {
    nameservers = [ "192.168.1.181" ];
    networkmanager.dns = "none";
    resolvconf.useLocalResolver = false;
  };
  
  environment.etc."resolv.conf".text = ''
    nameserver 192.168.1.181
  '';
# End AdGuard Home configuration
}
