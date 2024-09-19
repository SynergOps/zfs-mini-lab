# ZFS Mini Lab Playground

<p align="center">
    <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SATQ6Y9S3UCSG" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-yellow.svg" alt="Donate to project"></a>
</p>

A bash script for creating and managing mini ZFS pools (mirror or raidz) for learning and experimentation.

![zfsminilab](https://github.com/user-attachments/assets/750d80ad-57e8-489f-9c61-955cd774e20e)

_Note: This simple script was born out of lazyness when I was writing a tutorial in Greek titled: ["ZFS: Μην το δοκιμάσεις γιατί θα σου αρέσει"](https://cerebrux.net/2024/09/19/zfs-%ce%bc%ce%b7%ce%bd-%cf%84%ce%bf-%ce%b4%ce%bf%ce%ba%ce%b9%ce%bc%ce%ac%cf%83%ce%b5%ce%b9%cf%82-%ce%b3%ce%b9%ce%b1%cf%84%ce%af-%ce%b8%ce%b1-%cf%83%ce%bf%cf%85-%ce%b1%cf%81%ce%ad%cf%83%ce%b5%ce%b9/). I didn't want to manually create and destroy the testing zfs pools, so I wrote this script_

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
   cd zfs-mini-lab
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

This project is licensed under the MIT License - see the [LICENSE](https://github.com/SynergOps/zfs-mini-lab/blob/master/LICENSE) file for details.

## Acknowledgments

- Thanks to all contributors and users of this tool.

## Support

If you find this tool helpful, consider supporting it:
[PayPal Donation Link](https://www.paypal.me/cerebrux)
