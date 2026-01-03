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
RED="\e[31m"

clear

# Welcome message
echo -e "${PINK}\e[1m
 欢迎使用!${PINK} 现在将在基于 Arch 的系统上安装和设置 Hyprland
                       由 \e[1;4mPhunt_Vieg_ 创建
${WHITE}"

# Warning message
echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4m警告\e[0m${PINK}:                              *
 *               此脚本将修改您的系统配置!                *
 *         它将安装 Hyprland 和多个依赖包。        *
 *      请在继续之前确认您知道自己在做什么。     *
 *********************************************************************
\n
"

# Asking if the user want to proceed
echo -e "${YELLOW} 您确定要继续使用此脚本安装 Hyprland 吗？ [y/N]: \n"
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[确定]${PINK} ==> 继续安装..."
        ;;
    *)
        echo -e "${BLUE}[提示]${PINK} ==> 您 🫵 选择了 ${YELLOW}不继续${PINK}.. 正在退出..."
        echo
        exit 1
        ;;
esac

# 添加网络检测函数
check_network() {
    echo -e "${PINK}正在检测网络连接...${WHITE}"
    if ping -c 2 -W 3 mirrors.tuna.tsinghua.edu.cn > /dev/null 2>&1; then
        echo -e "${GREEN}[网络连接正常]${WHITE}"
        return 0
    else
        echo -e "${RED}[网络连接失败]${WHITE}"
        return 1
    fi
}

# Start of the install procedure
cd ~

# Full system update
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[1/11]${PINK} ==> 正在更新系统软件包\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -Syu --noconfirm

# 尝试多个镜像源下载远程脚本
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/11]${PINK} ==> 设置终端\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5

# 定义多个镜像源（按优先级排列）
MIRRORS=(
    "https://ghproxy.com/https://raw.githubusercontent.com/ViegPhunt/auto-setup-LT/main/arch.sh"
    "https://raw.fastgit.org/ViegPhunt/auto-setup-LT/main/arch.sh"
    "https://raw.githubusercontents.com/ViegPhunt/auto-setup-LT/main/arch.sh"
    "https://cdn.jsdelivr.net/gh/ViegPhunt/auto-setup-LT@main/arch.sh"
    "https://raw.githubusercontent.com/ViegPhunt/auto-setup-LT/main/arch.sh"  # 原始源（最后尝试）
)

# 检查网络连接
if ! check_network; then
    echo -e "${RED}[错误]${PINK} ==> 网络连接失败，无法继续安装。${WHITE}"
    echo -e "${YELLOW}请检查："
    echo "1. 网络连接是否正常"
    echo "2. 是否配置了代理（如有需要）"
    echo "3. 尝试手动配置pacman镜像源后再运行此脚本${WHITE}"
    exit 1
fi

# 尝试不同的镜像源
success=false
for mirror in "${MIRRORS[@]}"; do
    echo -e "${BLUE}[尝试]${PINK} ==> 使用镜像源: $(basename $(dirname $(dirname "$mirror")))${WHITE}"
    
    # 添加超时和重试机制
    if timeout 30 curl -fSL --retry 2 --retry-delay 3 --connect-timeout 10 "$mirror" > /tmp/arch_setup.sh 2>/dev/null; then
        echo -e "${GREEN}[成功]${PINK} ==> 脚本下载完成${WHITE}"
        
        # 检查下载的文件是否有效
        if [[ -s /tmp/arch_setup.sh ]] && head -n 1 /tmp/arch_setup.sh | grep -q "bash\|sh"; then
            echo -e "${GREEN}[执行]${PINK} ==> 开始执行安装脚本${WHITE}"
            chmod +x /tmp/arch_setup.sh
            bash /tmp/arch_setup.sh
            success=true
            break
        else
            echo -e "${YELLOW}[警告]${PINK} ==> 下载的文件无效，尝试下一个镜像源${WHITE}"
            continue
        fi
    else
        echo -e "${YELLOW}[失败]${PINK} ==> 当前镜像源不可用${WHITE}"
    fi
done

