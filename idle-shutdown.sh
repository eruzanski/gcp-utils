#!/bin/bash

# Summary:
# This script continually monitors the instances for inactivity due to low/no processor usage for a specified number of minutes.

# Instructions:
# 1. Copy this script to the /opt/deeplearning/bin directory on the target instance (note that this is the suggested target directory but this script can be placed into any directory) 
# 2. Add this script to the instance's metadata
#  a. Click on the name of the instance from the Vertex AI or Compute Engine console
#  b. Click VIEW VM DETAILS
#  c. Click EDIT
#  d. Scroll to the bottom of the page and enter the path and filename of this script on the field titled "Startup script"
#  e. Click the blue button at the bottom of the page labeled SAVE
# 3. Return to the Vertex AI Workbench
# 4. Click on OPEN JUPYTERLAB next to the target instance name
# 5. Follow File -> New -> Terminal
# 6. Run `cd /opt/deeplearning/bin` (or the appropriate path if different from /opt/deeplearning/bin)
# 7. Open an editor (e.g., `sudo vi idle-shutdown.sh`) 
# 8. Change the values assigned to the `threshold` and/or `wait_minutes` variables, save the changes and exit the editor 
# 9. Execute `sudo chmod 755 idle-shutdown.sh`
# 10. Execute `sudo apt-get install bc`
# 11. Execute `sudo reboot`
#
# The target instance will now shutdown if the level of inactivity defined by `threshold` if maintained over the entire duration defined by `wait_minutes`. The progress can be seen in the instance's log by clicking on the instance then LOGS. 
#
# References:
# 1. Google Cloud Platform (GCP) instance idle shutdown (https://gist.github.com/justinshenk/312b5e0ab7acc3b116f7bf3b6d888fa4)
# 2. How to Auto Shutdown An Idle VM Instance on GCP to Cut Fat Bills (https://medium.com/analytics-vidhya/how-to-auto-shutdown-an-idle-vm-instance-on-gcp-to-cut-fat-bills-b08ae20437af)
# 3. How can I automatically kill idle GCE instances based on CPU usage? (https://stackoverflow.com/questions/30556920/how-can-i-automatically-kill-idle-gce-instances-based-on-cpu-usage)

##### EDIT THESE VALUES BELOW #####
# `threshold` is the percentage of processor usage defining activity/idling 
threshold=0.05

# `wait_minutes` is the number of minutes defining the period of inactivity
wait_minutes=120

##### DO NOT EDIT BELOW THIS LINE #####
echo "Starting idle shutdown script..."
count=0
while true
do
	load=$(uptime | sed -e 's/.*load average: //g' | awk '{ print $1 }') # 1-minute average load
	load="${load//,}" # remove trailing comma
	load_flag=$(echo $load'<'$threshold | bc -l)
	
	if (( $load_flag ))
	then
		echo "Idling CPU..."
		(( count+=1 ))
	else
		count=0
	fi
	echo "Idle minutes count = $count"
	
	if (( count>wait_minutes ))
	then
		echo "Shutting down due to inactivity..."
		sleep 60
		sudo poweroff
	fi
	
	sleep 60
done
