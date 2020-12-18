
##############################################################################################
# Script to extract a list of all Private Message Queuing (MSMQ) names to a CSV file.
#
# Author: Sandro Pereira
##############################################################################################

Get-MsmqQueue -QueueType Private | Select-Object Name, Transactional, UseJournalQueue | Export-Csv -Path c:\temp\queues.csv -Encoding ascii -NoTypeInformation