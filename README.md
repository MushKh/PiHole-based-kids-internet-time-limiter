Installation procedure.

1. Assuming that you have Ph-Hole v6 (Lua script based) installed on Raspberry Pi and have access to it thru SSH.
For easy access to all Ph-Hole folders and files it's best to have WinSCP installed.
It need to connect to Rpi with SSH (Enable SSH from Rpi).
Also there will be needed to download and install putty for command-line access.
Also Pi-Hole IP need to be configured in local Modem/Router as primary DNS server.
I also disable secondary DNS server in router to avoid bypassing Pi-Hole.

3. Create directory /var/www/html/admin/myserver. 
Copy HiHole_V6_Mode folder content to that directory.

4. In Pi-Hole under /var/www/html/admin/  modify  index.lp page.
5. Remove original page and using ssh copy index.lp modified file from "myserver" folder to that folder. 
This will add "Allowed time" and "Times Log" additional fields to Pi-Hole Dashboard.
By doing this we realize that in case of Pi-Hole updates related to this page these fileds will be removed.

6. Set executable priviledges to following files.
	NewTimeLimiter.py, setGroupStatus.sh, UpdateGrav.sh
	To do that run commands below.

        sudo chmod +x NewTimeLimiter.py
        sudo chmod +x setGroupStatus.sh
        sudo chmod +x UpdateGrav.sh	
	Owner of whole myserver directory shall be "pihole" so run these commands too.
	
		sudo chown -R pihole:pihole /var/www/html/admin/myserver
		sudo chmod 775 /var/www/html/admin/myserver

7. Configring Pi-Hole
   
	A) Using Pi-Hole web interface open Groups page and create "Kids_Group" in it.

	B) Using Pi-Hole web interface open Clients page then in field "Add a new client" add your kid phone and/or PC MAC
        addresses.
        Using MAC address identification here seems to work more reliable that using IP address, because IP may change time to
        time.
   
	C) After seeing kids MAC addresses in "List of configured clients" on same page add them to both "Default" and
        "Kids_Group". For other IP that must not be affected by this scripts leave to just "Default" group.
   
	D) Go to Domains page.
	    Add in "RegEx:"  .* then click Add to Blacklist. This will blacklist all web-pages for kid except pages in next
        instruction.
	    Add in "RegEx:" field all web pages that must not be affected by this script for the kid. 
	    For example .*outlook.* Add to Whitelist.
   
	E) Under "List of domains" on the same page for appropriate pages choose "Kids_Group".
	
    These Whitelist and Blacklist paged will be working only when "Kids_Group" in Groups will be enabled. Enabling or
    Disabling this group is happening from NewTimeLimiter.py script. But is also can be tested/verified manually from ssh
    by running these bash script
    
    	sudo setGroupStatus.sh Kids_Group disable
    	sudo setGroupStatus.sh Kids_Group enable
    
    F) For Pi-Hole reliable IP/MACs identification in Logs Pi-Hole must be set as DHCP server. 
	    Go to Settings->DHCP page and set "Enable DHCP" tickbox. 
	    Also do not forget to disable DHCP server functionality in your Modem/Router to avoid conflict.

8. Do not forget to change default Pi-Hole password from "Raspberry" to something else. Kids are mostly smarter that we
   think.

9. Configure Rpi to start NewTimeLimiter.py script at start-up. This can be don by several methods. This one is also
10. working well. 
	in putty or any other command line interface for Rpi run

    	sudo nano /etc/rc.local
	add this line at the end of file

    	python3 /var/www/html/myserver/NewTimeLimiter.py &
	Then Ctl+O, Ctr+X
	
PS. Script written such a way that it will restart itself at 12PM. 
This will reset current time limit calculation. All changes to times i.e. 
Start times and Stop times are written in Log files. 
Log files can be reviewed by clicking "List Logs" on Pi-Hole Dashboard.

PPS. Some Debug tips.
Make sure sqlite3 installed. 

    sudo apt install sqlite3

If setGroupStatus.sh or other bash files cannot be found in ssh when trying to execute them, 
then most probably it was edited in Windows. 
To fix run this command first.

    sed -i 's/\r//g' setGroupStatus.sh
