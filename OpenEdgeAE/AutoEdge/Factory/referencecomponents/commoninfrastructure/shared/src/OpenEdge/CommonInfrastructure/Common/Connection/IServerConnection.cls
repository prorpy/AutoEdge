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
    File        : IServerConnection
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 20 08:55:22 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.Connection.IConnectionParameters.
using Progress.Lang.Object.

interface OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection:
    
    /** (mandatory) Reference to the actual server. The type of this property depends
        on the server type (since AppServers have HANDLEs, BPMServers have IBizLogicAPI 
        and databases none). */
    define public property Server as Object no-undo get.
    
    /** (mandatory) Parameters for this connection */
    define public property ConnectionParameters as IConnectionParameters no-undo get.
    
    /** Is the Server connected? */
    define public property IsConnected as logical no-undo get. 
    
    /** Connect to the server specified, basedon the ConnectionParameters (passed in to the ctor) */ 
    method public void Connect().
    
    /**  Disconnect from the Server  */
    method public void Disconnect().
    
end interface.
