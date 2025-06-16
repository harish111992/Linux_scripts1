#!/bin/bash
tput setaf 3
echo "        ======================================================="
echo "        Server Configuration and Validation script for HIB Team"
echo "        ======================================================="
while true
do
   tput setaf 6
   echo "                     Press 1 - Update the Host Name Configs
                     Press 2 - Update the REPO file - (CENTOS-7.x only)
                     Press 3 - Update the OS to up to date
                     Press 4 - Integrate to Puppet Server(bil-foreman-001v - CENTOS-7.x only)
                     Press 5 - Install and configuring Chrony
                     Press 6 - Config SNMPD
                     Press 7 - Integrate AD
                     Press 8 - Update System-auth file 
                     Press 9 - Exit from the Script "
   tput setaf 7
   echo -e " \n Please select your option: \c"
   read answer
   case "$answer" in
   #Case1
      1) echo -e "Enter hostname : \c"
         read host
         echo -e "Enter Domain Name : \c"
         read domain
         IP=$(ip r l | grep eth0 | grep src | awk {'print $9'})
         echo $host.$domain > /etc/hostname
         hostname $host.$domain
         echo "+-----------[ ${host^^} | $domain ]-------------------------------------+" > /etc/issue
         echo "+-----------[ ${host^^} | $domain ]-------------------------------------+" > /etc/issue.net
         cat << EOF > /etc/hosts
