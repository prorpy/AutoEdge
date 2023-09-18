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
    File        : BusinessTask
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Jan 26 11:59:49 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.Task.IBusinessTask.

using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.IService.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITaskRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITaskResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TaskResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.String.

class OpenEdge.BusinessComponent.Task.BusinessTask inherits Service
            implements IBusinessTask: 

	define public property Services as IMap no-undo
        get():
            if not valid-object(Services) then
                Services = new Map().
            
            return Services.
        end get.
        private set.
        
    /** Typically we'd only have a single request-response at a time, but we have no
        guarantee of that, so we use a map to be safe. */
    define protected property TaskResponses as IMap no-undo
        get():
            if not valid-object(TaskResponses) then
                TaskResponses = new Map().
            
            return TaskResponses.
        end get.
        private set.
    
	constructor public BusinessTask(input poComponentInfo as IComponentInfo):
		super (input poComponentInfo).
	end constructor.
	
	method public void ExecuteTask(input poRequest as ITaskRequest):
        define variable oIterator as IIterator no-undo.
        define variable oRequest as IServiceRequest extent 1 no-undo.
        define variable oResponse as IServiceResponse extent no-undo.
        define variable oService as IServiceProvider no-undo.
        define variable oTaskResponse as ITaskResponse no-undo.
        
        oTaskResponse = cast(TaskResponses:Put(
                                new String(cast(poRequest, IServiceMessage):MessageId),
                                new TaskResponse(poRequest))
                        , ITaskResponse).
        
        if poRequest:ServiceRequests:Size gt 0 then
        do:
            oIterator = poRequest:ServiceRequests:Iterator().
            do while oIterator:HasNext():
                oRequest[1] = cast(oIterator:Next(), IServiceRequest).
                
                oService = cast(Services:Get(new String(cast(oRequest[1], IServiceMessage):Service)), IServiceProvider).
                oResponse = oService:ExecuteSyncRequest(oRequest).
                oTaskResponse:ServiceResponses:Add(oResponse[1]).
            end.
        end.
	end method.
	
	method public ITaskResponse GetTaskResponse(input pcMessageId as longchar):
	    return cast(TaskResponses:Get(new String(pcMessageId)), ITaskResponse). 
	end method.
	
	method public void SetService(input pcService as character, input poService as IService):
	    Services:Put(new String(pcService), poService).
	end method.

end class.
