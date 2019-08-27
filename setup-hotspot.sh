#!/usr/bin/env bash

set -euo pipefail

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

echo "Installing packages..."

DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null
DEBIAN_FRONTEND=noninteractive apt-get install dnsmasq hostapd haveged -y >/dev/null

echo "Configuring network..."
cp etc/network/wlan0 /etc/network/interfaces.d/

echo "Configuring dnsmasq..."
cp etc/dnsmasq/hotspot /etc/dnsmasq.d/
systemctl restart dnsmasq

echo "Configuring hostapd..."
cp etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf
sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl restart hostapd
