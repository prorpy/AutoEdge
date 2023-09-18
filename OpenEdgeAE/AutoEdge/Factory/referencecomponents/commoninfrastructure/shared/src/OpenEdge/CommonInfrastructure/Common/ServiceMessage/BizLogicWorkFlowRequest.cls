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
/* ------------------------------------------------------------------------
    File        : BizLogicWorkFlowRequest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Dec 02 16:01:49 EST 2010
    Notes       : * DataSlotInstances are the payload? 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkflowRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Lang.Collections.ICollection.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.BizLogicWorkFlowRequest inherits ServiceRequest
        implements IWorkflowRequest, IExternalizable:
    
    define public property ProcessInstanceId as int64 no-undo get. set.
    define public property BizLogicServer as longchar no-undo get. set.
    
    constructor public BizLogicWorkFlowRequest():
        /* default ctor required for serialization */
    end constructor.
    
    constructor public BizLogicWorkFlowRequest(input pcMessageId as longchar,
                                               input pcService as character):
        super (pcMessageId, pcService, ServiceMessageActionEnum:PerformWorkFlow).
    end constructor.
    
    constructor public BizLogicWorkFlowRequest (input pcService as character):
        super (pcService, ServiceMessageActionEnum:PerformWorkFlow).
    end constructor.

    method override public void WriteObject(input poStream as IObjectOutput):
        super:WriteObject(poStream).
        
        poStream:WriteInt64(ProcessInstanceId).
        poStream:WriteLongchar(BizLogicServer).
    end method.
    
    method override public void ReadObject(input poStream as IObjectInput):
        super:ReadObject(poStream).
        
        assign ProcessInstanceId = poStream:ReadInt64()
               BizLogicServer = poStream:ReadLongChar().
    end method.    
    
end class.
