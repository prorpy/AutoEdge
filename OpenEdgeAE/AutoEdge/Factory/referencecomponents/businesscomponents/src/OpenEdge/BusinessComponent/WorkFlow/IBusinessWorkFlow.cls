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
    File        : IWorkFlow
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Dec 02 10:33:58 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowResponse.

interface OpenEdge.BusinessComponent.WorkFlow.IBusinessWorkFlow:
    /** (optional) The workflow name. */
    define public property Name as longchar no-undo get. set.
    
    /** Performs the WorkFlow */
    method public void PerformFlow().

    method public void PerformFlow(input poRequest as IWorkflowRequest).
    
    method public IWorkflowResponse GetResponse(input pcMessageId as longchar).

end interface.
