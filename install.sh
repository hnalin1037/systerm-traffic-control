#!/bin/bash

# 安装目录
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="traffic_control.sh"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"
TRFC_CMD="trfc"  # 新的命令名称
TRFC_PATH="$INSTALL_DIR/$TRFC_CMD"

# 下载 traffic_control.sh 脚本
echo "正在下载 traffic_control.sh 脚本到 $INSTALL_DIR..."
curl -o "$SCRIPT_PATH" https://example.com/path/to/traffic_control.sh

# 检查是否下载成功
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "下载失败，请检查 URL 或网络连接！"
    exit 1
fi

# 设置脚本可执行权限
echo "正在设置脚本权限..."
sudo chmod +x "$SCRIPT_PATH"

# 创建 trfc 命令的软链接
echo "正在创建软链接 $TRFC_CMD -> $SCRIPT_NAME ..."
sudo ln -s "$SCRIPT_PATH" "$TRFC_PATH"

# 解析 -time 参数来添加定时任务
if [[ "$1" == "-time" && ! -z "$2" ]]; then
    # 解析定时任务（单次或周期性）
    if [[ "$2" == "per" ]]; then
        # 周期性任务
        for time_config in "${@:3}"; do
            echo "添加周期性定时任务：$time_config"
            # 转换为 cron 表达式或其他调度方式
            (crontab -l 2>/dev/null; echo "$time_config $SCRIPT_PATH") | crontab -
        done
    else
        # 单次定时任务
        for time_config in "${@:2}"; do
            echo "添加单次定时任务：$time_config"
            # 转换为 cron 表达式或其他调度方式
            # 如果是指定日期和时间点的格式，转换为相应的 cron 表达式
            # 例如：2025-10-15 11:16:37 -> 37 16 15 10 * 2025
            cron_time=$(date -d "$time_config" "+%M %H %d %m * %Y")
            if [ $? -eq 0 ]; then
                (crontab -l 2>/dev/null; echo "$cron_time $SCRIPT_PATH") | crontab -
            else
                echo "无效的时间格式：$time_config"
            fi
        done
    fi
fi

# 完成安装
echo "安装完成！traffic_control.sh 脚本已成功安装。"
echo "同时，已创建命令 'trfc'，可以直接执行流量控制脚本。"
