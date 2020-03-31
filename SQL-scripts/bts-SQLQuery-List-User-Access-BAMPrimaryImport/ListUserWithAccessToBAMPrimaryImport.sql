USE BAMPrimaryImport
GO
Select Name,SID,SUser_SName(SID) as UserAccount from sysusers
WHERE ISLogin = 1 AND issqluser = 0 AND isntuser = 1
