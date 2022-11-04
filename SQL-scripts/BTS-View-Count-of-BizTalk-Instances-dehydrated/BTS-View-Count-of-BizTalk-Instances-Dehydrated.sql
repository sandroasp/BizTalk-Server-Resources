/********************************************************************************************************************************
 * View Count of BizTalk Instances Dehydrated                                                                                   *
 *                                                                                                                              *
 * DESCRIPTION                                                                                                                  *
 *    This script returns count of instance Dehydrated                                                                          * 
 *                                                                                                                              *
 * INSTRUCTIONS                                                                                                                 *
 * - RUN AGAINST THIS DB: BizTalkMsgBoxDB                                                                                       *
 * - SUPPORTED ON FOLLOWING VERSIONS OF BIZTALK: 2006, 2006 R2, 2009, 2010, 2013, 2013 R2,2016 and 2020                         *
 *                                                                                                                              *
 * RESULT                                                                                                                       *
 * - returns count of instances Dehydrated                                                                                      *
 *                                                                                                                              *
 ********************************************************************************************************************************/

USE BizTalkMsgBoxDb;
SELECT COUNT(nstate) Dehydrated 
FROM Instances WITH (NOLOCK)
WHERE nstate = 8

