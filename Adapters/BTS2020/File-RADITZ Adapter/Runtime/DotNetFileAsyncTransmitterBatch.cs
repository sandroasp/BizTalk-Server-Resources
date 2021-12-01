//---------------------------------------------------------------------
// File: DotNetFileAsyncTransmitterBatch.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
//
// Sample: Adapter framework runtime adapter.
//
//---------------------------------------------------------------------
// This file is part of the Microsoft BizTalk Server SDK
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// This source code is intended only as a supplement to Microsoft BizTalk
// Server release and/or on-line documentation. See these other
// materials for detailed information regarding Microsoft code samples.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
// KIND, WHETHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
// PURPOSE.
//---------------------------------------------------------------------

using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Collections;
using System.Threading;
using System.Runtime.InteropServices;

using Microsoft.BizTalk.TransportProxy.Interop;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Message.Interop;
using Microsoft.Samples.BizTalk.Adapter.Common;
using Microsoft.XLANGs.BaseTypes;


namespace Microsoft.BizTalk.SDKSamples.Adapters
{
    /// <summary>
    /// DotNetFileTransmitterEndpoint
    /// </summary>
	internal class DotNetFileAsyncTransmitterBatch : AsyncTransmitterBatch
	{
		public DotNetFileAsyncTransmitterBatch(int maxBatchSize, string propertyNamespace, IBTTransportProxy transportProxy, AsyncTransmitter asyncTransmitter)
			:
			base(maxBatchSize, propertyNamespace, transportProxy, asyncTransmitter)
		{
			base.createProperties = new ConfigProperties.CreateProperties(CreateProperties);
		}

		/// <summary>
		/// Implementation for IThreadpoolWorkItem.ProcessWorkItem where, the thread 
		/// pool will execute this method when we need to do work on the batch
		/// </summary>
		public override void ProcessWorkItem()
		{
			try
			{
				ArrayList messages = this.Messages;
				StandardTransmitBatchHandler btsBatch = new StandardTransmitBatchHandler(transportProxy, null);

				for (int c = 0; c < messages.Count; c++)
				{
					TransmitterMessage msg = (TransmitterMessage)messages[c];

					// Try to send the message, if successfull, Delete the message
					// from the AppQ
					if (TransmitMessage(msg))
					{
						btsBatch.DeleteMessage(msg.Message, null);
					}
					// If the send fails, Resubmit. Note, the batch handler
					// will handle the case where Resubmit fails
					else
					{
						btsBatch.Resubmit(msg.Message, null);
					}
				}

				try
				{
					btsBatch.Done(null);
				}
				catch (COMException e)
				{
					// If the BizTalk service is shutting done, drop this batch
					if (e.ErrorCode != BTTransportProxy.BTS_E_MESSAGING_SHUTTING_DOWN)
						throw e;
				}
			}
			catch (Exception)
			{
				// We should never get here, if we do it means messages will be 
				// left in the AppQ and not delivered. We should always handle 
				// any failures in Delete / Resubmit
				throw new DotNetFileException(DotNetFileException.UnhandledTransmit_Error);
			}
			finally
			{
				this.asyncTransmitter.Leave();
			}
		}

		/// <summary>
		/// Used to transmit an individual message. The message stream is read into 
		/// a buffer and written to disc. Note, we need to process the data in a 
		/// streaming fashion, since the strean we receive is most likely a forward- 
		/// only stream we have no idea how big it is. We therefore need to process
		/// it in a streaming fashion to avoid an out-of-memory (OOM) situation
		/// </summary>
		/// <param name="msg"></param>
		/// <returns></returns>
		private bool TransmitMessage(TransmitterMessage msg)
		{
			bool result = false;

			try
			{
				int numBytesRead = 0;
				Stream s = msg.Message.BodyPart.Data;

				// build url
				DotNetFileTransmitProperties props = (DotNetFileTransmitProperties)msg.Properties;
				string filePath = ConfigProperties.CreateFileName(msg.Message, props.Uri);

				byte[] buffer = new byte[DotNetFileTransmitProperties.BufferSize];

				// If we needed to use SSO to lookup the remote system credentials we will
				// need the following code.
				// Additionally:
				//   TransmitLocation.xsd in the design-time project must also be edited to
				//   expose the necessary SSO properties.
				//   DotNetFileProperties.cs within the run-time project must be edited 
				//	 to load these properties from the XML configuration.
				/*
	            string ssoAffiliateApplication = props.AffiliateApplication;
				if (ssoAffiliateApplication.Length > 0)
				{
					SSOResult ssoResult = new SSOResult(msg, affiliateApplication);
					string userName  = ssoResult.UserName;
					string password  = ssoResult.Result[0];
					string etcEtcEtc = ssoResult.Result[1]; // (you can have additional metadata associated with the login in SSO) 
						
					// use these credentials to login to the remote system
					// ideally zero off the password memory once we are done
				}					
				*/

				// Create the new file
				FileStream fs = new FileStream(filePath, props.FileMode);

				// Setup the stream writter and reader
				BinaryWriter w = new BinaryWriter(fs);
				w.BaseStream.Seek(0, SeekOrigin.End);

				if (s != null)
				{
					s.Seek(0, SeekOrigin.Begin);

					// Copy the data from the msg to the file
					int n = 0;
					do
					{
						n = s.Read(buffer, 0, DotNetFileTransmitProperties.BufferSize);

						if (n == 0) // We're at EOF
							break;

						w.Write(buffer, 0, n);
						numBytesRead += n;
					} while (n > 0);
				}

				w.Flush();
				w.Close();

				result = true;
			}
			catch (Exception e)
			{
				// If we failed, we need to set the exception on 
				// the message. BTS will include this exception in 
				// the event log message and also in HAT
				msg.Message.SetErrorInfo(e);
			}

			return result;
		}

		public ConfigProperties CreateProperties(string uri)
		{
			ConfigProperties properties = new DotNetFileTransmitProperties(uri);
			return properties;
		}
	}
}
