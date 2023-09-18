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
    File        : SecurityManagerRequest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jan 04 14:28:49 EST 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum. 
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequest.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Lang.Collections.ICollection.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerRequest inherits ServiceRequest
        implements IExternalizable:
    
    /* name of the user to whom this context applies */
    define public property UserName as character no-undo get. set.
    
    /* domain of the user to whom this context applies */
    define public property UserDomain as character no-undo get. set.
    
    /* name of the user to whom this context applies */
    define public property UserPassword as character no-undo get. set.
    
    /** Unique identifier for the client session */
    define public property ContextId as longchar no-undo get.  set.
    
    /** The user context for this request. */
    define public property UserContext as IUserContext no-undo get. set.
    
    constructor public SecurityManagerRequest ():
        /* default ctor required for serialization */
    end constructor.
    
    constructor public SecurityManagerRequest (input pcService as character,
                                               input poMessageType as ServiceMessageActionEnum ):
        super (input pcService, input poMessageType).
    end constructor.
    
    method override public void WriteObject(input poStream as IObjectOutput):
        super:WriteObject(input poStream).

        poStream:WriteChar(UserName).
        poStream:WriteChar(UserDomain).
        poStream:WriteChar(UserPassword).
        poStream:WriteLongChar(ContextId).
        poStream:WriteObject(UserContext).
    end method.
    
    method override public void ReadObject(input poStream as IObjectInput):
        super:ReadObject(input poStream).
        
        assign UserName = poStream:ReadChar()
               UserDomain = poStream:ReadChar()
               UserPassword = poStream:ReadChar()
               ContextId = poStream:ReadLongChar()
               UserContext = cast(poStream:ReadObject(), IUserContext).
    end method.
        
end class.
