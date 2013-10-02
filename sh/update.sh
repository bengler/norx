#!/bin/bash
name="norx"

echo "Pulling and restarting services"

cd /home/$name/services
sudo -u $name git pull

cd /home/$name/services/leaflet
sudo -u $name git pull
sudo -u $name npm --silent install

/etc/init.d/tilestache restart
/etc/init.d/leaflet restart

cd ~
