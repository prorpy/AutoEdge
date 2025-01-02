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
    File        : ConnectionManager
    Purpose     :
    Syntax      :
    Description :
    @author pjudge
    Created     : Wed Jan 12 15:46:56 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Connection.IConnectionParameters.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.

using OpenEdge.CommonInfrastructure.Common.Connection.AppServerConnectionParameters.
using OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnectionParameters.
using OpenEdge.CommonInfrastructure.Common.Connection.DBConnectionParameters.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionParameters.

using OpenEdge.CommonInfrastructure.Common.Connection.WebServiceConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.AppServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.SocketConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.DatabaseConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnection.

using OpenEdge.CommonInfrastructure.Common.ConnectionManagerActionEventArgs.
using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.
using OpenEdge.CommonInfrastructure.Common.IManager.

using OpenEdge.Core.InjectABL.ICache.
using OpenEdge.Core.InjectABL.Lifecycle.ILifecycleContext.
using OpenEdge.Core.InjectABL.Binding.IBinding.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.ReadModeEnum.
using OpenEdge.Lang.SerializationModeEnum.
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.String.
using OpenEdge.Lang.ABLSession.

using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ConnectionManager inherits Service
        implements IConnectionManager, IManager:

    /* Use a temp-table directly since the key is type+name, and we don't (yet) have a nice way of dealing
       with multi-part keys in our Map collection. */
    define private temp-table ConnectedServices no-undo
        field ConnectionType as Object  /* ConnectionTypeEnum */
        field ConnectionName as character
        field ConnectionParameters as Object    /* IConnectionParameters */
        field ServerConnection as Object    /* IServerConnection */
        index idx1 as primary unique ConnectionType ConnectionName.

    /** dsConfig and its component temp-tables can /should be extracted into their own class. */
    define private temp-table ttConfiguration no-undo serialize-name 'config'
        field ConfigName as character serialize-name 'name'
        index idx1 as primary unique ConfigName.

    define private temp-table ttProperty no-undo serialize-name 'property'
        field ConfigName as character
        field PropertyName as character serialize-name 'name'
        field PropertyValue as character serialize-name 'value'
        index idx1 as primary unique  ConfigName PropertyName.


    define private temp-table ttServerConnection no-undo serialize-name 'serverconnection'
        field ConfigName as character
        field ServerType as character serialize-name 'type'
        field ServerName as character serialize-name 'name'
        field IsEnabled as logical serialize-name 'enabled' initial true
        index idx1 as primary unique ConfigName ServerType ServerName.

    define private temp-table ttServerParameter no-undo serialize-name 'parameter'
        field ConfigName as character
        field ServerType as character
        field ServerName as character
        field ParameterName as character serialize-name 'name'
        field ParameterValue as character serialize-name 'value'
        index idx1 as primary unique ConfigName ServerType ServerName ParameterName.

    define private dataset dsConfig serialize-name 'configs' for ttConfiguration, ttProperty, ttServerConnection, ttServerParameter
        data-relation for ttConfiguration, ttProperty relation-fields(ConfigName, ConfigName) nested foreign-key-hidden
        data-relation for ttConfiguration, ttServerConnection relation-fields(ConfigName, ConfigName) nested foreign-key-hidden
        data-relation for ttServerConnection, ttServerParameter relation-fields(ConfigName, ConfigName, ServerType, ServerType, ServerName, ServerName) nested foreign-key-hidden
        .

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

    /** Use this property in lieu of having to say Class:GetClass('....IConnectionManager') every time */
    define static public property IConnectionManagerType as class Class no-undo get. private set.

    constructor static ConnectionManager():
        ConnectionManager:IConnectionManagerType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.IConnectionManager').
    end constructor.

	constructor public ConnectionManager(input poComponentInfo as IComponentInfo):
		super (input poComponentInfo).
	end constructor.

    /** Connects to a server of the given type, with a unique name, for the
        provided parameters.

        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection
        @param IConnectionParameters A set of parameters for the connection
        @return IServerConnection A reference to the connection's server. */
    method public IServerConnection Connect(input poConnectionType as ConnectionTypeEnum,
                                            input pcConnectionName as character,
                                            input poParameters as IConnectionParameters):
        define variable oServerConnection as IServerConnection no-undo.

        define buffer lbServer for ConnectedServices.

        /* Make sure we're registered first */
        RegisterConnection(poConnectionType, pcConnectionName, poParameters).

        OnBeforeConnectionConnected(
            new ConnectionManagerActionEventArgs(poConnectionType, pcConnectionName, poParameters, true)).

        find lbServer where
             lbServer.ConnectionType = poConnectionType and
             lbServer.ConnectionName = pcConnectionName
             no-error.
        Assert:ArgumentIsAvailable(buffer lbServer:handle, 'lbServer').

        oServerConnection = cast(lbServer.ServerConnection, IServerConnection).
        oServerConnection:Connect().

        OnAfterConnectionConnected(
            new ConnectionManagerActionEventArgs(
                    poConnectionType, pcConnectionName, poParameters, oServerConnection:IsConnected)).

        return oServerConnection.
    end method.

    /** Indicates whether a typed/named connection has been registered with the ConMgr.

        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection
        @return logical Whether the conntection has been registerd */
    method public logical IsRegistered(input poConnectionType as ConnectionTypeEnum,
                                       input pcConnectionName as character).
        define buffer lbServer for ConnectedServices.

        return can-find(lbServer where
                        lbServer.ConnectionType = poConnectionType and
                        lbServer.ConnectionName = pcConnectionName).
    end method.

    /** Disconnects from the specified connection

        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection */
    method public void Disconnect(input poConnectionType as ConnectionTypeEnum,
                                  input pcConnectionName as character):
        define variable lActionFailed as logical no-undo.
        define buffer lbServer for ConnectedServices.

        OnBeforeConnectionDisconnected(
            new ConnectionManagerActionEventArgs(poConnectionType, pcConnectionName, ?, true)).

        if IsConnected(poConnectionType, pcConnectionName) then
        do:
            find lbServer where
                 lbServer.ConnectionType = poConnectionType and
                 lbServer.ConnectionName = pcConnectionName
                 no-error.
            Assert:ArgumentIsAvailable(buffer lbServer:handle, 'lbServer').
            cast(lbServer.ServerConnection, IServerConnection):Disconnect().

            /* if the connection is still available, then the disconnect failed */
            lActionFailed = IsConnected(poConnectionType, pcConnectionName).
        end.
        else
            lActionFailed = true.

        OnAfterConnectionDisconnected(
            new ConnectionManagerActionEventArgs(poConnectionType, pcConnectionName, ?, lActionFailed )).
    end method.

    /** Indicates whether the connection already exists.

        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection */
    method public logical IsConnected(input poConnectionType as ConnectionTypeEnum,
                                      input pcConnectionName as character):
        define variable lConnected as logical no-undo.

        define buffer lbServer for ConnectedServices.

        find lbServer where
             lbServer.ConnectionType = poConnectionType and
             lbServer.ConnectionName = pcConnectionName
             no-error.
        /* No assertion here because we may not have registered the connection yet */
        if available lbServer then
            lConnected = cast(lbServer.ServerConnection, IServerConnection):IsConnected.
        else
            lConnected = false.

        return lConnected.
    end method.

    /** Returns the connection object of the specified connection.

        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection
        @return IServerConnection A reference to the connection's server. */
    method public IServerConnection GetServerConnection(input poConnectionType as ConnectionTypeEnum,
                                                        input pcConnectionName as character):
        define variable oServerConnection as IServerConnection no-undo.

        define buffer lbServer for ConnectedServices.

        find lbServer where
             lbServer.ConnectionType = poConnectionType and
             lbServer.ConnectionName = pcConnectionName
             no-error.
        if available lbServer then
            oServerConnection = cast(lbServer.ServerConnection, IServerConnection).

        return oServerConnection.
    end method.

    /** Register a connection for later use.

        @param ConnectionTypeEnum The type of connection
        @param character The unique name for this connection
        @param IConnectionParameters A set of parameters for the connection */
    method public void RegisterConnection(input poConnectionType as ConnectionTypeEnum,
                                          input pcConnectionName as character,
                                          input poParameters as IConnectionParameters):
        define buffer lbServer for ConnectedServices.

        if not IsRegistered(poConnectionType, pcConnectionName) then
        do:
            create lbServer.
            assign lbServer.ConnectionType = poConnectionType
                   lbServer.ConnectionName = pcConnectionName
                   lbServer.ConnectionParameters = poParameters
                   lbServer.ServerConnection = CreateServerConnection(poConnectionType, poParameters)
                   .
        end.
    end method.

    method protected IServerConnection CreateServerConnection(input poConnectionType as ConnectionTypeEnum,
                                                              input poParameters as IConnectionParameters):
        define variable oServerConnection as IServerConnection no-undo.

        case poConnectionType:
            when ConnectionTypeEnum:AppServer then oServerConnection = new AppServerConnection(cast(poParameters, AppServerConnectionParameters)).
            when ConnectionTypeEnum:Database then oServerConnection = new DatabaseConnection(cast(poParameters, DBConnectionParameters)).
            when ConnectionTypeEnum:WebService then oServerConnection = new WebServiceConnection(poParameters).
            when ConnectionTypeEnum:Socket then oServerConnection = new SocketConnection(poParameters).
            when ConnectionTypeEnum:BPMServer then oServerConnection = new BpmServerConnection(cast(poParameters, BpmServerConnectionParameters)).
        end case.

        return oServerConnection.
    end method.

	method override public void DestroyComponent(  ):
	    define buffer lbServer for ConnectedServices.

	    for each lbServer:
	        this-object:Disconnect(
	               cast(lbServer.ConnectionType, ConnectionTypeEnum),
	               lbServer.ConnectionName).
        end.

		super:DestroyComponent().
	end method.

    /** Allows raising of the BeforeConnectionConnected event by derived classes.

        @param ConnectionManagerActionEventArgs Arguments for the event.  */
	method protected void OnBeforeConnectionConnected(input poEventArgs as ConnectionManagerActionEventArgs):
	    BeforeConnectionConnected:Publish(this-object, poEventArgs).
    end method.

    /** Allows raising of the AfterConnectionConnected event by derived classes.

        @param ConnectionManagerActionEventArgs Arguments for the event.  */
    method protected void OnAfterConnectionConnected(input poEventArgs as ConnectionManagerActionEventArgs):
        AfterConnectionConnected:Publish(this-object, poEventArgs).
    end method.

    /** Allows raising of the BeforeConnectionDisconnected event by derived classes.

        @param ConnectionManagerActionEventArgs Arguments for the event.  */
    method protected void OnBeforeConnectionDisconnected(input poEventArgs as ConnectionManagerActionEventArgs):
        BeforeConnectionDisconnected:Publish(this-object, poEventArgs).
    end method.

    /** Allows raising of the AfterConnectionDisconnected event by derived classes.

        @param ConnectionManagerActionEventArgs Arguments for the event.  */
    method protected void OnAfterConnectionDisconnected(input poEventArgs as ConnectionManagerActionEventArgs):
        AfterConnectionDisconnected:Publish(this-object, poEventArgs).
    end method.

    method override public void CreateComponent(  ):
        define variable cConfig as character no-undo.
        define variable oProperty as String no-undo.

		super:CreateComponent().

        oProperty = cast(ABLSession:Instance:SessionProperties:Get(new String('Config.CFGNAME')), String).
        if valid-object(oProperty) then
            LoadConfigConnections(string(oProperty:Value)).
	end method.

    method protected void LoadConfigConnections(input pcConfigName as character):
        define variable oProperty as String no-undo.
        define variable oConnectionType as ConnectionTypeEnum no-undo.
        define variable oConnectionParameters as IConnectionParameters no-undo.

        define buffer lbConfig for ttConfiguration.
        define buffer lbProperty for ttProperty.
        define buffer lbConnection for ttServerConnection.

        oProperty = cast(ABLSession:Instance:SessionProperties:Get(new String('Config.CFGCONTENT')), String).
        dataset dsConfig:read-xml(SerializationModeEnum:LongChar:ToString(),
                                  oProperty:Value,
                                  ReadModeEnum:Empty:ToString(),
                                  ?,   /* schema-location */
                                  ?).  /* override-default-mapping */

        find lbConfig where
             lbConfig.ConfigName eq pcConfigName
             no-error.

        for each lbProperty where lbProperty.ConfigName eq lbConfig.ConfigName:
            ABLSession:Instance:SessionProperties:Put(
                new String(substitute('Config.Property.&1', caps(lbProperty.PropertyName))),
                new String(lbProperty.PropertyValue)).
        end.

        for each lbConnection where
                 lbConnection.ConfigName eq lbConfig.ConfigName and
                 lbConnection.IsEnabled eq true:

            oConnectionType = ConnectionTypeEnum:EnumFromString(lbConnection.ServerType).

            case oConnectionType:
                when ConnectionTypeEnum:AppServer then
                    oConnectionParameters = CreateAppServerParametersFromConfig(lbConnection.ConfigName, lbConnection.ServerName).
                when ConnectionTypeEnum:BpmServer then
                    oConnectionParameters = CreateBpmServerParametersFromConfig(lbConnection.ConfigName, lbConnection.ServerName).
                when ConnectionTypeEnum:Database then
                    oConnectionParameters = CreateDatabaseParametersFromConfig(lbConnection.ConfigName, lbConnection.ServerName).
                when ConnectionTypeEnum:Socket then
                    oConnectionParameters = CreateGenericParametersFromConfig(lbConnection.ConfigName, oConnectionType, lbConnection.ServerName).
                when ConnectionTypeEnum:WebService then
                    oConnectionParameters = CreateGenericParametersFromConfig(lbConnection.ConfigName, oConnectionType, lbConnection.ServerName).
            end case.

            RegisterConnection(oConnectionType, lbConnection.ServerName, oConnectionParameters).
        end.
    end method.
    /** Creates an IConnectionParameters for an AppServer server connection from a config file.

        @param character The config name to use
        @param character The server connection name
        @return AppServerConnectionParameters The connection parameters for the appserver connection. */
    method protected AppServerConnectionParameters CreateAppServerParametersFromConfig(input pcConfigName as character,
                                                                                       input pcServerName as character):
        define variable cOptions as longchar no-undo.
        define variable cUserName as character no-undo.
        define variable cPassword as character no-undo.
        define variable cAppServerInfo as character no-undo.

        define buffer lbParam for ttServerParameter.

        for each lbParam where
                 lbParam.ConfigName eq pcConfigName and
                 lbParam.ServerType eq ConnectionTypeEnum:AppServer:Name and
                 lbParam.ServerName eq pcServerName:
            case lbParam.ParameterName:
                when 'user' then cUserName = lbParam.ParameterValue.
                when 'password' then cPassword = lbParam.ParameterValue.
                when 'AppServerInfo' then cAppServerInfo = lbParam.ParameterValue.
                otherwise cOptions = cOptions + substitute(' -&1 &2 ', lbParam.ParameterName, lbParam.ParameterValue).
            end case.
        end.

        return new AppServerConnectionParameters(cAppServerInfo, cUserName, cPassword, cOptions).
    end.

    /** Creates an IConnectionParameters for a BPM server connection from a config file.

        @param character The config name to use
        @param character The server connection name
        @return BpmServerConnectionParameters The connection parameters for the BPM server connection. */
    method protected BpmServerConnectionParameters CreateBpmServerParametersFromConfig(input pcConfigName as character,
                                                                                       input pcServerName as character):

        define variable cHost as character no-undo.
        define variable iPort as integer no-undo.
        define variable cProtocol as character no-undo.
        define variable cOptions as longchar no-undo.
        define variable oConnectionParameters as BpmServerConnectionParameters no-undo.

        define buffer lbParam for ttServerParameter.

        for each lbParam where
                 lbParam.ServerName eq pcServerName and
                 lbParam.ConfigName eq pcConfigName and
                 lbParam.ServerType eq ConnectionTypeEnum:BpmServer:Name:
            case lbParam.ParameterName:
                when 'host' then cHost = lbParam.ParameterValue.
                when 'port' then iPort = int(lbParam.ParameterValue).
                when 'protocol' then cProtocol = lbParam.ParameterValue.
                otherwise cOptions = cOptions + substitute(' &1 &2 ', lbParam.ParameterName, lbParam.ParameterValue).
             end case.
        end.

        return new BpmServerConnectionParameters(cHost, cProtocol, iPort, cOptions).
    end.

    /** Creates an IConnectionParameters for a database server connection from a config file.

        @param character The config name to use
        @param character The server connection name
        @return DatabaseConnectionParameters The connection parameters for the database connection. */
    method protected DBConnectionParameters CreateDatabaseParametersFromConfig(input pcConfigName as character,
                                                                               input pcServerName as character):
        define variable cOptions as longchar no-undo.
        define variable cLogicalName as character no-undo.
        define variable cPhysicalName as character no-undo.

        define buffer lbParam for ttServerParameter.

        for each lbParam where
                 lbParam.ConfigName eq pcConfigName and
                 lbParam.ServerType eq ConnectionTypeEnum:Database:Name and
                 lbParam.ServerName eq pcServerName:
            case lbParam.ParameterName:
                when 'db' then cPhysicalName = lbParam.ParameterValue.
                when 'ld' then cLogicalName = lbParam.ParameterValue.
                otherwise cOptions = cOptions + substitute(' -&1 &2 ', lbParam.ParameterName, lbParam.ParameterValue).
            end case.
        end.

        return new DBConnectionParameters(cPhysicalName, cLogicalName, cOptions).
    end.

    /** Creates generic/non-specialised IConnectionParameters for a server connection
        from a config file.

        @param character The config name to use
        @param character The server connection name
        @return ConnectionParameters The connection parameters for the server connection. */
    method protected ConnectionParameters CreateGenericParametersFromConfig(input pcConfigName as character,
                                                                            input poConnectionType as ConnectionTypeEnum,
                                                                            input pcServerName as character):
        define variable cOptions as longchar no-undo.
        define variable oConnectionParameters as ConnectionParameters no-undo.

        define buffer lbParam for ttServerParameter.

        for each lbParam where
                 lbParam.ConfigName eq pcConfigName and
                 lbParam.ServerType eq poConnectionType:Name and
                 lbParam.ServerName eq pcServerName:
            cOptions = cOptions + substitute(' -&1 &2 ', lbParam.ParameterName, lbParam.ParameterValue).
        end.

        return new ConnectionParameters(cOptions).
    end.

    method override public void Initialize(  ):
		define buffer lbServer for ConnectedServices.

		super:Initialize().

		/* make connections from registered connections */
        for each lbServer:
            this-object:Connect(
                cast(lbServer.ConnectionType, ConnectionTypeEnum),
                lbServer.ConnectionName,
                cast(lbServer.ConnectionParameters, IConnectionParameters)).
        end.
	end method.

end class.
