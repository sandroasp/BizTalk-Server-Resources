#=== Name of the Enterprise Single Sign-On Service. ===#
$ENTSSOServiceName = 'ENTSSO'

#=== Change the startup type for BizTalk services to Automatic (Delayed Start) ===#
get-service BTSSvc* | foreach-object -process { SC.EXE config $_.Name start= delayed-auto}

#=== Change the startup type for Enterprise Single Sign-On Service to Automatic (Delayed Start) ===#
SC.EXE config $ENTSSOServiceName start= delayed-auto

