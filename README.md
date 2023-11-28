# 随身wifi debian固件编译 记录
适合有linux基础的人、折腾党看！入坑不深的直接用大佬编译好的包就行了！
## 本记录阅读顺序
prepare.sh  
kernel.sh  
rootfs.sh  
boot.sh  
sh文件并非可以直接执行的脚本，只是我懒得写markdown排版  
遇到奇怪的问题，或许可以从`others.md`中找到答案  
## 参考教程有：
### 1、构建底包
[How to create Debian 10 rootfs base for iMX8/iMX6 - ESS-WIKI](http://ess-wiki.advantech.com.tw/view/IoTGateway/BSP/Linux/Debian/How_to_Create_Debian10_Rootfs_Base)  
[制作 Deiban Rootfs | 刘帅的个人站](https://www.liuwantong.com/2021/02/16/debian-rootfs/)  
[【linux】rootfs根文件系统镜像制作_rootfs打包-CSDN博客](https://blog.csdn.net/iriczhao/article/details/127078414)

### 2、编译内核&超频
[编译内核（debian） · OpenStick项目 · 看云](https://www.kancloud.cn/handsomehacker/openstick/2637565)  
[编译UFI设备的Debian固件 | 宁宁's Blog](https://momoe.link/shizuku/065919.html)  
[随身wifi的Debian系统固件编译](https://www.knightli.com/2023/08/09/%E9%9A%8F%E8%BA%ABwif-idebian-%E5%9B%BA%E4%BB%B6%E7%BC%96%E8%AF%91/) 含超频教程  
[随身wifi折腾入门（2）-- 编译&刷入系统 - yanhy's 学习记录匣](https://yanhy.top/?p=382) 含超频教程


### 综合教程： 备份、刷机等
[在高通骁龙410主控的USB网卡上玩 GNU/Linux](https://techie-s.work/posts/2022/07/openstick-msm8916/#%E7%BC%96%E8%AF%91%E4%B8%8E%E4%BF%AE%E6%94%B9%E5%86%85%E6%A0%B8)  
[高通骁龙芯片的随身wifi入门刷机教程 来自 伏莱兮浜 - 酷安](https://www.coolapk.com/feed/37834896?shareKey=MjFhNGY4NzAxNGMzNjMwY2Y5NGU~&shareUid=11771529&shareFrom=com.coolapk.market_12.4.2)