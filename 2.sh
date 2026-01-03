# Warning message
echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4mWARNING\e[0m${PINK}:                              *
 *               This script will modify your system!                *
 *         It will install Hyprland and several dependencies.        *
 *      Make sure you know what you are doing before continuing.     *
 *********************************************************************
\n
"

# 检查网络连接
echo -e "${YELLOW}Checking network connectivity to GitHub mirror...${WHITE}"
if curl -s --connect-timeout 5 "${RAW_MIRROR}" > /dev/null; then
    echo -e "${GREEN}✓ GitHub mirror is accessible${WHITE}"
else
    echo -e "${YELLOW}⚠️ Primary mirror not available, trying alternative...${WHITE}"
    RAW_MIRROR="${RAW_MIRROR_ALT}"
    GITHUB_MIRROR="${GITHUB_MIRROR_ALT}"
fi

# Asking if the user want to proceed
echo -e "${YELLOW} Do you still want to continue with Hyprland installation using this script? [y/N]: \n"
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[OK]${PINK} ==> Continuing with installation..."
        ;;
    *)
        echo -e "${BLUE}[NOTE]${PINK} ==> You 🫵 chose ${YELLOW}NOT${PINK} to proceed.. Exiting..."
        echo
        exit 1
        ;;
esac
