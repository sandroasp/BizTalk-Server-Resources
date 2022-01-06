/*###############################################################################################################################
  # THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,                   #
  # INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.             #
  #    You can use, modify and redistribute this code in your product as per the Apache License, which governs this project.    #
  #                                                                                                                             #
  # Database Filter KeyCollection Class                                                                                         #
  ###############################################################################################################################*/

using System;
using System.Configuration;

namespace BizTalkTerminatorService
{
    /// <summary>
    /// Class that keeps the database filters as a key collection and reads its value from
    /// custom app.config file.
    /// </summary>
    [ConfigurationCollection(typeof(FilterElement))]
    public class DbFilterKeyCollection : ConfigurationElementCollection
    {
        /// <summary>
        /// When overridden in a derived class, creates a new <see cref="T:System.Configuration.ConfigurationElement"/>.
        /// </summary>
        /// <returns>
        /// A new <see cref="T:System.Configuration.ConfigurationElement"/>.
        /// </returns>
        protected override ConfigurationElement CreateNewElement()
        {
            return new FilterElement();
        }

        /// <summary>
        /// Gets the element key for a specified configuration element when overridden in a derived class.
        /// </summary>
        /// <param name="element">The <see cref="T:System.Configuration.ConfigurationElement"/> to return the key for.</param>
        /// <returns>
        /// An <see cref="T:System.Object"/> that acts as the key for the specified <see cref="T:System.Configuration.ConfigurationElement"/>.
        /// </returns>
        protected override object GetElementKey(ConfigurationElement element)
        {
            return ((FilterElement)(element)).Key;
        }

        /// <summary>
        /// Gets or sets a property, attribute, or child element of this configuration element.
        /// </summary>
        /// <returns>The specified property, attribute, or child element</returns>
        ///   
        /// <exception cref="T:System.Configuration.ConfigurationErrorsException">
        ///   <paramref name="prop"/> is read-only or locked.</exception>
        public FilterElement this[int idx]
        {
            get
            {
                return (FilterElement)BaseGet(idx);
            }
        }

        /// <summary>
        /// Gets or sets a property, attribute, or child element of this configuration element.
        /// </summary>
        /// <returns>The specified property, attribute, or child element</returns>
        ///   
        /// <exception cref="T:System.Configuration.ConfigurationErrorsException">
        ///   <paramref name="prop"/> is read-only or locked.</exception>
        new public FilterElement this[string keyname]
        {
            get
            {
                return (FilterElement)BaseGet(keyname);
            }
        }
    }
}
