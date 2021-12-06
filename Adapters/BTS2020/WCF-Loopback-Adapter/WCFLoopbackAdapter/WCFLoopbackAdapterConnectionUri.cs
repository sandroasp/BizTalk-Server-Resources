using System;
using System.ComponentModel;
using Microsoft.ServiceModel.Channels.Common;
using System.Diagnostics;

namespace Microsoft.BizTalk.WCFLoopback
{
    public class WCFLoopbackAdapterConnectionUri : ConnectionUri
    {
        #region Private Fields

        private UriBuilder _uriBuilder;

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the ConnectionUri class
        /// </summary>
        public WCFLoopbackAdapterConnectionUri()
        {
            Initialize(null);
        }

        /// <summary>
        /// Initializes a new instance of the ConnectionUri class with a given Uri
        /// </summary>
        /// <param name="uri"></param>
        public WCFLoopbackAdapterConnectionUri(Uri uri)
            : base()
        {
            Initialize(uri);
        }

        /// <summary>
        /// Initialize with the default value;
        /// </summary>
        /// <param name="uri"></param>
        public void Initialize(Uri uri)
        {
            if (uri != null)
                this._uriBuilder = new UriBuilder(uri);
            else
                this._uriBuilder = new UriBuilder();
            this._uriBuilder.Scheme = WCFLoopbackAdapter.SCHEME;
            // this needs to be set, otherwise it defaults to localhost
            this._uriBuilder.Host = "";
        }

        #endregion

        #region Properties Custom Generated 

        /// <summary>
        /// This function is responsible for constructing a
        /// URI from the properties in this object.
        /// </summary>
        /// <returns></returns>
        public Uri BuildUri()
        {
            // Build a Uri from respective properties in
            // the connection uri object
            this._uriBuilder.Scheme = WCFLoopbackAdapter.SCHEME;
            this._uriBuilder.Host = "";
            this._uriBuilder.Path = "";
            
            // Return the composed uri
            return _uriBuilder.Uri;
        }

        /// <summary>
        /// This function is responsible for parsing a passed
        /// in URI and place the value in the respective properties
        /// if the URI is valid.
        /// 
        /// Precondition: Uri has been validated.
        /// </summary>
        /// <param name="uri"></param>
        public void ParseUri(Uri uri)
        {
        }

        #endregion

        #region ConnectionUri Members

        /// <summary>
        /// Gets/Sets the Uri
        /// </summary>
        public override Uri Uri
        {
            // This getter is used by the MSB tool
            // to refresh the URI string on the main screen
            // based on the updated properties in the property grid.
            get
            {
                return BuildUri();
            }
            // This setter parses the passed in Uri into its individual
            // properties in this ConnectionUri object.  This object is 
            // used by the "Add Adapter Service Reference" and "Consume Adapter Service"
            // VS Plug-Ins to show the connection properties in Configure > Uri property grid.
            set
            {
                WCFLoopbackAdapterUtilities.Trace.Trace(TraceEventType.Verbose, "LOOPBACK", "In Uri Set with " + value);
                ValidateUri(value);
                ParseUri(value);
            }
        }

        /// <summary>
        /// Validate the input URI
        /// </summary>
        /// <param name="aUri"></param>
        public void ValidateUri(Uri aUri)
        {
            // input uri can't be null
            if (aUri == null)
            {
                throw new InvalidUriException("Invalid Connection Uri.");
            }
        }

        /// <summary>
        /// Returns the example string syntax for adapter's connection string format
        /// </summary>
        public override string SampleUriString
        {
            get
            {
                return WCFLoopbackAdapter.SCHEME + "://";
            }
        }

        #endregion 
    }
}


