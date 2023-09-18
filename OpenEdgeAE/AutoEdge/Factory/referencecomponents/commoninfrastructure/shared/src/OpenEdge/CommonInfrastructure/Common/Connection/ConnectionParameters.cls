/** ****************************************************************************
  Copyright 2012 Progress Software Corporation
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
    http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
**************************************************************************** **/
/** ------------------------------------------------------------------------
    File        : ConnectionParameters
    Purpose     : Generic connection parameters for connecting to a server or socket
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Jan 13 13:04:55 EST 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.Connection.IConnectionParameters.

class OpenEdge.CommonInfrastructure.Common.Connection.ConnectionParameters implements IConnectionParameters: 
    /** This property contains a nicely-formatted string for use by the
        ABL CONNECT statement or method. */ 
    define public property Options as longchar no-undo get. set.
    
	constructor public ConnectionParameters():
    end constructor.

    constructor public ConnectionParameters(input pcOptions as longchar):
        this-object:Options = pcOptions.
    end constructor.
    
    /** The Connection Manager will call GetConnectionString() on this 
        object, which returns a nicely-formatted string for use by the
        ABL CONNECT statement. 
        
        @return character A useable string of connection parameters. */
    method public longchar GetConnectionString():
        return this-object:Options.
    end method.
    
end class.
