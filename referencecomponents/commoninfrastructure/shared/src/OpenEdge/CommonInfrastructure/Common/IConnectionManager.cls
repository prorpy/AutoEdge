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
    File        : IConnectionManager
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 29 09:58:46 EST 2010
    Notes       : * Connections are uniquely identifed by the ConnectionType and name.
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.IConnectionParameters.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ConnectionManagerActionEventArgs.
using OpenEdge.CommonInfrastructure.Common.IComponent.

using OpenEdge.Lang.Collections.IMap.
using Progress.Lang.Object.

interface OpenEdge.CommonInfrastructure.Common.IConnectionManager:
    
    /** Event fired before a connection is attempted  
                    
        @param IComponent The object publishing the event
        @param ConnectionManagerActionEventArgs Arguments/parameters for the event. */
    define public event BeforeConnectionConnected signature void (input poSender as IComponent, input poEventArgs as ConnectionManagerActionEventArgs).

    /** Event fired after a connection attempt is made.  
        
        @param IComponent The object publishing the event
        @param ConnectionManagerActionEventArgs Arguments/parameters for the event. */
    define public event AfterConnectionConnected signature void (input poSender as IComponent, input poEventArgs as ConnectionManagerActionEventArgs).
    
    /** Event fired before a connection disconnect is attempted  
                    
        @param IComponent The object publishing the event
        @param ConnectionManagerActionEventArgs Arguments/parameters for the event. */
    define public event BeforeConnectionDisconnected signature void (input poSender as IComponent, input poEventArgs as ConnectionManagerActionEventArgs).

    /** Event fired after a connection disconnect is attempted.
        
        @param IComponent The object publishing the event
        @param ConnectionManagerActionEventArgs Arguments/parameters for the event. */
    define public event AfterConnectionDisconnected signature void (input poSender as IComponent, input poEventArgs as ConnectionManagerActionEventArgs).
    

    /** Register a connection for later use. 
            
        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection
        @param IConnectionParameters A set of parameters for the connection */    
    method public void RegisterConnection(input poConnectionType as ConnectionTypeEnum,
                                          input pcConnectionName as character,
                                          input poParameters as IConnectionParameters).
    
    /** Connects to a server of the given type, with a unique name, for the
        provided parameters.
        
        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection
        @return IServerConnection A reference to the connection's server. */
    method public IServerConnection Connect(input poConnectionType as ConnectionTypeEnum,
                                            input pcConnectionName as character,
                                            input poParameters as IConnectionParameters).

    /** Disconnects from the specified connection
    
        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection */
    method public void Disconnect(input poConnectionType as ConnectionTypeEnum,
                                  input pcConnectionName as character).

    /** Indicates whether the connection has already been made 
    
        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection */
    method public logical IsConnected(input poConnectionType as ConnectionTypeEnum,
                                      input pcConnectionName as character).
    
    /** Indicates whether a typed/named connection has been registered with the ConMgr. 
        
        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection 
        @return logical Whether the conntection already exists */
    method public logical IsRegistered(input poConnectionType as ConnectionTypeEnum,
                                       input pcConnectionName as character).
    
    /** Returns the connection object of the specified connection.
        
        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection 
        @return IServerConnection A reference to the connection's server. */
    method public IServerConnection GetServerConnection(input poConnectionType as ConnectionTypeEnum,
                                                        input pcConnectionName as character).
    
end interface.
