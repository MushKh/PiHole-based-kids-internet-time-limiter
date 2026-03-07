#!/usr/bin/env python3
import os
import sys
import requests
import datetime
import time
import subprocess
import logging
from datetime import date 

# New version of Time Limiter 
# Pi-Hole Time Limiter script v2.0
# Adjusted to work with PiHole Lua language. Removed redundant parts of the code.

PARAM_FILE = "/var/www/html/admin/myserver/Parameters.txt"
CHECK_INTERVAL = 20  # seconds

previous_usage = 0
remaining_seconds = 0

today = datetime.datetime.now().strftime("%d, %m, %Y")
log_filename = "/var/www/html/admin/myserver/Limiter_log" + today + ".html"

#Disabling the group will enable the Internet and vice versa
comm_DisGroup = "/var/www/html/admin/myserver/./setGroupStatus.sh Kids_Group disable"
comm_EnGroup = "/var/www/html/admin/myserver/./setGroupStatus.sh Kids_Group enable"
UpdateGravity = "/var/www/html/admin/myserver/./UpdateGrav.sh"

def restart_script():
    python = sys.executable
    os.execl(python, python, *sys.argv)

def reset_usage_minutes():
    try:
        with open(PARAM_FILE, "w") as f:
            f.write("0\n")   # reset to 0 minutes
        print("Parameters.txt reset to 0")
        logging.info(" <br><br><br> Script restarted. Allowed time was reset to 0 <br>")        
    except Exception as e:
        print(f"Error resetting Parameters.txt: {e}")
        
def read_usage_minutes():
    try:
        with open(PARAM_FILE, "r") as f:
            line = f.readline().strip()

            if not line:
                return 0   # file empty → treat as 0

            value = int(line)
            return value

    except Exception as e:
        print(f"Error reading file: {e}")
        return None


def EnableGroup():
    try:
        result = subprocess.run(comm_EnGroup, shell=True, capture_output=True, text=True)
        result = subprocess.run(UpdateGravity, shell=True, capture_output=True, text=True)        
        #print("Enable command executed")
    except Exception as e:
        print(f"Error executing enable script: {e}")


def DisableGroup():
    try:
        #Then disable group to start counting time
        result = subprocess.run(comm_DisGroup, shell=True, capture_output=True, text=True)
        result = subprocess.run(UpdateGravity, shell=True, capture_output=True, text=True)
        #print("Disable command executed")
    except Exception as e:
        print(f"Error executing disable script: {e}")
        
def format_seconds(seconds):
    hours, remainder = divmod(seconds, 3600)
    minutes, secs = divmod(remainder, 60)
    return f"{int(hours):02d}:{int(minutes):02d}:{int(secs):02d}"
    
def main():
    global previous_usage, remaining_seconds

    print("Usage monitor started")

    previous_usage = read_usage_minutes() or 0
    group_disabled = False   # tracks current state
    
    # Reset file at startup
    reset_usage_minutes()  
    
    # Track current day
    today = date.today()    
    
    while True:

        current_usage = read_usage_minutes()
        if current_usage is None:
            continue

        # If increased → extend countdown
        if current_usage > previous_usage:
            diff_minutes = current_usage - previous_usage
            added_seconds = diff_minutes * 60

            # If timer was not running before → disable once
            if remaining_seconds <= 0 and not group_disabled:
                print("Starting countdown.")
                print("Disabling group.")
                logging.info("DNS Service Enabled <br>")
                DisableGroup()
                group_disabled = True

            remaining_seconds += added_seconds
            print(f"Added {diff_minutes} minutes. Remaining: {remaining_seconds//60} minutes")
            logging.info("Added Min: %d <br>", diff_minutes)
        previous_usage = current_usage

        # Decrease remaining time
        if remaining_seconds > 0:
            remaining_seconds -= CHECK_INTERVAL
            print("Time Left: ",format_seconds(remaining_seconds))
            if remaining_seconds <= 0:
                remaining_seconds = 0
                if group_disabled:
                    print("Time expired. Enabling group.")
                    logging.info("DNS Service Disabled <br>")                    
                    EnableGroup()
                    group_disabled = False
                    
        # Check daily restart
        current_day = date.today()
        if current_day != today:
            print("New day detected. Restarting script.")
            restart_script()

        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, filename=log_filename, filemode="a+", format="%(asctime)-15s %(levelname)-8s %(message)s")
    logging.info("<!DOCTYPE HTML><html><head><title>Usage log</title><link rel='stylesheet' type='text/css' href='home.css'><meta charset='UTF-8'></head><body>")    
    try:
        main()
    except Exception as e:
        print(f"Fatal error: {e}")
        time.sleep(5)
        
