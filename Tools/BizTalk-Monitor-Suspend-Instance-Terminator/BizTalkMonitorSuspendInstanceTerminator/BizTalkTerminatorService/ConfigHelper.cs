/*###############################################################################################################################
  # THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,                   #
  # INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.             #
  #    You can use, modify and redistribute this code in your product as per the Apache License, which governs this project.    #
  #                                                                                                                             #
  # Configuration Helper Class                                                                                                  #
  ###############################################################################################################################*/
using System;
using System.Configuration;

namespace BizTalkTerminatorService
{
    /// <summary>
    /// Configuration Helper Class reads the Configuration Section into a Object 
    /// of collection of Db Hash Keys and Service Hash Keys.
    /// </summary>
    public class ConfigurationHelper : ConfigurationSection
    {
        /// <summary>
        /// Gets the db hash keys.
        /// </summary>
        [ConfigurationProperty("DatabaseFilter")]
        public DbFilterKeyCollection DbHashKeys
        {
            get 
            {
                DbFilterKeyCollection dbFilters = (DbFilterKeyCollection)base["DatabaseFilter"];
                return dbFilters;
            }
        }

        /// <summary>
        /// Gets the service hash keys.
        /// </summary>
        [ConfigurationProperty("ServiceFilter")]
        public ServiceFilterKeyCollection ServiceHashKeys
        {
            get 
            {
                ServiceFilterKeyCollection serviceFilters = (ServiceFilterKeyCollection)base["ServiceFilter"];
                return serviceFilters;
            }
        }
    }
}
