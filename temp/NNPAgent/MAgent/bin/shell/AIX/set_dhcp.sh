function setup_dhcp
{
#
# Generate replacement text
#
STATE="NONE"
OUTPUT=""

for i in $*
do
        case "$STATE" in
                "NONE")
                        if [ "$i" = "interface" ]
                        then
                                STATE="interface"
                        elif [ "$i" = "when" ]
                        then
                                STATE="when"
                        elif [ "$i" = ":option" ]
                        then
                                STATE="option"
                        fi;;

                "when")
                        WHEN=$i
                        STATE="NONE";;

                "interface")
                        INTERFACE=$i
                        if [ "$OUTPUT" = "" ]
                        then
                                OUTPUT="interface $i\n{"
                        else
                                OUTPUT=$OUTPUT"\ninterface $i\n{"
                        fi
                        STATE="NONE";;

                "option")
                        NUM=$i
                        STRING=""
                        STATE="optionnum";;

                "optionnum")
                        if [ "$i" = ":option" ]
                        then
                                STATE="option"
                                if [ "$NUM" = "12" ] || [ "$NUM" = "14" ] ||
                                   [ "$NUM" = "15" ] || [ "$NUM" = "17" ] ||
                                   [ "$NUM" = "18" ] || [ "$NUM" = "40" ] ||
                                   [ "$NUM" = "43" ] || [ "$NUM" = "47" ] ||
                                   [ "$NUM" = "53" ] || [ "$NUM" = "56" ]
                                then
                                        if [ "$OUTPUT" = "" ]
                                        then
                                OUTPUT="        option $NUM \"$STRING\""
                                        else
                                OUTPUT=$OUTPUT"\n       option $NUM \"$STRING\""
                                        fi
                                else
                                        if [ "$OUTPUT" = "" ]
                                        then
                                OUTPUT="        option $NUM $STRING"
                                        else
                                OUTPUT=$OUTPUT"\n       option $NUM $STRING"
                                        fi
                                fi
                        else
                                if [ "$STRING" = "" ]
                                then
                                        STRING=$i
                                else
                                        STRING=$STRING" "$i
                                fi
                        fi;;
        esac
done

if [ "$STATE" = "optionnum" ]
then
        if [ "$NUM" = "12" ] || [ "$NUM" = "14" ] ||
           [ "$NUM" = "15" ] || [ "$NUM" = "17" ] ||
           [ "$NUM" = "18" ] || [ "$NUM" = "40" ] ||
           [ "$NUM" = "43" ] || [ "$NUM" = "47" ] ||
           [ "$NUM" = "53" ] || [ "$NUM" = "56" ]
        then
                if [ "$OUTPUT" = "" ]
                then
                        OUTPUT="        option $NUM \"$STRING\""
                else
                        OUTPUT=$OUTPUT"\n       option $NUM \"$STRING\""
                fi
        else
                if [ "$OUTPUT" = "" ]
                then
                        OUTPUT="        option $NUM $STRING"
                else
                        OUTPUT=$OUTPUT"\n       option $NUM $STRING"
                fi
        fi
fi

if [ "$OUTPUT" = "" ]
then
        continue
else
        OUTPUT=$OUTPUT"\n}\n"
fi

#
# Remove interface
#

EAT="0"

rm -f /tmp/dhcpcd.ini.$$

exec 3< /etc/dhcpcd.ini
while read -u3 -r line
do

if [ "$EAT" = "0" ] && [ "${line#interface }" != "$line" ]
then
        HERE=${line#*interface }
        WORKINGIF=${HERE%%( )+([a-zA-Z0-9 \t])*}
fi

if [ "$EAT" != 0 ] ||
   ([ "$WORKINGIF" != "" ] &&
    ([ "$INTERFACE" = "$WORKINGIF" ] || [ "$INTERFACE" = "any" ] ||
     ([ "$INTERFACE" != "any" ] && [ "$WORKINGIF" = "any" ])))
then
        if [ "$EAT" = "0" ]
        then
                EAT="1"
        elif [ "$EAT" = "1" ]
        then
                if [ "$line" = "{" ]
                then
                        EAT="2"
                else
                        EAT="0"
                        WORKINGIF=""
                        echo $line >> /tmp/dhcpcd.ini.$$
                fi
        elif [ "$EAT" = "2" ]
        then
                if [ "$line" = "}" ]
                then
                        EAT="0"
                        WORKINGIF=""
                fi
        fi
else
        echo $line >> /tmp/dhcpcd.ini.$$
fi

done
exec 3<&-

mv /etc/dhcpcd.ini /etc/dhcpcd.ini.bak
mv /tmp/dhcpcd.ini.$$ /etc/dhcpcd.ini

#
# Add interface back
#
echo $OUTPUT >> /etc/dhcpcd.ini

if [ "$WHEN" = "1" ]
then
        echo $WHEN > /dev/null
elif [ "$WHEN" = "2" ]
then
        startsrc -s dhcpcd
else
        if [ "$WHEN" = "3" ]
        then
                /usr/sbin/chrctcp -a dhcpcd
        else
                /usr/sbin/chrctcp -S -a dhcpcd
        fi
fi
}

stopsrc -s dhcpcd

EN_NAME="any"
if [ "$1" = "" ] then
    EN_NAME="any"
else
    EN_NAME="$1"
fi

#setup_dhcp interface 'any' when '4' :option 12 'localhost' :option 19 '0' :option 20 '0' :option 27 '0' :option 29 '0' :option 30 '0' :option 31 '0' :option 34 '0' :option 36 '0' :option 39 '0'
setup_dhcp interface '$EN_NAME' when '4' :option 12 'localhost' :option 19 '0' :option 20 '0' :option 27 '0' :option 29 '0' :option 30 '0' :option 31 '0' :option 34 '0' :option 36 '0' :option 39 '0'


