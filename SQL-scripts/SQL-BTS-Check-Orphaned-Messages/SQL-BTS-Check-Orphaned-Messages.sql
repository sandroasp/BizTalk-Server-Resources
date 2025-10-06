-- =================================================================================================================
-- Author:		Sandro Pereira
-- Create date: 2026/10/06
-- Description:	SQL Server Query that checks if exists Orphaned Messages in your BizTalk Server environement
-- =================================================================================================================

USE [biztalkDTADb]

SELECT * FROM [dbo].[dta_ServiceInstances]
WHERE dtEndTime is NULL AND 
	  [uidServiceInstanceId] NOT IN(SELECT [uidInstanceID]
									  FROM BizTalkMsgBoxDb.[dbo].[Instances] WITH (NOLOCK) 
									  UNION SELECT [StreamID]
									  FROM BizTalkMsgBoxDb.[dbo].[TrackingData] WITH (NOLOCK))