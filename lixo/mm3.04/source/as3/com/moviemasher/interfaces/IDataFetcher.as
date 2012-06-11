/*
* The contents of this file are subject to the Mozilla Public
* License Version 1.1 (the "License"); you may not use this
* file except in compliance with the License. You may obtain a
* copy of the License at http://www.mozilla.org/MPL/
* 
* Software distributed under the License is distributed on an
* "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express
* or implied. See the License for the specific language
* governing rights and limitations under the License.
* 
* The Original Code is 'Movie Masher'. The Initial Developer
* of the Original Code is Doug Anarino. Portions created by
* Doug Anarino are Copyright (C) 2007-2011 Syntropo.com, Inc.
* All Rights Reserved.
*/

package com.moviemasher.interfaces
{
/** 
* Interface for fetching text based server side resources and CGI responses. A call to either 
* function in this interface will purge the fetch if it has loaded, so it's up to the caller to 
* store the returned value somehow. Purged fetches should not be reused - create a new one instead. 
*
* @see ILoadManager
*/
	public interface IDataFetcher extends IFetcher
	{
/** 
* Retrieves the server response as a String object if loaded. 
* @returns String representation of response or empty string if not yet loaded.
*/
		function data():String;
/** 
* Retrieves the server response as an XML object if loaded.
* @returns XML representation of response string or null if not yet loaded.
*/
		function xmlObject():XML;
	}
}