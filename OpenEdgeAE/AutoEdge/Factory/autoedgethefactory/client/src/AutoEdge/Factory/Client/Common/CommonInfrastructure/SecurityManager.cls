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
    File        : SecurityManager
    Purpose     : Application-specific client-side SecMgr  
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jun 03 11:29:47 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Client.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.String.
using Progress.Lang.Object.

class AutoEdge.Factory.Client.Common.CommonInfrastructure.SecurityManager inherits SecurityManager: 

	constructor public SecurityManager(input poComponentInfo as IComponentInfo ):
		super(input poComponentInfo).
	end constructor.
	
    method override public void EstablishSession(input poContext as IUserContext):
        super:EstablishSession(input poContext).

        BpmEstablishSession(poContext).
    end method.
    
    method protected void BpmEstablishSession(input poContext as IUserContext):
        define variable oServerConnection as IServerConnection no-undo.
        define variable cBpmSessionId as longchar no-undo.
        define variable oStringKey as String no-undo.
        define variable oPropValue as Object no-undo.
        
        oServerConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
        /* if we're connected to the server, the establish a connection */
        if valid-object(oServerConnection) and oServerConnection:IsConnected then
        do:
            oStringKey = new String('BPMServer.SessionId').
            oPropValue = poContext:UserProperties:Get(oStringKey).
            if valid-object(oPropValue) then
                cBpmSessionId = cast(oPropValue, String):Value.
            
            /* Re-establish the BPM connection when we establish the ABL session */
            if cBpmSessionId ne '' and cBpmSessionId ne ? then
                cast(oServerConnection:Server, IBizLogicAPI)
                    :EstablishSession(cBpmSessionId).
        end.
    end method.	
    
    method override public longchar UserLogin(input pcUserName as character, input pcUserDomain as character, input pcPassword as character):
        define variable cContextId as longchar no-undo.
        define variable oUserContext as IUserContext no-undo.
        
        cContextId = super:UserLogin(input pcUserName, input pcUserDomain, input pcPassword).
        
        oUserContext = GetUserContext(cContextId).
        
        /* Now we're logged into OpenEdge, log into Savvion, if a connection exists and we're not a guest. */
        BpmUserLogin(oUserContext, pcPassword).
        
        return cContextId.
    end method.
    
	method override public void UserLogout():
        define variable oBpmServer as IBizLogicAPI no-undo.
        define variable cBpmSessionId as longchar no-undo.
        define variable oStringKey as String no-undo.
        define variable oPropValue as Object no-undo.
        
        if valid-object(CurrentUserContext) then
        do:
            /* Keep the value of the session id, if any before heading off to do the logout.
               The logout may log us off on the server, and so we want keep the session id locally 
               so as to clean up on the client nicely. */
            oStringKey = new String('BPMServer.SessionId').
            oPropValue = CurrentUserContext:UserProperties:Get(oStringKey).
            if valid-object(oPropValue) then
                cBpmSessionId = cast(oPropValue, String):Value.
        end.
                
		super:UserLogout().
		
	    BpmUserLogout(cBpmSessionId).
	end method.
	
    method protected void BpmUserLogout(input pcBpmSessionId as longchar):
        define variable oServerConnection as IServerConnection no-undo.
        define variable oBpmServer as IBizLogicAPI no-undo.
        
        oServerConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
        if valid-object(oServerConnection) and oServerConnection:IsConnected then
        do:
            if pcBpmSessionId ne '' and pcBpmSessionId ne ? then
            do:
                oBpmServer = cast(oServerConnection:Server, IBizLogicAPI).
                
                /* We should already have an established session on the client.
                   We may have logged out on the server, and if so, then simply
                   end the client session. However, this may be a client-only session
                   and in that case we need to log out locally. */
                if oBpmServer:IsSessionValid() then
                    oBpmServer:Logout().
                else
                    oBpmServer:EndSession().
                
                /* Only remove key when we're sure the logout has succeeded. We may
                   not have any context here, so check first. */
                if valid-object(CurrentUserContext) then
                    CurrentUserContext:UserProperties:Remove(new String('BPMServer.SessionId')).
            end.
        end.
    end method.
    
    method protected void BpmUserLogin(input poUserContext as IUserContext, 
                                       input pcPassword as character):
        
        define variable oServerConnection as IServerConnection no-undo.                                           
        define variable oBpmServer as IBizLogicAPI no-undo.
        define variable cBpmUserName as character no-undo.
        define variable cBpmDomain as character no-undo.
        define variable cBpmSessionId as longchar no-undo.
        define variable oPropValue as Object no-undo.
        define variable oStringKey as String no-undo.
                
        oServerConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
        if valid-object(oServerConnection) then
        do:
            /* Make sure we're connected to the BPM server. */            
            if not oServerConnection:IsConnected then
                oServerConnection:Connect().
            
            /* we should now be happily connected to a BPM server */
            assign oStringKey = new String('BPMServer.SessionId')
                   oPropValue = poUserContext:UserProperties:Get(oStringKey).            
            if valid-object(oPropValue) then
                cBpmSessionId = cast(oPropValue, String):Value.
            
            oBpmServer = cast(oServerConnection:Server, IBizLogicAPI).
            
            /* Check whether we're logged in already (ie simply establish) or whether we
               need to do the login ourselves. */
            if cBpmSessionId eq '' or cBpmSessionId eq ? then
            do:
                /* perform login */
                cBpmUserName = substitute('&1@&2',
                                          poUserContext:UserName,
                                          lc(poUserContext:TenantName)).
                oBpmServer:Login(cBpmUserName, pcPassword).
                poUserContext:UserProperties:Put(oStringKey, new String(oBpmServer:SessionId)).
            end.
            else
                /* establish session */
                oBpmServer:EstablishSession(cBpmSessionId).
        end.
    end method.

end class.
