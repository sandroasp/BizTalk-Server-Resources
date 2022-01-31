
//---------------------------------------------------------------------
// File: LogHelper.cs
// 
// Summary: Helper class to log things to the event log.
//
// Sample: Void Adapter
//---------------------------------------------------------------------

using System;
using System.Diagnostics;

namespace Microsoft.BizTalk.Void.Adapter
{
    /// <summary>
    /// Helper class to log things to the event log.
    /// </summary>
    internal class LogHelper
    {
        const string LOGSOURCE = "Void Adapter";
        const int MSGDISCAREDID = 1010;

        /// <summary>
        /// Log a message discarded event to the event log
        /// </summary>
        /// <param name="msgID">Message ID</param>
        /// <param name="interchangeID">Interchange ID</param>
        /// <param name="msgData">Message content</param>
        public static void RegisterLogEntry(Guid msgID, string interchangeID, string msgData)
        {
            string entry =
                  "The following message has been discarded: " +
                  "\r\n\r\n" +
                  "MessageID: {0}\r\n" +
                  "InterchangeID: {0}\r\n" +
                  "Message Body:\r\n{1}\r\n";
            entry = string.Format(entry, msgID, interchangeID, msgData);

            EventLog.WriteEntry(LOGSOURCE, entry, EventLogEntryType.Information, MSGDISCAREDID);
        }

        #region EventSource Management

        /// <summary>
        /// Creates the event source
        /// </summary>
        public static void CreateEventSource()
        {
            if (!EventLog.SourceExists(LOGSOURCE))
            {
                EventLog.CreateEventSource(LOGSOURCE, "CustomAdapters");
            }
        }

        /// <summary>
        /// Deletes the event source
        /// </summary>
        public static void DeleteEventSource()
        {
            if (EventLog.SourceExists(LOGSOURCE))
            {
                EventLog.DeleteEventSource(LOGSOURCE);
            }
        }

        #endregion
    }
}