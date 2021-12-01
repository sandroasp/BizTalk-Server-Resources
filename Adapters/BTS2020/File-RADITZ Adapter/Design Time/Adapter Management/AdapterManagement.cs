//---------------------------------------------------------------------
// File: AdapterManagement.cs
// 
// Summary: Implementation of adapter framework interfaces for sample
// adapters.
//
// Sample: Adapter framework adapter.
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
using System.Reflection;
using System.Resources;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using Microsoft.Win32;
using Microsoft.BizTalk.Component.Interop;
using Microsoft.BizTalk.Adapter.Framework;

namespace Microsoft.BizTalk.SDKSamples.Adapters.Designtime 
{
    
    /// <summary>
    /// Description: 
    /// Class DynamicAdapterManagement implements
    /// IAdapterConfig and IDynamicAdapterConfig interfaces for
    /// management to illustrate a dynamic adapter that uses the
    /// adapter framework.
    /// </summary>
    public class DynamicAdapterManagement : IAdapterConfig, IDynamicAdapterConfig 
	{
        
		private static ResourceManager resourceManager = new ResourceManager("Microsoft.BizTalk.SDKSamples.Adapters.DotNetFile.Designtime.DotNetFileResource", Assembly.GetExecutingAssembly());

		/// <summary>
        /// Returns the configuration schema as a string.
        /// (Implements IAdapterConfig)
        /// </summary>
        /// <param name="type">Configuration schema to return</param>
        /// <returns>Selected xsd schema as a string</returns>
        public string GetConfigSchema(ConfigType type) 
		{
            switch (type) 
			{
				case ConfigType.ReceiveHandler:
					return LocalizeSchema(GetResource("AdapterManagement.ReceiveHandler.xsd"), resourceManager);

				case ConfigType.ReceiveLocation:
					return LocalizeSchema(GetResource("AdapterManagement.ReceiveLocation.xsd"), resourceManager);

				case ConfigType.TransmitHandler:
					return LocalizeSchema(GetResource("AdapterManagement.TransmitHandler.xsd"), resourceManager);

				case ConfigType.TransmitLocation:
					return LocalizeSchema(GetResource("AdapterManagement.TransmitLocation.xsd"), resourceManager);

				default:
					return null;
            }
        }

		protected string LocalizeSchema (string schema, ResourceManager resourceManager)
		{
			XmlDocument document = new XmlDocument();
			document.LoadXml(schema);

			XmlNodeList nodes = document.SelectNodes("/descendant::*[@_locID]");
			foreach (XmlNode node in nodes)
			{
				string locID = node.Attributes["_locID"].Value;
				node.InnerText = resourceManager.GetString(locID);
			}

			StringWriter writer = new StringWriter();
			document.WriteTo(new XmlTextWriter(writer));

			string localizedSchema = writer.ToString();
			return localizedSchema;
		}

		/// <summary>
        /// Get the WSDL file name for the selected WSDL
        /// </summary>
        /// <param name="wsdls">place holder</param>
        /// <returns>An empty string[]</returns>
        public string [] GetServiceDescription(string [] wsdls) 
		{
            string []result = null;
            return result;
        }

        /// <summary>
        /// Acquire externally referenced xsd's.
        /// </summary>
        /// <param name="xsdLocation">Location of schema</param>
        /// <param name="xsdNamespace">Namespace</param>
        /// <param name="XSDFileName">Schmea file name (return)</param>
        /// <returns>Outcome of acquisition</returns>
        public Result GetSchema( string xsdLocation, string xsdNamespace, out string xsdSchema) 
		{
            xsdSchema = null;
            return Result.Continue;
        }

        /// <summary>
        /// Acquire wsdl(s) from which to build the user interface
        /// </summary>
        /// <param name="endPointConfiguration"></param>
        /// <param name="owner"></param>
        /// <param name="WSDLList">Array of custom UI's WSDL (returned)</param>
        /// <returns></returns>
        public Result DisplayUI(IPropertyBag endPointConfiguration, 
            IWin32Window owner,
            out string [] WSDLList) 
		{
            WSDLList = new string[1];
            WSDLList[0] = GetResource("AdapterManagement.service1.wsdl");
            return Result.Continue;
        }

