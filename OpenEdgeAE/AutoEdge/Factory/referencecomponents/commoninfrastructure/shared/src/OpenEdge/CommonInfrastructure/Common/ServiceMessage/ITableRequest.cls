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
    File        : ITableRequest
    Purpose     : Interface for table fetch request  
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Tue Feb 09 18:28:13 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.

using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Lang.FillModeEnum.
using OpenEdge.Lang.FindTypeEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.String.

interface OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest inherits IQueryDefinition:
    
    /** protected set - not changeable - provide with constructor  */  
    define property TableName as char no-undo get.
    
    /** The number of records to return per page or batch */
    define property PageSize as integer no-undo get. set.
    
    /** The default FillMode for this request. */
    define property FillMode as FillModeEnum no-undo get. set.
    
    /** Retrieve full page when page position is at beginning or end of result-set */
    define property FullPage as logical no-undo get. set.

    /** The number of remaining pages to retrieve. If this is zero, then
        all data has been retrieved. This value is returned from the server/business
        component layer. */
    define public property NumRemainingPages as integer no-undo get. set.
    
    define property TableRequestType as TableRequestTypeEnum no-undo get. set.

    /** context info/key for where to start appending page begin or end */
    define property PageContext as char extent no-undo get. set.
    
    /** Return page positioned to this key (i.e. resort request/ reopen ) 
        Typically used with TableRequestTypeEnum:Position */                
    define property RowKey as char extent no-undo get. set.
    
    @todo(task="question", action="no fill mode on tablerequest? ").

    /** Add search expression  (need to be kept separate from filter). 
       - Allthough this in theory could be any complex expression it normally 
         only makes sense when the field(s) correspond(s) to the sort.    
       - AddSearch can be refactored to have type-specific signatures, removing the need to pass a
         DataTypeEnum. */
    method public void AddSearch (input pcBufferName as char,
                                  input pcFieldName as char,
                                  input poOperator as OperatorEnum,
                                  input poFieldValue as String,
                                  input poFieldType as DataTypeEnum,
                                  input poJoinType as JoinEnum).
    
    method public void GetSearch (input pcBufferName as char,
                                  output pcFieldName as char extent,
                                  output poOperator as OperatorEnum extent,
                                  output pcFieldValue as String extent,
                                  output poFieldType as DataTypeEnum extent,
                                  output poJoinType as JoinEnum extent).
    
    /** returns the search expression applied to the BuildQueryString */
    method public longchar BuildSearchString().
    
end interface.
