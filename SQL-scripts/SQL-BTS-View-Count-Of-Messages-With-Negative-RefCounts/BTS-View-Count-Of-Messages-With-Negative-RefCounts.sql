/********************************************************************************************************************************
 * View Count of Messages With Negative RefCounts                                                                               *
 *                                                                                                                              *
 * DESCRIPTION                                                                                                                  *
 *    This script returns the count of negative refcounts in the MessageRefCountLogTotals table. Once a refcount goes negative, *  
 *    the MsgBox cleanup jobs will not be able to clean up the corresponding message                                            * 
 *                                                                                                                              *
 * INSTRUCTIONS                                                                                                                 *
 * - RUN AGAINST THIS DB: BizTalkMsgBoxDB                                                                                       *
 * - SUPPORTED ON FOLLOWING VERSIONS OF BIZTALK: 2004, 2006, 2006 R2, 2009, 2010, 2013, 2013 R2,2016 and 2020                   *
 * - MULTI-MSGBOX SUPPORT: Supported. Run against individual messageboxes as needed.                                            *
 *                                                                                                                              *
 * RESULT                                                                                                                       *
 * - returns count of messages with negative refcounts                                                                          *
 *                                                                                                                              *
 ********************************************************************************************************************************/

DECLARE @count bigint
SET @count = 0

SELECT @count = COUNT(*) FROM [dbo].[MessageRefCountLogTotals] WHERE [snRefCount] < 0

IF @count = 0
BEGIN
    SELECT 'There are no negative RefCounts'
END
ELSE
BEGIN
    SELECT COUNT(*) Count, [snRefCount] as 'RefCount Value' 
	FROM [dbo].[MessageRefCountLogTotals] 
	WHERE [snRefCount] < 0
    GROUP BY [snRefCount] 
    ORDER BY [snRefCount] 
END
