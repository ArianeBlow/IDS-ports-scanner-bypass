#!/bin/bash
banner()
{
echo "                ..........................."                 
echo "             ................................."              
echo "           ..............         .............."            
echo "         ................          ..............."          
echo "        ................           ................"         
echo "      ..................            ................."       
echo "     ................................................."      
echo "    ..................               .................."     
echo "   .................                   ................."    
echo "  .....................      .      ....................."   
echo "  ....................      ...      ...................."   
echo " ......................    .....    ......................"  
echo " ........................................................."  
echo "..........................................................." 
echo "..........................................................." 
echo ".......................  .........  ......................." 
echo ".......................    .....    ......................." 
echo "......................    .......    ......................"
echo "................        ...........        ................" 
echo "............            ....   ....            ............" 
echo "...........            .....   .....            ..........." 
echo "...........           .......  ......           ..........." 
echo "...........            .....   .....            ..........." 
echo " ...........            ....   :...     ..     ..........."  
echo "  ..........             ..     ..             .........."   
echo "  ..........              .     ..             .........."   
echo "   ..........                                 .........."    
echo "    .........     IPS / IDS scann fucker      ........."     
echo "     .........              By               ........."      
echo "      ........          Ariane.Blow          ........"
echo "        .......                             ........"
echo "         ......        When security         ......"       
echo "           .....  is blocking nmap probs     ....."         
echo "             ................................."
}
help()
{
echo ""
echo "[-] you must provide a vlan as first argument and the time sleep time between every request in the second arg."
echo "    Exemple : script.sh 192.168.1 9"
echo ""
echo "    Ports can be modified in line 75"
echo ""
exit
}
$1
$2
#CLEAN OLD SESSIONS
rm /tmp/hosts_up_DCs.txt
rm /tmp/hosts_up_smb.txt
clear
banner
if [ -z "$*" ]; then
    help
fi
if [ -z "$2" ]; then
    help
fi
if [ $1 == help ]; then
    help
fi
clear
echo ""
echo "[*] testing vlan $1.0/24, available hosts gonna be printed on the terminal ... Wait ..."
echo ""
for hosts in $(seq 1 254); do
    if ping -c 1 -W 1 $1.$hosts &> /dev/null; then
        sleep $2
        echo "[+] $1.$hosts" && echo $1.$hosts >> hostsUP.list
    fi
done
echo "[+] IPs of UP hosts saved in /tmp/hosts_up.dat : "
cat hostsUP.list >> /tmp/hosts_up.dat
echo ""
echo "[+] hosts scan's over"
echo ""
echo "[-] starting port scan"
for port in 135 445 636 389 80 443 8080 8089 8081 22 21 23; do
    for i in $(cat hostsUP.list); do
        clear
        banner
        echo ""
        echo "$i $port"
        sleep $2
        timeout 1 bash -c "echo >/dev/tcp/$i/$port" && echo port $port is open on host $i >> res.txt
    done
done
cat res.txt | grep 445 | cut -d " " -f 7 >> /tmp/hosts_up_smb.txt
clear
banner
echo ""
cat res.txt | sort -u
echo ""
echo "[+] IPs of UP hosts with active SMB saved in /tmp/hosts_up_smb.txt (perfect for crackmapexec scan...)"
echo ""
cat /tmp/hosts_up_smb.txt
egrep "636|389" res.txt >> /tmp/hosts_up_DCs.txt
echo ""
echo "[+] IPs of UP hosts with ports 636 and 389 (DCs suspected) saved in /tmp/hosts_up_DCs.txt (perfect for impacket tests)"
echo ""
cat /tmp/hosts_up_DCs.txt
rm hostsUP.list
rm res.txt
