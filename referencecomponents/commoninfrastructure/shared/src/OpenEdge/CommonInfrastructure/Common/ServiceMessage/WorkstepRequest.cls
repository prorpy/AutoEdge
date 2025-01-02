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
    File        : WorkstepRequest
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 01 19:04:36 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.WorkstepRequest inherits ServiceRequest
        implements IWorkStepRequest, IExternalizable:
    
    /** (optional) The workstep name. */
    define public property Name as longchar no-undo
       get():
           if this-object:Name eq ? or this-object:Name eq '' then
               Name = Service.
       end get.
       set.
    
    constructor public WorkstepRequest():
        /* default ctor required for serialization */
    end constructor.
    
    constructor public WorkstepRequest(input pcService as character):
        super (input pcService, ServiceMessageActionEnum:PerformWorkStep).
    end constructor.
    
    constructor public WorkstepRequest ( input pcMessageId as longchar, input pcService as character):
        super (input pcMessageId, input pcService, input ServiceMessageActionEnum:PerformWorkStep).
    end constructor.

    method override public void WriteObject(input poStream as IObjectOutput):
        super:WriteObject(poStream).
        
        poStream:WriteLongchar(Name).
    end method.

    method override public void ReadObject(input poStream as IObjectInput):
        super:ReadObject(poStream).
        
        name = poStream:ReadLongchar().
    end method.
    
end class.
