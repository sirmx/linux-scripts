# linux-scripts
# Bootstrap for kali linux
# Download kali-setup.sh
# Run: source kali-setup.sh
####
# +----------+ +----------+ +----------+
# + Functions:
# + uppd :- Upgrades the OS
# + install_kali :- Converts debian based OS to kali.
# + clean_up :- Runs deep cleans to remove all traces using bleachbit.
# + gen_list :- Generates a special passlist for cracking wpa2 really fast.
# "+ scan_host :- Automated pentesting scanning prodecures.
# "+ set_host :- Sets hostname and appends IP and hostname into /etc/hosts.
# + crack_wpa2 :- Automated pentesting WiFi WPA/WPA2-PSK brute forcing prodecures.
# + metasploit :- Spawns msfconsole after updating the database.
# +----------+ +----------+ +----------+
#####
# uppd - Updates the operating system to the latest kali packages.
# install_kali - Converts a debian based VM or VPC into a kali server.
# clean_up - Runs bleachbit in a loop with different cleaning specs.
# scan_host - Automated nmap command to find information about a host.
# set_host - Sets the hostname of the kali server.
# crack_wpa2 - Automated aircrack-ng brute forcing method with custom dictionary.
# metasploit - Launches msfconsole after running msfupdate.
######
