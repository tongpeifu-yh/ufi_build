#编译内核
git clone https://github.com/OpenStick/linux --depth=1
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
make msm8916_defconfig
make menuconfig
#按理说不需要进行额外的menuconfig就可以运行才对，但这两天试了一下似乎不能正常usb共享网络
#现在把一个成功共享的config-5.15.0-handsomekernel放在configure_files/

make -j16
#下面构建deb安装包，如果没有kernel-package可以使用make deb-pkg代替，但是实测不推荐使用，速度比make-kpkg慢很多（似乎是先clean了一把，然后整个重新编译）
fakeroot make-kpkg  --initrd --cross-compile aarch64-linux-gnu- --arch arm64  kernel_image kernel_headers