########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: After rebooting the operating system BizTalk Server services can fails to               #
# start automatically. This is a Microsoft known Issues with BizTalk Runtime forcing us to manually    #
# start the services. To fix this we should manually configure the Startup type of these services to   #
# Automatic (Delayed Start)..                                                                          #
# This script will automatically go thru all BizTalk Server services installed on the machine and      #
# set up the Startup type to Automatic (Delayed Start).                                                #
#                                                                                                      #
########################################################################################################

get-service BTSSvc* | foreach-object -process { SC.EXE config $_.Name start= delayed-auto}