#!/bin/bash

# 配置文件路径
CONFIG_FILE="./config.ini"

# 默认值（如果 config.ini 文件不存在）
default_limit="100G"
default_services="sing-box, nginx"
block_traffic="none"
default_time="per 1h"

# 读取配置文件的值
function read_config() {
    if [ -f "$CONFIG_FILE" ]; then
        default_limit=$(grep '^default_limit' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
        default_services=$(grep '^default_services' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
        block_traffic=$(grep '^default_block_traffic' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
        default_time=$(grep '^default_time' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
    else
        echo "配置文件 $CONFIG_FILE 不存在，使用默认设置！"
    fi
}

# 读取配置
read_config

# 输出帮助信息
function show_help {
    echo "Usage: traffic_control.sh [options]"
    echo ""
    echo "Options:"
    echo "  -t <limit>         Set traffic limit, for example: 100M, 500G, 2T (default unit is GB)"
    echo "  -s <service1> [-s <service2>]    Specify the services to control. Multiple services can be specified, for example: -s sing-box -s nginx"
    echo "  -cl <in|out|all>   Specify traffic blocking direction: in (block incoming traffic), out (block outgoing traffic), all (block all traffic)"
    echo "  -time <time_config> Set scheduled task time. Multiple configurations can be provided, such as: '2025-10-15 11:16:37' or '-time per 1h'"
    echo "  -h                 Display this help message"
    echo ""
    echo "Examples:"
    echo "  trfc -t 100G -s sing-box -s nginx        # Set traffic limit to 100GB and control sing-box and nginx services"
    echo "  trfc -t 500M -s apache2 -cl out        # Set traffic limit to 500MB, control apache2 service, block outgoing traffic"
    echo "  trfc -cl all                           # Block all incoming and outgoing traffic"
    echo "  trfc -time '2025-10-15 11:16:37'       # Set one-time scheduled task to execute at the specified time"
    echo "  trfc -time per 1h                      # Execute every hour"
    echo "  trfc -time per 1M                      # Execute every 30 days"
    echo ""
    echo "Traffic units: Support K (KB), M (MB), G (GB), T (TB), default unit is GB"
    exit 0
}

# 默认流量限制
if [ -z "$LIMIT_INPUT" ]; then
    LIMIT_GB=$default_limit
    echo "No traffic limit provided, using default limit: $LIMIT_GB"
else
    # 流量限制处理逻辑（如之前的逻辑）
fi

# 处理其他指令
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h)
            show_help
            exit 0
            ;;
        -t)
            LIMIT_INPUT="$2"
            shift 2
            ;;
        -s)
            SERVICES=($2)
            shift 2
            ;;
        -cl)
            block_traffic=$2
            shift 2
            ;;
        -time)
            time_config=$2
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# 根据配置执行流量控制、服务控制等操作
# 例如：流量限制、服务管理、流量方向控制等
