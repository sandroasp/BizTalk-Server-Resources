/*###############################################################################################################################
  # THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,                   #
  # INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.             #
  #    You can use, modify and redistribute this code in your product as per the Apache License, which governs this project.    #
  #                                                                                                                             #
  # Constants class.                                                                                                            #
  ###############################################################################################################################*/

using System;
using System.Threading.Tasks;

namespace BizTalkTerminatorUtil
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Various project level constants are held in this class.
    /// </summary>
    public static class Constants
    {
        /// <summary>
        /// 
        /// </summary>
        public const string Empty = "";

        #region ParallelOptions
        public static readonly int IdealThreadsPerProcessor = 4;
        public static readonly int ConcurrencyLevel = Environment.ProcessorCount * IdealThreadsPerProcessor;
        public static readonly ParallelOptions ConcurrencyOption = new ParallelOptions
        {
            MaxDegreeOfParallelism = ConcurrencyLevel,
            TaskScheduler = TaskScheduler.Current
        };
        #endregion

        #region QueryStrings        
        /// <summary>
        /// Only ServiceClass is provided
        /// </summary>
        public const string ServiceInstanceServiceClassQuery = "SELECT * FROM MSBTS_ServiceInstance WHERE ServiceClass={0}";

        /// <summary>
        /// Only ServiceStatus is provided
        /// </summary>
        public const string ServiceInstanceServiceStatusQuery = "SELECT * FROM MSBTS_ServiceInstance WHERE ServiceStatus={0}";

        /// <summary>
        /// Only ErrorId (or ErrorCode) is provided
        /// </summary>
        public const string ServiceInstanceErrorIdQuery = "SELECT * FROM MSBTS_ServiceInstance WHERE ErrorId='{2}'";

        /// <summary>
        /// ServiceClass and ServiceStatus is provided
        /// </summary>
        public const string ServiceInstanceServiceClassAndStatusQuery = "SELECT * FROM MSBTS_ServiceInstance WHERE ServiceClass={0} and ServiceStatus={1}";

        /// <summary>
        /// ServiceClass and ErrorId (or ErrorCode) is provided
        /// </summary>
        public const string ServiceInstanceServiceClassAndErrorQuery = "SELECT * FROM MSBTS_ServiceInstance WHERE ServiceClass={0} and ErrorId={1}";

        /// <summary>
        /// ServiceStatus and ErrorId (or ErrorCode) is provided
        /// </summary>        
        public const string ServiceInstanceServiceStatusAndErrorQuery = "SELECT * FROM MSBTS_ServiceInstance WHERE ServiceStatus={0} and ErrorId={1}";

        /// <summary>
        /// ServiceClass, ServiceStatus and ErrorId (or ErrorCode) is provided
        /// </summary>
        public const string ServiceInstanceAllQuery = "SELECT * FROM MSBTS_ServiceInstance WHERE ServiceClass={0} and ServiceStatus={1} and ErrorId='{2}'";
        #endregion
    }
}
