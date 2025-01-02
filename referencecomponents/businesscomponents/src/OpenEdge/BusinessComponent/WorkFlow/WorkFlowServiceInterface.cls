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
    File        : WorkFlowServiceInterface
    Purpose     : Decorates a Business WorkFlow with a Service Provider interface -
                  ie. exposes it as an external service.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Dec 07 11:10:29 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.WorkFlow.IBusinessWorkFlow.
using OpenEdge.BusinessComponent.WorkFlow.WorkFlowDecorator.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.

using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.

using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.Assert.

class OpenEdge.BusinessComponent.WorkFlow.WorkFlowServiceInterface inherits WorkFlowDecorator 
        implements IServiceProvider: 

    /** Stores a reference to the session's Service Manager */
    define protected property ServiceManager as IServiceManager no-undo
        get():
            if not valid-object(ServiceManager) then
                ServiceManager = cast(ABLSession:Instance:SessionProperties:Get(OpenEdge.CommonInfrastructure.Common.ServiceManager:IServiceManagerType)
                                    , IServiceManager).
            return ServiceManager.
        end get.
        private set.

    /** The ServiceMessageManager is used plentifully; we keep it as a property so that
        we can get it whenever needed, without fuss. */
    define protected property ServiceMessageManager as IServiceMessageManager no-undo
        get():
            if not valid-object(ServiceMessageManager) then
                ServiceMessageManager = cast(ServiceManager:GetService(OpenEdge.CommonInfrastructure.Common.ServiceMessageManager:IServiceMessageManagerType)
                                          , IServiceMessageManager).
            
            return ServiceMessageManager.
        end get.
        private set.

    /** The service for which this provider is currently servicing a request. */
    define public property Service as character no-undo get. set.
        
    constructor public WorkFlowServiceInterface(input poWorkFlow as IBusinessWorkFlow):
        super(input poWorkFlow).
    end constructor.

    /** External method to dynamically set the service property via InjectABL */
    method public void SetService (input pcService as character):
        this-object:Service = pcService.
    end method.

    method public void ExecuteRequest(input poRequest as IServiceRequest extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oResponse as IServiceResponse extent no-undo.
        
        iMax = extent(poRequest).
        do iLoop = 1 to iMax:
            PerformFlow(cast(poRequest[iLoop], IWorkflowRequest)).
            oResponse[iLoop] = cast(GetResponse(cast(poRequest[iLoop], IServiceMessage):MessageId)
                                , IServiceResponse).
        end.
        
        ServiceMessageManager:ExecuteResponse(oResponse).
    end method.
    
    method public IServiceResponse extent ExecuteSyncRequest(input poRequest as IServiceRequest extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oResponse as IServiceResponse extent no-undo.
        
        iMax = extent(poRequest).
        extent(oResponse) = iMax.
        
        do iLoop = 1 to iMax:
            PerformFlow(cast(poRequest[iLoop], IWorkflowRequest)).
            oResponse[iLoop] = cast(GetResponse(cast(poRequest[iLoop], IServiceMessage):MessageId)
                                , IServiceResponse).
        end.
        
        return oResponse.
    end method.
    
end class.
