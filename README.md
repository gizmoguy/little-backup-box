# Little Backup Box

A collection of scripts that transform a Raspberry Pi (or any single-board computer running a Debian-based Linux distribution) into an inexpensive, fully-automatic, pocketable photo backup device.

<img src="https://i.imgur.com/oHljRK8.jpg" alt="" width="800"/>

## Little Backup Box features

- Back up the contents of a storage card to an external USB storage device. Little Backup Box supports practically any USB card reader, and, by extension, any card format.
- Use multiple cards. Little Backup Box assigns a unique ID to each card and create a separate folder for each card on the backup storage device.
- Perform card backup fully automatically with no user interaction.
- Stream the backed up photos to any DLNA-compatible client.
- Access the backed up content from other machines on the network.

## Installation

1. Create a bootable SD card with the latest version of [Raspbian Lite](https://www.raspberrypi.org/documentation/installation/installing-images/).
2. Make sure that your Raspberry Pi is connected to the internet.
3. Run the following commands on the Raspberry Pi:

```
   pi@raspberrypi:~ $ sudo apt-get update && sudo apt-get install -y git
   pi@raspberrypi:~ $ git clone https://github.com/gizmoguy/little-backup-box
   pi@raspberrypi:~ $ cd little-backup-box
   pi@raspberrypi:~ $ sudo ./install-little-backup-box.sh
```

## Usage

1. Boot the Raspberry Pi.
2. When the status led on the Raspberry Pi starts pulsing once a second the system is fully booted.
2. Plug in a USB hard drive (or pen drive) as well as an SD card with a USB adaptor.
3. When the status led on the Raspberry Pi starts pulsing rapidly the backup has begun.
4. You will know the backup has completed when the Raspberry Pi turns itself off and the status led turns off.

## License

The [GNU General Public License version 3](http://www.gnu.org/licenses/gpl-3.0.en.html)
