#!/bin/bash
#echo "Add User vao Group Wheel"
yum update -y && yum upgrade -y
yum install aide rsyslog openscap-scanner scap-security-guide -y
systemctl  restart  rsyslog && systemctl  enable  rsyslog
# Dùng fwd hoặc iptables tùy thuộc phiên bản os
systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld
dnf -y install iptables-services iptables-utils
systemctl enable iptables
systemctl  restart  iptables && systemctl  status iptables
#Cau hinh chinh sach mat khau manh															
echo "Cau hinh chinh sach mat khau manh"
echo -e "\nResult:"; folder="/etc/pam.d/system-auth"; para2=`cat /etc/pam.d/system-auth | grep -v ^# | grep password | grep retry | awk '{print $2}'`; para3=`cat /etc/pam.d/system-auth | grep -v ^# | grep password | grep retry | awk '{print $3}'`; if [[ -z $para2 || -z $para3 ]]; then echo "Nothing to do"; else standard=`echo -e "password\t$para2\t$para3\ttry_first_pass\tretry=3\tminlen=8\tdcredit=-1\tucredit=-1\tocredit=-1\tlcredit=-1"`; check=`cat $folder | grep -v ^# | grep ^password | grep -w $para2| grep -w $para3`; if [[ -z $check ]]; then echo "$standard" >> $folder; echo "Inserted config: $standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s/$check/#$check\n$standard/g" $folder; echo "Replaced config: $standard"; fi; fi; echo "";
echo -e "\nResult:"; folder="/etc/pam.d/system-auth"; standard=`echo -e "password\tsufficient\tpam_unix.so\tsha512\tshadow\tnullok\ttry_first_pass use_authtok\tremember=5"`; check=`cat $folder | grep -v ^# | grep ^password | grep -w sufficient | grep -w pam_unix.so`; if [[ -z $check ]]; then echo "$standard" >> $folder; echo "Inserted config: $standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s/$check/#$check\n$standard/g" $folder; echo "Replaced config: $standard"; fi; echo "";
echo -e "\nResult:"; folder="/etc/login.defs"; standard=`echo -e "PASS_MAX_DAYS\t90"`; check=`cat $folder | grep -v ^# | grep ^PASS_MAX_DAYS`; if [[ -z $check ]]; then echo "$standard" >> $folder; echo "Inserted config: $standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s/$check/#$check\n$standard/g" $folder; echo "Replaced config: $standard"; fi; echo "";
echo -e "\nResult:"; check=`authconfig --test | grep hashing | grep sha512`; if [[ -z $check ]]; then authconfig --passalgo=sha512 --update; echo "Updated: authconfig --passalgo=sha512 --update"; else echo "Nothing to do"; fi; echo "";
echo "NEXT CRITERIA";
#5.4.3 Ensure password hashing algorithm is SHA-512 (Automated)
echo '#5.4.3 Ensure password hashing algorithm is SHA-512 (Automated)'
echo 'Run the following command to verify the sha512 option is included:'
grep -P '^\h*password\h+(sufficient|requisite|required)\h+pam_unix\.so\h+([^#\n\r]+)?sha512(\h+.*)?$' /etc/pam.d/system-auth /etc/pam.d/password-auth
echo -e "\nResult:"; check=`authconfig --test | grep hashing | grep sha512`; if [[ -z $check ]]; then authconfig --passalgo=sha512 --update; echo "Updated: authconfig --passalgo=sha512 --update"; else echo "Nothing to do"; fi; echo "";

