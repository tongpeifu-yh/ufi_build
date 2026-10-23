## 设备树

### 提取设备树

从原始安卓系统的boot.img或者recover.img中均可提取出设备树，具体操作如下。

首先安装必要的工具，binwalk 与 Device Tree Compiler：

```Shell
sudo apt-get install binwalk
sudo apt-get install device-tree-compiler
```

然后，使用 binwalk 分析boot.img：

```Shell
binwalk boot.img
```

将会输出该img文件中每一段数据是什么。然后，可以通过dd命令提取出dtb格式的设备树，例如

```Shell
dd if=recovery.img bs=1 skip=6955008 count=162799 of=device_tree.dtb
```

最后，将 .dtb 转换为 DTS：

```Shell
dtc -I dtb -O dts -o output.dts device_tree.dtb
```

### 查询设备树

boot.img中可能存在多个设备树。这些设备树中可能只有一个属于当前的棒子，我们需要首先把它们都提取出来并反编译得到DTS文件，然后在安卓系统中查询运行时加载的设备树是哪一个，选择真正的设备树并加入linux源码中。

查询设备树同样需要root权限。获取root权限后，在adb shell中通过下面的指令查询：

```Shell
cat /proc/device-tree/model
cat /proc/device-tree/compatible
```

例如，我的一个ufi003c棒子上的输出为

```Shell
Qualcomm Technologies, Inc. MSM 8916 512MB MTP
qcom,msm8916-mtpqcom,msm8916qcom,mtpshell
```

那么我就可以通过如下命令找到是哪个dtb：

```Shell
binwalk boot.img > boot.txt
mkdir dtb dts
cat boot.txt | grep "Flattened device tree" | awk 'BEGIN{c=0} {printf "dd if=boot.img bs=1 skip=%d count=%d of=dtb/%d.dtb\n",$1,$7,c; c++}' > ex.sh
bash ex.sh
for n in `seq 0 32` ; do dtc -I dtb -O dts -o dts/$n.dts dtb/$n.dtb; done
cd dts
grep "Qualcomm Technologies, Inc. MSM 8916 512MB MTP" -r .
```

> 实测发现ufi003与ufi001c的设备树完全一致，ufi103s与ufi001c也只有一处区别在4G LED灯的默认状态。因此这三个型号可以看作一样的，设备树可以通用。但是不确定固件是否也一样。

### 编译设备树

理论上设备树的编译与内核编译是完全分离、互不干扰的，因此在修改棒子的配置时如果只修改了设备树，就不需要重新编译安装整个内核，只需要编译设备树，然后利用新设备树`.dtb`文件和已有的内核镜像`Image.gz`、`/boot/initrd.img*`重新生成`boot.img`，重新刷写boot分区即可。

```bash
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- dtbs
```

如果内核版本足够接近，我们甚至可以直接用上面提取的`.dtb`文件来制作新的`boot.img`。但是显然棒子原厂搭载的安卓4.4.4内核版本非常低，不能直接使用。
