#!/bin/bash

echo "[DEBUG]################### GET LATEST ISO INFO ###################"
latest_iso_name=$(curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/SHA256SUMS | awk '{print $2}' | head -n 1)
latest_iso_hash=$(curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/SHA256SUMS | awk '{print $1}' | head -n 1)

echo "[DEBUG]################### GET LATEST ISO ###################"
curl -o /tmp/${latest_iso_name} http://debian.ethz.ch/debian-cd/current/amd64/iso-dvd/${latest_iso_name}

if [[ $(sha256sum /tmp/${latest_iso_name} | awk '{print $1}') == $latest_iso_hash ]]; then
    echo "Checksum Valid !!!";

    cd /work
    xorriso -osirrox on -indev /tmp/${latest_iso_name} -extract / debian_iso_custom
    rm -f /tmp/${latest_iso_name}
    echo "############################################ GRUB.CFG"
    ls debian_iso_custom

    sed -i '0,/vmlinuz/ s#\(vmlinuz\).*$#\1 vga=788 file=/cdrom/preseed/preseed.cfg auto=true priority=critical --- quiet#' debian_iso_custom/boot/grub/grub.cfg
    echo "set timeout=5" >> debian_iso_custom/boot/grub/grub.cfg

    echo "############################################ PRESEED"

    mkdir debian_iso_custom/preseed
    cp /work/preseed.cfg debian_iso_custom/preseed/

    echo "############################################"

    # Emulate mkisofs to create the ISO
    # Output file name
    # MBR for hybrid boot (BIOS + USB bootable)
    # Boot catalog for BIOS boot (El Torito)
    # ISOLINUX bootloader binary for BIOS
    # Disable floppy emulation for BIOS boot
    # Number of 512-byte sectors to load for bootloader
    # Include boot information table (required by ISOLINUX)
    # Embed GRUB2 boot information
    # Start a new El Torito boot entry (for UEFI boot)
    # EFI bootloader image for UEFI systems
    # Disable floppy emulation for UEFI boot
    # Enable Joliet support for long filenames
    # Allow very long filenames in Joliet format
    # Enable Rock Ridge extensions (Unix file attributes)
    # Set volume label to "Custom Debian ISO"

    cd debian_iso_custom

    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -joliet \
        -joliet-long \
        -rational-rock \
        -isohybrid-mbr "isolinux/isolinux.bin" \
        -append_partition 2 0xef "boot/grub/efi.img" \
        -partition_cyl_align all \
        -c "isolinux/boot.cat" \
        -b "isolinux/isolinux.bin" \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        -eltorito-alt-boot \
        -e --interval:appended_partition_2:all:: \
        -no-emul-boot \
        -V "Custom Debian ISO" \
        -o "debian_latest_custom_KARIM.iso" \
        ./

    cd ..        


else
    echo "ERROR Checksum ???";
fi