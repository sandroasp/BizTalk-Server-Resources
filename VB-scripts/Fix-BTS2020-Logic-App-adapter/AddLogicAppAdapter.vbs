'AddAdapter.vbs
'Adds adapter to BizTalk

strAdapterName = "LogicApp"
strAdapterComment = "Adapter for communicating with Logic Apps."
strAdapterMgmtCLSID = "{EC50860C-24CB-4934-BE2E-1694093B721F}"
AddAdapter strAdapterName, strAdapterComment, strAdapterMgmtCLSID

Sub AddAdapter(strAdapterName, strAdapterComment, strAdapterMgmtCLSID)
    Set objLocator = CreateObject("WbemScripting.SWbemLocator")
    Set objService = objLocator.ConnectServer("localhost", "root/MicrosoftBizTalkServer")
    Set objAdapterClass = objService.Get("MSBTS_AdapterSetting")
    On Error Resume Next
    Set objAdapterInstance = objService.Get("MSBTS_AdapterSetting.Name='" & strAdapterName & "'")
    If (objAdapterInstance is Nothing) Then
        On Error Goto 0
        Set objAdapterInstance = objAdapterClass.SpawnInstance_
    Else
        On Error Goto 0
    End If

    objAdapterInstance.Name = strAdapterName
    objAdapterInstance.Comment = strAdapterComment
    objAdapterInstance.MgmtCLSID = strAdapterMgmtCLSID

    On Error Resume Next
    objAdapterInstance.Put_(0) 'Flags: 0 = wbemChangeFlagCreateOrUpdate, 2 = wbemChangeFlagCreateOnly
    If (Err.Number <> 0) Then
        Wscript.Echo "Failed to add adapter."
	    Wscript.Echo "Error " & Hex(Err.Number) & ": " & Err.Description
    End If
    On Error Goto 0

End Sub