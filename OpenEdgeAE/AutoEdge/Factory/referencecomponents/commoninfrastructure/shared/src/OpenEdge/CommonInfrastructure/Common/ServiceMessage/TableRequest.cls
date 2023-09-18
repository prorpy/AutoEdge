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
    File        : TableRequest
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 27 14:42:27 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.

using OpenEdge.Core.System.QueryDefinition.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IObjectInput.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Map.

using OpenEdge.Lang.FillModeEnum.
using OpenEdge.Lang.FindTypeEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.String.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest inherits QueryDefinition
        implements ITableRequest, IExternalizable: 
    
    /** protected set - not changeable - provide with constructor  */  
    define property TableName as char no-undo get. private set.
    
    /** The number of records to return per page or batch */
    define property PageSize as integer no-undo get. set.
    
    /** The default FillMode for this request. */
    define property FillMode as FillModeEnum no-undo
        get():
            if not valid-object(FillMode) then
                FillMode = FillModeEnum:Default.
            return FillMode.
        end get.
        set.
    
    /** Retrieve full page when page position is at beginning or end of result-set */
    define property FullPage as logical no-undo get. set.

    /** The number of remaining pages to retrieve. If this is zero, then
        all data has been retrieved. */
    define public property NumRemainingPages as integer no-undo get. set.
    
    define property TableRequestType as TableRequestTypeEnum no-undo
        get():
            if not valid-object(TableRequestType) then
                TableRequestType = TableRequestTypeEnum:Default.
            return TableRequestType.
        end get.
        set.
    
    /** context info/key for where to start appending page begin or end */
    define property PageContext as char extent no-undo get. set.
    
    /** Return page positioned to this key (i.e. resort request/ reopen ) 
        Typically used with TableRequestTypeEnum:Position */ 
    define property RowKey as char extent no-undo get. set.
    
    define protected property QuerySearch as IMap no-undo
        get():
            if not valid-object(QuerySearch) then
                QuerySearch = new Map().
            return QuerySearch.
        end get.
        private set.
    
    /* default ctor required for serialization */
    constructor public TableRequest():
        super().
    end constructor.
    
    constructor public TableRequest(pcTableName as character):
        this-object().
        
        TableName = pcTableName.
        AddBuffer(TableName).
    end constructor.
    
    /** Add search expression  (need to be kept separate from filter.). 
       - Allthough this in theory could be any complex expression it normally 
         only makes sense when the field(s) correspond(s) to the sort.    
       - AddSearch can be refactored to have type-specific signatures, removing the need to pass a
         DataTypeEnum. */
    method public void AddSearch(pcBufferName as character,
                                 pcFieldName as character,
                                 poOperator as OperatorEnum,
                                 poFieldValue as String,
                                 poFieldType as DataTypeEnum,
                                 poJoinType as JoinEnum):
        QuerySearch:Put(
            new QueryFilter(pcBufferName,
                        pcFieldName,
                        poOperator,
                        poFieldValue,
                        poFieldType,
                        poJoinType),
            new String(pcBufferName)).
    end method.
    
    method public void GetSearch(pcBufferName as character,
                                 output pcFieldName as character extent,
                                 output poOperator as OperatorEnum extent,
                                 output poFieldValue as String extent,
                                 output poFieldType as DataTypeEnum extent,
                                 output poJoinType as JoinEnum extent):
                            
        @todo(task="implement", action="").
    end method.
    
    method public longchar BuildSearchString():
        return GetQueryString().
    end method.

/** IExternalizable **/
    method override public void WriteObject(po as IObjectOutput):
        super:WriteObject(po).
        
        po:WriteChar(TableName).
        po:WriteInt(PageSize).
        po:WriteEnum(FillMode).
        po:WriteLogical(FullPage).
        po:WriteInt(NumRemainingPages).
        po:WriteEnum(TableRequestType).
        po:WriteCharArray(PageContext).
        po:WriteCharArray(RowKey).
        
        po:WriteObjectArray(QuerySearch:KeySet:ToArray()).
        po:WriteObjectArray(QuerySearch:Values:ToArray()).
    end method.
    
    method override public void ReadObject(po as IObjectInput):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oKeys as Object extent no-undo.
        define variable oValues as Object extent no-undo.
                
        super:ReadObject(po).
        
        TableName = po:ReadChar().
        PageSize = po:ReadInt().
        FillMode = cast(po:ReadEnum(), FillModeEnum).
        FullPage = po:ReadLogical().
        NumRemainingPages = po:ReadInt().
        TableRequestType = cast(po:ReadEnum(), TableRequestTypeEnum).
        PageContext = po:ReadCharArray().
        RowKey = po:ReadCharArray().
        
        assign oKeys = po:ReadObjectArray()
               oValues = po:ReadObjectArray()
               iMax = extent(oKeys).
        do iloop = 1 to iMax:
            QuerySearch:Put(oKeys[iLoop], oValues[iLoop]).
        end.
    end method.
    
end class.
