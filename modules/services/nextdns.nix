{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ nextdns ];

  services.nextdns = {
    enable = true;
    arguments = [ 
      "-config-file"
      config.sops.secrets.nextdns_config.path
      "-cache-size"
      "10MB" 
    ];
  };

  networking = {
    nameservers = [
      "45.90.28.110"
      "45.90.30.110" ];
  };
}
