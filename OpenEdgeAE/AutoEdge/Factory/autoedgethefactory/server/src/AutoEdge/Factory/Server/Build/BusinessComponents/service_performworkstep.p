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
/*------------------------------------------------------------------------
    File        : AutoEdge/Factory/Server/Build/BusinessComponents/service_performworkstep.p
    Purpose     : 
    Syntax      :
    Description : 
    Author(s)   : pjudge
    Created     : Mon Jul 19 11:33:46 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.WorkStepRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.CommonInfrastructure.Server.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.CommonInfrastructure.Common.UserContext.

using OpenEdge.Core.System.ApplicationError.

using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.AppError.
using Progress.Lang.Error.

/** -- params, defs -- **/
define input parameter pcWorkFlowName as character no-undo.             /* expecting 'BuildVehicle' or similar. */
define input parameter pcWorkstepName as character no-undo.             /* expecting 'ProcessComponents' or 'AssembleChassis' or similar. */
define input parameter pcOrderId as character no-undo.
define input parameter pcUserContextId as longchar no-undo.
/* return */
define output parameter pcBuildStatus as longchar no-undo.

define variable oServiceMessageManager as IServiceMessageManager no-undo.
define variable oServiceMgr as IServiceManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.
define variable oRequest as IWorkstepRequest extent 1 no-undo.
define variable oResponse as IWorkstepResponse extent 1 no-undo.

/** Dummy return for modelling purposes (Savvion lets us make a test call to a WebService). */
if pcUserContextId eq 'Savvion::Test' then
do:
    pcBuildStatus = 'pcBuildStatus'.
    return.
end.

pcBuildStatus = ' [DEBUG] RETURN.'.
/* [DEBUG] */ RETURN.


/** -- validate defs -- **/
Assert:ArgumentNotNullOrEmpty(pcWorkFlowName, 'Workflow Name').
Assert:ArgumentNotNullOrEmpty(pcWorkstepName, 'Workstep Name').
Assert:ArgumentNotNullOrEmpty(pcOrderId, 'Order Id').
Assert:ArgumentNotNullOrEmpty(pcUserContextId, 'User Context Id').

/** -- main -- **/
oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).

/* Are we who we say we are? Note that this should really happen on activate. activate doesn't run for state-free AppServers */
oSecMgr = cast(oServiceMgr:StartService(SecurityManager:ISecurityManagerType)
               ,ISecurityManager).

/* log in and establish tenancy, user context */
oSecMgr:EstablishSession(pcUserContextId).

/* add parameter values to the user context */
oServiceMessageManager = cast(oServiceMgr:StartService(ServiceMessageManager:IServiceMessageManagerType), IServiceMessageManager).

/* Create the WorkStepRequest */
oRequest[1] = new WorkstepRequest(substitute('&1::&2', pcWorkFlowName, pcWorkstepName)).
oRequest[1]:Name = pcWorkstepName.
cast(oRequest[1], IServiceMessage):SetMessageData(pcOrderId).

/* Perform request. This is where the actual work happens. */
oResponse = cast(oServiceMessageManager:ExecuteRequest(cast(oRequest, IServiceRequest)), IWorkstepResponse).
if cast(oResponse[1], IServiceResponse):HasError then
do:
    pcBuildStatus = cast(oResponse[1], IServiceResponse):ErrorText.
    return error string(pcBuildStatus).
end.

pcBuildStatus = oResponse[1]:Status.

error-status:error = no.
return.

/** -- error handling -- **/
catch oApplError as ApplicationError:
    return error oApplError:ResolvedMessageText().
end catch.

catch oAppError as AppError:
    return error oAppError:ReturnValue. 
end catch.

catch oError as Error:
    return error oError:GetMessage(1).
end catch.
/** -- eof -- **/
