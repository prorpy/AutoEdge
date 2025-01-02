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
    File        : IQuery
    Purpose     : interface for standard query wrapper/object
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jul 31 16:33:06 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.RowPositionEnum.   
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.ITableOwner.
using OpenEdge.Lang.FindTypeEnum.

using OpenEdge.Core.System.EventArgs.

interface OpenEdge.Core.System.IQuery:
    
    /* Events */
    /** Fired when the query is opened or reopened. This event only fires on query represented by the public QueryHandle.
        
        @param IQuery The query being operated on
        @param EventArgs Arguments pertaining to the operation. */
    define public event QueryOpened signature void (input poQuery as IQuery, input poArgs as EventArgs).
    
    /** Fired when the query is closed. This event only fires on query represented by the public QueryHandle.
        
        @param IQuery The query being operated on
        @param EventArgs Arguments pertaining to the operation. */
    define public event QueryClosed signature void (input poQuery as IQuery, input poArgs as EventArgs).

    /** Fired when the query is repositioned. This even only fires on query represented by the 
        public QueryHandle property, not any (internal) clones.
        
        @param IQuery The query being operated on
        @param EventArgs Arguments pertaining to the operation. */
    define public event QueryRepositioned signature void (input poQuery as IQuery, input poArgs as EventArgs).
    
    /** The ABL handle to the underlying query. Read-only. */
    define public property QueryHandle as handle no-undo get.
    
    /** (derived) Is the query open? */
    define public property IsOpen as logical no-undo get.

    define public property Definition as IQueryDefinition no-undo get.
    define public property NumRows as integer no-undo get.
    define public property CurrentRow as integer no-undo get.
    define public property RowPosition as RowPositionEnum no-undo get.
    define public property TableOwner as ITableOwner no-undo get.
    
    method public void Prepare().
    
    /** Resets the query definition to it's original state */
    method public void Reset().
    
    /** Sets the base query definition to the current query definition. */
    method public void Rebase().
    
    /* Constructs an ABL query based on the existing QueryDefinition */
    method public void Open().
    method public logical Close().
        
    method public logical Reopen().
    method public logical Reopen(input pcRowKey as character extent).
    method public logical Reopen(input piRow as integer).
    
    /* position to rowid specified by keys */
    method public logical Reposition(input pcRowKey as character extent).
    /* reposition to row number */
    method public logical Reposition(input piRow as integer).    
    /* navigate through query */
    method public logical GetFirst().
    method public logical GetNext().
    method public logical GetLast().
    method public logical GetPrev().
    
    /* Use method since we can't add a get override for the entire array as property. */
    method public character extent GetRowKey(input piPosition as integer).
    method public character extent GetRowKeyWhere(input poQueryDefinition as IQueryDefinition,    
                                                  input poFindType as FindTypeEnum).
    
    method public character extent GetCurrentRowKey().
    method public character extent GetFirstRowKey().
    method public character extent GetNextRowKey().
    method public character extent GetLastRowKey().
    method public character extent GetPrevRowKey().
    
    method public character GetCurrentBufferKey(input pcBufferName as character).
    method public character GetBufferTableName(input pcBufferName as character).
    
    
    
end interface.
