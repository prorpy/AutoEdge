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
    File        : SaveRequest
    Purpose     : A request for committing data.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 27 15:04:55 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Lang.Collections.ICollection.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.SaveRequest inherits ServiceRequest
        implements ISaveRequest, IExternalizable:
    
    define public property TableNames as character extent no-undo get. set. 

    constructor public SaveRequest():
        /* default ctor required for serialization */
    end constructor.

    constructor public SaveRequest(input pcService as character):
        super(pcService, ServiceMessageActionEnum:SaveData).
    end constructor.
    
    constructor public SaveRequest(input pcMessageId as character,
                                   input pcService as character):
        super(pcMessageId, pcService, ServiceMessageActionEnum:SaveData).
    end constructor.

    constructor public SaveRequest(input pcService as character,
                                   input poMessageType as ServiceMessageActionEnum ):
        super (input pcService, input poMessageType).
    end constructor.
        
    constructor public SaveRequest(input pcMessageId as character,
                                   input pcService as character,
                                   input poActionType as ServiceMessageActionEnum ):
        super (input pcMessageId, input pcService, input poActionType).
    end constructor.

    method override public void WriteObject(input poStream as IObjectOutput):
        super:WriteObject(poStream).

        poStream:WriteCharArray(TableNames).
    end method.

    method override public void ReadObject(input poStream as IObjectInput):
        super:ReadObject(poStream).
        
        TableNames = poStream:ReadCharArray().
    end method.
    
end class.
