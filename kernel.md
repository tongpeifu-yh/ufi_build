## 内核

### 编译内核

编译内核最简单的方式是克隆openstick的内核源码并编译。

```Shell
#编译内核
git clone https://github.com/OpenStick/linux --depth=1
cd linux
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
make msm8916_defconfig
make menuconfig
# 如果不需要增加其他选项，直接保持默认即可，不需要make menuconfig
# 若不识别usb rndis网络不是内核的问题，是安装顺序的原因，具体见others.md
make -j 16
# 下面构建deb安装包，如果没有安装kernel-package可以使用make bindeb-pkg代替
fakeroot make-kpkg  --initrd --cross-compile aarch64-linux-gnu- --arch arm64  kernel_image kernel_headers

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
    KDEB_CHANGELOG_DIST=bookworm \
    bindeb-pkg
```

该内核的问题是版本5.15，比较老。如果有需要可以克隆上游[github.com/msm8916-mainline/linux](https://github.com/msm8916-mainline/linux)，需要手动配置。若使用该上游，需要在menuconfig时手动启用下面的模块：

1. USB Gadget

   进入`Device Drivers → USB support → USB Gadget Support`（确认开启 `USB Gadget Support [y]`），开启 `USB functions configurable through configfs`（`USB_CONFIGFS`，选 y），之后下面会多出一排 function，逐个选 y（没有 M 选项，都是 bool）

   - `Generic serial bulk in/out`
   - `Abstract Control Model (CDC ACM)`
   - `Network Control Model (CDC NCM)`
   - `Ethernet Control Model (CDC ECM)`
   - `Ethernet Control Model (CDC ECM) subset`
   - `RNDIS`
   - `Ethernet Emulation Model (EEM)`
   - `Mass storage`
   - `Function filesystem (FunctionFS)`

2. nftables / iptables 补充

   进入`Networking support → Networking options → Network packet filtering framework (Netfilter) → Core Netfilter Configuration`。

   - `Netfilter nftables support`（选 m），选上后展开一批，全部选上：
     - `Netfilter nftables mixed IPv4/IPv6 tables support`（选 y）
     - `Netfilter nftables netdev tables support`（选 y）
     - `nf_tables` 各种 module：`conntrack / counter / log / limit / masquerade / nat / reject / reject for default-inet / x_tables over nf_tables compat`（选 m）
   - 继续向下到 `Xtables targets`，开启`MASQUERADE target support`、`TCPMSS target support`（都 m）
   - 继续向下到`Xtables matches`，开 `"multiport" Multiple port match support`、`"tcpmss" match support`（都 m）
   - 如果 TCPMSS 之类不显示，先把本菜单底部的` Advanced netfilter configuration`打开再回来

   进入`Networking support → Networking options → Network packet filtering framework (Netfilter)`，开启`IP set support`（选 m）。

3. 路由 / QoS / WireGuard

   进入`Networking support → Networking options`，

   -  开启 `TCP/IP networking` （选 y），开启下面的`IP: advanced router`（选 y），再开启下面出现的 `IP: policy routing`（选 y）。也可直接把 `TCP/IP networking` 的所有子项都选 y。
   - 开启`The IPv6 protocol`（选 m）并进入，开启`IPv6: Multiple Routing Tables`（选 y）。
   - 开启`QoS and/or fair queueing`（选 y）并进入，开启`Hierarchical Token Bucket (HTB)`、`Fair Queue Controlled Delay AQM (FQ_CODEL)`、`Common Applications Kept Enhanced (CAKE)`（都 m）。

   进入`Device Drivers → Network device support`，开启 `WireGuard secure network tunnel`（选 m）。

4. zram

   进入`Device Drivers → Block devices`，开启`Compressed RAM block device support`（选 m），开启下面出现的`zstd compression support`（选 y），进入下面的`Default zram compressor (???)`，选择 `zstd`。

5. 文件系统与文件格式

   - 进入`File systems → DOS/FAT/EXFAT/NT Filesystems` ，开启`MSDOS fs support`、`exFAT filesystem support`（都 m）。
   - 进入`File systems`，开启` F2FS filesystem support`（选 m）。
   - 进入`File systems → Miscellaneous filesystems`，开启`SquashFS 4.0 - Squashed file system support`（选 m）。
   - 进入`Executable file formats`，开启 `Kernel support for MISC binaries`（选 m）。

6. 外接 USB 网卡 / 4G Modem（可选，按需）

   进入`Device Drivers → Network device support → Wireless LAN`，

   - 开启`MediaTek devices`（选 y），开启下面的`MediaTek MT7601U (USB) support`（选 m）。
   - 开启`Realtek devices`（选 y），按需开启下面的网卡驱动（选 m）。

   进入`Device Drivers → Network device support → USB Network Adapters`，

   - 开启`Multi-purpose USB Networking Framework`（选 m），开启下面的 `CDC Ethernet support`、`CDC NCM support`（都 m）。
   - 开启`QMI WWAN driver for Qualcomm MSM based 3G and LTE modems`（选 m）。

   进入`Device Drivers → USB support`，

   - 开启`USB Wireless Device Management support`（选 m）。
   - 开启`USB Serial Converter support`（选 m）并进入，开启 `USB Qualcomm Serial modem`、`USB driver for GSM and CDMA modems`（都 m）。

   进入`Device Drivers → Network device support` ，开启`PPP (point-to-point protocol) support`（选 m），再开启其下的`PPP BSD-Compress compression`、`PPP Deflate compression`、`PPP MPPE compression (encryption)`、`PPP over Ethernet`、`PPP support for async serial ports`、`PPP support for sync tty ports`（都 m）。

以下模块可以关闭：

1. KVM虚拟化

   进入`Virtualization`，关闭`Kernel-based Virtual Machine (KVM) support`。

2. DRM_MSM

   进入`Device Drivers → Graphics support → Direct Rendering Manager` ，关闭`MSM DRM`。

3. 摄像头

   进入`Device Drivers → Multimedia support → Media drivers  → Media platform devices`，关闭`Qualcomm V4L2 Camera Subsystem driver`。如果完全没有视频需求，可直接关掉`Device Drivers → Multimedia support`。

4. 声卡

   进入`Device Drivers → Sound card support → Advanced Linux Sound Architecture→ ALSA for SoC audio support`，关闭`ASoC support for QCOM platforms` 。如果完全没有音频播放需求，可直接关掉`Device Drivers → Sound card support`。

5. NFC

   进入`Networking support`，关闭`NFC subsystem support`。


### 安装内核

登录进入rootfs，使用`dpkg -i`命令安装生成的包即可。如果没有生成`/boot/initrd.img-*`这个镜像文件，可能是没有安装`initramfs-tools`。可以先安装`initramfs-tools`再用`dpkg -i`安装一次，也可以安装`initramfs-tools`后直接用命令生成：

```Shell
update-initramfs -c -k <版本号>
```

## 生成boot.img

这部分直接看[openstick](https://www.kancloud.cn/handsomehacker/openstick/2637565)的官方教程即可。

取前面文件系统安装新内核后`/boot/initrd.img*`文件与内核编译阶段生成的`Image.gz`和`arch/arm64/boot/dts/qcom/`下对应设备的`*.dtb`，首先将devicetree(dtb)附在Image.gz之后：

```Shell
 cat Image.gz dtb > kernel-dtb
```

然后生成boot.img：

```Shell
mkbootimg --base 0x80000000 \
    --kernel_offset 0x00080000 \
    --ramdisk_offset 0x02000000 \
    --tags_offset 0x01e00000 \
    --pagesize 2048 \
    --second_offset 0x00f00000 \
    --ramdisk initrd.img \
    --cmdline "earlycon root=PARTUUID=a7ab80e8-e9d1-e8cd-f157-93f69b1d141e console=ttyMSM0,115200 no_framebuffer=true rw"\
    --kernel kernel-dtb -o boot.img
```
