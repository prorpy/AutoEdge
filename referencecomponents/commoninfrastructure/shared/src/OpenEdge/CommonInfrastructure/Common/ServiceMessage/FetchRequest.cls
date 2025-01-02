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
    File        : FetchRequest
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 27 14:33:56 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequestCollection.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Lang.Collections.ICollection.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest inherits ServiceRequest
        implements IFetchRequest, IExternalizable:
    
    define public property TableRequests as ITableRequestCollection no-undo
        get():
            if not valid-object(TableRequests) then
                TableRequests = new ITableRequestCollection().

            return TableRequests.
        end get.
        private set.

    constructor public FetchRequest():
        /* default ctor required for serialization */
    end constructor.
    
    constructor public FetchRequest(input pcService as character):
        super(input pcService, input ServiceMessageActionEnum:FetchData).
    end constructor.
    
    constructor public FetchRequest(input pcService as character,
                                    input poMessageType as ServiceMessageActionEnum):
        super(input pcService, input poMessageType).
    end constructor.
    
    constructor public FetchRequest(input pcMessageId as character,
                                    input pcService as character,
                                    input poActionType as ServiceMessageActionEnum):
        super(input pcMessageId, input pcService, input poActionType).
    end constructor.
    
    method override public void WriteObject( input poStream as IObjectOutput ):
        super:WriteObject(poStream).

        poStream:writeObject(TableRequests).        
        poStream:WriteObjectArray(TableRequests:KeySet:ToArray()).
        poStream:WriteObjectArray(TableRequests:Values:ToArray()).
    end method.
    
    method override public void ReadObject(input poStream as IObjectInput):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oKeys as Object extent no-undo.
        define variable oValues as Object extent no-undo.
        
        super:ReadObject(poStream).
        
        assign oKeys = poStream:ReadObjectArray()
               oValues = poStream:ReadObjectArray()
               iMax = extent(oKeys).
        
        do iloop = 1 to iMax:
            TableRequests:Put(oKeys[iLoop], oValues[iLoop]).
        end.
    end method.
    
end class.
