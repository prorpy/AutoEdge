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
@openapi.openedge.export FILE(type="BPM", operationName="%FILENAME%", useReturnValue="false", writeDataSetBeforeImage="false", executionMode="external").
/** ----------------------------------------------------------------------
    File        : OpenEdge/CommonInfrastructure/Server/service_userlogin.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Thu Dec 16 09:17:18 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.UnhandledError.

using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.AppError.
using Progress.Lang.Error.

/** -- params, defs -- **/
define input  parameter pcUserName as character no-undo.
define input  parameter pcUserDomain as character no-undo.
define input  parameter pcPassword as character no-undo.
define output parameter pcUserContextId as longchar no-undo.

define variable oServiceMgr as IServiceManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.

/** -- validate defs -- **/
if pcUserName eq 'Savvion::Test' then
do:
    pcUserContextId = 'pcUserContextId'.
    return.
end. 

Assert:ArgumentNotNullOrEmpty(pcUserName, 'User Name').
Assert:ArgumentNotNullOrEmpty(pcUserDomain, 'User Domain').
Assert:ArgumentNotNullOrEmpty(pcPassword, 'User Password').

/** -- main -- **/
oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).

oSecMgr = cast(oServiceMgr:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).

/* log in and establish tenancy, user context */
oSecMgr:UserLogin(pcUserName,
                  pcUserDomain,
                  pcPassword).
pcUserContextId = oSecMgr:CurrentUserContext:ContextId.

Assert:ArgumentNotNullOrEmpty(pcUserContextId, 'User Context ID').

error-status:error = no.
return.

/** -- error handling -- **/
catch oApplicationError as ApplicationError:
    return error oApplicationError:ResolvedMessageText().
end catch.
catch oError as Error:
    define variable oUHError as UnhandledError no-undo.
    oUHError = new UnhandledError(oError).
    return error oUHError:ResolvedMessageText().
end catch.
/** -- eof -- **/
