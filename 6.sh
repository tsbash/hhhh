# Making all the scripts executable
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/11]${PINK} ==> Make executable\n---------------------------------------------------------------------\n${WHITE}"
sudo chmod +x ~/dotfiles/.config/viegphunt/*

# download & mv the wallpapers in the right directory
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/11]${PINK} ==> Download wallpaper\n---------------------------------------------------------------------\n${WHITE}"

# 使用国内镜像克隆壁纸仓库
if git clone --depth 1 "${GITHUB_MIRROR}/ViegPhunt/Wallpaper-Collection.git" ~/Wallpaper-Collection; then
    echo -e "${GREEN}✓ Wallpaper collection downloaded successfully${WHITE}"
else
    echo -e "${YELLOW}⚠️ Failed to download from mirror, trying direct clone...${WHITE}"
    git clone --depth 1 "https://github.com/ViegPhunt/Wallpaper-Collection.git" ~/Wallpaper-Collection
fi

mkdir -p ~/Pictures/Wallpapers
if [ -d ~/Wallpaper-Collection/Wallpapers ]; then
    mv ~/Wallpaper-Collection/Wallpapers/* ~/Pictures/Wallpapers 2>/dev/null || true
    rm -rf ~/Wallpaper-Collection
else
    echo -e "${YELLOW}[WARNING]${WHITE} Wallpaper directory not found, skipping...\n"
fi
