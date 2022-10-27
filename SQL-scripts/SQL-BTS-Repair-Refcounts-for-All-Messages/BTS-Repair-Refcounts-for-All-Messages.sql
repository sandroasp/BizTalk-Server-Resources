/********************************************************************************************************************************
 * Repair Refcounts for All Messages                                                                                            *
 *                                                                                                                              *
 * WARNINGS                                                                                                                     *
 * - THIS OPERATION WILL PERMANENTLY REMOVE OR ALTER DATA IN YOUR DATABASE.                                                     *
 * - All BizTalk databases should be backed up, all host instances should be stopped, all BizTalk SQL Agent jobs should be      *
 *   stopped.                                                                                                                   * 
 *                                                                                                                              *
 * DESCRIPTION                                                                                                                  *
 *    This script rebuilds all the MessageRefCountLog tables and the MessageZeroSum table to resolve the                        *
 *    'Messages w/out RefCounts' issue that MessageBoxViewer identifies. While doing this, control messages are rebuilt if      *
 *    needed.                                                                                                                   * 
 *                                                                                                                              *
 * INSTRUCTIONS                                                                                                                 *
 * - RUN AGAINST THIS DB: BizTalkMsgBoxDB                                                                                       *
 * - SUPPORTED ON FOLLOWING VERSIONS OF BIZTALK: 2006, 2006 R2, 2009, 2010, 2013, 2013 R2,2016 and 2020                         *
 * - MULTI-MSGBOX SUPPORT: Supported. Run against individual messageboxes as needed.                                            *
 *                                                                                                                              *
 * RESULT                                                                                                                       *
 * - returns count of messages with negative refcounts                                                                          *
 *                                                                                                                              *
 ********************************************************************************************************************************/

SET NOCOUNT ON

DECLARE @nvcAppName nvarchar(256), @ret int
DECLARE curse CURSOR FOR 
SELECT nvcApplicationName FROM Applications

/********************************************************************************************************************************
* REPARE THE REFCOUNT LOG                                                                                                       *
* - first make sure that all biztalk services are stopped including SQL Agent which runs jobs which affect refcounting          *
* - then make sure you have a backup of the messagebox incase anything might happen so that you can restore it                  *
* - finally, lets truncate the refcount logs and reconstruct them from what is actually in the server                           *
 ********************************************************************************************************************************/
TRUNCATE TABLE MessageRefCountLog1
TRUNCATE TABLE MessageRefCountLog2
TRUNCATE TABLE MessageRefCountLogTotals
TRUNCATE TABLE MessageZeroSum

UPDATE ActiveRefCountLog SET tnActiveTable = 1 WHERE fType = 1

OPEN curse
FETCH NEXT FROM curse INTO @nvcAppName
WHILE (@@FETCH_STATUS = 0)
BEGIN 
	-- Truncate local application refcount log if it exists
	EXEC('if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[' + @nvcAppName + '_MessageRefCountLog]'') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) TRUNCATE TABLE [' + @nvcAppName + '_MessageRefCountLog]')           

	-- Find all the message refs which have no associated row in the spool
	EXEC ('INSERT INTO MessageRefCountLog1 (uidMessageID, snRefCount) SELECT uidMessageID, COUNT(*) FROM [' + @nvcAppName + 'Q] GROUP BY uidMessageID')
	EXEC ('INSERT INTO MessageRefCountLog1 (uidMessageID, snRefCount) SELECT uidMessageID, COUNT(*) FROM [' + @nvcAppName + 'Q_Suspended] GROUP BY uidMessageID')
	EXEC ('INSERT INTO MessageRefCountLog1 (uidMessageID, snRefCount) SELECT uidMessageID, COUNT(*) FROM [InstanceStateMessageReferences_' + @nvcAppName + '] GROUP BY uidMessageID')
                
                
	FETCH NEXT FROM curse INTO @nvcAppName
END
CLOSE curse
DEALLOCATE curse

INSERT INTO MessageRefCountLog1 (uidMessageID, snRefCount) 
SELECT uidMessageID, COUNT(*) 
FROM [TrackingMessageReferences] GROUP BY uidMessageID
                
-- Inserting restart message details, for service recovery
IF NOT EXISTS (SELECT TOP 1 uidMessageID FROM Spool WHERE uidMessageID = N'61EAA7FC-AC85-42d9-BF3E-1BED258B82BE')
BEGIN
	INSERT INTO Spool (uidMessageID, nNumParts, nCounter, imgContext) VALUES (N'61EAA7FC-AC85-42d9-BF3E-1BED258B82BE', 0, 0, 0xD4E0906C1849D311A24200C04F60A53302000000090000009800000050006100720074004E0061006D00650073005E0068007400740070003A002F002F0073006300680065006D00610073002E006D006900630072006F0073006F00660074002E0063006F006D002F00420069007A00540061006C006B002F0032003000300033002F006D006500730073006100670065006100670065006E0074002D00700072006F007000650072007400690065007300000001000000010820010000000000000000000700000098000000540069006D0065007200490044005E0068007400740070003A002F002F0073006300680065006D00610073002E006D006900630072006F0073006F00660074002E0063006F006D002F00420069007A00540061006C006B002F0032003000300033002F0078006C0061006E00670073002D00720075006E00740069006D0065002D00700072006F0070006500720074006900650073000000010000000008004A000000300030003000300030003000300030002D0030003000300030002D0030003000300030002D0030003000300030002D003000300030003000300030003000300030003000300030000000)
