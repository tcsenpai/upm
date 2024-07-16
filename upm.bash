#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VERSION="1.0.0"
LOG_FILE="/var/log/upm.log"

# Function to log messages
log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to check and elevate privileges if necessary
elevate_privileges() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}This script requires root privileges. Attempting to run with sudo...${NC}"
        exec sudo "$0" "$@"
        log "Elevating privileges"
    fi
}

# Call the function to elevate privileges
elevate_privileges "$@"


function usage {
    echo -e "${BLUE}Usage: upm <command> <package>${NC}"
    echo -e "${BLUE}Commands: install, remove, update, search, version${NC}"
    exit 1
}

function run_command {
    local action=$1
    local pkg=$2
    
    # Validate package name
    if [[ ! "$pkg" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        echo -e "${RED}Invalid package name. Only alphanumeric characters, underscores, hyphens, and dots are allowed.${NC}"
        log "Invalid package name: $pkg"
        return 1
    fi
    
    local managers=(
        "apt:install:remove:upgrade:search"
        "brew:install:uninstall:upgrade:search"
        "pip:install:uninstall:install --upgrade:search"
        "npm:-g install:uninstall:update:search"
        "cargo:install:uninstall:update:search"
    )

    for manager_info in "${managers[@]}"; do
        IFS=':' read -r manager install remove update search <<< "$manager_info"
        if command -v $manager &> /dev/null; then
            echo -e "${BLUE}Attempting to $action $pkg using $manager...${NC}"
            log "Attempting to $action $pkg using $manager"
            case $action in
                install) cmd=$install ;;
                remove) cmd=$remove ;;
                update) cmd=$update ;;
                search) cmd=$search ;;
            esac
            if $manager $cmd $pkg; then
                echo -e "${GREEN}Successfully $action $pkg using $manager.${NC}"
                log "Successfully $action $pkg using $manager"
                return 0
            else
                echo -e "${YELLOW}Failed to $action $pkg using $manager. Trying next package manager...${NC}"
                log "Failed to $action $pkg using $manager"
            fi
        else
            echo -e "${YELLOW}$manager is not installed. Skipping...${NC}"
            log "$manager is not installed. Skipping"
        fi
    done

    echo -e "${RED}Failed to $action $pkg with any available package manager.${NC}"
    log "Failed to $action $pkg with any available package manager"
    return 1
}

if [ $# -lt 1 ]; then
    usage
fi

command=$1
package=$2

case $command in
    install|remove|update|search)
        if [ -z "$package" ]; then
            echo -e "${RED}Error: Package name is required for $command command.${NC}"
            log "Error: Package name is required for $command command"
            usage
        fi
        run_command "$command" "$package"
        ;;
    version)
        echo "upm version $VERSION"
        exit 0
        ;;
    *)
        usage
        ;;
esac

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Operation completed successfully.${NC}"
    log "Operation completed successfully"
else
    echo -e "${RED}Operation failed.${NC}"
    log "Operation failed"
    exit 1
fi