#Cau hinh SSH
echo "Cau hinh SSH"
echo -e "\nResult:"; folder="/etc/ssh/sshd_config"; standard="Protocol 2"; check=`cat $folder | grep -v ^# | grep -w "Protocol"`; if [[ -z $check ]]; then echo "$standard" >> $folder; echo "Inserted config: $standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s~$check~#$check\n$standard~g" $folder; echo "Replaced config: $standard"; fi; echo "";
echo -e "\nResult:"; folder="/etc/ssh/sshd_config"; standard="PermitRootLogin no"; check=`cat $folder | grep -v ^# | grep -w "PermitRootLogin"`; if [[ -z $check ]]; then echo "$standard" >> $folder; echo "Inserted config: $standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s~$check~#$check\n$standard~g" $folder; echo "Replaced config: $standard"; fi; echo "";
echo -e "\nResult:"; check=`cat /etc/ssh/sshd_config | grep -v ^# | grep -w AllowUsers`;if [[ -z $check ]]; then echo AllowUsers >> /etc/ssh/sshd_config; fi; list=`cat /etc/passwd |grep /bin/bash | grep -v ^# | grep -v nfsnobody | awk -F: '($3>=400) {print $1}'`; for user in $list;do check=`cat /etc/ssh/sshd_config | grep -v ^# | grep -w AllowUsers | grep -w $user`; if [[ $check == *$user* ]] ; then echo "$user OK"; else sed -i "s/AllowUsers/AllowUsers $user/g" /etc/ssh/sshd_config ; echo $user Inserted; fi; done; echo "";
echo -e "\nResult:"; folder="/etc/profile"; standard="TMOUT=900"; check=`cat $folder | grep -v ^# | grep $standard`; if [[ -z $check ]]; then echo -e "TMOUT=900\nreadonly TMOUT\nexport TMOUT" >> $folder; echo -e "Inserted config:\n$standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s~$check~#$check\n$standard~g" $folder; echo -e "Replaced config:\n$standard";fi; echo "";
service sshd reload
echo "NEXT CRITERIA";

#Cau hinh disable cac dich vu thua															
echo "Cau hinh disable cac dich vu thua"
echo -e "\nResult:"; check=`systemctl status postfix | grep "Active: active"`; if [[ -z $check ]]; then echo "Nothing to do"; else systemctl stop postfix; systemctl disable postfix; echo "Stopped service postfix"; fi; echo "";
echo -e "\nResult:"; check=`systemctl status kdump | grep "Active: active"`; if [[ ! -z $check ]]; then echo "Nothing to do"; else systemctl start kdump; systemctl enable kdump; echo "Started service kdump"; fi; echo "";
echo "NEXT CRITERIA";

#Cau hinh SELinux															
echo "Cau hinh SELinux"
echo -e "\nResult:"; folder="/etc/selinux/config"; standard="SELINUX=disabled"; check=`cat $folder | grep -v ^# | grep "SELINUX="`; if [[ -z $check ]]; then echo "$standard" >> $folder; echo "Inserted config: $standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s~$check~#$check\n$standard~g" $folder; echo "Replaced config: $standard"; fi; echo "";
echo -e "\nResult:"; check=`sestatus | grep "Current mode"`; if [[ -z $check ]]; then echo "Nothing to do"; elif [[ $check == *"enforcing"* ]]; then setenforce 0; echo "Fixed selinux permissive mode"; else echo "Nothing to do"; fi; echo "";
echo -e "\nResult:"; check=`systemctl status cups | grep "Active: active"`; if [[ -z $check ]]; then echo "Nothing to do"; else systemctl stop cups; systemctl disable cups; echo "Stopped service cups"; fi; echo "";


#5.4 Configure PAM
#5.4.1 Ensure password creation requirements are configured (Automated)
#minlen = 14 - password must be 14 characters or more
#minclass = 4 - The minimum number of required classes of characters for the new password (digits, uppercase, lowercase, others)
# The following is set in the /etc/pam.d/password-auth and /etc/pam.d/system-auth files
#try_first_pass - retrieve the password from a previous stacked PAM module. If not available, then prompt the user for a password.
#retry=3 - Allow 3 tries before sending back a failure.
echo '#5.4.1 Ensure password creation requirements are configured (Automated)'
grep '^\s*minlen\s*' /etc/security/pwquality.conf
grep '^\s*minclass\s*' /etc/security/pwquality.conf
grep -P '^\s*password\s+(?:requisite|required)\s+pam_pwquality\.so\s+(?:\S+\s+)*(?!\2)(retry=[1-3]|try_first_pass)\s+(?:\S+\s+)*(?!\1)(retry=[1-3]|try_first_pass)\s*(?:\s+\S+\s*)*(?:\s+#.*)?$' /etc/pam.d/password-auth
grep -P '^\s*password\s+(?:requisite|required)\s+pam_pwquality\.so\s+(?:\S+\s+)*(?!\2)(retry=[1-3]|try_first_pass)\s+(?:\S+\s+)*(?!\1)(retry=[1-3]|try_first_pass)\s*(?:\s+\S+\s*)*(?:\s+#.*)?$' /etc/pam.d/system-auth

