########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will restart all BizTalk Server services installed on the machine.          #
#                                                                                                      #
########################################################################################################

get-service BTS* | foreach-object -process {restart-service $_.Name}