#!/usr/bin/bash
#首先安装依赖与构建工具
#其中，simg2img与img2simg更新为android-sdk-libsparse-utilsi
#kernel-package已经被官方取消，需要手动安装，现置于deb/目录下；当然也可以不安装，只是要用到其中的make-kpkg命令而已，有替代方法
sudo apt install git vim android-sdk-libsparse-utils fakeroot mkbootimg bison flex gcc-12-aarch64-linux-gnu binfmt-support qemu-user-static wget libncurses-dev gcc-aarch64-linux-gnu libssl-dev debootstrap
