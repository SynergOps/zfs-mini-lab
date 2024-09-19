#!/bin/bash
# License: MIT
# Copyright (c) 2024 Salih Emin - SynergOps
# Origin: https://github.com/synergops/zfs-mini-lab.git

# Check if ZFS is installed
if ! command -v zfs &> /dev/null || ! command -v zpool &> /dev/null; then
    echo "Bro... Really bro? "
    sleep 1
    echo "What are you doing? "
    sleep 1
    echo "You don't even have the ZFS package installed!"
    sleep 1
    echo "Just go and install it...Exiting..."
    exit 1
fi

# Function to clean up image files and clear ZFS labels
cleanup_devices() {
    img_files=("/mnt/disk"*.img)
    if [[ -e "${img_files[0]}" ]]; then
        for file in "${img_files[@]}"; do
            # Force clear ZFS label if present, suppress error output
            sudo zpool labelclear -f "$file" 2>/dev/null || true
            sudo rm -f "$file"
            printf "Deleted %s\n" "$file"
        done

    else
        printf "No image files found to delete.\n"
    fi
}

# Function to create image files as ZFS devices
create_image_files() {
    local num_disks=$1
    local start_index=$2
    local disks=()
    for ((i=0; i<num_disks; i++)); do
        local file="/mnt/disk$((start_index + i)).img"
        sudo truncate -s 100M "$file"
        disks+=("$file")
    done
    # Return the list of image files
    echo "${disks[@]}"
}

# Function to create a ZFS pool
create_pool() {
    local pool_type=$1
    local pool_name=$2
    local disks=($3)
    local spare_disk=$4
    # Check if either ZFS pool already exists
    if sudo zpool list | grep -qE "zfsmini_MIRROR|zfsmini_RAIDZ"; then
        existing_pool=$(sudo zpool list -H -o name 2>/dev/null | grep -E "zfsmini_MIRROR|zfsmini_RAIDZ" | head -n1)
        printf "_________________________________________________________________________\n"
        printf "Error: A ZFS pool (%s) already exists.\n" "$existing_pool"
        printf "Please destroy the %s pool before creating a new one.\n" "$existing_pool"
        printf "You can use option 3 from the main menu to destroy and clean up.\n"
        printf "_________________________________________________________________________\n"
        sleep 2
        return 1
    fi

    # Create ZFS pool with the selected configuration
    echo "Creating ZFS pool with devices: ${disks[*]}, spare: $spare_disk"
    sudo zpool create "$pool_name" "$pool_type" "${disks[@]}" spare "$spare_disk"

    # Check for successful pool creation before setting properties
    if [[ $? -eq 0 ]]; then
        # Set compression on the root dataset of the pool (e.g., zfsmini_mi)
        if sudo zfs get all | grep -q 'compression=zstd'; then
            sudo zfs set compression=zstd "$pool_name"
        else
            sudo zfs set compression=lz4 "$pool_name"
        fi

        # Set other properties
        sudo zpool set autoreplace=on "$pool_name"
        sudo zfs set atime=off "$pool_name"

        echo "ZFS pool '$pool_name' created with the following settings:"
        echo "Compression: ${COMPRESSION:-lz4}, Autoreplace: on, atime: off"
        sudo zpool status "$pool_name"
    else
        echo "Error: Failed to create ZFS pool '$pool_name'"
    fi
}

# Function to destroy the pool and clean up
destroy_and_cleanup() {
    local pool_name=$1
    echo "Destroying ZFS pool '$pool_name' and cleaning up image files..."

    # Destroy the pool if it exists
    if sudo zpool list | grep -q "$pool_name"; then
        sudo zpool destroy "$pool_name"
    else
        echo "No pool named '$pool_name' found."
    fi

    # Clean up image files and ZFS labels
    cleanup_devices
    printf "Cleanup completed.\n"
    sleep 2
    echo ""
}

# Main menu function
main_menu() {
    # Update existing_pool at the start of each menu display
    existing_pool=$(sudo zpool list -H -o name 2>/dev/null | grep -E "zfsmini_mi|zfsmini_RAIDZ" | head -n1)
    printf "########################################################\n"
    printf "Welcome to the ZFS Mini Lab Playground!       v24.09.19\n"
    printf "########################################################\n"
    echo ""
    printf "Select an option:\n"
    printf "1) Create a mirror with 2 disk image files and 1 spare\n"
    printf "2) Create a RAIDZ with 3 disk image files and 1 spare\n"
    printf "3) Destroy and clean up (Current lab pool: %s)\n" "$existing_pool"
    printf "4) Exit\n"
    echo ""
    printf "________________________________________________________\n"
    printf "    Once you make your pool, you can exit or use another\n"
    printf "    terminal and practice your skills with zfs commands.\n"
    printf "########################################################\n"
    read -rp "Enter your choice: " choice
    case $choice in
        1)
            # Clean up previous devices, then create mirror with spare
            disks=($(create_image_files 2 1))  # Create 2 disks starting at index 1
            spare=$(create_image_files 1 3)    # Create 1 spare starting at index 3
            create_pool "mirror" "zfsmini_MIRROR" "${disks[*]}" "$spare"
            sleep 2
            ;;
        2)
            # Clean up previous devices, then create RAIDZ with spare
            disks=($(create_image_files 3 1))  # Create 3 disks starting at index 1
            spare=$(create_image_files 1 4)    # Create 1 spare starting at index 4
            create_pool "raidz" "zfsmini_RAIDZ" "${disks[*]}" "$spare"
            sleep 2
            ;;
        3)
            if [ -z "$existing_pool" ]; then
                echo "No existing pool found."
            else
                read -rp "Are you sure you want to destroy the pool '$existing_pool' and all its data? (yes/no): " confirm
                if [[ $confirm == [Yy]* ]]; then
                    destroy_and_cleanup "$existing_pool"
                else
                    echo "Pool destruction cancelled."
                fi
            fi
            ;;
        4)
            echo ""
            echo "Thank you for using ZFS Mini Lab Playground!"
            echo "If you find this tool helpful, consider supporting it."
            echo "Donations are welcome at: "
            echo "          https://www.paypal.me/cerebrux"
            sleep 2
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 2
            ;;
    esac
}

# Run the main menu in a loop until the user exits
while true; do
    main_menu
done

