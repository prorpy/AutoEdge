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
using OpenEdge.CommonInfrastructure.Server.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.AuthenticationError.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo. 
using OpenEdge.CommonInfrastructure.Common.ITenantManager.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.Service.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.InvalidActionError.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.LoginStateEnum.
using Progress.Lang.SysError.
using OpenEdge.Lang.String.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Server.SecurityManager abstract inherits SecurityManager 
        implements ISecurityManager:
    
    define protected property TenantManager as ITenantManager no-undo
        get():
            if not valid-object(TenantManager) then
                TenantManager = cast(ServiceManager:GetService(Class:GetClass('OpenEdge.CommonInfrastructure.Common.ITenantManager')), ITenantManager).
            
            return TenantManager.
        end get.
        set.
    
    /** Validates that the passed context is valid and that the session can be established.
        
        @param IUserContext The passed-in user context to validate. */
    method public void EstablishSession(input poContext as IUserContext):
        
        /* Check whether this context matches the stored/persisted context we have
           for the ID. This could be the CurrentUserContext or stored elsewhere,
           but we let GetUserContext() figure that out. */
        if not poContext:Equals(GetUserContext(poContext:ContextId)) then
            undo, throw new AuthenticationError(
                    'User context',
                    substitute('passed context does not match current user context (Context ID = &1)', CurrentUserContext:ContextId)).
        
        /* At this point, we've validated the context is for the current user. Now we can 
           continue. */
        
        /* Read the client principal from it's store; this may already have happened, if 
           the original call was done with a context id instead of object. */
        if poContext:ClientPrincipal:session-id eq '' then
            ReadClientPrincipalFromStore(poContext).
        
        SealUserCredentials(poContext).
        SetUserContext(poContext).
    end method.
    
    /** Validates that the passed context is valid and that the session can be established.
        
        @param longchar A user context id. */
    method public void EstablishSession(input pcContextId as longchar):
        EstablishSession(ReadContextFromStore(pcContextId)).
    end method.
    
    /** Ends a user's session (not a log out, but the opposite of EstablishSession) 
        
        @param longchar The context ID identifying the user who's session is being ended. */
    method public void EndSession(input pcContextId as longchar):
        define variable oContext as IUserContext no-undo.
        
        oContext = GetUserContext(pcContextId).
        
        /* write out the context values */
        WriteContextToStore(oContext).
        
        if oContext:Equals(CurrentUserContext) then
        do:
            CurrentUserContext = ?.
/*            security-policy:set-client(?).*/
        end.
    end method.
    
    /** Merges the passed context into the current user's context. The
        default is to replace the current context completely.
        
        @param IUserContext The context to merge.   */
    method override public void SetUserContext(input poUserContext as IUserContext).
        CurrentUserContext = MergeUserContext(GetUserContext(poUserContext:ContextId), poUserContext).
    end method.
    
    method public IUserContext GetPendingContext( input pcContextId as longchar):
        /* defualt is to return all context */
        return GetUserContext(pcContextId).
    end method.
    
    method abstract protected void ValidateCredentials(input pcUserName as character,
                                                       input pcUserDomain as character,
                                                       input pcPassword as character).
    
    method protected void SealUserCredentials(input poUserContext as IUserContext):
        define variable cDomainKey as character no-undo.
        
        cDomainKey = FindDomainKey(poUserContext).
        
        /* Only perform a single seal per login session */
        if not LoginStateEnum:EnumFromString(poUserContext:ClientPrincipal:login-state):Equals(LoginStateEnum:Login) then 
            poUserContext:ClientPrincipal:seal(cDomainKey).
        
        /* Perform a validate-seal() first, since the errors thrown from here are more
           meaningful than errors trown from the set-client() call. */
        poUserContext:ClientPrincipal:validate-seal().
        
        security-policy:set-client(poUserContext:ClientPrincipal).
    end method.
    
    method override public longchar UserLogin(input pcUserName as character,
                                              input pcUserDomain as character,
                                              input pcPassword as character):
        define variable oUC as IUserContext no-undo.
                
        /* validate login credentials */
        ValidateCredentials(pcUserName, pcUserDomain, pcPassword).
        
        /* create context and establish tenancy */
        oUC = CreateContextObject(pcUserName, pcUserDomain).         
        oUC:EstablishTenancy(TenantManager).
        
        SealUserCredentials(oUC).
        
        /* CurrentuserContext should be null at this point, but we 'merge' into it
           anyway. */
        CurrentUserContext = MergeUserContext(CurrentUserContext, oUC).
        
        WriteContextToStore(oUC).
        
        return oUC:ContextId.
        
        catch oSysError as SysError:
            undo, throw new AuthenticationError(
                    oSysError,
                    'user login',
                    substitute(' user &1 in domain &2 ', pcUserName, pcUserDomain)).
        end catch.
    end method.
    
    /** Creates a IUserContext object for a validated user/domain. Will usually be 
        overridden to add more details.
        
        @param character The user name
        @param character The user domain
        @return IUserContext The user's context object */
    method protected IUserContext CreateContextObject(input pcUserName as character,
                                                      input pcUserDomain as character):
        return new UserContext(pcUserName, pcUserDomain).
    end method.
    
    method override public void Initialize(  ):
		super:Initialize().
		
		LoadAuthenticationDomains().
	end method.
	
	method override public void DestroyComponent(  ):
		super:DestroyComponent().
		
		UnloadAuthenticationDomains().
	end method.

    /** Loads the security authentication domains for the application. */
    method abstract void LoadAuthenticationDomains().
    
    /** Unloads the security authentication domains for the application. */
    method abstract void UnloadAuthenticationDomains().
    
    /** Finds/retrieves/calculates a domain key for given context.
                
        @param IUserContext The context for which to find the key 
        @return character The domain key for the given context. */
    method abstract protected character FindDomainKey(input poContext as IUserContext).
    
    /** Logs a user out of the application.
        
        @param IUserContext The (validated) user context object for the given credentials. */
    method public void UserLogout(input poContext as IUserContext):
        EstablishSession(poContext).
        
        poContext:ClientPrincipal:logout().
        
        /* end the session */
        EndSession(poContext:ContextId).
    end method.
    
    /** Logs a user out of the application.
        
        @param longchar The user context ID. */
    method public void UserLogout(input pcContextId as longchar):
        UserLogout(GetUserContext(pcContextId)).
    end method.
		
	constructor public SecurityManager(input poComponentInfo as IComponentInfo):
		super(input poComponentInfo).
	end constructor.

end class.
