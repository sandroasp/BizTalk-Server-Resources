/********************************************************************************************************************************
 * View Count of BizTalk Instances Suspended Resumable                                                                          *
 *                                                                                                                              *
 * DESCRIPTION                                                                                                                  *
 *    This script returns count of instance Suspended Resumable                                                                 * 
 *                                                                                                                              *
 * INSTRUCTIONS                                                                                                                 *
 * - RUN AGAINST THIS DB: BizTalkMsgBoxDB                                                                                       *
 * - SUPPORTED ON FOLLOWING VERSIONS OF BIZTALK: 2006, 2006 R2, 2009, 2010, 2013, 2013 R2,2016 and 2020                         *
 *                                                                                                                              *
 * RESULT                                                                                                                       *
 * - returns count of instances Suspended Resumable                                                                             *
 *                                                                                                                              *
 ********************************************************************************************************************************/

USE BizTalkMsgBoxDb;
SELECT COUNT(nstate) SuspendedResumable  
FROM Instances WITH (NOLOCK)
WHERE nstate = 4

