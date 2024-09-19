# ZFS Mini Lab Playground

A bash script for creating and managing mini ZFS pools for learning and experimentation.

## Features

- Create mirror or RAIDZ, ZFS pools using disk image files
- Automatically set up spare disks for the pools
- Easy cleanup and destruction of pools once you are done
- Interactive menu-driven interface

## Requirements

- ZFS installed on your system
- Sudo privileges

## Usage

1. Clone the repository:
   ```
   git clone https://github.com/synergops/zfs-mini-lab.git
   ```

2. Make the script executable:
   ```
   chmod +x zfsminilab.sh
   ```

3. Run the script:
   ```
   ./zfsminilab.sh
   ```

4. Follow the on-screen menu to create or destroy mini ZFS pools.

## Options

1. Create a mirror with 2 disk image files and 1 spare
2. Create a RAIDZ with 3 disk image files and 1 spare
3. Destroy and clean up existing pools

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to all contributors and users of this tool.

## Support

If you find this tool helpful, consider supporting it:
[PayPal Donation Link](https://www.paypal.me/cerebrux)