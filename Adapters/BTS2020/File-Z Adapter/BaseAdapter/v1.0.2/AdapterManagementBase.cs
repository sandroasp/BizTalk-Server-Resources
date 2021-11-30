//---------------------------------------------------------------------
// File: AdapterManagementBase.cs
// 
// Summary: Implementation of an adapter framework sample adapter. 
// This class constitutes one of the BaseAdapter classes, which, are
// a set of generic re-usable set of classes to help adapter writers.
//
// Sample: Base Adapter Class Library v1.0.2
//
// Description: TODO:
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
using System.Resources;
using System.Reflection;
using Microsoft.Win32;

namespace Microsoft.Samples.BizTalk.Adapter.Common
{
	public class AdapterManagementBase
	{
		//  implementation - access schema buried in resources

		protected string GetSchemaFromResource (string name)
		{
			Assembly assem = this.GetType().Assembly;
            using (Stream stream = assem.GetManifestResourceStream(name))
            {
                using (StreamReader reader = new StreamReader(stream))
                {
                    string schema = reader.ReadToEnd();
                    return schema;
                }
            }
		}

		protected XmlDocument LocalizeSchemaDOM (string schema, ResourceManager resourceManager)
		{
			XmlDocument document = new XmlDocument();
			document.LoadXml(schema);

			XmlNodeList nodes = document.SelectNodes("/descendant::*[@_locID]");
			foreach (XmlNode node in nodes)
			{
				string locID = node.Attributes["_locID"].Value;
				node.InnerText = resourceManager.GetString(locID);
			}

			return document;
		}

		protected string MakeString (XmlDocument document)
		{
            using (StringWriter writer = new StringWriter())
            {
                document.WriteTo(new XmlTextWriter(writer));
                return writer.ToString();
            }
		}

		protected string LocalizeSchema (string schema, ResourceManager resourceManager)
		{
			return MakeString(LocalizeSchemaDOM(schema, resourceManager));
		}

		protected XmlDocument AddPathToEditorAssembly (XmlDocument document, string assemblyPath)
		{
			XmlNamespaceManager nsmgr = new XmlNamespaceManager(new NameTable());
			nsmgr.AddNamespace("baf", "BiztalkAdapterFramework.xsd");

			//  add editor and converter elements that have an assembly attribute
			string xpath = "/descendant::baf:editor[@assembly] | /descendant::baf:converter[@assembly]";

			XmlNodeList nodes = document.SelectNodes(xpath, nsmgr);
			foreach (XmlNode node in nodes)
			{
				XmlAttribute attribute = node.Attributes["assembly"];
				attribute.Value = assemblyPath + attribute.Value;
			}

			return document;
		}

		//  useful debug code
		protected string GetSchemaFromFile (string name)
		{
            using (RegistryKey bts30 = Registry.LocalMachine.OpenSubKey("SOFTWARE\\Microsoft\\BizTalk Server\\3.0"))
            {
                string installPath = (string)bts30.GetValue("InstallPath");
                string productLanguage = (string)bts30.GetValue("ProductLanguage");
                string fullName = installPath + productLanguage + "\\" + name;

                using (StreamReader reader = new StreamReader(fullName))
                {
                    string schema = reader.ReadToEnd();
                    return schema;
                }
            }
		}
	}
}