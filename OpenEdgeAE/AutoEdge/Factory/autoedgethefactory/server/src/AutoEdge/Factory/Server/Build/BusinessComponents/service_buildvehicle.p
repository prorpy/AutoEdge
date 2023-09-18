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
    File        : AutoEdge/Factory/Server/Build/BusinessComponents/service_buildvehicle.p
    Purpose     : 
    Syntax      :
    Description : 
    Author(s)   : pjudge
    Created     : Mon Jul 19 11:33:46 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.BizLogicWorkFlowRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowResponse.
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

using OpenEdge.Lang.ABLSession.
using Progress.Lang.Class.

/* ***************************  parameters, definitions  *************************** */
define input parameter pcOrderId as character no-undo.
define input parameter pcContextId as longchar no-undo.
define input parameter piProcessInstanceId as int64 no-undo.
define input parameter pcProcessInstanceName as character no-undo.

define variable oServiceMgr as IServiceManager no-undo.
define variable oServiceMessageManager as IServiceMessageManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.
define variable oRequest as BizLogicWorkFlowRequest extent 1 no-undo.
define variable oResponse as IWorkflowResponse extent 1 no-undo.

/* ***************************  Main Block  *************************** */
oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).

/* Are we who we say we are? Note that this should really happen on activate. activate doesn't run for state-free AppServers */
oSecMgr = cast(oServiceMgr:StartService(SecurityManager:ISecurityManagerType)
               ,ISecurityManager).

oSecMgr:EstablishSession(pcContextId).
/* add parameter values to the user context */ 

oServiceMessageManager = cast(oServiceMgr:StartService(ServiceMessageManager:IServiceMessageManagerType), IServiceMessageManager).

/* Create the WorkFlowRequest */
oRequest[1] = new BizLogicWorkFlowRequest(entry(1, pcProcessInstanceName, '#')).
oRequest[1]:ProcessInstanceId = piProcessInstanceId.
cast(oRequest[1], IServiceMessage):SetMessageData(pcOrderId).

/* Perform request. This is where the actual work happens. */
oResponse = cast(oServiceMessageManager:ExecuteRequest(oRequest), IWorkflowResponse).

if cast(oResponse[1], IServiceResponse):HasError then
    return error string(cast(oResponse[1], IServiceResponse):ErrorText).

error-status:error = no.
return.
/* EOF */
