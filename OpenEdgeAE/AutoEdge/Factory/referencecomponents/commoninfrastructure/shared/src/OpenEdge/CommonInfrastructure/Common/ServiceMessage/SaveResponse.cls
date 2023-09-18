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
    File        : SaveResponse
    Purpose     : General save response class 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 27 15:09:22 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponseCollection.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequestCollection.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Lang.Collections.ICollection.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.SaveResponse inherits ServiceResponse
        implements ISaveResponse, IExternalizable:
    
    /** A collection of individual table responses for this larger request */ 
    define public property TableResponses as ITableResponseCollection no-undo get. private set.
    
    constructor public SaveResponse():
        /* default ctor required for serialization */
        TableResponses = new ITableResponseCollection().
    end constructor.
    
    /**  Constructor to create a request from a response, so we can tie 'em together again. */
    constructor public SaveResponse(input poServiceRequest as ISaveRequest):
        super (input cast(poServiceRequest, IServiceRequest)).
        
        TableResponses = new ITableResponseCollection().                      
    end constructor.
    
    destructor SaveResponse():
        TableResponses:Clear().
    end destructor.
    
    /** Pre-populates the table response collection from the request's tablerequests */
    method public void InitTableResponseFromRequest(input poRequestCollection as ITableRequestCollection):
        define variable oTableResponse as ITableResponse no-undo.
        define variable oTableRequest as ITableRequest no-undo.
        define variable oIterator as IIterator no-undo.
        
        oIterator = poRequestCollection:KeySet:Iterator().
        do while oIterator:HasNext():
            oTableRequest = cast(oIterator:Next(), ITableRequest).
            oTableResponse = new TableResponse(oTableRequest:TableName).
            oTableResponse:TableContext = CreateContextFromRequest(oTableRequest).
            TableResponses:Put(oTableRequest:TableName, oTableResponse).
        end.
    end method.
    
    method protected ITableContext CreateContextFromRequest(input poTableRequest as ITableRequest):
        @todo(task="implement", action="").
    end method.

    method override public void WriteObject(input poStream as IObjectOutput):
        super:WriteObject(input poStream).
        
        poStream:WriteObjectArray(TableResponses:KeySet:ToArray()).
        poStream:WriteObjectArray(TableResponses:Values:ToArray()).
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
            TableResponses:Put(oKeys[iLoop], oValues[iLoop]).
        end.
    end method.    
    
end class.
