# Edu-related packages
pkgs="$pkgs
idle python3-pygame python-pygame python-tk
idle3 python3-tk
python3-rpi.gpio
python-serial python3-serial
python-picamera python3-picamera
python3-pygame python-pygame python-tk
python3-tk
debian-reference-en dillo x2x
scratch nuscratch
timidity
smartsim penguinspuzzle
pistore
sonic-pi
python3-numpy
python3-pifacecommon python3-pifacedigitalio python3-pifacedigital-scratch-handler python-pifacecommon python-pifacedigitalio
minecraft-pi python-minecraftpi
wolfram-engine
bluej geany greenfoot node-red
libreoffice-*
claws-mail
epiphany-browser
netsurf-gtk
realvnc-vnc-server realvnc-vnc-viewer
python-picraft python3-picraft
"


# Remove packages
for i in $pkgs; do
	apt-get -y remove --purge $i
done

# Remove automatically installed dependency packages
apt-get -y autoremove
