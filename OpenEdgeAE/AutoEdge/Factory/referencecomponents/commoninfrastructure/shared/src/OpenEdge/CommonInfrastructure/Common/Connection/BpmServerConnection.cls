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
    File        : BpmServerConnection
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Apr 20 12:40:20 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnectionParameters.
using OpenEdge.CommonInfrastructure.Common.Connection.IConnectionParameters.

using OpenEdge.Lang.BPM.WorkFlowWebService.
using OpenEdge.Lang.BPM.IBizLogicAPI.

using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnection 
        implements IServerConnection:

    /** (mandatory) Reference to the actual server. The type of this property depends
        on the server type (since AppServers have HANDLEs, BPMServers have IBizLogicAPI 
        and databases none). */
    define public property Server as Object no-undo get. protected set.
    
    /** (mandatory) Parameters for this connection */
    define public property ConnectionParameters as IConnectionParameters no-undo get. set.
    
    /** Is the Server connected? */
    define public property IsConnected as logical no-undo
        get():
            return valid-object(Server) and type-of(Server, WorkFlowWebService).
        end get.
    
	constructor public BpmServerConnection (input poParameters as BpmServerConnectionParameters):
        super ().
        
        ConnectionParameters = poParameters.
    end constructor.

    /** Connect to the server specified, basedon the ConnectionParameters (passed in to the ctor) */
    method public void Connect():
        Server = new WorkFlowWebService(string(ConnectionParameters:GetConnectionString())).
        cast(Server, WorkFlowWebService):ConnectService().
    end method.
    
    /**  Disconnect from the Server  */ 
    method public void Disconnect():
        if IsConnected then
            cast(Server, WorkFlowWebService):DisconnectService().
    end method.
    
end class.
