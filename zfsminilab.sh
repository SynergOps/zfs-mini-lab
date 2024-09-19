#!/bin/bash

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
            # Force clear ZFS label if present
            sudo zpool labelclear -f "$file" || echo "Failed to clear label for $file"
            sudo rm -f "$file"
            echo "Deleted $file"
        done
    else
        echo "No image files found to delete."
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
    if sudo zpool list | grep -qE "myzfspool_mirror|myzfspool_raidz"; then
        echo "Error: A ZFS pool (myzfspool_mirror or myzfspool_raidz) already exists."
        echo "Please destroy the existing pool before creating a new one."
        echo "You can use option 3 from the main menu to destroy and clean up."
        return 1
    fi

    # Create ZFS pool with the selected configuration
    echo "Creating ZFS pool with devices: ${disks[*]}, spare: $spare_disk"
    sudo zpool create "$pool_name" "$pool_type" "${disks[@]}" spare "$spare_disk"

    # Check for successful pool creation before setting properties
    if [[ $? -eq 0 ]]; then
        # Set compression on the root dataset of the pool (e.g., myzfspool_mirror)
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
    echo "Cleanup completed."
}

# Main menu function
main_menu() {
    # Update existing_pool at the start of each menu display
    existing_pool=$(sudo zpool list -H -o name 2>/dev/null | grep -E "myzfspool_mirror|myzfspool_raidz" | head -n1)
    echo "########################################################"
    echo "Welcome to the ZFS Playground!"
    echo "########################################################"
    echo "Select an option:"
    echo "1) Create a mirror with 2 disk image files and 1 spare"
    echo "2) Create a RAIDZ with 3 disk image files and 1 spare"
    echo "3) Destroy and clean up (Current lab pool: $existing_pool)"
    echo "4) Exit"
    echo "########################################################"
    read -rp "Enter your choice: " choice
    case $choice in
        1)
            # Clean up previous devices, then create mirror with spare
            disks=($(create_image_files 2 1))  # Create 2 disks starting at index 1
            spare=$(create_image_files 1 3)    # Create 1 spare starting at index 3
            create_pool "mirror" "myzfspool_mirror" "${disks[*]}" "$spare"
            ;;
        2)
            # Clean up previous devices, then create RAIDZ with spare
            disks=($(create_image_files 3 1))  # Create 3 disks starting at index 1
            spare=$(create_image_files 1 4)    # Create 1 spare starting at index 4
            create_pool "raidz" "myzfspool_raidz" "${disks[*]}" "$spare"
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
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

# Run the main menu in a loop until the user exits
while true; do
    main_menu
done

