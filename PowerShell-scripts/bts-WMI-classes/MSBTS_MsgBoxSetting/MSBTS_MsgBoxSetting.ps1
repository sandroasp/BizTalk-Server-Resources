########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_MsgBoxSetting WMI Class.                                               #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

$BizTalkMsgBoxDb = Get-WmiObject MSBTS_MsgBoxSetting -namespace root\MicrosoftBizTalkServer -ErrorAction Stop

Write-Host "SQL Server Name: " $BizTalkMsgBoxDb.MsgBoxDBServerName
Write-Host "BizTalk MessageBox Database: " $BizTalkMsgBoxDb.MsgBoxDBName