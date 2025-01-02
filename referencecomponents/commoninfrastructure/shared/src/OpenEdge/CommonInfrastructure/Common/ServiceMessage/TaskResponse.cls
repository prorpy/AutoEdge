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
    File        : TaskResponse
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Jan 26 12:05:46 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITaskResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITaskRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.TaskResponse inherits ServiceResponse 
        implements ITaskResponse, IExternalizable: 

	define public property ServiceResponses as ICollection no-undo
	   get():
            if not valid-object(ServiceResponses) then
                ServiceResponses = new Collection().
            
            return ServiceResponses.
        end get.
    private set.
		
	constructor public TaskResponse ( input pcMessageId as longchar, input pcService as character, input poActionType as ServiceMessageActionEnum):
		super (input pcMessageId, input pcService, input poActionType).
	end constructor.

	constructor public TaskResponse ( input poServiceRequest as ITaskRequest ):
		super (cast(poServiceRequest, IServiceRequest)).
	end constructor.

	constructor public TaskResponse (  ):
		super ().
	end constructor.

	method override public void ReadObject( input poStream as IObjectInput ):
		super:ReadObject(input poStream).
		
		ServiceResponses:AddArray(poStream:ReadObjectArray()).
	end method.

	method override public void WriteObject( input poStream as IObjectOutput ):
		super:WriteObject(input poStream).
		
		poStream:WriteObjectArray(ServiceResponses:ToArray()).
	end method.

end class.
