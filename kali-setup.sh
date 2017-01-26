#!/bin/sh
# https://github.com/sirmx/linux-scripts.git
function msg ()
{
	local red="\033[01;31m"
	local green="\033[01;32m"
	local yellow="\033[01;33m"
	local blue="\033[01;34m"
	local rst="\033[00m"
	if [ $2 -eq 1 ]
	then
		printf "${red}[ERROR]: $1${rst}\n"
	else
		printf "${green}[INFO]: $1${rst}\n"
	fi
}
function uppd ()
{
	msg "Updating kali...." 0
	dpkg --configure -a &>/dev/null;apt-get -f install -qq -y;apt-get autoremove -qq -y;apt-get autoclean -qq -y;apt-get clean;apt-get update;apt-get upgrade -qq -y;apt-get dist-upgrade -qq --force-yes -y;apt-get autoremove -qq -y;apt-get autoclean -qq -y;apt-get clean;apt-get update -qq
	msg "Updating completed." 0
}
function install_kali ()
{
	msg "Installing Kali Rolling Linux" 0
	msg "This may take some time depending on your connection." 0
	sleep 4
	echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | sudo tee > /etc/apt/sources.list
	echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free"| sudo tee >> /etc/apt/sources.list
	apt-get clean
	apt-get install -y --force-yes kali-archive-keyring -qq
	apt-get install -y --force-yes localepurge bleachbit
	localepurge -v
	apt-get autoremove -y &>/dev/null && apt-get autoclean -y &>/dev/null && apt-get clean
	apt-get update -qq
	apt-get install -f -y --force-yes -qq
	apt-get update -qq
	apt-get install -y debian-archive-keyring debian-keyring debian-ports-archive-keyring kali-archive-keyring -qq --force-yes
	apt-get install -y kali-debtags kali-defaults kali-desktop-common kali-desktop-lxde kali-linux-full --force-yes;wget -c https://raw.githubusercontent.com/sirmx/linux-scripts/master/kali-rolling.sh
	bash kali-rolling.sh -burp -dns -openvas|tee -a ~/kali-rolling-setup.log
	useradd -c "MX" -m -g sudo mx
	echo "mx:Passw0rd1"|chpasswd
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	echo "AllowUsers mx" | sudo tee -a /etc/ssh/sshd_config
	echo "DenyUsers root" | sudo tee -a /etc/ssh/sshd_config
	echo -e "\033[1;31m[ATTENTION] \033[1;34mNew sudo user account 'mx' added.. Password is: \033[1;33mPassw0rd1\033[1;34m Chnage this on first SSH login! \nRoot SSH login will be \033[1;31mDISABLED!\033[0m"
	read -p
	service sshd restart
	update-rc.d -f ssh enable
	for i in `bleachbit -l|grep -v memory`; do bleachbit -s -c $i 2>/dev/null;done
	cat ${PWD}/$0 >> ~/.profile
	msg "Done." 0
}
function set_host ()
{
	local host_name="$1"
	local _ip="$2"
	echo "${host_name}" > /etc/hostname
	echo "${_ip}    ${host_name}" >> /etc/hosts
}
function clean_up ()
{
	apt-get install --force-yes -y -qq bleachbit &>/dev/null
	for i in `bleachbit -l|grep -v memory`; do bleachbit -s -c $i 2>/dev/null;done
}
function gen_list ()
{
	test ! -f /usr/share/seclists/Passwords/rockyou.txt && test ! -f /usr/share/seclists/Passwords/rockyou.txt.gz || wget -c https://github.com/danielmiessler/SecLists/raw/master/Passwords/rockyou.txt.tar.gz
	test -f rockyou.txt.tar.gz && tar -xf rockyou.txt.tar.gz -C /usr/share/seclists/Passwords/
	msg "Please wait while I generator a wordlist..." 0
	crunch 8 8 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&-+='|nice -n -20 shuf -n 10 >> ~/WORDLIST.txt&  wait $!
	msg "Section: 2" 0
	cat /usr/share/seclists/Passwords/rockyou.txt| pw-inspector -m 8 -M 16 |nice -n -20 shuf -n 10 >> ~/WORDLIST.txt
	msg "Section: 3" 0
	crunch 8 8 -f /usr/share/rainbowcrack/charset.txt numeric  | pw-inspector -m 8 -M 16 |nice -n -20 shuf -n 10 >> ~/WORDLIST.txt
	msg "Section: 4" 0
	crunch 8 8 -f /usr/share/rainbowcrack/charset.txt mixalpha-numeric|nice -n -20 shuf -n 10 >> ~/WORDLIST.txt
	msg "Section: 5" 0
	msg "Sorting passlist now and removing duplicates..." 0
	sort ~/WORDLIST.txt|uniq -u >> ~/WORDLIST.tx
	msg "Randomizing passlist now..." 0
	nice -n -20 shuf -n 10 ~/WORDLIST.tx >> ~/WORDLIST.txx
	mv -v ~/WORDLIST.txx ~/WORDLIST.txt
	rm -f ~/WORDLIST.tx
	msg "Passlist completed." 0
}
function scan_host ()
{
	local _host="$1"
	nmap -v -Pn -A -O -sS -sV -sU --top-ports 10000 -sC --system-dns --max-retries 8 --max-rtt-timeout 4000ms --script-args force  --script http-waf-detect --script-args="http-waf-detect.uri=/testphp.vulnweb.com/artists.php,http-waf-detect.detectBodyChanges" --script "http-*,ip-*,vnc-*,smb-*" --script-args=unsafe=1 --script-args "default or unsafe" --scan-delay 4 -ff --badsum --spoof-mac Cisco ${_host}|tee -a ~/nmap_${_host}-log.log
}
function metasploit ()
{
	msfupdate && msfconsole -q
}
function crack_wpa2 ()
{
	(
		nice -n -15
		touch /tmp/.wpa-codes.log
		local _wpa_file="$1"
		local _bssid="$2"
		test ! -f ~/rockyou.txt && wget -c https://github.com/danielmiessler/SecLists/raw/master/Passwords/rockyou.txt.tar.gz
		tar -xf rockyou.txt.tar.gz
		msg "Cracking WPA/WPA2-PSK...." 0
		cat rockyou.txt| pw-inspector -m 12 -M 12 |nice -n -20 shuf -n 12 |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
		cat rockyou.txt| pw-inspector -m 8 -M 08 |nice -n -20 shuf -n 8 |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
		msg "Section: 2" 0
		crunch 8 8 -f charset.txt numeric  | pw-inspector -m 8 -M 16 |nice -n -20 shuf -n 16  |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
		msg "Section: 3" 0
		crunch 8 8 -f charset.txt mixalpha-numeric|nice -n -20 shuf -n 8  |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
		msg "Section: 4" 0
		crunch 12 12 -f charset.txt numeric  | pw-inspector -m 8 -M 16 |nice -n -20 shuf -n 12  |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
		msg "Section: 5" 0
		crunch 12 12 -f charset.txt mixalpha-numeric|nice -n -20 shuf -n 12  |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
		crunch 8 8 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&-+='|nice -n -20 shuf -n 8 |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
		crunch 12 12 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&-+='|nice -n -20 shuf -n 12 |aircrack-ng -w - -l /tmp/.wpa-codes.log -b ${_bssid} ${_wpa_file}
	msg "Section: 6 - Completed." 0
	msg "If brute force was successful you will have the password stored in file: /tmp/.wpa-codes.log" 0
	msg "WPA/WPA2-PSK brute force completed." 0
function run ()
{
	git clone https://github.com/sirmx/linux-scripts.git
	set_host
	uppd
	clean_up
	install-kali || bash ./linux-scripts/kali-setup.sh -burp -dns -openvas|tee -a log.log
	clean_up
	uppd
	msg "You need to reboot... System will reboot in one minute without CTRL+C"
	sleep 60
	return $?
	reboot
}
function menu ()
{
	msg "+----------+ +----------+ +----------+" 0
	msg "+ Functions:" 0
	msg "+ uppd :- Upgrades the OS" 0
	msg "+ install_kali :- Converts debian based OS to kali." 0
	msg "+ clean_up :- Runs deep cleans to remove all traces using bleachbit." 0
	msg "+ gen_list :- Generates a special passlist for cracking wpa2 really fast." 0
	msg "+ scan_host :- Automated pentesting scanning prodecures." 0
	msg "+ set_host :- Sets hostname and appends IP and hostname into /etc/hosts." 0
	msg "+ crack_wpa2 :- Automated pentesting WiFi WPA/WPA2-PSK brute forcing prodecures." 0
	msg "+ metasploit :- Spawns msfconsole after updating the database." 0
	msg "+ run :- Tweaks kali install." 0
	msg "+----------+ +----------+ +----------+" 0
}
msg "kali-strap loaded."
msg "Type: menu for options"
