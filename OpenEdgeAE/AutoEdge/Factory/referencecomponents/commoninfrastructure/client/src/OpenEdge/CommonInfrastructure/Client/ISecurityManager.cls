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
    Purpose     : Interface for client-side security manager operations.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 06 14:39:50 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.IUserContext.
  
interface OpenEdge.CommonInfrastructure.Client.ISecurityManager /* inherits OpenEdge.CommonInfrastructure.Common.ISecurityManager */ :

    /** Retrieves or build user context for passing across the wire (in either direction).
        The complement to this method is the SetUserContext() method, which will be invoked
        after the call across the wire.

        @return IUserContext User context for sending across the wire */
    method public IUserContext GetPendingContext().
    
    /** Logs the current user out of the application. */
    method public void UserLogout().
    
end interface.
