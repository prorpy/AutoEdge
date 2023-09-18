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
    File        : ISecurityManager
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 18 11:53:52 EDT 2010
    Notes       : * Needs to be split into client and server portions
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
  
interface OpenEdge.CommonInfrastructure.Common.ISecurityManager /* inherits IManager */:
    
    /** Returns the current user's context. The current user is the one who has
        a request being serviced by this AVM. */ 
    define public property CurrentUserContext as IUserContext no-undo get.
        
    /** Describes whether the current session is managed or not. */
    define public property IsManagedSession as logical no-undo get.
    
    /** Ends a user's session (not a log out, but the opposite of EstablishSession).
        Ends the current session. */
    method public void EndSession().
    
    /** Sets the passed context into that user's context. 
        
        @param IUserContext The context to merge.   */
    method public void SetUserContext(input poUserContext as IUserContext).
    
    /** Resolves a context ID into a context object.
        
        @param longchar The identifier for the context.
        @return IUserContext The user context object. */
    method public IUserContext GetUserContext(input pcContextId as longchar).
    
    /** Logs a user into the application
    
        @param character The user's login name
        @param character The user's password. This should be encoded/encrypted.
        @return longchar If the login succeeded, the context id of the logged-in
                user. */
    method public longchar UserLogin(input pcUserName as character,
                                     input pcPassword as character).

    /** Logs a user into the application
    
        @param character The user's login name
        @param character The user's login/security domain
        @param character The user's password. This should be encoded/encrypted. 
        @return longchar If the login succeeded, the context id of the logged-in
                user. */
    method public longchar UserLogin(input pcUserName as character,
                                     input pcUserDomain as character,
                                     input pcPassword as character).
        
    /** Authorises the current user to undertake the specified action on the
        service. An error is thrown if the authentication fails.
        
        @param character The service being operated upon.
        @param ServiceMessageActionEnum The Action being performed. */
    method public void AuthoriseServiceAction (input pcService as character,
                                               input poServiceMessageAction as ServiceMessageActionEnum).
    
    /** Authorises the current user to undertake the specified action on the
        service. An error is thrown if the authentication fails. */
    @todo(task="implement", action="").
    method public void AuthoriseOperation(input poOperation as OpenEdge.Lang.EnumMember).
    
end interface.
