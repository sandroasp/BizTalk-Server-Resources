-- ================================================
-- Shrink BizTalk Databases
-- Author: Sandro Pereira
-- Date: 05-02-2017
-- ================================================

-- ================================================
-- BizTalkMsgBoxDb
-- ================================================
USE BizTalkMsgBoxDb
GO

ALTER DATABASE BiztalkMsgBoxDb
SET RECOVERY SIMPLE;
GO
DBCC SHRINKFILE (BizTalkMsgBoxDb)
GO
DBCC SHRINKFILE (BizTalkMsgBoxDb_Log)
GO
ALTER DATABASE BiztalkMsgBoxDb
SET RECOVERY FULL
GO

-- ================================================
-- BizTalkDTADb
-- ================================================
USE BizTalkDTADb
GO

ALTER DATABASE BizTalkDTADb
SET RECOVERY SIMPLE;
GO
DBCC SHRINKFILE (BizTalkDTADb)
GO
DBCC SHRINKFILE (BizTalkDTADb_Log)
GO
ALTER DATABASE BizTalkDTADb
SET RECOVERY FULL
GO

-- ================================================
-- BizTalkMsgBoxDb
-- ================================================
USE BizTalkMsgBoxDb
GO

ALTER DATABASE BizTalkMsgBoxDb
SET RECOVERY SIMPLE;
GO
DBCC SHRINKFILE (BizTalkMsgBoxDb)
GO
DBCC SHRINKFILE (BizTalkMsgBoxDb_Log)
GO
ALTER DATABASE BizTalkMsgBoxDb
SET RECOVERY FULL
GO

-- ================================================
-- BAMPrimaryImport
-- ================================================
USE BAMPrimaryImport
GO

ALTER DATABASE BAMPrimaryImport
SET RECOVERY SIMPLE;
GO
DBCC SHRINKFILE (BAMPrimaryImport)
GO
DBCC SHRINKFILE (BAMPrimaryImport_Log)
GO
ALTER DATABASE BAMPrimaryImport
SET RECOVERY FULL
GO

-- ================================================
-- BAMArchive
-- ================================================
USE BAMArchive
GO

ALTER DATABASE BAMArchive
SET RECOVERY SIMPLE;
GO
DBCC SHRINKFILE (BAMArchive)
GO
DBCC SHRINKFILE (BAMArchive_Log)
GO
ALTER DATABASE BAMArchive
SET RECOVERY FULL
GO

-- ================================================
-- SSODB
-- ================================================
USE SSODB
GO

ALTER DATABASE SSODB
SET RECOVERY SIMPLE;
GO
DBCC SHRINKFILE (SSODB)
GO
DBCC SHRINKFILE (SSODB_Log)
GO
ALTER DATABASE SSODB
SET RECOVERY FULL
GO

-- ================================================
-- BizTalkRuleEngineDb
-- ================================================
USE BizTalkRuleEngineDb
GO

ALTER DATABASE BizTalkRuleEngineDb
SET RECOVERY SIMPLE;
GO
DBCC SHRINKFILE (BizTalkRuleEngineDb)
GO
DBCC SHRINKFILE (BizTalkRuleEngineDb_Log)
GO
ALTER DATABASE BizTalkRuleEngineDb
SET RECOVERY FULL
GO