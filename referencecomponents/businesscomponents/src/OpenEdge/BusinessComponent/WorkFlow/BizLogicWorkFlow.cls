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
    File        : BizLogicWorkFlow
    Purpose     : Savvion BizLogic workflow class. This can be used to decorate
                  any IWorkFlow class.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Dec 06 11:50:45 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.WorkFlow.WorkFlowDecorator.
using OpenEdge.BusinessComponent.WorkFlow.IBusinessWorkFlow.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.Connection.ServerConnectionError.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnection.

using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Lang.BPM.PriorityEnum.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.WorkFlowWebService.
using OpenEdge.Lang.BPM.DataSlotTemplate.
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.ABLSession.
using Progress.Lang.Class. 

class OpenEdge.BusinessComponent.WorkFlow.BizLogicWorkFlow inherits WorkFlowDecorator:
    
    /** Stores a reference to the session's Service Manager */
    define protected property ServiceManager as IServiceManager no-undo
        get():
            if not valid-object(ServiceManager) then
                ServiceManager = cast(ABLSession:Instance:SessionProperties:Get(OpenEdge.CommonInfrastructure.Common.ServiceManager:IServiceManagerType)
                                    , IServiceManager).
            return ServiceManager.
        end get.
        private set.

    /** The ConnectionManager is used plentifully; we keep it as a property so that
        we can get it whenever needed, without fuss. */
    define protected property ConnectionManager as IConnectionManager no-undo
        get():
            if not valid-object(ConnectionManager) then
                ConnectionManager = cast(ServiceManager:GetService(OpenEdge.CommonInfrastructure.Common.ConnectionManager:IConnectionManagerType)
                                            , IConnectionManager).
            return ConnectionManager.
        end get.
        private set.
    
    /** The logical name of the BPM Server we're interacting with */
    define public property BpmServerName as character no-undo get. protected set.
    
    define protected property BpmServer as IBizLogicAPI no-undo
        get():
            define variable oServerConnection as IServerConnection no-undo.
            
            oServerConnection = ConnectionManager:GetServerConnection(ConnectionTypeEnum:BpmServer, BpmServerName).
            Assert:ArgumentNotNull(oServerConnection, 'BPM Server connection').
            
            if not oServerConnection:IsConnected then
                undo, throw new ServerConnectionError(
                        BpmServerName,
                        oServerConnection:ConnectionParameters:GetConnectionString()).
        
            BpmServer = cast(oServerConnection:Server, IBizLogicAPI).            
        end get.
        private set.
    
    constructor public BizLogicWorkFlow(input poWorkFlow as IBusinessWorkFlow,
                                        input pcBpmServerName as character):
        super (poWorkFlow).
        
        Assert:ArgumentNotNullOrEmpty(pcBpmServerName, 'BPM Server name').
        BpmServerName = pcBpmServerName.
    end constructor.

    /* eaxmple */
	method override public void PerformFlow( ):
	    define variable oDST as DataSlotTemplate extent no-undo.
	    define variable cProcessInstanceNamePrefix as character no-undo.
	    
        BpmServer:CreateProcessInstance(string(this-object:Name),
                                        cProcessInstanceNamePrefix,
                                        PriorityEnum:Medium:Name,
                                        oDST).
	end method.

	method override public void PerformFlow( input poRequest as IWorkflowRequest ):
        Assert:ArgumentNotType(poRequest,
                               Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.BizLogicWorkFlowRequest')).
		
		super:PerformFlow(input poRequest).
	end method.
    
end class.
