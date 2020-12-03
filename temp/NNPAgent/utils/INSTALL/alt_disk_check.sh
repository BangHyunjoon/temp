#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

ALT_DSK_CHK=0
CHK_CNT=0

CMD=`rm -f /tmp/alt_disk_check.log`
CMD=`date > /tmp/alt_disk_check.log`
CMD=`lspv | grep rootvg | grep active > /tmp/lspv_old.out`
while [ "$ALT_DSK_CHK" = "0" ]
do
    let "CHK_CNT = $CHK_CNT + 1"
    CMD=`echo "check...[$CHK_CNT]" >> /tmp/alt_disk_check.log`

    CMD=`cfgmgr`
    CMD=`lspv > /tmp/lspv.out`
    ALT_DSK_NAME=`diff /tmp/lspv_old.out  /tmp/lspv.out | grep hdisk | cut -d' ' -f2`
    if [ ! "$ALT_DSK_NAME" = "" ] ; then
        CMD=`echo "found alt disk...[$ALT_DSK_NAME]" >> /tmp/alt_disk_check.log`

        CMD=`cat /etc/rc | grep -v "^exit " | grep -v rc.atcp > /etc/rc_`
        CMD=`rm -f /etc/rc`
        CMD=`mv /etc/rc_ /etc/rc`
        CMD=`echo "/etc/rc.dhcp2" >> /etc/rc`
        CMD=`echo "exit 0" >> /etc/rc`

        CMD=`cp -f /NCIA/POLESTAR/NNPAgent/utils/INSTALL/rc.atcp* /etc/`
        CMD=`cp -f /NCIA/POLESTAR/NNPAgent/MAgent/bin/shell/AIX/rc.dhcp* /etc/`
        CMD=`chmod +x /etc/rc`
        CMD=`chmod +x /etc/rc.actp*`
        CMD=`chmod +x /etc/rc.dhcp*`

        CMD=`cd /NCIA/POLESTAR/;./vagentinstall.sh`

        CMD=`rmdev -dl ent0`
        CMD=`rmdev -dl et0`
        CMD=`rmdev -dl en0`
        CMD=`rmdev -dl ent1`
        CMD=`rmdev -dl et1`
        CMD=`rmdev -dl en1`
        CMD=`rmdev -dl ent2`
        CMD=`rmdev -dl et2`
        CMD=`rmdev -dl en2`
#        CMD=`echo "interface en0" >> /etc/dhcpcd.ini`
#        CMD=`echo "{" >> /etc/dhcpcd.ini"
#        CMD=`echo " option 19 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 20 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 27 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 29 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 30 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 31 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 34 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 36 0" >> /etc/dhcpcd.ini`
#        CMD=`echo " option 39 0" >> /etc/dhcpcd.ini`
#        CMD=`echo "}" >> /etc/dhcpcd.ini`

        CMD=`echo "alt_disk_copy -d $ALT_DSK_NAME" >> /tmp/alt_disk_check.log`
        CMD=`alt_disk_copy -d $ALT_DSK_NAME >> /tmp/alt_disk_check.log 2>&1;echo "alt_disk_copy complat[$?]" >> /tmp/alt_disk_check.log`

        CMD=`echo "alt_disk_install -X altinst_rootvg" >> /tmp/alt_disk_check.log`
        CMD=`alt_disk_install -X altinst_rootvg >> /tmp/alt_disk_check.log 2>&1;echo "altinst_rootvg remove[$?]" >> /tmp/alt_disk_check.log`

        CMD=`echo "rmdev -dl $ALT_DSK_NAME" >> /tmp/alt_disk_check.log`
        CMD=`rmdev -dl $ALT_DSK_NAME >> /tmp/alt_disk_check.log 2>&1`

        CMD=`cat /etc/rc | grep -v "^exit " | grep -v "rc.dhcp" | grep -v "nomni" > /etc/rc_`
        CMD=`mv /etc/rc_ /etc/rc`
        CMD=`echo "/etc/rc.atcp2" >> /etc/rc`
        CMD=`echo "exit 0" >> /etc/rc`
        CMD=`cp -f /NCIA/POLESTAR/NNPAgent/utils/INSTALL/rc.atcp* /etc/`
        CMD=`chmod +x /etc/rc`

        CMD=`du -k / >> /tmp/du.dat`

        CMD=`echo "shutdown -hv" >> /tmp/alt_disk_check.log`
        CMD=`shutdown -hv >> /tmp/alt_disk_check.log 2>&1`
    else
        CMD=`echo "not found alt disk..." >> /tmp/alt_disk_check.log`
    fi

    sleep 10
done

