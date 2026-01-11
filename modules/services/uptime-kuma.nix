{ lib, ... }:

# The lib.mkForce [] overrides the default wantedBy = [ "multi-user.target" ]
# that the module sets, which is what causes services to start at boot. With
# this configuration:
#
# * The systemd unit file is fully generated with all the proper paths,
#   user/group settings, and dependencies
# * The service won't start automatically on boot
# * You can manually control it with systemctl start uptime-kuma and systemctl
#   stop uptime-kuma
#
# If you want to temporarily enable it to start at boot later without changing
# your config, you can also use systemctl enable uptime-kuma (though that change
# won't persist through a nixos-rebuild).

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "3001";
      # HOST = "127.0.0.1";  # if you want to restrict to localhost
    };
  };
  systemd.services.uptime-kuma.wantedBy = lib.mkForce [];
}
