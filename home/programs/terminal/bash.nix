{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
      ll = "ls -alh";
      butane = "podman run --rm --interactive --security-opt label=disable --volume \"\${PWD}:/pwd\" --workdir /pwd quay.io/coreos/butane:release";
      coreos-installer = "podman run --pull=always --rm --interactive --security-opt label=disable --volume \"\${PWD}:/pwd\" --workdir /pwd quay.io/coreos/coreos-installer:release";
      ignition-validate = "podman run --rm --interactive --security-opt label=disable --volume \"\${PWD}:/pwd\" --workdir /pwd quay.io/coreos/ignition-validate:release";
    };

    bashrcExtra = ''
      # Custom bash configuration
      export EDITOR=vim
    '';
  };
}
