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
    File        : ServiceResponse
    Purpose     : General response class for service messages that are requests 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Aug 24 16:21:47 EDT 2010
    Notes       : * This general response also contains information about
                    errors on the request.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceResponse inherits ServiceMessage
            implements IServiceResponse, IExternalizable:
    
    /** Was there an error on the request? */
    define public property HasError as logical no-undo get. set.
    
    /** If an error occurred, some text related to the error. Could 
       be some meaningful or structured text. Could be a serialized 
       Progress.Lang.Error object. */
    define public property ErrorText as longchar no-undo get. set.
    
    constructor public ServiceResponse():
        /* default ctor required for serialization */
    end constructor.
        
    constructor public ServiceResponse(input pcMessageId as longchar,
                                       input pcService as character,
                                       input poActionType as ServiceMessageActionEnum ):
        super (input pcMessageId, input pcService, input poActionType).
    end constructor.
    
    constructor public ServiceResponse (input poServiceRequest as IServiceRequest):
        super(input cast(poServiceRequest, IServiceMessage):MessageId,
              input cast(poServiceRequest, IServiceMessage):Service,
              input cast(poServiceRequest, IServiceMessage):ActionType).
    end constructor.    

    method override public void WriteObject(input poStream as IObjectOutput):
        super:WriteObject(poStream).
        
        poStream:WriteLogical(HasError).
        poStream:WriteLongchar(ErrorText).
    end method.
    
    method override public void ReadObject(input poStream as IObjectInput):
        super:ReadObject(poStream).
        
        assign HasError = poStream:ReadLogical()
               ErrorText = poStream:ReadLongchar().
    end method.

end class.
