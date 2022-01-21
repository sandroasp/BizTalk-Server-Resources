########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will allow you to change the user credentials of a specific Host Instance   #
#                                                                                                      #
########################################################################################################

$hostApp = gwmi -n 'root/MicrosoftBizTalkServer' -q 'select * from MSBTS_HostInstance where HostName="BiztalkDemoApplication"'
  
$hostApp.Install("DOMAIN\User", "password", "true")