127.0.0.1 localhost localhost.localdomain
$IP  $host.$domain $host
EOF
         #sed -i "2s/.*/$IP   $host.$domain $host/" /etc/hosts
         echo -e "\n `tput setaf 2` Hostname is updated to `cat /etc/hostname` \n"
         tput setaf 7;;
      #Case2
      2) echo -e "\n Verifing REPO file.....\n"
         REPO=$(ls -l /etc/yum.repos.d/ | awk '{print $9}' | sed '1d' | grep parexel.repo)
         os=$(cat /etc/redhat-release  | awk {'print $1'})
         if [ "$REPO" == "parexel.repo" ] && [ "$os" == "CentOS" ]
         then
                echo "REPO file is already updated"
         elif [ $os == "CentOS" ]
         then
                echo -e "\n REPO file is not updated, Updating REPO file....\n"
                sleep 3
                echo -e "\n #### REPO file is updated #### \n"
                mv /etc/yum.repos.d/*.repo /tmp
                cat << 'EOF' > /etc/yum.repos.d/parexel.repo
##YUM REPOS FOR CENTOS UPDATES and PUPPET BINARIES##

[centosrelease-7-extras-$basearch]
enabled = 1
name =  Parexel Centos release-$basearch
baseurl = http://bil.ext/pub/repos/centos-7-extras-$basearch/
gpgcheck = 0

[centosrelease-7-repos-$basearch]
enabled = 1
name =  Parexel Centos release-repos-$basearch
baseurl = http://bil.pii-dmz.ext/pub/repos/centos-7-base-$basearch/
gpgcheck = 0


[centosrelease-7-updates-$basearch]
enabled = 1
name = Parexel Centos Update release-updates-$basearch
baseurl = http://bil.pii-dmz.ext/pub/repos/centos-7-updates-$basearch/
gpgcheck = 0


[puppetlabs-products-el7-$basearch]
enabled = 1
name = Parexel Puppet release-$basearch
baseurl = http://bil.pii-dmz.ext/pub/repos/puppetlabs7-products/
gpgcheck = 0

[puppetlabs-devel-el7-$basearch]
enabled = 1
name = Parexel Puppet devel release-$basearch
baseurl = http://bil.pii-dmz.ext/pub/repos/puppetlabs7-devel/
gpgcheck = 0

[puppetlabs-deps-el7-$basearch]
enabled = 1
name = Parexel Puppet Deps release-$basearch
baseurl = http://bil.pii-dmz.ext/pub/repos/puppetlabs7-deps/
gpgcheck = 0

[epel]
enabled = 1
name = Parexel epel base release-$basearch
baseurl = http://bil.pii-dmz.ext/pub/repos/epel7/
gpgcheck = 0

EOF
         else
                echo -e "\n`tput setaf 2`This is Applicable for CENTOS7 only `tput setaf 7` \n"
         fi ;;

       #Case3
      3) yum update -y
         echo -e "\n \n `tput setaf 2` Check YUM o/p and mention if system needs reboot  'yes/no': `tput setaf 7` \c"
         read ans
         if [ "$ans" == "yes" ]
         then
                init 6
         fi ;;
       #Case4
      4) OS=$(cat /etc/redhat-release  | awk {'print $1'})
         if [ "$OS" == "CentOS" ]
         then
            echo -e " `tput setaf 2`\n \n Integrating to bil-foreman-001v.pii-dmz.ext"
            echo "      -----------------------------------------------------------------------------"
            echo "      Once server Integrated to foreman select the Hardening class in foreman server
                          and run  'puppet agent -t' in client server"
            echo -e "   -----------------------------------------------------------------------------\n\n"
            tput setaf 7
            cat << 'EOF' > /root/bil_foreman.sh
#!/bin/bash
PUPPETMASTER="bil-foreman-001v.pii-dmz.ext"
# Please change the environment based on the server’s   development/production
ENVIRON=development

# Please make sure you copy the working parexel.repo from any server already added to foreman


yum clean all
yum –y install epel-release*
sleep 1
yum –y install puppetlabs-release*
sleep 1
yum –y install yum-utils*
sleep 1
# install dependent packages
yum install -y augeas puppet git policycoreutils-python
sleep 1

# if Augeas is not available use echo to add parameters in puppet.conf file
#echo -e "server= bil-foreman-001v.pii-dmz.ext " >> /etc/puppet/puppet.conf
#echo -e "ca_server= bil-foreman-001v.pii-dmz.ext " >> /etc/puppet/puppet.conf
#echo -e "environment=production" >> /etc/puppet/puppet.conf
#echo -e "certname=$(hostname -f | tr '[:upper:]' '[:lower:]')" >> /etc/puppet/puppet.conf
#echo -e "report=true" >> /etc/puppet/puppet.conf
#echo -e "pluginsync=true" >> /etc/puppet/puppet.conf
#echo -e "listen=true" >> /etc/puppet/puppet.conf
#echo -e "runinterval=30m" >> /etc/puppet/puppet.conf
# Set PuppetServer
augtool -s set /files/etc/puppet/puppet.conf/agent/server $PUPPETMASTER

# Set Environment
augtool -s set /files/etc/puppet/puppet.conf/agent/environment $ENVIRON

# Set ca cert
augtool -s set /files/etc/puppet/puppet.conf/agent/ca_server $PUPPETMASTER

# Set cert name
augtool -s set /files/etc/puppet/puppet.conf/agent/certname $(hostname -f | tr '[:upper:]' '[:lower:]')

# Set runinterval
augtool -s set /files/etc/puppet/puppet.conf/agent/runinterval 30m

# Puppet Plugins
augtool -s set /files/etc/puppet/puppet.conf/main/pluginsync true

# Allow puppetrun from foreman/puppet master to work
augtool -s set /files/etc/puppet/puppet.conf/main/listen true


# check in to foreman
puppet agent --test
sleep 1
puppet agent --test

#/etc/init.d/puppet start
systemctl start puppet

#chkconfig puppet on
systemctl enable puppet
# end of the script.
EOF
         chmod +x /root/bil_foreman.sh
         sh /root/bil_foreman.sh         
         else
            echo -e "\n`tput setaf 2` This is Applicable for CENTOS7 only `tput setaf 7`\n "
         fi ;;   

      #Case5
      5) yum install chrony -y
         systemctl disable ntpd
         systemctl stop ntpd   
         echo -n "Enter desired AD name Ex `tput setaf 3` pii-dmz.ext OR pii.pxl.int `tput setaf 7` :  "   
         read CHRONY
         cat << EOF > /etc/chrony.conf
# Parexel Azure Time Client configuration

server $CHRONY iburst

#server ntpuse2.parexelcloud.ext iburst
#server ntpuscn.computer.parexelcloud.ext iburst

##Use the on-prem servers below ONLY if the Azure servers cannot be reached
#then notify Linux Engineering
#server ntp01.parexel.com iburst
#server ntp02.parexel.com iburst

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
minsources 2

# This is definition for if you want to run this system as a time server
#UDP ports 123 and 323 must be reachable
# Allow NTP client access from local network.
#allow 192.168.0.0/16

# Serve time even if not synchronized to a time source.
#local stratum 10

# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys

# Specify directory for log files.
logdir /var/log/chrony

# Select which information is logged.
#log measurements statistics tracking
#===end of file===
EOF
         systemctl restart chronyd; sleep 5; chronyc sources
         systemctl enable chronyd ;;
      #Case6         
      6) yum install snmpd -y
         PXL=$(grep glblpxl /etc/snmp/snmpd.conf | awk '{print $4}')
         if [[ "$PXL" == "sys@glblpxl" ]]
         then
               tput setaf 3
               echo -e "\n sys@glblpxl paremeter already exists, Please verify the config file once \n"
               tput setaf 7
         else
               echo "com2sec OrionUser        default        sys@glblpxl" >>  /etc/snmp/snmpd.conf
               echo "group   notConfigGroup v1               OrionUser" >> /etc/snmp/snmpd.conf
               echo "group   notConfigGroup v2c              OrionUser" >> /etc/snmp/snmpd.conf
               echo -e "\n`tput setaf 2` Configured SNMPD successfully `tput setaf 7`\n "
         fi
         systemctl restart snmpd ;;
      #Case 7
      7) echo "`tput setaf 5`--------------------------------------------------------"
         echo "Enter desire AD domain name Ex pii.pxl.int  pii-dmz.ext"
         echo "--------------------------------------------------------`tput setaf 7`"
         echo -e "Enter your input: \c"
         read AD
         echo -e "`tput setaf 2` Enter your AD username:  \c "
         tput setaf 7
         read USR
         PAM=/etc/security/access.conf
         SUDO=/etc/sudoers.d/pii_linuxadmins
         KRB=/etc/krb5.conf
         RES=/etc/resolv.conf
         SSSD=/etc/sssd/sssd.conf
         SSHD=/etc/ssh/sshd_config
         REL=$(cat /etc/redhat-release |awk -F' ' '{print $7}'|awk -F'.' '{print $1}')
         SUBREL=$(cat /etc/redhat-release |awk -F' ' '{print $7}'|awk -F'.' '{print $2}')
         yum install openssl -y
         yum install -y finger
         yum install -y yum-utils* puppet git policycoreutils-python
         yum install -y NetworkManager-0.9.9.1-13.git20140326.4dba720.el7.x86_64 NetworkManager-tui
         yum install -y sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python
         yum install -y nmap
         # expect required for script functionality
         yum install -y expect
         yum install -y chrony
         sed -i '/^PASS_MIN_LEN/c PASS_MIN_LEN    8' /etc/login.defs
         yum update -y
         cat << EOF > $KRB
# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

includedir /var/lib/sss/pubconf/krb5.include.d/
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
dns_lookup_realm = false
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
rdns = false
# default_realm = EXAMPLE.COM
default_ccache_name = KEYRING:persistent:%{uid}

default_realm = ${AD^^}
[realms]
# EXAMPLE.COM = {
#  kdc = kerberos.example.com
#  admin_server = kerberos.example.com
# }

${AD^^} = {
}

[domain_realm]
# .example.com = EXAMPLE.COM
# example.com = EXAMPLE.COM
$AD = ${AD^^}
.$AD = ${AD^^}
EOF
         sleep 5
         realm discover $AD
         slepp 5
         #realm leave -v -U kandrup $AD
         realm join -v $AD --user $USR
         sleep 5
         realm permit --realm $AD --all
         sleep 5
         realm list
         sleep 5
         cat << EOF > $PAM
# Groups allowed acccess to this system
# Example "+ : dba_group : 192.168.200.1"

+ : pii_linuxadmins : ALL
+ : LinuxAdmins   : ALL

# Individual Users allowed access to this system
# Example "+ : foo : 192.168.200.1"
#+ : oracle : LOCAL

##############################################################################
# Do not add anything below this Line!!!
# User "root" should be allowed to get access via cron .. tty5 tty6.
+ : root : LOCAL 10.238.36.24 172.24.147.50 172.24.173.59
# All other users should be denied to get access from all sources.
- : ALL : ALL
EOF
         cat << EOF >> $SUDO
##Allow linuxadmins root privileges
%pii_linuxadmins ALL=(ALL)      NOPASSWD: ALL
%LinuxAdmins ALL=(ALL)       NOPASSWD: ALL
####################################
EOF
         cat << EOF > $SSSD
[sssd]
domains = $AD
config_file_version = 2
services = nss, pam

[domain/$AD]
ad_domain = $AD
krb5_realm = $AD
realmd_tags = manages-system joined-with-samba
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
fallback_homedir = /home/%u@%d
access_provider = ad
use_fully_qualified_names = False
ad_gpo_ignore_unreadable = True
EOF
         systemctl restart sssd
         echo ""
         echo "Configuring SSHD..."
         echo ""  
         cat << EOF > $SSHD
# ---
# Perceptive Secure Shell Daemon Configuration
# ---
Protocol 2
# Port 22
SyslogFacility AUTHPRIV
PasswordAuthentication yes
ChallengeResponseAuthentication no
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
UsePAM yes
AuthorizedKeysFile     .ssh/authorized_keys
# - PermitRootLogin : LAN yes DMZ without-password - use regular user for SSH then 'su -' for root access
PermitRootLogin no
# PermitRootLogin without-password
# PermitRootLogin no
# PermitRootLogin forced-commands-only
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL
X11Forwarding yes
Subsystem sftp /usr/libexec/openssh/sftp-server
Banner /etc/issue.net
# ---
# Perceptive Secure Shell Daemon Configuration
# ---
EOF
         echo "Updated SSHD..."
         systemctl restart sshd ;;
      #Case 8
      8) tally2=$(cat /etc/pam.d/system-auth | grep pam_tally2.so | awk {'print $3'})
         RMBR=$(cat /etc/pam.d/system-auth | grep remember=12 | awk {'print $9'})
         mv /etc/motd /etc/motd_bkp
         if [[ "$tally2" == "pam_tally2.so" ]]
         then
               echo -e "\n `tput setaf 6` Deny set to 4  `tput setaf 7`\n"
         else
               sed -i '$a\auth        required      pam_tally2.so deny=4 onerr=fail unlock_time=1140\' /etc/pam.d/system-auth
               echo -e "\n `tput setaf 6` Deny set to 4 is already updated `tput setaf 7`\n"
         fi
         if [[ "$RMBR" == "remember=12" ]]
         then
               echo -e " \n `tput setaf 6` Password history set to 12 is already updated `tput setaf 7` \n "
         else
               sed -i '$a\password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=12\' /etc/pam.d/system-auth
               echo -e " \n `tput setaf 6` Password history set to 12 `tput setaf 7` \n "
         fi;;
      9) exit ;;


   esac
done


#VA scannig
#MOnitoring 
#backup 
#update in Tracker sheet
#ADD in DNS
#Name servers 
#CMDB update
#Sudoers update 



