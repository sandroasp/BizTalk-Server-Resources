/*###############################################################################################################################
  # THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,                   #
  # INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.             #
  #    You can use, modify and redistribute this code in your product as per the Apache License, which governs this project.    #
  #                                                                                                                             #
  # Service Filter class.                                                                                                       #
  ###############################################################################################################################*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using System.Security.AccessControl;
using System.Security.Principal;

namespace BizTalkTerminatorUtil
{
    /// <summary>
    /// Service Filter Class that helps the Service to Filter a Service that it needs to act upon.
    /// </summary>
    public class ServiceFilter
    {
        public string ServiceClass { get; set; }

        public string ServiceStatus { get; set; }

        public string ErrorId { get; set; }

        public string Action { get; set; }

        public string SaveLocation { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="ServiceFilter"/> class.
        /// </summary>
        /// <param name="serviceClass">The service class.</param>
        /// <param name="serviceStatus">The service status.</param>
        /// <param name="errorId">The error id.</param>
        /// <param name="action">The action.</param>
        /// <param name="saveLocation">The save location.</param>
        public ServiceFilter(string serviceClass = Constants.Empty, string serviceStatus = Constants.Empty, string errorId = Constants.Empty, string action = "Terminate", string saveLocation=Constants.Empty)
        {
            // One of the [serviceClass, serviceStatus, errorId] is mandatory, if all 3 are missing then it is an error condition.
            if (string.IsNullOrWhiteSpace(serviceClass) && string.IsNullOrWhiteSpace(serviceStatus) && string.IsNullOrWhiteSpace(errorId))
            {
                throw new ArgumentException("Argument Exception: Supplied arguments are either null or empty.");
            }

            this.ServiceClass = serviceClass;
            this.ServiceStatus = serviceStatus;
            this.ErrorId = errorId;

            if (!string.IsNullOrWhiteSpace(action))
            {
                this.Action = action;
                // Action is specified.
                if (string.IsNullOrWhiteSpace(saveLocation) && (string.Compare(action, "SaveAndTerminate", true) == 0))
                {
                    this.Action = "Terminate";
                    throw new ArgumentException("Argument Exception: SaveLocation is missing or not well defined when action specified is [SaveAndTerminate]");
                }
                else
                {
                    this.Action = "Terminate";
                    if (!Directory.Exists(saveLocation))
                    {
                        // Dir does not exist, create it
                        try
                        {
                            Directory.CreateDirectory(saveLocation);
                        }
                        catch (UnauthorizedAccessException)
                        {                            
                            throw new ArgumentException("Argument Exception: Given SaveLocation is not accessible by the current service user.");
                        }
                        catch (Exception)
                        {                            
                            throw new ArgumentException("Argument Exception: Given SaveLocation is not accessible by the current service user.");
                        }
                    }
                    else if (!HasAccessToWrite(saveLocation))
                    {                        
                        throw new ArgumentException("Argument Exception: Given SaveLocation is not writable by the current service user.");
                    }
                    else
                    {
                        // Finally all pre-requisites are met (I guess)
                        this.SaveLocation = saveLocation;
                        this.Action = "SaveAndTerminate";
                    }
                }
            }
            else
            {
                this.Action = "Terminate";
            }
        }

        /// <summary>
        /// Determines whether [has access to write] [the specified path].
        /// </summary>
        /// <param name="path">The path.</param>
        /// <returns>
        ///   <c>true</c> if [has access to write] [the specified path]; otherwise, <c>false</c>.
        /// </returns>
        private bool HasAccessToWrite(string path)
        {
            try
            {
                using (FileStream fs = File.Create(Path.Combine(path, "Access.txt"), 1, 
                        FileOptions.DeleteOnClose))
                {
                }
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Determines whether [has folder write permission] [the specified dest dir].
        /// </summary>
        /// <param name="destDir">The dest dir.</param>
        /// <returns>
        ///   <c>true</c> if [has folder write permission] [the specified dest dir]; otherwise, <c>false</c>.
        /// </returns>
        private bool HasFolderWritePermission(string destDir)
        {
            if (string.IsNullOrEmpty(destDir) || !Directory.Exists(destDir)) return false;
            try
            {
                DirectorySecurity security = Directory.GetAccessControl(destDir);
                SecurityIdentifier users = new SecurityIdentifier(WellKnownSidType.BuiltinUsersSid, null);
                foreach (AuthorizationRule rule in security.GetAccessRules(true, true, typeof(SecurityIdentifier)))
                {
                    if (rule.IdentityReference == users)
                    {
                        FileSystemAccessRule rights = ((FileSystemAccessRule)rule);
                        if (rights.AccessControlType == AccessControlType.Allow)
                        {
                            if (rights.FileSystemRights == (rights.FileSystemRights | FileSystemRights.Modify)) return true;
                        }
                    }
                }
                return false;
            }
            catch
            {
                return false;
            }
        }
    }
}
