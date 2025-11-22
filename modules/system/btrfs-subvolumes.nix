# nixos-config/modules/system/btrfs-subvolumes.nix
{ config, pkgs, lib, ... }:

{
  # Create btrfs subvolumes before they are mounted
  # This ensures subvolumes exist on a fresh installation
  system.activationScripts.createBtrfsSubvolumes = lib.stringAfter [ "var" ] ''
    # Device and mount point configuration
    DEVICE="/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15"
    TEMP_MOUNT="/mnt/btrfs-root-temp"
    
    # List of subvolumes to create
    SUBVOLUMES=(
      "@home-Desktop"
      "@home-Documents"
      "@home-Music"
      "@home-Pictures"
      "@home-Videos"
    )
    
    # Check if device exists
    if [ ! -e "$DEVICE" ]; then
      echo "Warning: Device $DEVICE not found, skipping subvolume creation"
      exit 0
    fi
    
    # Create temporary mount point
    mkdir -p "$TEMP_MOUNT"
    
    # Mount the btrfs root (subvolid=5)
    if ! mountpoint -q "$TEMP_MOUNT"; then
      mount -o subvolid=5 "$DEVICE" "$TEMP_MOUNT" || {
        echo "Failed to mount btrfs root"
        exit 0
      }
    fi
    
    # Create subvolumes if they don't exist
    for subvol in "''${SUBVOLUMES[@]}"; do
      if [ ! -d "$TEMP_MOUNT/$subvol" ]; then
        echo "Creating btrfs subvolume: $subvol"
        ${pkgs.btrfs-progs}/bin/btrfs subvolume create "$TEMP_MOUNT/$subvol"
      else
        echo "Subvolume $subvol already exists"
      fi
    done
    
    # Unmount temporary mount
    umount "$TEMP_MOUNT" || true
    rmdir "$TEMP_MOUNT" || true
  '';
  
  # Ensure home directories exist before mounting
  systemd.tmpfiles.rules = [
    "d /home/samir 0755 samir users -"
    "d /home/samir/Desktop 0755 samir users -"
    "d /home/samir/Documents 0755 samir users -"
    "d /home/samir/Music 0755 samir users -"
    "d /home/samir/Pictures 0755 samir users -"
    "d /home/samir/Videos 0755 samir users -"
  ];
}
