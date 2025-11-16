{ config, lib, pkgs, ... }:

{
  # OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # GPU drivers (uncomment as needed)
  # services.xserver.videoDrivers = [ "nvidia" ];
  # services.xserver.videoDrivers = [ "amdgpu" ];
}
