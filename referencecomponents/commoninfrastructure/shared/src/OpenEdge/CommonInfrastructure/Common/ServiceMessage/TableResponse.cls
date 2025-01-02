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
    File        : TableResponse
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Aug 30 20:48:33 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.

using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IObjectInput.

using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.String.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableResponse
            implements ITableResponse, IExternalizable:
    
    /** (mandatory) The name of the table */
    define property TableName as character no-undo get. private set.
    
    /** The error texts associated with the request, if any.
        There's an entry in the map for each row that has an error,
        keyed on the RowKey. */
    define public property ErrorText as IMap no-undo
        get():
            if not valid-object(ErrorText) then
                ErrorText = new TypedMap(String:Type, String:Type).
            return ErrorText.
        end get.
        private set.
    
    /** Whether the service request resulted in an error or not. */
    define public property HasError as logical no-undo
        get():
            /* the flag could have been raised without an associated error text. */
            if not HasError then                
                return (not ErrorText:IsEmpty()).
            else
                return HasError.
        end get.
        set.    
    
    /** The ITableContext (page size retrieved, etc) for this response, if any.
        Typically only Fetch actions will have one of these; Save not so much.  */
    define public property TableContext as ITableContext no-undo get. set.
    
    constructor public TableResponse():
        /* default ctor required for serialization */
    end constructor.        
    
    constructor public TableResponse(input pcTableName as character ):
        super().
        
        assign TableName = pcTableName
               HasError = false.
    end constructor.
    
/** IExternalizable **/
    method public void WriteObject(po as IObjectOutput):
        po:WriteChar(TableName).
        po:WriteLogical(HasError).
        po:WriteObject(TableContext).
        
        /* Serialize these separately, so we don't carry all the bumpf along. */
        po:WriteObjectArray(ErrorText:KeySet:ToArray()).
        po:WriteObjectArray(ErrorText:Values:ToArray()).
    end method.
    
    method public void ReadObject(po as IObjectInput):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oKeys as Object extent no-undo.
        define variable oValues as Object extent no-undo.
                
        TableName = po:ReadChar().
        HasError = po:ReadLogical().
        TableContext =  cast(po:ReadObject(), ITableContext).
         
        assign oKeys = po:ReadObjectArray()
               oValues = po:ReadObjectArray()
               iMax = extent(oKeys).
        do iloop = 1 to iMax:
            ErrorText:Put(oKeys[iLoop], oValues[iLoop]).
        end.
    end method.
    
end class.
