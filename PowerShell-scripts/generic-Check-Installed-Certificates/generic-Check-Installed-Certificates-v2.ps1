########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira & José Anónio Silva                                                           #
#                                                                                                      #
# Description: This script will get information were a specific certificated is installed              #
#                                                                                                      #
########################################################################################################

gci cert:\* -Recurse | ?{$_.Thumbprint -eq "5693ae76acfe33325bd6e1f05f38a9941892cb69"} | select PSParentPath