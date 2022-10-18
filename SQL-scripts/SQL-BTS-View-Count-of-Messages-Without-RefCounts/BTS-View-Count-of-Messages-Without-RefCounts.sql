/********************************************************************************************************************************
 * View Count of Messages Without RefCounts                                                                                     *
 *                                                                                                                              *
 * DESCRIPTION                                                                                                                  *
 *    This script returns the count of messages that don't have correlating rows in the MessageRefCountLog tables and the       *  
 *    MessageZeroSum table and should align with the 'Messages w/out RefCounts' issue that MessageBoxViewer identifies.         * 
 *                                                                                                                              *
 * INSTRUCTIONS                                                                                                                 *
 * - RUN AGAINST THIS DB: BizTalkMsgBoxDB                                                                                       *
 * - SUPPORTED ON FOLLOWING VERSIONS OF BIZTALK: 2006, 2006 R2, 2009, 2010, 2013, 2013 R2,2016 and 2020                         *
 * - MULTI-MSGBOX SUPPORT: Supported. Run against individual messageboxes as needed.                                            *
 *                                                                                                                              *
 * RESULT                                                                                                                       *
 * - returns count of messages without refcounts                                                                                *
 *                                                                                                                              *
 ********************************************************************************************************************************/


DECLARE @nvcAppName nvarchar(256)

CREATE TABLE ##msgs_wout_refs (uidMessageID uniqueidentifier NOT NULL)
CREATE UNIQUE CLUSTERED INDEX [CIX_msg_wout_refs] ON [##msgs_wout_refs](uidMessageID)

INSERT INTO ##msgs_wout_refs (uidMessageID)
SELECT uidMessageID FROM Spool WHERE uidMessageID NOT IN(SELECT uidMessageID FROM MessageRefCountLogTotals UNION
															SELECT uidMessageID FROM MessageRefCountLog1 UNION 
															SELECT uidMessageID FROM MessageRefCountLog2 UNION
															SELECT uidMessageID FROM MessageZeroSum
														 )

DECLARE hostcursor CURSOR FOR 
SELECT nvcApplicationName FROM Applications WITH (NOLOCK) 
OPEN hostcursor
	FETCH NEXT FROM hostcursor INTO @nvcAppName
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		EXEC ('DELETE FROM ##msgs_wout_refs FROM ##msgs_wout_refs m, [dbo].[' + @nvcAppName + '_MessageRefCountLog] r WHERE m.uidMessageID = r.uidMessageID')
	FETCH NEXT FROM hostcursor INTO @nvcAppName
	END
CLOSE hostcursor
DEALLOCATE hostcursor

DECLARE @count bigint
SET @count=0
SELECT @count = count(*) from ##msgs_wout_refs

SELECT 'Messages w/o Refcounts:  ' + cast (@count as nvarchar(10))

DROP TABLE ##msgs_wout_refs
