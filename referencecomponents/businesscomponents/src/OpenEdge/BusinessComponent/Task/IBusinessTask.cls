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
    File        : IBusinessTask
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Jan 26 10:15:53 EST 2011
    Notes       : * This task represents a collection of entities.
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITaskRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITaskResponse.
using OpenEdge.CommonInfrastructure.Common.IService.

using OpenEdge.Lang.Collections.IMap.

interface OpenEdge.BusinessComponent.Task.IBusinessTask:
    
    /** Contains a collection of the entities that this Task knows about and operates on with. */
    define public property Services as IMap no-undo get.
    
    /** Sets a business entity into the Services map. Used to work around 
        the lack of dynamic property invocation in the ABL in 10.2Bx.
        
        @param character The service name represented by the entity
        @param IService The service used. Typically an entity */
    method public void SetService(input pcService as character, input poService as IService).
    
    /** Executes a requested task 
        
        @param ITaskRequest The request for this task */
    method public void ExecuteTask(input poRequest as ITaskRequest).
    
    /** Response complement method for ExecuteTask.
        
        @param character The message id for the *Task* request/response
        @return ITaskResponse The response */
    method public ITaskResponse GetTaskResponse(input pcMessageId as longchar).       
    
end interface.
