#!/bin/bash

# 默认流量限制为 100GB（如果没有输入流量限制）
DEFAULT_LIMIT_GB=100

# 默认服务列表为空
SERVICES=()

# 默认流量控制选项为空
BLOCK_TRAFFIC="none"

# 输出帮助信息
function show_help {
    echo "使用说明: traffic_control.sh [options]"
    echo ""
    echo "选项："
    echo "  -t <流量限制>     设置流量限制，例如 100M, 500G, 2T (默认单位为GB)"
    echo "  -s <服务1> [-s <服务2>]    指定要控制的服务，可以指定多个服务，例如 -s sing-box -s nginx"
    echo "  -cl <in|out|all>   指定是否阻止流量：in (阻止入站流量)，out (阻止出站流量)，all (阻止所有流量)"
    echo "  -time <时间配置>   设置定时任务的执行时间，可以多个，格式如：'2025-10-15 11:16:37' 或者 '-time per 1h'"
    echo "  -h                 显示帮助信息"
    echo ""
    echo "示例："
    echo "  trfc -t 100G -s sing-box -s nginx        # 设置流量限制为 100GB，控制 sing-box 和 nginx 服务"
    echo "  trfc -t 500M -s apache2 -cl out        # 设置流量限制为 500MB，控制 apache2 服务，阻止出站流量"
    echo "  trfc -cl all                           # 阻止所有进出站流量"
    echo "  trfc -time '2025-10-15 11:16:37'       # 设置单次执行定时任务的时间"
    echo "  trfc -time per 1h                      # 每小时执行一次"
    echo "  trfc -time per 1M                      # 每30天执行一次"
    echo ""
    echo "流量单位：支持 K (KB), M (MB), G (GB), T (TB)，默认单位是 GB"
    exit 0
}

# 如果用户输入 -h 显示帮助
if [[ "$1" == "-h" ]]; then
    show_help
fi

# 解析命令行参数
while getopts "t:s:cl:time:" opt; do
    case $opt in
        t)  # -t 用于控制流量限制
            LIMIT_INPUT=$OPTARG
            ;;
        s)  # -s 用于指定需要控制的服务
            SERVICES+=($OPTARG)
            ;;
        cl|close)  # -cl 或 -close 用于指定流量控制
            BLOCK_TRAFFIC=$OPTARG
            ;;
        time)  # -time 用于定时任务配置
            TIME_CONFIG=$OPTARG
            ;;
        *)
            show_help
            ;;
    esac
done

# 如果没有指定流量限制，则使用默认值
if [ -z "$LIMIT_INPUT" ]; then
    LIMIT_GB=$DEFAULT_LIMIT_GB
    echo "未输入流量限制，使用默认限制：$LIMIT_GB GB"
else
    # 提取单位和数字
    LIMIT_VALUE=$(echo "$LIMIT_INPUT" | sed 's/[A-Za-z]*$//')  # 提取数字
    LIMIT_UNIT=$(echo "$LIMIT_INPUT" | sed 's/[0-9]*//')  # 提取单位

    # 默认单位是GB
    if [ -z "$LIMIT_UNIT" ]; then
        LIMIT_UNIT="G"
    fi

    # 处理不同单位并转换为GB
    case $LIMIT_UNIT in
        "K")
            LIMIT_GB=$(echo "$LIMIT_VALUE / 1024 / 1024" | bc -l)
            echo "输入流量限制为：$LIMIT_VALUE K = $LIMIT_GB GB"
            ;;
        "M")
            LIMIT_GB=$(echo "$LIMIT_VALUE / 1024" | bc -l)
            echo "输入流量限制为：$LIMIT_VALUE M = $LIMIT_GB GB"
            ;;
        "G")
            LIMIT_GB=$LIMIT_VALUE
            echo "输入流量限制为：$LIMIT_VALUE G"
            ;;
        "T")
            LIMIT_GB=$(echo "$LIMIT_VALUE * 1024" | bc -l)
            echo "输入流量限制为：$LIMIT_VALUE T = $LIMIT_GB GB"
            ;;