sed -i 's/minlen/#minlen/g'  /etc/security/pwquality.conf
sed -i 's/minclass/#minclass/g'  /etc/security/pwquality.conf
echo 'minlen = 14' >>  /etc/security/pwquality.conf
echo 'minclass = 4' >>   /etc/security/pwquality.conf

#5.5.5 Ensure default user umask is configured (Automated)
echo '#5.5.5 Ensure default user umask is configured (Automated)'
sed -i 's/UMASK		022/UMASK		027/g' /etc/login.defs
sed -i 's/USERGROUPS_ENAB yes/USERGROUPS_ENAB no/g' /etc/login.defs
echo 'umask 027' >> /etc/profile.d/set_umask.sh
echo 'session optional pam_umask.so' >> /etc/pam.d/password-auth
echo 'session optional pam_umask.so' >> /etc/pam.d/system-auth
grep -RPi '(^|^[^#]*)\s*umask\s+([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b|[0-7][01][0-7]\b|[0-7][0-7][0-6]\b|(u=[rwx]{0,3},)?(g=[rwx]{0,3},)?o=[rwx]+\b|(u=[rwx]{1,3},)?g=[^rx]{1,3}(,o=[rwx]{0,3})?\b)' /etc/login.defs /etc/profile* /etc/bashrc*
grep UMASK /etc/login.defs

#5.3.16 Ensure SSH Idle Timeout Interval is configured (Automated)
echo '#5.3.16 Ensure SSH Idle Timeout Interval is configured (Automated)'
sed -i 's/ClientAliveInterval/#ClientAliveInterval/g' /etc/ssh/sshd_config
sed -i 's/ClientAliveCountMax/#ClientAliveCountMax/g' /etc/ssh/sshd_config
echo 'ClientAliveInterval 900
ClientAliveCountMax 0'  >> /etc/ssh/sshd_config 
#Check
sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep clientaliveinterval
echo 'match with clientaliveinterval 900'
sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep clientalivecountmax 
echo 'clientalivecountmax 3'

grep -Ei '^\s*ClientAliveInterval\s+(0|9[0-9][1-9]|[1-9][0-9][0-9][0-9]+|1[6-9]m|[2-9][0-9]m|[1-9][0-9][0-9]+m)\b' /etc/ssh/sshd_config
grep -Ei '^\s*ClientAliveCountMax\s+([1-9]|[1-9][0-9]+)\b' /etc/ssh/sshd_config
echo 'Nothing should be returned'

#5.5 User Accounts and Environment
#5.5.1 Set Shadow Password Suite Parameters
#5.5.1.1 Ensure password expiration is 365 days or less (Automated)
echo '#5.5.1.1 Ensure password expiration is days or less and number of login(Automated)'
sed -i 's/PASS_MAX_DAYS	365/PASS_MAX_DAYS	365/g'  /etc/login.defs
sed -i 's/#MaxAuthTries 6/MaxAuthTries 5/g' /etc/ssh/sshd_config

grep ^\s*PASS_MAX_DAYS /etc/login.defs
grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,5
#5.5.1.2 Ensure minimum days between password changes is configured (Automated)
echo '#5.5.1.2 Ensure minimum days between password changes is configured (Automated)'
sed -i 's/PASS_MIN_DAYS 0/PASS_MIN_DAYS 1/g'  /etc/login.defs

grep ^\s*PASS_MIN_DAYS /etc/login.defs
grep -E ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1,4
#5.5.1.3 Ensure password expiration warning days is 7 or more (Automated)
echo '#5.5.1.3 Ensure password expiration warning days is 7 or more (Automated)'

grep ^\s*PASS_WARN_AGE /etc/login.defs
grep -E ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1,6
#5.5.1.4 Ensure inactive password lock is 30 days or less (Automated)
echo '#5.5.1.4 Ensure inactive password lock is 30 days or less (Automated)'
useradd -D -f 30

