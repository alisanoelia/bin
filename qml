#!/bin/sh
qemu-system-x86_64 \
  -M q35 \
  -cpu host \
  -enable-kvm \
  -vga virtio \
  -display sdl,show-cursor=on \
  -smp 2,cores=2 \
  -m 2G \
  -boot d \
  -cdrom $1 \
  -hda $2
