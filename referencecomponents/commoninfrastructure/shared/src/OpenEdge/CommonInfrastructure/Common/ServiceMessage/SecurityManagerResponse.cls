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
    File        : SecurityManagerResponse
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jan 04 14:29:05 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerResponse inherits ServiceResponse
        implements IExternalizable: 
    
    define public property UserContext as IUserContext no-undo get. set.
    
    constructor public SecurityManagerResponse():
        /* default ctor required for serialization */
    end constructor.
     
    constructor public SecurityManagerResponse(input poServiceRequest as SecurityManagerRequest ):
        super (input cast(poServiceRequest, IServiceRequest)).
    end constructor.
    
    method override public void WriteObject(input poStream as IObjectOutput ):
        super:WriteObject(poStream).
        
        poStream:WriteObject(UserContext).
    end method.

    method override public void ReadObject(input poStream as IObjectInput):
        super:ReadObject(poStream).
        
        UserContext = cast(poStream:ReadObject(), IUserContext).
    end method.    
    
    
end class.
