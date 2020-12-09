'RemoveAdapter.vbs
'Removes adapter from BizTalk

strAdapterName = "LogicApp"
RemoveAdapter strAdapterName
Sub RemoveAdapter(strAdapterName)
    Set objLocator = CreateObject("WbemScripting.SWbemLocator")
    Set objService = objLocator.ConnectServer("localhost", "root/MicrosoftBizTalkServer")
    On Error Resume Next
    Set objAdapterInstance = objService.Get("MSBTS_AdapterSetting.Name='" & strAdapterName & "'")
    If (objAdapterInstance is Nothing) Then
        On Error Goto 0
        Wscript.Echo "No existing logicApp adapter to remove: " & strAdapterName
        return 2
    Else
        On Error Resume Next
        objService.Delete("MSBTS_AdapterSetting.Name='" & strAdapterName & "'")
        If (Err.Number <> 0) Then
            Wscript.Echo "Warning: Please remove all ports which are using LogicApp adapter. Error Code: " & Hex(Err.Number) & " Error Description: " & Err.Description
            return 2
        End If
        On Error Goto 0
    End If

End Sub