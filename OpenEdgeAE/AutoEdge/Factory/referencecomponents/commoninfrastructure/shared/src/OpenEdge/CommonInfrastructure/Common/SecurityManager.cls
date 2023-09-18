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
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 18 11:54:05 EDT 2010
    Notes       :               
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.CommonInfrastructure.Common.UserContext.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo. 
using OpenEdge.CommonInfrastructure.Common.ITenantManager.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.IManager.
using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.IComponent.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.ObjectInputStream.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.ObjectOutputStream.
using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.InvalidActionError.
using OpenEdge.Core.System.NotFoundError.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.String.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Common.SecurityManager abstract inherits Service 
        implements ISecurityManager, IManager:
    
    /** Use these properties in lieu of having to say Class:GetClass('....ISecurityManager') every time */
    define static public property IUserContextType as class Class no-undo get. private set.
    define static public property ISecurityManagerType as class Class no-undo get. private set.
    
    /** Returns the current user's context. The current user is the one who has
        a request being serviced by this AVM. */
    define public property CurrentUserContext as IUserContext no-undo
        get.
        protected set.
    
    /** Describes whether the current session is managed or not. A managed session
        basically has a user associated with it. */
    define public property IsManagedSession as logical no-undo
        get():
            return valid-object(CurrentUserContext).
        end get.
    
    define protected property ConnectionManager as IConnectionManager no-undo
        get():
            if not valid-object(ConnectionManager) then
                ConnectionManager = cast(ServiceManager:StartService(Class:GetClass('OpenEdge.CommonInfrastructure.Common.IConnectionManager')), IConnectionManager).
            
            return ConnectionManager.
        end get.
        set.
    
    constructor static SecurityManager():
        SecurityManager:ISecurityManagerType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.ISecurityManager').
        SecurityManager:IUserContextType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.IUserContext').
    end constructor.
    
    constructor public SecurityManager(input poComponentInfo as IComponentInfo):
        super(poComponentInfo).
    end constructor.
    
    /** Merges the passed context into the current user's context. The
        default is to replace the current context completely. 
        
        @param IUserContext The context to merge.   */
    method public void SetUserContext(input poUserContext as IUserContext):
        CurrentUserContext = MergeUserContext(CurrentUserContext, poUserContext).
    end method.
    
    /** Resolves a context ID into a context object.
        
        @param longchar The identifier for the context.
        @return IUserContext The user context object. */
    method public IUserContext GetUserContext(input pcContextId as longchar):
        define variable oContext as IUserContext no-undo.
        
        /* Assume the user is allowed to retrieve their own */
        if valid-object(CurrentUserContext) and 
           CurrentUserContext:ContextId eq pcContextId then
            oContext = CurrentUserContext.
        else
        do:
            /* is the current user allowed to return context for others? */
            AuthoriseOperation(? /* SomeOperationEnum:EnumMember */).
            oContext = ReadContextFromStore(pcContextId).
        end.
        
        return oContext.
    end method.
    
    /** Merges contexts.
        
        @param IUserContext The target for the merge of context. Typically the CurrentUserContext
        @param IUserContext The source context to merge into the target.    
        @return IUserContext The merged context. */
    method protected IUserContext MergeUserContext(input poTargetContext as IUserContext,
                                                   input poSourceContext as IUserContext):
        @todo(task="question", action="use :Clone() instead? ").
        if not valid-object(poTargetContext) or
           poTargetContext:Equals(poSourceContext) then                                                       
            poTargetContext = poSourceContext.
        
        return poTargetContext.
    end method.
    
    /** Logs a user into the application
    
        @param character The user's login name
        @param character The user's login/security domain
        @param character The user's password. This should be encoded/encrypted.    
        @return longchar If the login succeeded, the context id of the logged-in
                user. */
    method abstract public longchar UserLogin(input pcUserName as character,
                                              input pcUserDomain as character,
                                              input pcPassword as character).
    /** Logs a user into the application
    
        @param character The user's login name
        @param character The user's password. This should be encoded/encrypted.
        @return longchar If the login succeeded, the context id of the logged-in
                user. */
    method public longchar UserLogin(input pcUserName as character,
                                 input pcPassword as character):
        define variable cDomain as character no-undo.
        
        if num-entries(pcUserName, '@') eq 2 then
            assign cDomain = entry(2,  pcUserName, '@')
                   pcUserName = entry(1,  pcUserName, '@').
        
        return UserLogin(pcUserName, cDomain, pcPassword).                                             
    end method.
    
    /** Ends a user's session (not a log out, but the opposite of EstablishSession).
        Ends the current session. */
    method public void EndSession():
        /* release context */
        CurrentUserContext = ?.
    end method.
    
    /** Read and write allows us to turn context into a kind of cookie, if we so desire. */
    method protected IUserContext ReadContextFromStore(input pcContextId as longchar):
        define variable oOIS as IObjectInput no-undo.
        define variable oUC as IUserContext no-undo.
        define variable cFilename as character no-undo.
        
        /* context goes in one place ... */ 
        cFilename = search(string(session:temp-dir + pcContextId + '.' + SecurityManager:IUserContextType:TypeName + '.ser')).
        if not cFilename eq ? then
        do:
            oOIS = new ObjectInputStream().
            oOIS:Read(cFilename).
            oUC = cast(oOIS:ReadObject(), IUserContext).
            
            /** ... client-principal in another */
            if valid-object(oUC) then
                ReadClientPrincipalFromStore(oUC).
        end.
        
        return oUC.
    end method.
    
    method protected void ReadClientPrincipalFromStore(input poUserContext as IUserContext):
        define variable cFilename as character no-undo.
        define variable cClientPrincipal as longchar no-undo.
        define variable mClientPrincipal as memptr no-undo.
        define variable rClientPrincipal as raw no-undo.
        
        if valid-object(poUserContext) then
        do: 
            cFilename = search(string(session:temp-dir + poUserContext:ContextId + '.ClientPrincipal.ser')).
            if not cFilename eq ? then
            do:
                copy-lob file cFilename to cClientPrincipal.
                
                if cClientPrincipal ne '' then
                do:
                    mClientPrincipal = base64-decode(cClientPrincipal).
                    rClientPrincipal = get-bytes(mClientPrincipal, 1, get-size(mClientPrincipal)).
                    poUserContext:ClientPrincipal:import-principal(rClientPrincipal).
                end.
            end.
        end.
    end method.
    
    method protected void WriteContextToStore(input poUserContext as IUserContext):
        define variable oOOS as IObjectOutput no-undo.
        define variable oUC as IUserContext no-undo.
        define variable cFilename as character no-undo.
        
        if valid-object(poUserContext) then
        do:
            /* context goes in one place ... */
            cFilename = session:temp-dir + poUserContext:ContextId + '.' + SecurityManager:IUserContextType:TypeName + '.ser'.
            oOOS = new ObjectOutputStream().
            oOOS:WriteObject(poUserContext).
            oOOS:Write(cFilename).
            
            /* ... client-principal to another */
            WriteClientPrincipalToStore(poUserContext).
        end.
    end method.
    
    method protected void WriteClientPrincipalToStore(input poUserContext as IUserContext):
        define variable oOOS as IObjectOutput no-undo.
        define variable oUC as IUserContext no-undo.
        define variable cFilename as character no-undo.
        define variable cClientPrincipal as longchar no-undo.
        
        if valid-object(poUserContext) then
        do:
            /* ... client-principal in another */
            cFilename = session:temp-dir + poUserContext:ContextId + '.ClientPrincipal.ser'.
            cClientPrincipal = base64-encode(poUserContext:ClientPrincipal:export-principal()). 
            copy-lob cClientPrincipal to file cFilename.
        end.
    end method.    
    
    /** Authorises the current user to undertake the specified action on the
        service. AN error is thrown if the authentication fails.
        
        @param character The service being operated upon.
        @param ServiceMessageActionEnum The Action being performed. */
    @method(virtual="true").        
    method public void AuthoriseServiceAction(input pcService as character,
                                              input poServiceMessageAction as ServiceMessageActionEnum):
    end method.
    
    /** Authorises the current user to undertake the specified action on the
        service. An error is thrown if the authentication fails. */
    @method(virtual="true").
    method public void AuthoriseOperation(input poOperation as OpenEdge.Lang.EnumMember):
        @todo(task="implement", action="").        
    end method.
    
end class.
