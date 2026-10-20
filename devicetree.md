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

可能的输出为

```Shell
Qualcomm Technologies, Inc. MSM 8916 512MB MTP
qcom,msm8916-mtpqcom,msm8916qcom,mtpshell
```

那么我就可以通过如下命令找到是哪个dtb：

```Shell
mkdir dtb dts
binwalk boot.img > boot.txt
cat boot.txt | grep "Flattened device tree" | awk 'BEGIN{c=0} {printf "dd if=boot.img bs=1 skip=%d count=%d of=dtb/%d.dtb\n",$1,$7,c; c++}' > ex.sh
bash ex.sh
for n in `seq 0 32` ; do dtc -I dtb -O dts -o dts/$n.dts dtb/$n.dtb; done
cd dts
grep "Qualcomm Technologies, Inc. MSM 8916 512MB MTP" -r .
```
