# systerm-traffic-control
帮助ubuntu系统的流量控制
概述

本工具包含两个主要脚本：install.sh 和 traffic_control.sh，用于实现系统流量限制、服务管理以及定时任务调度。通过这两个脚本，您可以方便地管理系统流量、控制服务的开启和关闭，并设置定时任务来自动执行流量控制任务。

功能概述：

流量限制：控制入站和出站流量，可以通过指定大小限制流量（如 100GB, 500MB, 1TB 等）。

服务管理：可以通过 -s 参数指定要控制的服务，支持多个服务的同时管理。

流量控制：通过 -cl 参数阻止入站、出站或所有流量。

定时任务管理：通过 -time 配置单次执行或周期性执行的定时任务，支持按时长（如 1h, 1d, 1M）或时间点（如 2025-10-15 11:16:37）执行。

安装与配置
1. 下载并安装 traffic_control.sh 脚本

在使用该工具之前，您需要安装 traffic_control.sh 脚本。您可以使用以下命令下载并安装：

# 下载 traffic_control.sh 脚本
wget https://example.com/path/to/traffic_control.sh

# 赋予脚本执行权限
chmod +x traffic_control.sh

# 将脚本移到 /usr/local/bin 目录中
sudo mv traffic_control.sh /usr/local/bin/

# 创建软链接，方便使用 trfc 命令
sudo ln -s /usr/local/bin/traffic_control.sh /usr/local/bin/trfc

2. 安装过程

install.sh 脚本会帮助您自动安装和配置 traffic_control.sh。它会下载 traffic_control.sh 脚本，并为您配置周期性或单次执行的定时任务。

# 运行安装脚本
wget https://example.com/path/to/install.sh

# 赋予执行权限
chmod +x install.sh

# 执行安装脚本
sudo ./install.sh


此安装脚本会：

下载并安装 traffic_control.sh 脚本。

创建 trfc 命令的软链接，使您可以直接使用 trfc 控制流量和服务。

配置一些默认的定时任务，例如每小时执行一次流量控制。

使用方法
1. 设置流量限制

使用 -t 参数可以设置流量限制。您可以使用不同的单位（如 K, M, G, T）来定义限制大小。

# 设置流量限制为 100GB
trfc -t 100G

# 设置流量限制为 500MB
trfc -t 500M

# 设置流量限制为 2TB
trfc -t 2T


流量单位支持以下几种：

K：千字节（KB）

M：兆字节（MB）

G：吉字节（GB）

T：太字节（TB）

2. 控制服务

使用 -s 参数来指定要控制的服务。可以同时控制多个服务。

# 控制 sing-box 和 nginx 服务
trfc -s sing-box -s nginx

3. 流量控制选项

使用 -cl 参数来控制流量的方向。您可以选择阻止入站流量、出站流量或全部流量。

# 阻止所有入站流量
trfc -cl in

# 阻止所有出站流量
trfc -cl out

# 阻止所有流量（进出站）
trfc -cl all

4. 设置定时任务

使用 -time 参数来设置定时任务。您可以设置单次任务或周期性任务。

4.1 单次定时任务

您可以指定一个具体的时间点来执行任务。时间格式可以是 YY-MM-DD HH:MM:SS 或只指定日期（如 YY-MM-DD）。

# 在 2025-10-15 11:16:37 执行任务
trfc -time "2025-10-15 11:16:37"

# 在 2025-10-18 0:00:00 执行任务
trfc -time "2025-10-18"

4.2 周期性定时任务

使用 -time per 来设置周期性任务，支持按时长（如 1h, 1d, 1M）或时间点（如 YY-01-01）。

# 每小时执行一次
trfc -time per 1h

# 每天执行一次
trfc -time per 1d

# 每月执行一次（按 30 天计算）
trfc -time per 1M

# 每年执行一次（按 365 天计算）
trfc -time per 1Y

4.3 组合时间

您可以将多个时间单位组合在一起，形成复合的定时任务。例如：

# 每年 1 天执行一次任务
trfc -time per 1Y1D

# 每月 1 天执行一次任务
trfc -time per 1M1D

# 每年 1 分钟执行一次任务
trfc -time per 1Y1m

4.4 设置周期性时间点

您还可以设置每年、每月、每天的特定时间点执行任务。例如：

# 每年 1 月 1 日执行
trfc -time per 01-01

# 每年 1 月 3 日 12:00:01 执行
trfc -time per 01-03 12:00:01

# 每个小时的 18:03 执行
trfc -time per HH:18:03

# 每分钟的 03 秒执行
trfc -time per HH:MM:03

常见问题
1. 如何查看当前定时任务？

您可以使用以下命令查看当前系统中的定时任务（cron 表）：

crontab -l

2. 如何删除定时任务？

要删除某个定时任务，您可以手动编辑 cron 表：

crontab -e


在编辑界面中删除您不需要的定时任务，然后保存退出。

3. 如何调整流量限制？

通过运行 trfc -t 命令，您可以随时调整流量限制。例如：

# 将流量限制修改为 200GB
trfc -t 200G

4. 如何添加更多的服务控制？

您可以通过多个 -s 参数来控制多个服务。例如：

# 控制 sing-box 和 nginx 服务
trfc -s sing-box -s nginx

贡献

如果您遇到问题，或者有改进建议，欢迎提交 Issue
 或直接修改 源码
。

许可证

该项目采用 MIT License
 进行许可。
