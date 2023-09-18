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
    File        : WorkStep
    Purpose     : WorkFlow WorkStep 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Dec 06 13:14:00 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.WorkFlow.IWorkStep.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.WorkstepResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.InvocationError.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.

class OpenEdge.BusinessComponent.WorkFlow.WorkStep abstract inherits Service
        implements IWorkStep:
    
    /** [IWorkStep] (optional) The workstep name. Defaults to the service name in this case. */
    define public property Name as character no-undo get. set.

    /** Typically we'd only have a single request-response at a time, but we have no
        guarantee of that, so we use a map to be safe. */
    define protected property WorkstepResponses as IMap no-undo get. private set.
    
    constructor public WorkStep(input poComponentInfo as IComponentInfo):
        super(poComponentInfo).
        
        WorkstepResponses = new TypedMap(
                                      String:Type, 
                                      Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepResponse')).
    end constructor.
    
    destructor public WorkStep():
        WorkstepResponses:Clear().
    end destructor.
    
    /** External method to dynamically set the service property via InjectABL */
    method public void SetName (input pcName as character):
        this-object:Name = pcName.
    end method.
    
    method public void PerformStep(input poRequest as IWorkstepRequest):
        WorkstepResponses:Put(new String(cast(poRequest, IServiceMessage):MessageId),
                              new WorkstepResponse(poRequest)).
        
        PerformStep().
        
        catch oError as ApplicationError:
            define variable oCurrentResponse as IServiceResponse no-undo.
            
            oCurrentResponse = cast(WorkstepResponses:Get(new String(cast(poRequest, IServiceMessage):MessageId))
                                , IServiceResponse).
            assign oCurrentResponse:HasError = true
                   oCurrentResponse:ErrorText = oError:ResolvedMessageText().
            undo, throw oError. 
        end catch.
    end method.
    
    /** Perform the actual step. Each concrete implementation of this
        class does something different.
        
        Note: make sure this method appears after PerformStep(IWorkstepRequest) because
        of bug OE00202799  */
    method abstract public void PerformStep().        
    
    method public IWorkstepResponse GetResponse(input pcMessageId as longchar):
        return cast(WorkstepResponses:Remove(new String(pcMessageId)), IWorkstepResponse).        
    end method.
    
end class.
