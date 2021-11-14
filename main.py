import os
from time import sleep
import re
import subprocess
import configparser
config = configparser.ConfigParser()
pwd=os.getcwd()
from datetime import datetime
datumHeute = datetime.date(datetime.now()).strftime("%Y%m%d")

if (os.path.isfile(pwd+"/config.ini")):
    config.read(pwd+'/config.ini')
    dlDir = config['CHECKER']['downloaddir']

else:
    print("ERROR: NO CONFIG FILE! Exiting...")
    logWriter = open (pwd+"/logs/"+datumHeute+"_checker.log", "a+")
    logWriter.write(datetime.time(datetime.now()).strftime("[%H:%M:%S]")+" [ERROR] - Started without config File, please rename TEMPLATEconfig.txt to config.txt and fill the parameters.\n")
    logWriter.close()
    quit()

if (os.path.isfile(pwd+"/check_batch.txt")):
    logWriter = open (pwd+"/logs/"+datumHeute+"_checker.log", "a+")
    logWriter.write(datetime.time(datetime.now()).strftime("[%H:%M:%S]")+" [INFO] - Process started\n")
    logWriter.close()
    with open(pwd+"/check_batch.txt") as check_batch:
        for line in check_batch:
            videoIDedit = re.search("(\?v=)(.*)", str(line))
            videoID = videoIDedit.group(2)
            print("Hier line: "+line.rstrip())
            ytdlpCall = subprocess.Popen("yt-dlp -F --cookies /opt/archiving/cookies/ytcookies.txt "+line.rstrip()+" | perl -ne '/(https \| vp9)/ && print'", shell=True, stdout=subprocess.PIPE, close_fds=True, universal_newlines=True)
            ytdlpCall_return = ytdlpCall.communicate()[0]
            print(ytdlpCall_return)
            if (ytdlpCall_return != ""):
                linkWriteAdd = open (dlDir+"/batch.txt", "a+")
                linkWriteAdd.write(line)
                linkWriteAdd.close()

                logWriter = open (pwd+"/logs/"+datumHeute+"_checker.log", "a+")
                logWriter.write(datetime.time(datetime.now()).strftime("[%H:%M:%S]")+" [INFO] - Video ID ["+videoID+"] converted, adding to downloader and removing queue...\n")
                logWriter.close()
            else:
                linkWriteRequeue = open (pwd+"/next_queue.txt", "a+")
                linkWriteRequeue.write(line)
                linkWriteRequeue.close()
                
                logWriter = open (pwd+"/logs/"+datumHeute+"_checker.log", "a+")
                logWriter.write(datetime.time(datetime.now()).strftime("[%H:%M:%S]")+" [INFO] - Video ID ["+videoID+"] not converted yet, keeping in queue...\n")
                logWriter.close()
    os.replace(pwd+"/next_queue.txt", pwd+"/check_batch.txt")
    logWriter = open (pwd+"/logs/"+datumHeute+"_checker.log", "a+")
    logWriter.write(datetime.time(datetime.now()).strftime("[%H:%M:%S]")+" [INFO] - Run finished, closing...\n")
    logWriter.close()
else:
    logWriter = open (pwd+"/logs/"+datumHeute+"_checker.log", "a+")
    logWriter.write(datetime.time(datetime.now()).strftime("[%H:%M:%S]")+" [ERROR] - No check_batch.txt present, closing...\n")
    logWriter.close()
    quit()
