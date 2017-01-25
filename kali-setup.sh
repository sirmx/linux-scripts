#!/bin/bash
echo -e "\033[1;31m[ATTENTION] \033[1;34mBootstrapping kali linux pentesting distro... Note: This will take an hour or more depending on your connection speeds... Press ENTER to continue.\033[0m"
read -p
_src1 () {
cat > /etc/apt/sources.list << "EOF"
deb http://http.kali.org/kali kali-rolling main contrib non-free
# For source package access, uncomment the following line
deb-src http://http.kali.org/kali kali-rolling main contrib non-free
EOF;
}
_src2
apt-get install -y debian-archive-keyring debian-keyring debian-ports-archive-keyring kali-archive-keyring -qq --force-yes
_src2 () {
cat > /usr/bin/uppd << "EOF"
apt-get autoremove -y;apt-get autoclean -y;apt-get clean;apt-get update;apt-get upgrade -y;apt-get dist-upgrade -y;apt-get autoremove -y;apt-get autoclean -y;apt-get clean;apt-get update
EOF;
}
_src2
chmod +x /usr/bin/uppd
uppd
apt-get install -y localepurge bleachbit;localepurge -v;apt-get install -y kali-debtags kali-defaults kali-desktop-common kali-desktop-lxde kali-linux-all
useradd -c "MX" -m mx
usermod -aG sudo,wheel mx
echo -e "\033[1;31m[ATTENTION] \033[1;34mNew sudo user account 'mx' added.. Password is: \033[1;33mPassw0rd1\033[1;34m Chnage this on first SSH login! \nRoot SSH login will be \033[1;31mDISABLED!\033[0m"
read -p
echo "mx:Passw0rd1"
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
service sshd restart
#wget -4 -c -O /tmp/kali-rolling.sh https://raw.githubusercontent.com/sirmx/linux-scripts/master/kali-rolling.sh
#chmod +x kali-rolling.sh
bash kali-rolling.sh -burp -dns -openvas|tee -a /tmp/kali-rolling.log
uppd
tail -10 /tmp/kali-rolling.log
echo -e "\033[1;31m[ATTENTION] \033[1;34mPlease remember to change the above mentioned passwords after you reboot... A reboot is needed at this time.\033[0m"
