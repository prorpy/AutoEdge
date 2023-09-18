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
    Purpose     : Application-specific security manager 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 22 09:27:08 EST 2010
    Notes       : * The UserDomains are structured as follows:
                        <department>.employee.<tenant>
                    or
                        system.<tenant>
                    or
                        customer.<tenant>
                  * Also see autoedgethefactory/shared/doc/applicationusers.txt
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using AutoEdge.Factory.Common.CommonInfrastructure.UserTypeEnum.

using OpenEdge.CommonInfrastructure.Server.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.CommonInfrastructure.Common.UserContext.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo. 
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.ConnectionManagerActionEventArgs.
using OpenEdge.CommonInfrastructure.Common.Connection.DatabaseConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.AuthorizationError.

using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.String.
using Progress.Lang.Object.

class AutoEdge.Factory.Server.Common.CommonInfrastructure.SecurityManager inherits SecurityManager:

    constructor public SecurityManager(input poComponentInfo as IComponentInfo ):
        super(input poComponentInfo).
    end constructor.
    
    method override public void ValidateCredentials(input pcUserName as character,
                                                    input pcUserDomain as character,
                                                    input pcPassword as character):
        define buffer lbUser for ApplicationUser.
        
        /* validate login credentials */
        find lbUser where
             lbUser.LoginName = pcUserName and
             lbUser.LoginDomain = pcUserDomain
             no-lock no-error.
        if not available lbUser then
           undo, throw new InvalidValueSpecifiedError(substitute('user name', '(&1)', pcUserName),'').

        if lbUser.Password ne encode(pcPassword) then
           undo, throw new InvalidValueSpecifiedError('password', substitute(' for user ', '(&1)', pcUserName)).
        
        do transaction:
            find current lbUser exclusive-lock.
            assign lbUser.LastLoginDate = now.
        end.
    end method.

    /** Creates a IUserContext object for a validated user/domain. Will usually be 
        overridden to add more details.
        
        @param character The user name
        @param character The user domain
        @return IUserContext The user's context object */
    method override protected IUserContext CreateContextObject(input pcUserName as character,
                                                               input pcUserDomain as character):
        define variable oUC as IUserContext no-undo.
        define variable cEmailAddress as character no-undo.
        define variable cBizLogicSessionId as character no-undo.
        define variable cDomainType as character no-undo.
        define variable oUserType as UserTypeEnum no-undo.
        
        define buffer lbCustomer for Customer.
        define buffer lbContactDetail for ContactDetail.
        define buffer lbCustomerContact for CustomerContact.
        define buffer lbContactType for ContactType.
        define buffer lbUser for ApplicationUser.
        define buffer lbEmployee for Employee.
        define buffer lbSalesrep for Salesrep.
        define buffer lbDealer for Dealer.
        define buffer lbTenant for Tenant.
        
        oUC = super:CreateContextObject(pcUserName, pcUserDomain).
        
        find lbUser where
             lbUser.LoginName = pcUserName and
             lbUser.LoginDomain = pcUserDomain
             no-lock no-error.
        
        /* The user's security domain as set in the AETF DB is at the tenant level. The domain we pass in to the user 
           context is the login domain, and so we need to correct this for the CLIENT-PRINCIPAL. */
        find lbTenant where lbTenant.TenantId eq lbUser.TenantId no-lock no-error.
        oUC:ClientPrincipal:domain-name = lc(lbTenant.Name).
        
        cDomainType = entry(max(num-entries(pcUserDomain, '.') - 1, 1), pcUserDomain, '.').            
        oUserType = UserTypeEnum:EnumFromString(cDomainType).
        
        oUC:UserProperties:Put(new String('UserType'), oUserType).
        
        if oUserType:Equals(UserTypeEnum:Customer) then
        do:
            /* guests are special customers */
            oUserType = UserTypeEnum:EnumFromString(pcUserName).
            if valid-object(oUserType) and oUserType:Equals(UserTypeEnum:Guest) then
                oUC:UserProperties:Put(new String('UserType'), UserTypeEnum:Guest).
            else
            do:
                /* since we've already validated, we know that this user record exists */
                find lbCustomer where
                     lbCustomer.CustomerId = lbUser.CustomerId and
                     lbCustomer.TenantId = lbUser.TenantId
                     no-lock no-error.
                if not available lbCustomer then
                   undo, throw new InvalidValueSpecifiedError(substitute('customer', '(&1 - &2)', pcUserName, pcUserDomain), '').
                
                oUC:UserProperties:Put(new String('Customer.CustomerId'), new String(lbCustomer.CustomerId)).
                oUC:UserProperties:Put(new String('Customer.CustNum'), new String(string(lbCustomer.CustNum))).
                oUC:UserProperties:Put(new String('Customer.CreditLimit'), new String(string(lbCustomer.CreditLimit))).
                oUC:UserProperties:Put(new String('Customer.Name'), new String(string(lbCustomer.Name))).
                
                find lbContactType where lbContactType.Name = 'email-home' no-lock.
                find lbCustomerContact where
                     lbCustomerContact.CustomerId = lbCustomer.CustomerId and
                     lbCustomerContact.TenantId = lbCustomer.TenantId and
                     lbCustomerContact.ContactType = lbContactType.Name
                     no-lock no-error.                 
                if available lbCustomerContact then
                find lbContactDetail where
                     lbContactDetail.ContactDetailId = lbCustomerContact.ContactDetailId
                     no-lock no-error.
                if available lbContactDetail then
                    cEmailAddress = lbContactDetail.Detail.
                
                oUC:UserProperties:Put(new String('Customer.PrimaryEmailAddress'), new String(cEmailAddress)).
            end.    /* 'real' customers */
        end.
        else
        if oUserType:Equals(UserTypeEnum:Employee) then
        do:
            find first lbEmployee where
                       lbEmployee.TenantId = lbUser.TenantId and
                       lbEmployee.EmployeeId = lbUser.EmployeeId
                       no-lock no-error.
            if available lbEmployee then
                find first lbDealer where
                           lbDealer.TenantId = lbUser.TenantId and 
                           lbDealer.DealerId = lbEmployee.DealerId
                           no-lock no-error.
            if available lbDealer then
            do:
                oUC:UserProperties:Put(new String('Dealer.Code'), new String(lbDealer.Code)).
                oUC:UserProperties:Put(new String('Dealer.Name'), new String(lbDealer.Name)).
            end.
            
            find first lbSalesrep where
                       lbSalesrep.TenantId = lbUser.TenantId and 
                       lbSalesrep.EmployeeId = lbEmployee.EmployeeId
                       no-lock no-error.
            if available lbSalesrep then
                oUC:UserProperties:Put(new String('Salesrep.Code'), new String(lbSalesrep.Code)).
        end.
        
        return oUC.
    end method.
    
    /** Finds/retrieves/calculates a domain key for given context.
        
        @param IUserContext The context for which to find the key 
        @return character The domain key for the given context. */
    method override protected character FindDomainKey(input poContext as IUserContext):
        define buffer lbUser for ApplicationUser.
        define buffer lbTenant for Tenant.
        
        find lbUser where
             lbUser.LoginName = poContext:UserName and
             lbUser.LoginDomain = poContext:UserDomain
             no-lock no-error.
        if not available lbUser then
            undo, throw new InvalidValueSpecifiedError(substitute('user name', '(&1)', poContext:UserName), '').
        
        find lbTenant where lbTenant.TenantId eq lbUser.TenantId no-lock no-error.
        
        return substitute('&1::&2', 'TABLE-ApplicationUser', lbTenant.TenantId).
    end method.
    
    /** Authorises the current user to undertake the specified action on the
        service. An error is thrown if the authentication fails.
        
        @param character The service being operated upon.
        @param ServiceMessageActionEnum The Action being performed. */
    @todo(task="refactor", action="this functionality properly belongs in an authorization manager.").        
	method override public void AuthoriseServiceAction(input pcService as character,
	                                                      input poServiceMessageAction as ServiceMessageActionEnum):
		super:AuthoriseServiceAction(input pcService, input poServiceMessageAction).
		
		if poServiceMessageAction:Equals(ServiceMessageActionEnum:SaveData) then
        do:
            if IsManagedSession then
            do:
                /* Guests cannot save data */
                if cast(CurrentUserContext:UserProperties:Get(new String('UserType')), UserTypeEnum):Equals(UserTypeEnum:Guest) then
                    undo, throw new AuthorizationError('Guest user', poServiceMessageAction:ToString(), pcService).
            end.
            /* Only logged-in users can perform save actions */
            else
                undo, throw new AuthorizationError('Unknown user', poServiceMessageAction:ToString(), pcService).
        end.    /* save */
	end method.
	
    /** Loads the security authentication domains for the application. */    
    method override void LoadAuthenticationDomains():
        define variable oDbConnection as IServerConnection no-undo.
        
        oDbConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:Database, 'dbAutoEdgeTheFactory').        
        if valid-object(oDbConnection) and oDbConnection:IsConnected then                
    		security-policy:load-domains(cast(oDbConnection, DatabaseConnection):LogicalName).
	end method.
	
    /** Unloads the security authentication domains for the application. */
    method override void UnloadAuthenticationDomains().
    
    end method.
    
    method override public void Initialize(  ):
        super:Initialize().
        
        ConnectionManager:BeforeConnectionConnected:Subscribe(BeforeConnectionConnectedHandler).
        ConnectionManager:AfterConnectionConnected:Subscribe(AfterConnectionConnectedHandler).
        ConnectionManager:AfterConnectionDisconnected:Subscribe(AfterConnectionDisconnectedHandler).
    end method.
    
    method override public void DestroyComponent():
        super:DestroyComponent().
        
        ConnectionManager:AfterConnectionConnected:Unsubscribe(AfterConnectionConnectedHandler).
        ConnectionManager:AfterConnectionDisconnected:Unsubscribe(AfterConnectionDisconnectedHandler).
    end method.
        
    method public void AfterConnectionDisconnectedHandler(input poSender as IComponent, input poEventArgs as ConnectionManagerActionEventArgs):
        if poEventArgs:ActionFailed eq false and poEventArgs:ConnectionType eq ConnectionTypeEnum:Database then
            UnloadAuthenticationDomains().
    end method.

    method public void BeforeConnectionConnectedHandler(input poSender as IComponent, input poEventArgs as ConnectionManagerActionEventArgs):
        
    end method.
    
    method public void AfterConnectionConnectedHandler(input poSender as IComponent, input poEventArgs as ConnectionManagerActionEventArgs):
        if poEventArgs:ActionFailed eq false and poEventArgs:ConnectionType eq ConnectionTypeEnum:Database then 
            LoadAuthenticationDomains().
    end method.
    
    method override public longchar UserLogin(input pcUserName as character, input pcUserDomain as character, input pcPassword as character):
        define variable cContextId as longchar no-undo.
        
        cContextId = super:UserLogin(input pcUserName, input pcUserDomain, input pcPassword).
        
        BpmUserLogin(GetUserContext(cContextId), pcPassword).

        return cContextId.
	end method.
	
	/** Login to a BPM server.
	    
	    @param IUserContext The currently-logged in user's context.
	    @param character The password. This value is not set in context, while most others are. */
	method protected void BpmUserLogin(input poContext as IUserContext,
	                                   input pcPassword as character):
        define variable oBpmServer as IBizLogicAPI no-undo.
        define variable cBpmUserName as character no-undo.
        define variable oServerConnection as IServerConnection no-undo.
        
        /* Now we're logged into OpenEdge, log into Savvion, if a connection exists and we're not a guest.
           
           Customers don't have logins to the BPM server. Guests do though, since they are system users of a kind. */
        oServerConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
        if not cast(poContext:UserProperties:Get(new String('UserType')), UserTypeEnum):Equals(UserTypeEnum:Customer) and
           valid-object(oServerConnection) then
        do:
            /* Make sure we're connected to the BPM server. */            
            if not oServerConnection:IsConnected then
                oServerConnection:Connect().
            
            /* Same passwords in Savvion and OE; usernames are <OpenEdge user>@<tenant> in Savvion */
            cBpmUserName = substitute('&1@&2',
                                      poContext:UserName,
                                      lc(poContext:TenantName)).
            
            oBpmServer = cast(oServerConnection:Server, IBizLogicAPI).
            
            oBpmServer:Login(cBpmUserName, pcPassword).
            poContext:UserProperties:Put(
                        new String('BPMServer.SessionId'),
                        new String(oBpmServer:SessionId)).
        end.
    end method.
    
    method override public void UserLogout(input poContext as IUserContext):
        BpmUserLogout(poContext).
        
		super:UserLogout(input poContext).		
	end method.
	
    method override public void EstablishSession(input poContext as IUserContext):
		super:EstablishSession(input poContext).
		
        BpmEstablishSession(poContext).
	end method.
	
	method protected void BpmEstablishSession(input poContext as IUserContext):
        define variable cBpmContextId as longchar no-undo.
        define variable oStringKey as String no-undo.
        define variable oPropValue as Object no-undo.
        define variable oServerConnection as IServerConnection no-undo.
        
        oServerConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
        if valid-object(oServerConnection) then
        do:
            oStringKey = new String('BPMServer.SessionId').
            oPropValue = poContext:UserProperties:Get(oStringKey).
            if valid-object(oPropValue) then
                cBpmContextId = cast(oPropValue, String):Value.
            
            /* Re-establish the BPM connection when we establish the ABL session */
            if cBpmContextId ne '' and cBpmContextId ne ? then
                cast(oServerConnection
                        :Server, IBizLogicAPI)
                            :EstablishSession(cBpmContextId).
        end.
    end method.
    
	method protected void BpmUserLogout(input poContext as IUserContext):
	    define variable oServerConnection as IServerConnection no-undo.
	    define variable oBpmServer as IBizLogicAPI no-undo.
        define variable cBpmContextId as longchar no-undo.
        define variable oStringKey as String no-undo.
        define variable oPropValue as Object no-undo.
        
        oServerConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
        if valid-object(oServerConnection) then
        do: 
            oStringKey = new String('BPMServer.SessionId').
            oPropValue = poContext:UserProperties:Get(oStringKey).
            if valid-object(oPropValue) then
                cBpmContextId = cast(oPropValue, String):Value.
            
    	    if cBpmContextId ne '' and cBpmContextId ne ? then
    	    do:
    	        oBpmServer = cast(oServerConnection:Server, IBizLogicAPI).
                if oBpmServer:IsSessionValid() then
                    oBpmServer:Logout().
                
                /* onlt remove key when we're sure the logout has succeeded. */
                poContext:UserProperties:Remove(oStringKey).
            end.
        end.
    end method.
        	    	    
end class.
