## 性能释放

网上常见的性能释放手段，包括释放modem内存、超频等。

### 去除modem释放内存

去除基带（Modem）并释放内存，总共可以回收 **86 MiB** 的基带专属内存，其中`mba_mem`约1MiB，`mpss_mem`约85MiB。dts的语法支持重复定义时合并+覆盖，只需要修改对应设备的dts文件，结尾增加如下代码：

```dts
/* 禁用 Modem 子系统与 BAM DMUX 通道 */
&bam_dmux {
	status = "disabled";
};

&bam_dmux_dma {
	status = "disabled";
};

&mba_mem {
	status = "disabled";
};

&mpss {
	status = "disabled";
};

&mpss_mem {
	status = "disabled";
};
```

然后手动禁用下列服务（不禁用也影响不大）：

```bash
sudo systemctl disable  rmtfs.service ModemManager.service
```

系统启动后，可通过`free`命令查看内存大小：

```bash
free -h
```

### 增加频率档位

msm8916内核中有两个时钟源：辅助固定时钟源`GPLL0_VOTE`和高频专用锁相环 `a53pll`。它们提供原始的时钟频率 $f_{PARENT}$，经过一个半整数分频器分频，得到可用的CPU时钟 $f_{CPU}$。半整数分频器的分频系数 $\text{div}$ 通过硬件寄存器 $\text{hid\_div}$ 的值计算，公式为

$$
\text{div} = \frac{\text{hid\_div} + 1}{2}
$$

于是，CPU时钟频率的计算公式为
$$
f_{CPU} = \frac{f_{PARENT}}{\text{div}} = \frac{2 \times f_{PARENT}}{\text{hid\_div} + 1}
$$
硬件寄存器 $\text{hid\_div}$ 宽度是5bit，理论取值范围$0 \sim 31$，但是实际代码中写的范围是$0 \sim 29$。要注意的是，硬件寄存器 $\text{hid\_div}$ 设为0效果与设为1一样，都是1倍频，原因是数字分频器在物理上只能通过计数或双沿触发来**降低或保持**时钟频率，不可能像锁相环（PLL）那样倍频。在高通 RCG2（Root Clock Generator 2）半整数分频器硬件设计中，寄存器值 `0`（`5'b00000`）被硬件定义为 **Bypass（旁路直通模式，即 $\div 1$）**，而 `1`（`5'b00001`）代入公式 $\frac{1+1}{2} = 1$ 也是 **$\div 1$**。也就是说，只有当 $\text{hid\_div} \ge 1$ 时，公式 $\text{div} = \frac{\text{hid\_div} + 1}{2}$ 才在数学上严格成立。因此实际分频系数范围为 **$1 \sim 15$ 分频（步进 $0.5$）**。

> 虽然硬件上PLL无法倍频，但是内核中部分代码似乎没有注意到这一点，把寄存器为0当成了频率翻倍来处理。这可能造成假倍频，即软件认为自己运行在2倍频，但硬件仍然在1倍频。

时钟源`gpll0_vote`固定提供800MHz的父时钟，而`a53pll`能够提供的父时钟频率 $f_{a53pll}$ 在`drivers/clk/qcom/a53-pll.c`中定义，如下

```c
static const struct pll_freq_tbl a53pll_freq[] = {
	{  998400000, 52, 0x0, 0x1, 0 },
	{ 1094400000, 57, 0x0, 0x1, 0 },
	{ 1152000000, 62, 0x0, 0x1, 0 },
	{ 1209600000, 63, 0x0, 0x1, 0 },
	{ 1248000000, 65, 0x0, 0x1, 0 },
	{ 1363200000, 71, 0x0, 0x1, 0 },
	{ 1401600000, 73, 0x0, 0x1, 0 },
	{ }
};
```

`a53pll`的PLL硬件频率合成公式为：
$$
f_{a53pll} = \text{19.2MHz} \times (L + \frac{M}{N})
$$
其中，$\text{19.2MHz}$ 是板载晶振的本振频率，$L$、$M$、$N$都是硬件寄存器参数。

表`a53pll_freq`中第一列就是 $f_{a53pll}$ ，第二列、三列、四列分别是$L$、$M$、$N$。注意，源代码中`1152000000`一行的62可能是写错了，应当是60。部分教程把第二列参数当作了电压，实际上是不对的，msm8916内核没有提供电压控制功能，第二列是整数倍频系数 $L$ 。硬件时钟频率完全由$L$、$M$、$N$三个参数计算得到，表中第一列只是参考，如果二者不一致，实际运行以硬件为准。

骁龙 410 (MSM8916) 官方标称最高频为1209.6MHz，骁龙 412 (MSM8916v2) 官方标称最高频为1401.6MHz。目前 `msm8916-mainline/linux` 主线默认尚未启用 CPR 动态调压，CPU 保持在 Bootloader（`aboot`/`lk2nd`）初始化的固定电压（通常处于高档位电压，足以支撑 1.2 GHz ~ 1.4 GHz）。如果需要超频，不建议超过1.4GHz。

.c代码中定义的是可用频率，设备树中定义的才是设备运行请求的频率。因此要更改运行时的主频，还需要更改设备树文件。dts的语法支持重复定义时合并+覆盖，因此只需要在对应设备的dts文件结尾追加如下形式的代码即可：

```dts
/* 追加到 dts 末尾 */
&cpu_opp_table {
	opp-1094400000 {
		opp-hz = /bits/ 64 <1094400000>;
	};

	opp-1209600000 {
		opp-hz = /bits/ 64 <1209600000>;
	};

	opp-1248000000 {
		opp-hz = /bits/ 64 <1248000000>;
	};

	opp-1363200000 {
		opp-hz = /bits/ 64 <1363200000>;
	};

	opp-1401600000 {
		opp-hz = /bits/ 64 <1401600000>;
	};
};
```

运行时程序会根据实际请求的频率选择合适的时钟源和 $\text{hid\_div}$ 。要注意的是，如果设备树请求的频率在c代码没有找到完全一致的，那么程序会倾向于选择第一个大于该频率的可用频率。如果需要低频档位（$\le 800\text{ MHz}$），不建议用 `a53pll` 设置的高频率（比如1.4GHz）分频到低频，而建议用 `GPLL0` 分频，因为PLL锁相环维持在高速振荡会造成较大的功耗浪费，而且在`a53pll`的频率间切换会需要先跳回`GPLL0` 的 400 MHz 等待 PLL 重新锁相，调频延迟较大。

最合理的档位设计原则：

- **$\le 800\text{ MHz}$ 区间**：用 **`800000000` (`GPLL0`) 的 $1 \sim 15$ 倍半整数分频**（如 `100000000` [$\div 8$]、`200000000` [$\div 4$]、`400000000` [$\div 2$]、`533333333` [$\div 1.5$]、`800000000` [$\div 1$]）。
- **$> 800\text{ MHz}$ 区间**：要么用 `a53pll` 档位的 **$\div 1.5$ 分频**（如 `934400000` = $1401.6\text{ MHz} \div 1.5$），要么直接用 **`a53pll` 的 $\div 1$ 直通频率**（必须在 `a53-pll.c` 的 `a53pll_freq[]` 中声明，切勿超过 `a53pll_freq[]` 的最大值）。

系统启动后，可通过lscpu命令查看当前CPU的最高和最低频率，以及`/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq`文件中查看当前CPU的实时频率：

```bash
lscpu | grep "MHz"
watch -n 1 'cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq'
```

