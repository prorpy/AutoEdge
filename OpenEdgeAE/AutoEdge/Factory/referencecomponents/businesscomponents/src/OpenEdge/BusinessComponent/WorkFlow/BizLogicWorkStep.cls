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
    File        : BizLogicWorkStep
    Purpose     : Savvion BizLogic workflow class. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Dec 06 13:45:41 EST 2010
    Notes       : * This might be used when we complete a step, and want to notify
                    the Savvion process of that fact. Or when we want to update 
                    DataSlotValues on completion.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.WorkFlow.WorkStepDecorator.
using OpenEdge.BusinessComponent.WorkFlow.WorkStep.
using OpenEdge.BusinessComponent.WorkFlow.IWorkStep.


using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.BizLogicWorkStepRequest.

using OpenEdge.CommonInfrastructure.Common.Connection.ServerConnectionError.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnection.

using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.ABLSession.
using Progress.Lang.Class. 


class OpenEdge.BusinessComponent.WorkFlow.BizLogicWorkStep abstract inherits WorkStepDecorator:
    
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
    
    define protected property CurrentRequest as BizLogicWorkStepRequest no-undo get. set.
    
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
    
    constructor public BizLogicWorkStep(input poWorkStep as IWorkStep,
                                        input pcBpmServerName as character):
        super (poWorkStep).
        
        Assert:ArgumentNotNullOrEmpty(pcBpmServerName, 'BPM Server name').
        BpmServerName = pcBpmServerName.
    end constructor.
    
    method override public void PerformStep( input poRequest as IWorkstepRequest):
        define variable oBLRequest as BizLogicWorkStepRequest no-undo.
        
        Assert:ArgumentNotType(poRequest,
                               Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.BizLogicWorkStepRequest')).
        
        CurrentRequest = cast(poRequest, BizLogicWorkStepRequest).
        
        super:PerformStep(input poRequest).
        finally:        
            CurrentRequest = ?.
        end finally.
    end method.
    
    method override public void PerformStep():
        define variable oDSI as DataSlotInstance extent no-undo.
        
        super:PerformStep().
        
        /* Complete the step in Bizlogic */
        CompleteWorkItem(oDSI).
    end method.
    
    method protected void CompleteWorkItem(input poDataSlotInstance as DataSlotInstance extent):
        BpmServer:CompleteWorkItem(string(Name), poDataSlotInstance).
    end method.

    method protected void UpdateDataSlotValue(input pcDataSlotName as character extent,
                                              input pcDataSlotValue as character extent):
        define variable oDataSlotInstance as DataSlotInstance extent no-undo.
        define variable iInnerLoop as integer no-undo.
        define variable iInnerMax as integer no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.

        oDataSlotInstance= BpmServer:GetProcessInstanceDataSlot(
                                CurrentRequest:ProcessInstanceId,
                                pcDataSlotName).
        iMax = extent(oDataSlotInstance).
        iInnerMax = extent(pcDataSlotName).
        do iLoop = 1 to iMax:
            
            do iInnerLoop = 1 to iInnerMax:
                if pcDataSlotName[iInnerLoop] eq oDataSlotInstance[iLoop]:Name then
                do:
                    oDataSlotInstance[iLoop]:Value = pcDataSlotValue[iInnerLoop].
                    leave.
                end.
            end.    /* inner loop */
        end. /* outer loop */
        
        BpmServer:SetProcessInstanceDataSlotsValue(
                            CurrentRequest:ProcessInstanceName,
                            oDataSlotInstance).
    end method.

end class. 