if [[ "$success" == false ]]; then
    echo -e "${RED}[错误]${PINK} ==> 所有镜像源都失败，无法下载安装脚本${WHITE}"
    echo -e "${YELLOW}备用方案："
    echo "1. 手动下载安装脚本:"
    echo "   curl -fSL https://ghproxy.com/https://raw.githubusercontent.com/ViegPhunt/auto-setup-LT/main/arch.sh -o arch.sh"
    echo "   chmod +x arch.sh && ./arch.sh"
    echo "2. 或稍后再试"
    echo "3. 检查您的网络设置和代理配置${WHITE}"
    
    read -p "是否继续其他安装步骤？(部分功能可能不可用) [y/N]: " -r continue_without
    if [[ ! "$continue_without" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Making all the scripts executable
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/11]${PINK} ==> 设置脚本可执行权限\n---------------------------------------------------------------------\n${WHITE}"
if [[ -d ~/dotfiles/.config/viegphunt ]]; then
    sudo chmod +x ~/dotfiles/.config/viegphunt/*
else
    echo -e "${YELLOW}[跳过]${PINK} ==> dotfiles目录不存在，跳过此步骤${WHITE}"
fi

# Download & move the wallpapers to the right directory
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/11]${PINK} ==> 下载壁纸\n---------------------------------------------------------------------\n${WHITE}"
if timeout 60 git clone --depth 1 https://ghproxy.com/https://github.com/ViegPhunt/Wallpaper-Collection.git ~/Wallpaper-Collection 2>/dev/null; then
    mkdir -p ~/Pictures/Wallpapers
    mv ~/Wallpaper-Collection/Wallpapers/* ~/Pictures/Wallpapers 2>/dev/null || true
    rm -rf ~/Wallpaper-Collection
else
    echo -e "${YELLOW}[跳过]${PINK} ==> 壁纸下载失败，跳过此步骤${WHITE}"
    echo -e "${BLUE}[提示]${PINK} ==> 您可以稍后手动下载壁纸${WHITE}"
fi

# Install the required packages
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/11]${PINK} ==> 安装软件包\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
if [[ -f ~/dotfiles/.config/viegphunt/install_archpkg.sh ]]; then
    ~/dotfiles/.config/viegphunt/install_archpkg.sh
else
    echo -e "${YELLOW}[跳过]${PINK} ==> 安装脚本不存在，跳过此步骤${WHITE}"
    echo -e "${BLUE}[提示]${PINK} ==> 请确保已成功下载dotfiles${WHITE}"
fi

# Enable bluetooth & networkmanager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/11]${PINK} ==> 启用蓝牙和网络管理器\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5
sudo systemctl enable --now bluetooth 2>/dev/null || echo -e "${YELLOW}[警告]${PINK} ==> 蓝牙服务启用失败${WHITE}"
sudo systemctl enable --now NetworkManager 2>/dev/null || echo -e "${YELLOW}[警告]${PINK} ==> NetworkManager启用失败${WHITE}"

# Set Ghostty as default terminal emulator for Nemo
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/11]${PINK} ==> 为 Nemo 设置 Ghostty 为默认终端\n---------------------------------------------------------------------\n${WHITE}"
if command -v gsettings > /dev/null 2>&1; then
    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty 2>/dev/null || echo -e "${YELLOW}[跳过]${PINK} ==> 未找到gsettings或Nemo${WHITE}"
else
    echo -e "${YELLOW}[跳过]${PINK} ==> 未安装gsettings${WHITE}"
fi

# Apply fonts
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/11]${PINK} ==> 应用字体\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv 2>/dev/null || echo -e "${YELLOW}[警告]${PINK} ==> 字体缓存更新失败${WHITE}"

# Set cursor
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[9/11]${PINK} ==> 设置鼠标指针\n---------------------------------------------------------------------\n${WHITE}"
if [[ -f ~/dotfiles/.config/viegphunt/setcursor.sh ]]; then
    ~/dotfiles/.config/viegphunt/setcursor.sh
else
    echo -e "${YELLOW}[跳过]${PINK} ==> setcursor.sh不存在${WHITE}"
fi

# Stow
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[10/11]${PINK} ==> 部署配置文件\n---------------------------------------------------------------------\n${WHITE}"
if [[ -d ~/dotfiles ]] && command -v stow > /dev/null 2>&1; then
    cd ~/dotfiles
    stow -t ~ . 2>/dev/null || echo -e "${YELLOW}[警告]${PINK} ==> stow执行失败${WHITE}"
    cd ~
else
    echo -e "${YELLOW}[跳过]${PINK} ==> dotfiles目录不存在或未安装stow${WHITE}"
fi

# Check display manager
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[11/11]${PINK} ==> 检查显示管理器\n---------------------------------------------------------------------\n${WHITE}"
if [[ ! -e /etc/systemd/system/display-manager.service ]]; then
    if command -v sddm > /dev/null 2>&1; then
        sudo systemctl enable sddm 2>/dev/null
        echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee -a /etc/sddm.conf > /dev/null 2>&1
        sudo sed -i 's|astronaut.conf|purple_leaves.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop 2>/dev/null || true
        echo -e "\n${PINK}SDDM 已启用。"
    else
        echo -e "${YELLOW}[跳过]${PINK} ==> 未安装SDDM${WHITE}"
    fi
fi

# Wait a little just for the last message
sleep 0.7
clear

# Calculate how long the script took
end=$(date +%s)
duration=$((end - start))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

printf -v minutes "%02d" "$minutes"
printf -v seconds "%02d" "$seconds"

echo -e "\n
 *********************************************************************
 *                    Hyprland 设置完成！                    *
 *                                                                   *
 *             耗时 : $hours 小时, $minutes 分钟, $seconds 秒            *
 *                                                                   *
 *   建议 \e[1;4m重启\e[0m 系统以应用所有更改。   *
 *                                                                   *
 *                  \e[4m祝您使用 Hyprland 愉快！${WHITE}                 *
 *********************************************************************
\n
"

# 显示安装状态总结
echo -e "${PINK}=== 安装状态总结 ===${WHITE}"
echo -e "${BLUE}[提示]${WHITE} 如果某些步骤失败，您可以："
echo "1. 手动运行失败的步骤"
echo "2. 检查网络连接后重新运行脚本"
echo "3. 访问 https://github.com/ViegPhunt/auto-setup-LT 查看文档"
