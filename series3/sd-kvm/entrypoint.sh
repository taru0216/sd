#!/bin/sh
#
# Copyright 2018 Masato Taruishi <taru@retty.me>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

set -e

# Debug
if test "x$DOCKERTIPS3_DEBUG" != "x"; then
  set -x
fi


# KVM Options
if test "x$DOCKERTIPS3_QEMU_MACHINE" = "x"; then
  DOCKERTIPS3_QEMU_MACHINE="pc"
  if test -w /dev/kvm; then
    DOCKERTIPS3_QEMU_MACHINE="$DOCKERTIPS3_QEMU_MACHINE,accel=kvm"
    DOCKERTIPS3_QEMU_CPU="${DOCKERTIPS3_QEMU_CPU:-host}"
  fi
fi

DOCKERTIPS3_QEMU_CPU="${DOCKERTIPS3_QEMU_CPU:-qemu64}"

DOCKERTIPS3_DISK_BASE="${DOCKERTIPS3_DISK_BASE:-/dockertips3.img}"
DOCKERTIPS3_DISK="${DOCKERTIPS3_DISK:-/cache/$(basename $DOCKERTIPS3_DISK_BASE)}"

DOCKERTIPS3_FACTORY_RESET=${DOCKERTIPS3_FACTORY_RESET:-}

DOCKERTIPS3_QEMU_MEM="${DOCKERTIPS3_QEMU_MEM:-1024}"
DOCKERTIPS3_QEMU_SMP="${DOCKERTIPS3_QEMU_SMP:-$(getconf _NPROCESSORS_ONLN)}"
DOCKERTIPS3_QEMU_EXTRA_ARGS="${DOCKERTIPS3_QEMU_EXTRA_ARGS:--m ${DOCKERTIPS3_QEMU_MEM} -smp ${DOCKERTIPS3_QEMU_SMP}}"

DOCKERTIPS3_DEVICE_DRIVE="${DOCKERTIPS3_DEVICE_DRIVE:-ide-hd}"
DOCKERTIPS3_DEVICE_NET="${DOCKERTIPS3_DEVICE_NET:-e1000}"
DOCKERTIPS3_DEVICE_VGA="${DOCKERTIPS3_DEVICE_VGA:-qxl-vga}"

DOCKERTIPS3_GRAPHIC_DISPLAY_0="${DOCKERTIPS3_GRAPHIC_DISPLAY_0:--vnc :0}"
DOCKERTIPS3_GRAPHIC_DISPLAY_1="${DOCKERTIPS3_GRAPHIC_DISPLAY_1:--spice port=5901,disable-ticketing,seamless-migration=on}"
DOCKERTIPS3_GRAPHIC="${DOCKERTIPS3_GRAPHIC:-$DOCKERTIPS3_GRAPHIC_DISPLAY_0 $DOCKERTIPS3_GRAPHIC_DISPLAY_1}"
DOCKERTIPS3_HOST_PORTS="${DOCKERTIPS3_HOST_PORTS:-5900 5901}"

# Display
cat > /ports <<EOF
DOCKERTIPS3_HOST_PORTS="${DOCKERTIPS3_HOST_PORTS}"
EOF

# Disk
DISK_FORMAT=qcow2
QEMU_IMG_DISK=$DOCKERTIPS3_DISK
if ! test -f "$DOCKERTIPS3_DISK" || test "x$DOCKERTIPS3_FACTORY_RESET" != "x"; then
  DISK_NEED_GENERATE=1
  QEMU_IMG_CREATE_ARGS="-o size=32G"
  if ! test -f "$DOCKERTIPS3_DISK_BASE" && test -f "$DOCKERTIPS3_PRESEED" && test -x /kvmbootstrap; then
    /kvmbootstrap $DOCKERTIPS3_DISK_BASE 32g $DOCKERTIPS3_PRESEED
  fi
  if test -f "$DOCKERTIPS3_DISK_BASE"; then
    QEMU_IMG_CREATE_ARGS="$QEMU_IMG_CREATE_ARGS,backing_file=$DOCKERTIPS3_DISK_BASE"
  fi
fi

install -d $(dirname $DOCKERTIPS3_DISK)

if test "$DISK_NEED_GENERATE" = "1"; then
  echo "Generating a disk image: $DOCKERTIPS3_DISK..." 1>&2
  qemu-img create -f $DISK_FORMAT $QEMU_IMG_CREATE_ARGS $QEMU_IMG_DISK
fi

# Boot
echo "Booting KVM using $DOCKERTIPS3_DISK... "
exec qemu-system-x86_64 \
    -nodefaults \
    -machine $DOCKERTIPS3_QEMU_MACHINE \
    -cpu $DOCKERTIPS3_QEMU_CPU \
    -serial mon:stdio \
    -drive file=$DOCKERTIPS3_DISK,if=none,id=drive0 -device $DOCKERTIPS3_DEVICE_DRIVE,drive=drive0 \
    -netdev tap,id=hostnet0,script=/kvm-ifup.sh,downscript=/kvm-ifdown.sh \
    -device $DOCKERTIPS3_DEVICE_NET,netdev=hostnet0,id=net0 \
    $DOCKERTIPS3_GRAPHIC -nographic \
        -device $DOCKERTIPS3_DEVICE_VGA \
        -device virtio-serial-pci,id=virtio-serial0,bus=pci.0 \
        -chardev spicevmc,id=charchannel0,name=vdagent \
        -device virtserialport,bus=virtio-serial0.0,chardev=charchannel0,id=channel0,name=com.redhat.spice.0 \
    -device virtio-balloon-pci,id=balloon0,bus=pci.0 \
    $QEMU_EXTRA_ARGS \
    $DOCKERTIPS3_QEMU_EXTRA_ARGS \
    "$@"