        /// <summary>
        /// Helper to get resource from manafest.  Replace with ResourceManager.GetString if .resources or
        /// .resx files are used for managing this assemblies resources.
        /// </summary>
        /// <param name="resource">Full resource name</param>
        /// <returns>Resource value</returns>
        private string GetResource(string resource) 
		{
            string value = null;
            if (null != resource) 
			{
                Stream stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resource);
                StreamReader reader = null;
                using (reader = new StreamReader(stream)) 
				{
                    value = reader.ReadToEnd();
                }
            }

            return value;
        }
    }

    /// <summary>
    /// Class StaticAdapterManagement implements
    /// IAdapterConfig and IStaticAdapterConfig interfaces for
    /// management to illustrate a static adapter that uses the
    /// adapter framework
    /// </summary>
    public class StaticAdapterManagement : IAdapterConfig, IStaticAdapterConfig, IAdapterConfigValidation 
	{
		private static ResourceManager resourceManager = new ResourceManager("AdapterManagement.DotNetFileResource", Assembly.GetExecutingAssembly());
																																				  
		
		protected string LocalizeSchema (string schema, ResourceManager resourceManager)
		{
			XmlDocument document = new XmlDocument();
			document.LoadXml(schema);

			XmlNodeList nodes = document.SelectNodes("/descendant::*[@_locID]");
			foreach (XmlNode node in nodes)
			{
				string locID = node.Attributes["_locID"].Value;
				node.InnerText = resourceManager.GetString(locID);
			}

			StringWriter writer = new StringWriter();
			document.WriteTo(new XmlTextWriter(writer));

			string localizedSchema = writer.ToString();
			return localizedSchema;
		}

		/// <summary>
        /// Returns the configuration schema as a string.
        /// (Implements IAdapterConfig)
        /// </summary>
        /// <param name="type">Configuration schema to return</param>
        /// <returns>Selected xsd schema as a string</returns>
        public string GetConfigSchema(ConfigType type) 
		{
            switch (type) 
			{
				case ConfigType.ReceiveHandler:
					return LocalizeSchema(GetResource("AdapterManagement.ReceiveHandler.xsd"), resourceManager);

				case ConfigType.ReceiveLocation:
					return LocalizeSchema(GetResource("AdapterManagement.ReceiveLocation.xsd"), resourceManager);
	            
				case ConfigType.TransmitHandler:
					return LocalizeSchema(GetResource("AdapterManagement.TransmitHandler.xsd"), resourceManager);

				case ConfigType.TransmitLocation:
					return LocalizeSchema(GetResource("AdapterManagement.TransmitLocation.xsd"), resourceManager);

				default:
					return null;
            }
        }

        /// <summary>
        /// Get the WSDL file name for the selected WSDL
        /// </summary>
        /// <param name="wsdls">place holder</param>
        /// <returns>An empty string[]</returns>
        public string[] GetServiceDescription(string[] wsdls) 
		{
            string[] result = new string[1];
            result[0] = GetResource("AdapterManagement.service1.wsdl");
            return result;
        }

        /// <summary>
        /// Gets the XML instance of TreeView that needs to be rendered
        /// </summary>
        /// <param name="endPointConfiguration"></param>
        /// <param name="NodeIdentifier"></param>
        /// <returns>Location of TreeView xml instance</returns>
        public string GetServiceOrganization(IPropertyBag endPointConfiguration,
                                             string NodeIdentifier) 
		{
            string result = GetResource("AdapterManagement.CategorySchema.xml");
            return result;
        }

        
        /// <summary>
        /// Acquire externally referenced xsd's
        /// </summary>
        /// <param name="xsdLocation">Location of schema</param>
        /// <param name="xsdNamespace">Namespace</param>
        /// <param name="XSDFileName">Schmea file name (return)</param>
        /// <returns>Outcome of acquisition</returns>
        public Result GetSchema(string xsdLocation,
                                string xsdNamespace,
								out string xsdSchema) 
		{
            xsdSchema = null;
            return Result.Continue;
        }

        /// <summary>
        /// Validate xmlInstance against configuration.  In this example it does nothing.
        /// </summary>
        /// <param name="type">Type of port or location being configured</param>
        /// <param name="xmlInstance">Instance value to be validated</param>
        /// <returns>Validated configuration.</returns>
        public string ValidateConfiguration(ConfigType configType,
            string xmlInstance) 
		{
            string validXml = String.Empty;

            switch (configType) 
			{
				case ConfigType.ReceiveHandler:
					validXml = xmlInstance; 
					break;

				case ConfigType.ReceiveLocation:
					validXml = ValidateReceiveLocation(xmlInstance); 
					break;

				case ConfigType.TransmitHandler:
					validXml = xmlInstance; 
					break;

				case ConfigType.TransmitLocation:
					validXml = ValidateTransmitLocation(xmlInstance); 
					break;
            }

            return validXml;
        }

        /// <summary>
        /// Helper to get resource from manafest.  Replace with 
        /// ResourceManager.GetString if .resources or
        /// .resx files are used for managing this assemblies resources.
        /// </summary>
        /// <param name="resource">Full resource name</param>
        /// <returns>Resource value</returns>
        private string GetResource(string resource) 
		{
            string value = null;
            if (null != resource) 
			{
				Assembly assem = this.GetType().Assembly;
				Stream stream = assem.GetManifestResourceStream(resource);
				StreamReader reader = null;

                using (reader = new StreamReader(stream)) 
				{
                    value = reader.ReadToEnd();
                }
            }

            return value;
        }

		/// <summary>
		/// Generate uri entry based on directory and fileMask values
		/// </summary>
		/// <param name="type">Type of port or location being configured</param>
		/// <param name="xmlInstance">Instance value to be validated</param>
		/// <returns>Validated configuration.</returns>
		private string ValidateReceiveLocation(string xmlInstance) 
		{
			// Load up document
			XmlDocument document = new XmlDocument();
			document.LoadXml(xmlInstance);
            
			// Build up inner text
			StringBuilder builder = new StringBuilder();
            
			XmlNode directory = document.SelectSingleNode("Config/directory");
			if (null != directory && 0 < directory.InnerText.Length) 
			{
				builder.Append(directory.InnerText + @"\");
			}

			XmlNode fileMask  = document.SelectSingleNode("Config/fileMask");
			if (null != fileMask && 0 < fileMask.InnerText.Length) 
			{
				builder.Append(fileMask.InnerText);
			}

			XmlNode uri = document.SelectSingleNode("Config/uri");
			if (null == uri) 
			{
				uri = document.CreateElement("uri");
				document.DocumentElement.AppendChild(uri);
			}

			uri.InnerText = builder.ToString();
                           
			return document.OuterXml;
		}

        /// <summary>
        /// Generate uri entry based on directory and fileName values
        /// </summary>
        /// <param name="type">Type of port or location being configured</param>
        /// <param name="xmlInstance">Instance value to be validated</param>
        /// <returns>Validated configuration.</returns>
        private string ValidateTransmitLocation(string xmlInstance) 
		{
            // Load up document
            XmlDocument document = new XmlDocument();
            document.LoadXml(xmlInstance);
            
            // Build up inner text
            StringBuilder builder = new StringBuilder();
            
            XmlNode directory = document.SelectSingleNode("Config/directory");
            if (null != directory && 0 < directory.InnerText.Length) 
			{
                builder.Append(directory.InnerText + @"\");
            }

            XmlNode filename  = document.SelectSingleNode("Config/fileName");
            if (null != filename && 0 < filename.InnerText.Length) 
			{
                builder.Append(filename.InnerText);
            }

            XmlNode uri = document.SelectSingleNode("Config/uri");
            if (null == uri) 
			{
                uri = document.CreateElement("uri");
                document.DocumentElement.AppendChild(uri);
            }
            uri.InnerText = builder.ToString();
                           
            return document.OuterXml;
        }

	} 
}