END

-- Inserting Suspend Control message
IF NOT EXISTS (SELECT TOP 1 uidMessageID FROM Spool WHERE uidMessageID = N'2BE3D5B8-5685-40F2-BD97-51ADA3D02347')
BEGIN
	INSERT INTO Spool (uidMessageID, nNumParts, nCounter, imgContext) VALUES (N'2BE3D5B8-5685-40F2-BD97-51ADA3D02347', 0, 0, 0xD4E0906C1849D311A24200C04F60A53303000000000000001E000000420069007A00540061006C006B0043006F006E00740072006F006C000000020000000008002A000000410064006D0069006E00530075007300700065006E00640049006E007300740061006E00630065000000000000000C0000004A006F006200490044000000020000000008004E0000007B00340037004100450033003300380034002D0031003000410041002D0034003400430033002D0038003200350036002D003200350033003400380045004200390032004200320031007D000000090000009800000050006100720074004E0061006D00650073005E0068007400740070003A002F002F0073006300680065006D00610073002E006D006900630072006F0073006F00660074002E0063006F006D002F00420069007A00540061006C006B002F0032003000300033002F006D006500730073006100670065006100670065006E0074002D00700072006F00700065007200740069006500730000000100000001082001000000000000000000)
END

-- Inserting  Terminate Control message
IF NOT EXISTS (SELECT TOP 1 uidMessageID FROM Spool WHERE uidMessageID = N'57E5E753-0207-435D-8BE7-2B9F3C6556F9')
BEGIN
	INSERT INTO Spool (uidMessageID, nNumParts, nCounter, imgContext) VALUES (N'57E5E753-0207-435D-8BE7-2B9F3C6556F9', 0, 0, 0xD4E0906C1849D311A24200C04F60A53303000000000000001E000000420069007A00540061006C006B0043006F006E00740072006F006C000000020000000008002E000000410064006D0069006E005400650072006D0069006E0061007400650049006E007300740061006E00630065000000000000000C0000004A006F006200490044000000020000000008004E0000007B00350032003500390031004600310031002D0046003700370034002D0034003600330038002D0042004300390041002D003200380034003800380034003600300034003500450032007D000000090000009800000050006100720074004E0061006D00650073005E0068007400740070003A002F002F0073006300680065006D00610073002E006D006900630072006F0073006F00660074002E0063006F006D002F00420069007A00540061006C006B002F0032003000300033002F006D006500730073006100670065006100670065006E0074002D00700072006F00700065007200740069006500730000000100000001082001000000000000000000)
END

-- Inserting Resume in Debug Mode message
IF NOT EXISTS (SELECT TOP 1 uidMessageID FROM Spool WHERE uidMessageID = N'50D173AF-5D6F-4D5F-AE23-1A7178CEBDC3')
BEGIN
	INSERT INTO Spool (uidMessageID, nNumParts, nCounter, imgContext) VALUES (N'50D173AF-5D6F-4D5F-AE23-1A7178CEBDC3', 0, 0, 0xD4E0906C1849D311A24200C04F60A53303000000000000001E000000420069007A00540061006C006B0043006F006E00740072006F006C0000000200000000080026000000410064006D0069006E004400650062007500670049006E007300740061006E00630065000000000000000C0000004A006F006200490044000000020000000008004E0000007B00330032003800330030004500450045002D0035004400330041002D0034003700370037002D0041003200440035002D003100320033004100450035004600340044004500420039007D000000090000009800000050006100720074004E0061006D00650073005E0068007400740070003A002F002F0073006300680065006D00610073002E006D006900630072006F0073006F00660074002E0063006F006D002F00420069007A00540061006C006B002F0032003000300033002F006D006500730073006100670065006100670065006E0074002D00700072006F00700065007200740069006500730000000100000001082001000000000000000000)                
END
--we need to add refcounts for the control messages in our system.

INSERT INTO MessageRefCountLogTotals (uidMessageID, snRefCount) VALUES (N'61EAA7FC-AC85-42d9-BF3E-1BED258B82BE', 1)
INSERT INTO MessageRefCountLogTotals (uidMessageID, snRefCount) VALUES (N'2BE3D5B8-5685-40F2-BD97-51ADA3D02347', 1)
INSERT INTO MessageRefCountLogTotals (uidMessageID, snRefCount) VALUES (N'57E5E753-0207-435D-8BE7-2B9F3C6556F9', 1)
INSERT INTO MessageRefCountLogTotals (uidMessageID, snRefCount) VALUES (N'50D173AF-5D6F-4D5F-AE23-1A7178CEBDC3', 1)

--lets run the stored procedure to process all of this and add up the values to put them in the totals table
EXEC int_PurgeMessageRefCountLog 1, @ret OUTPUT


--Now we have everything in the totals table (nothing is in the zero sum table since we only added references to messages
--currently in the messagebox. There were no releases (ie negative numbers)
--Lets populate the zerosum table with any messages in the spool which are not in the totals table
INSERT INTO MessageZeroSum (uidMessageID)
SELECT uidMessageID FROM Spool s WHERE s.uidMessageID NOT IN (SELECT uidMessageID FROM MessageRefCountLogTotals)

PRINT 'Done'