#5.5.1.5 Ensure all users last password change date is in the past(Automated)
echo '#5.5.1.5 Ensure all users last password change date is in the past(Automated)'
echo 'Run the following command and verify nothing is returned'
for usr in $(cut -d: -f1 /etc/shadow); do [[ $(chage --list $usr | grep '^Last password change' | cut -d: -f2) > $(date) ]] && echo "$usr :$(chage --list $usr | grep '^Last password change' | cut -d: -f2)"; done
#5.5.2 Ensure system accounts are secured (Automated)
echo '#5.5.2 Ensure system accounts are secured (Automated)'
#The following command will set all system accounts to a non login shell:
awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!="'"$(which nologin)"'" && $7!="/bin/false" && $7!="/usr/bin/false") {print $1}' /etc/passwd | while read -r user; do usermod -s "$(which nologin)" "$user"; done 
#The following command will automatically lock not root system accounts:
awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}' | while read -r user; do usermod -L "$user"; done
echo '5.5.2 Ensure system accounts are secured (Automated)'
awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!="'"$(which nologin)"'" && $7!="/bin/false") {print}' /etc/passwd
awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}'

#5.5.3 Ensure default group for the root account is GID 0 (Automated)
echo '#5.5.3 Ensure default group for the root account is GID 0 (Automated)'
usermod -g 0 root
grep "^root:" /etc/passwd | cut -f4 -d:
#5.5.4 Ensure default user shell timeout is configured (Automated)
echo '#5.5.4 Ensure default user shell timeout is configured (Automated)'
echo -e "\nResult:"; folder="/etc/profile"; standard="TMOUT=900"; check=`cat $folder | grep -v ^# | grep $standard`; if [[ -z $check ]]; then echo -e "TMOUT=900\nreadonly TMOUT\nexport TMOUT" >> $folder; echo -e "Inserted config:\n$standard"; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s~$check~#$check\n$standard~g" $folder; echo -e "Replaced config:\n$standard";fi; echo "";

#5.5.5 Ensure default user umask is configured (Automated)
echo '#5.5.5 Ensure default user umask is configured (Automated)'
sed -i 's/UMASK		022/UMASK		027/g' /etc/login.defs
sed -i 's/USERGROUPS_ENAB yes/USERGROUPS_ENAB no/g' /etc/login.defs
echo 'umask 027' >> /etc/profile.d/set_umask.sh
echo 'session optional pam_umask.so' >> /etc/pam.d/password-auth
echo 'session optional pam_umask.so' >> /etc/pam.d/system-auth
grep -RPi '(^|^[^#]*)\s*umask\s+([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b|[0-7][01][0-7]\b|[0-7][0-7][0-6]\b|(u=[rwx]{0,3},)?(g=[rwx]{0,3},)?o=[rwx]+\b|(u=[rwx]{1,3},)?g=[^rx]{1,3}(,o=[rwx]{0,3})?\b)' /etc/login.defs /etc/profile* /etc/bashrc*
grep UMASK /etc/login.defs

#5.6 Ensure root login is restricted to system console (Manual)
echo '#5.6 Ensure root login is restricted to system console (Manual)'
rm -rf  /etc/securetty
cat /etc/securetty
#5.7 Ensure access to the su command is restricted (Automated)
echo '#5.7 Ensure access to the su command is restricted (Automated)'
echo "Cau hinh chi cho phep user thuoc group wheel duoc phep su root"														
echo -e "\nResult:"; folder="/etc/pam.d/su"; standard=`echo -e "auth\trequired\tpam_wheel.so use_uid"`; check=`cat $folder | grep -v ^# | grep -w auth | grep -w required | grep -w "pam_wheel.so" | grep -w "use_uid"`; if [[ -z $check ]]; then comment=`cat $folder | grep "require a user to be"`; if [[ ! -z $comment ]]; then sed -i "s/$comment/$comment\n$standard/g" $folder; echo "Inserted config: $standard"; else echo "Nothing to do"; fi; elif [[ $check == $standard ]]; then echo "Nothing to do"; else sed -i "s/$check/#$check\n$standard/g" $folder; echo "Replaced config: $standard"; fi; echo "";
echo "NEXT CRITERIA";
grep wheel /etc/group

