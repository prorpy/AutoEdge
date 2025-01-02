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
    File        : SecurityManagerDecorator
    Purpose     : Decorator class for decoracting/customising Client-side Security Managers
                  without requiring inheritance.
    Syntax      : 
    Description : 
    @author  pjudge
    Created     : Fri Jun 03 13:06:06 EDT 2011
    Notes       : * There's a decent description of Decorator pattern in Wikipedia
                    at http://en.wikipedia.org/wiki/Decorator_pattern
                  * This class should be extended to provide specific functionality.
                    For instance, if we allow logons to a BPM Client. 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Client.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Lang.EnumMember.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Client.SecurityManagerDecorator abstract 
    implements OpenEdge.CommonInfrastructure.Client.ISecurityManager, 
               OpenEdge.CommonInfrastructure.Common.ISecurityManager:
    
    define protected property DecoratedSecurityManager as ISecurityManager no-undo get. private set.
    
    constructor public SecurityManagerDecorator(input poSecMgr as ISecurityManager):
        /* We need to manually check that the decorated SecMgr implements both the Client and common interfaces.
           Once the ABL implements interface inheritance, we can remove this check and also the IMPLEMENTS statement,
           as well as the various CASTs. */
        Assert:ArgumentIsType(poSecMgr, Class:GetClass('OpenEdge.CommonInfrastructure.Common.ISecurityManager')).
    end constructor.

	define public property CurrentUserContext as IUserContext no-undo 
	get():
	    return cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):CurrentUserContext.
    end get.
    
	define public property IsManagedSession as logical no-undo 
	get():
	    return cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):IsManagedSession.
    end get.
    
	method public void AuthoriseOperation(input poOperation as EnumMember ):
	    cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):AuthoriseOperation(poOperation).
	end method.

	method public void AuthoriseServiceAction( input pcService as character, input poServiceMessageAction as ServiceMessageActionEnum ):
		cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):AuthoriseServiceAction(pcService, poServiceMessageAction).
	end method.

	method public void EndSession():
	    cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):EndSession().
	end method.

	method public IUserContext GetUserContext( input pcContextId as longchar ):
	    return cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):GetUserContext(pcContextId).
	end method.

	method public void SetUserContext( input poUserContext as IUserContext ):
	    cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):SetUserContext(poUserContext).
	end method.

	method public longchar UserLogin( input pcUserName as character, input pcPassword as character ):
	    return cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):UserLogin(pcUserName, pcPassword).
	end method.

	method public longchar UserLogin( input pcUserName as character, input pcUserDomain as character, input pcPassword as character ):
        return cast(DecoratedSecurityManager, OpenEdge.CommonInfrastructure.Common.ISecurityManager):UserLogin(pcUserName, pcUserDomain, pcPassword).		
	end method.

	method public IUserContext GetPendingContext(  ):
	    return DecoratedSecurityManager:GetPendingContext().
	end method.
	
	method public void UserLogout(  ):
	    DecoratedSecurityManager:UserLogout().
	end method.

end class.
