#!/bin/bash

# 配置文件路径
CONFIG_FILE="./config.ini"

# 安装目录
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="traffic_control.sh"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"
TRFC_CMD="trfc"  # 新的命令名称
TRFC_PATH="$INSTALL_DIR/$TRFC_CMD"

# 读取配置文件的值
function read_config() {
    if [ -f "$CONFIG_FILE" ]; then
        default_limit=$(grep '^default_limit' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
        default_block_traffic=$(grep '^default_block_traffic' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
        default_time=$(grep '^default_time' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
        default_services=$(grep '^default_services' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
    else
        echo "配置文件 $CONFIG_FILE 不存在，使用默认设置！"
        default_limit="100G"
        default_block_traffic="none"
        default_time="per 1h"
        default_services="sing-box, nginx"
    fi
}

# 在安装脚本开始时读取配置
read_config

# 检查同级目录下是否已有 traffic_control.sh
if [ -f "./traffic_control.sh" ]; then
    echo "当前目录已存在 traffic_control.sh，跳过下载步骤。"
    SCRIPT_PATH="./traffic_control.sh"
else
    echo "当前目录未找到 traffic_control.sh，正在下载..."
    # 下载 traffic_control.sh 脚本
    curl -o "$SCRIPT_PATH" https://example.com/path/to/traffic_control.sh

    # 检查是否下载成功
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "下载失败，请检查 URL 或网络连接！"
        exit 1
    fi
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
