## 备份原始数据

在刷机或者进一步操作前，最好先备份原始的数据，比如分区镜像、基带等。这部分参考酷安@伏莱兮浜的教程。

### 安装驱动

安装vivo的9008驱动。

### 进入9008模式

以下两种方式均可进入9008模式：

1. 使用adb命令进入：`adb reboot edl`
2. 使用硬件：按住板子的恢复键，插入电脑一两秒后再松手。

在设备管理器里看到端口有9008就表示成功。

### 使用miko备份

1. 进入9008模式，打开miko loader。
2. 点击“Read”。
3. 点击“Partition Backup/Erase”。
4. 双击选择保存目录。
5. 点击“Load Partition Structure”。
6. 全选所有分区。
7. 点击“Read Full Image”。

### 使用Qualcomm Premium Tool备份

1. 进入9008模式，打开Qualcomm Premium Tool。
2. 点击右边上方第一行的“Qualcomm”。
3. 点击右边上方第二行的“Partition”。
4. 选中右边下方的“Scan”。
5. 点击“Do Job”。
6. 选中“Backup”。
7. 选中“Backup All”。
8. 点击“Do Job”。

### Root设备

1. 安装ARDC，把APK文件直接拖进投屏界面，即可安装软件。在棒子中安装Launcher、文件管理器和Magisk。
2. 将Qualcomm Premium Tool备份的boot.img传入棒子。ARDC打开ES文件管理器，打开目标文件夹，然后把boot.img拖入投屏界面即可。
3. ARDC打开Magisk修补：点击安装，下一步，选择并修补一个文件，选择传入的boot.img，等待修补完成。
4. 导出修补后的boot.img。使用`adb pull 源路径 目标路径`。
5. adb重启进入fastboot模式：`adb reboot bootloader`。
6. 烧写修补后的boot.img：`fastboot flash boot boot.img`。注意ARDC的CMD输入框也可直接拖入文件。
7. 重启设备：`fastboot reboot`。
8. ARDC打开Magisk，下面有四个图标，表示已经获取Root权限。

### 备份QCN

需要先Root才能备份QCN。

1. 申请Root权限：`adb shell su`。
2. 关掉ardc并杀掉adb进程，打开星海svip这个软件（如果打开时提示缺少库文件，安装微软软件）。
3. 选择高通，再点联机会出现设备信息，找到高通强开1，点一键执行，在设备管理器上查看是否有端口901D（如果开启失败可以尝试手动开启，文件夹里有命令代码）
4. 选择备份qcn，一键执行，选择qcn文件生成路径，正常情况就能备份qcn成功，如果不行就检查901d端口或者重启电脑，备份的qcn一般在500多k，远小于这个大小的应该是备份失败了，可尝试再来一次。

## 恢复原始数据

当设备变砖，或者遇到其他异常情况，需要把棒子恢复到原始状态时就可以使用前面的备份。

### 使用miko恢复

1. 进入9008模式，打开miko loader。
2. 点击“Flash”。
3. 点击“emmc block0 flasher”。
4. 双击选择bin文件。
5. 点击”Flash!“。

### 使用Qualcomm Premium Tool恢复

1. 进入9008模式，打开Qualcomm Premium Tool。
2. 点击右边上方第一行的“Qualcomm”。
3. 点击右边上方第二行的“Partition”。
4. 选中右边下方的“Scan”。
5. 点击“Do Job”。
6. 选中“write”。
7. 选择要刷的分区。
8. 点击“Do Job”。
9. 选择分区文件。
