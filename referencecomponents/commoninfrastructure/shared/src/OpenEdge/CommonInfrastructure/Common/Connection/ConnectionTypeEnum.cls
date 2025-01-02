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
    File        : ConnectionTypeEnum
    Purpose     : Enumerates the types of connections the AVM can make
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri Jan 07 16:25:19 EST 2011
    Notes       : * Roughly equivalent to the ABL CONNECT method and statements
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum inherits EnumMember: 

    define static public property AppServer as ConnectionTypeEnum no-undo get. private set.
    define static public property BpmServer as ConnectionTypeEnum no-undo get. private set.
    define static public property Database as ConnectionTypeEnum no-undo get. private set.
    define static public property Socket as ConnectionTypeEnum no-undo get. private set.
    define static public property WebService as ConnectionTypeEnum no-undo get. private set.
    
    constructor static ConnectionTypeEnum():
        ConnectionTypeEnum:AppServer = new ConnectionTypeEnum('AppServer').
        ConnectionTypeEnum:Database = new ConnectionTypeEnum('Database').
        ConnectionTypeEnum:Socket = new ConnectionTypeEnum('Socket').
        ConnectionTypeEnum:WebService = new ConnectionTypeEnum('WebService').
        ConnectionTypeEnum:BpmServer = new ConnectionTypeEnum('BpmServer').
    end constructor.
    
	constructor public ConnectionTypeEnum(input pcName as character):
		super (input pcName).
	end constructor.
	
	method public static ConnectionTypeEnum EnumFromString(input pcConnectionType as character):
        define variable oMember as ConnectionTypeEnum no-undo.
        
        case pcConnectionType:
            when ConnectionTypeEnum:AppServer:Name then oMember = ConnectionTypeEnum:AppServer.
            when ConnectionTypeEnum:Database:Name then oMember = ConnectionTypeEnum:Database.
            when ConnectionTypeEnum:Socket:Name then oMember = ConnectionTypeEnum:Socket.
            when ConnectionTypeEnum:WebService:Name then oMember = ConnectionTypeEnum:WebService.
            when ConnectionTypeEnum:BpmServer:Name then oMember = ConnectionTypeEnum:BpmServer.
        end.
        
        return oMember.
    end method.
    
end class.
