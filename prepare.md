## 确保ADB可用

一般情况下ADB默认开启，将棒子连接到电脑就可以使用`adb devices`查看到设备。部分机型没有开启，需要修改`system`分区中的配置文件`build.prop`，在其中的`persist.sys.usb.config`、`ro.sys.usb.default.config`等相关配置中追加`adb`。如果配置中有tcp的adb服务，例如`persist.adb.tcp.port`、`service.adb.tcp.port`，最好用`#`注释掉，防止干扰。如果有`persist.sys.usb.config.extra`也最好注释掉。如果实在不会修改，可直接问AI。

找到Qualcomm Premium Tool提取出的文件中的`system.img`，在linux中以可读写方式挂载它，修改其中根目录下的build.prop文件。注意修改需要主机root权限。

```Shell
sudo mount -o loop system.img ./sys
cd sys
sudo vim build.prop
cd ..
sudo umount ./sys
```

## 安装所需的软件

构建底包、编译内核都在linux上进行，我们需要在用来构建的主机上安装相应的软件。其中，`simg2img`和`img2simg`这两个软件现在被并入`android-sdk-libsparse-utils`。

`kernel-package`已经被官方取消，需要手动安装，要用到其中的`make-kpkg`命令。也可以不安装这个包，有替代手段。

`gcc`需要根据软件源和系统版本，选择合适的版本号。例如，对于Debian 13 Trixie，应该安装`gcc-14-aarch64-linux-gnu`。

```Shell
sudo apt install git vim android-sdk-libsparse-utils \
    fakeroot mkbootimg bison flex gcc-14-aarch64-linux-gnu \
    binfmt-support qemu-user-static wget libncurses-dev \
    gcc-aarch64-linux-gnu libssl-dev debootstrap libelf-dev:native \
    libssl-dev 
sudo dpkg --add-architecture arm64
sudo apt update
sudo apt install libssl-dev:arm64
```
