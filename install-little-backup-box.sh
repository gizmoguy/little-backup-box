#!/usr/bin/env bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo $0)"
   exit 1
fi

echo "Updating the system..."

apt-get update -qq >/dev/null
apt-get dist-upgrade -y -qq >/dev/null
apt-get install jq rsync exfat-fuse exfat-utils ntfs-3g php-cli minidlna samba samba-common-bin -y >/dev/null

echo "Install web interface..."
rsync -a www/ /var/www/
cp etc/systemd/little-backup-box-website.service /etc/systemd/system
systemctl daemon-reload
systemctl enable little-backup-box-website.service
systemctl start little-backup-box-website.service

echo "Install backup job and configure to run on boot..."
rsync -a bin/ /usr/local/bin/
cp etc/systemd/little-backup-box.* /etc/systemd/system
systemctl daemon-reload
systemctl enable little-backup-box.timer

echo "Configuring minidlna..."

sed -i 's|'media_dir=/var/lib/minidlna'|'media_dir=/mnt/destination'|' /etc/minidlna.conf
service minidlna restart

echo "Configuring Samba..."

pw="raspberry"
(echo $pw; echo $pw ) | smbpasswd -s -a pi
echo '### Global Settings ###' > /etc/samba/smb.conf
cp etc/sambda/smb.conf /etc/samba/smb.conf

samba restart
