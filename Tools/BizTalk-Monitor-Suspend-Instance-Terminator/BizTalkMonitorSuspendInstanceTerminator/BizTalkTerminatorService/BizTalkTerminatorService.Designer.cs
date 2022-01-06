// -----------------------------------------------------------------------
// <copyright file="BizTalkTerminatorService.cs" company="Ready4Operations Pvt Ltd">
//   Copyright (c) Ready4Operations Pvt Ltd. All rights reserved. THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
//   You can use, modify and redistribute this code in your product as per the Apache License, which governs this project.
// </copyright>
// <date>2013-03-06</date>
// <summary>BizTalk Terminator Service Class</summary>
//-----------------------------------------------------------------------

namespace BizTalkTerminatorService
{
    partial class BizTalkTerminatorService
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.bizTalkTerminatorEventLog = new System.Diagnostics.EventLog();
            ((System.ComponentModel.ISupportInitialize)(this.bizTalkTerminatorEventLog)).BeginInit();
            // 
            // bizTalkTerminatorEventLog
            // 
            this.bizTalkTerminatorEventLog.Log = "Application";
            this.bizTalkTerminatorEventLog.Source = "BTSTerminator";
            // 
            // BizTalkTerminatorService
            // 
            this.ServiceName = "BTSTerminator";
            ((System.ComponentModel.ISupportInitialize)(this.bizTalkTerminatorEventLog)).EndInit();

        }

        #endregion

        private System.Diagnostics.EventLog bizTalkTerminatorEventLog;
    }
}
