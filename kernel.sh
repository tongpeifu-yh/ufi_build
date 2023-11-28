#编译内核
git clone https://github.com/OpenStick/linux --depth=1
cd linux
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
make msm8916_defconfig
make menuconfig
#如果不需要增加其他选项，直接保持默认即可，不需要make menuconfig
#若不识别usb rndis网络不是内核的问题，是安装顺序的原因，具体见others.md
make -j16
#下面构建deb安装包，如果没有安装kernel-package可以使用make deb-pkg代替，但是实测不推荐使用，速度比make-kpkg慢很多（似乎是先clean了一把，然后整个重新编译）
fakeroot make-kpkg  --initrd --cross-compile aarch64-linux-gnu- --arch arm64  kernel_image kernel_headers