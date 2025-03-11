#!/bin/sh

# vars
file=""
run=""
dir="$(dirname "$(realpath "$0")")"
dry_run=false

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"  # No Color

# func
get_lang() {
    local lang="${LANG:0:2}"
    local available=("pt")
    if [[ " ${available[*]} " == *"$lang"* ]]; then
        ulang="$lang"
    else
        ulang="en"
    fi
    if [ "$ulang" = "pt" ]; then
        source ./langs/pt
    else
        source ./langs/en
    fi
}

deps () {
    echo -e "${BLUE}Installing dependencies...${NC}"
    if [ "$dry_run" = false ]; then
        sudo zypper addrepo https://download.opensuse.org/repositories/home:frispete:Tumbleweed/openSUSE_Tumbleweed/home:frispete:Tumbleweed.repo
        sudo zypper refresh
        sudo zypper in --non-interactive libxcb-dri2-0 libxcb-dri2-0-32bit libgthread-2_0-0 libgthread-2_0-0-32bit libapr1 libapr-util1
    fi
}

install () {
    echo -e "${BLUE}Installing DaVinci Resolve...${NC}"
    if [ "$dry_run" = false ]; then
        unzip "$file"
        ./$run
        if [ $? -eq 0 ]; then
            cd /opt/resolve/libs
            sudo mkdir -p disabled
            sudo mv libglib* disabled
            sudo mv libgio* disabled
            sudo mv libgmodule* disabled
        else
            echo -e "${RED}$cancelled${NC}"
            sleep 5
            exit 2
        fi
    fi
}

version () {
    echo "$versionpick"
    read -p "Enter version number (e.g., 19.1.3) or leave blank for latest: " version_number
    if [ -z "$version_number" ]; then
        version_number="19.1.3"  # Default to the latest known version if not provided
    fi

    echo "1) Free"
    echo "2) Studio"
    read -p "1/2: " choice
    case "$choice" in
        1)
            file="DaVinci_Resolve_${version_number}_Linux.zip"
            run="DaVinci_Resolve_${version_number}_Linux.run";;
        2)
            file="DaVinci_Resolve_Studio_${version_number}_Linux.zip"
            run="DaVinci_Resolve_Studio_${version_number}_Linux.run";;
        *)
            echo -e "${RED}$cancelled${NC}"
            sleep 5
            exit 2;;
    esac
}

# runtime
if [ "$1" = "--dry-run" ]; then
    dry_run=true
    echo -e "${YELLOW}Dry run mode enabled. No changes will be made.${NC}"
fi

get_lang
if command -v "zypper" &> /dev/null; then
    echo -e "${GREEN}$start${NC}"
else
    echo -e "${RED}$incompat${NC}"
    sleep 5
    exit 1
fi

version

if [[ -f "$dir/$file" ]]; then
    deps
    install
else
    echo -e "${YELLOW}$missing${NC}"
    read -p "Would you like to download the file now? (y/n): " download_choice
    if [ "$download_choice" = "y" ]; then
        echo -e "${BLUE}Attempting to download...${NC}"
        # Example download command (user needs to provide correct URL)
        if [ "$dry_run" = false ]; then
            wget "https://example.com/$file" -O "$dir/$file"
        fi
    else
        echo -e "${RED}Download cancelled.${NC}"
        exit 3
    fi
fi

echo -e "${GREEN}$success${NC}"
sleep 5
exit 0
