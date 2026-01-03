# Lunch auto-setup script and dl all the dotfiles
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/11]${PINK} ==> Setup terminal\n---------------------------------------------------------------------\n${WHITE}"
sleep 0.5

# 使用国内镜像下载自动设置脚本
echo -e "${BLUE}[INFO]${WHITE} Downloading setup script from mirror...\n"
if curl -fSL "${RAW_MIRROR}/ViegPhunt/auto-setup-LT/main/arch.sh" -o /tmp/arch_setup.sh; then
    bash /tmp/arch_setup.sh
    rm /tmp/arch_setup.sh
else
    echo -e "${YELLOW}[WARNING]${WHITE} Failed to download from mirror, trying direct download...\n"
    # 备用直接下载（可能需要代理）
    if curl -fSL "https://raw.githubusercontent.com/ViegPhunt/auto-setup-LT/main/arch.sh" -o /tmp/arch_setup.sh; then
        bash /tmp/arch_setup.sh
        rm /tmp/arch_setup.sh
    else
        echo -e "${PINK}[ERROR]${WHITE} Could not download setup script. Please check your network connection.\n"
        exit 1
    fi
fi
