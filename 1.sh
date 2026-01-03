#!/usr/bin/env bash
set -euo pipefail

# Variables
#----------------------------

# time variable
start=$(date +%s)

# Color variables
PINK="\e[35m"
WHITE="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"

# 国内镜像源配置
# 主要使用 GitHub 镜像
GITHUB_MIRROR="https://ghproxy.com/https://github.com"
RAW_MIRROR="https://ghproxy.com/https://raw.githubusercontent.com"
# 备用镜像
GITHUB_MIRROR_ALT="https://github.com.cnpmjs.org"
RAW_MIRROR_ALT="https://raw.fastgit.org"

# 阿里云镜像 (用于部分资源)
ALIYUN_MIRROR="https://mirrors.aliyun.com"

clear

# Welcome message
echo -e "${PINK}\e[1m
 WELCOME!${PINK} Now we will install and setup Hyprland on an Arch-based system
                       Created by \e[1;4mPhunt_Vieg_
${WHITE}"
