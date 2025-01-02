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
    File        : IQueryDefinition
    Purpose     : Interface for query definition: the decomposed parts of a query. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Mar 27 16:06:04 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryDefinitionEventArgs.
using OpenEdge.Core.System.QueryBuffer.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.QueryJoin.
using OpenEdge.Core.System.QuerySort.

using OpenEdge.Lang.QueryBlockTypeEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.LockModeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.QueryTypeEnum.
using OpenEdge.Lang.SortDirectionEnum.
using OpenEdge.Lang.String.

using Progress.Lang.Object.

interface OpenEdge.Core.System.IQueryDefinition:
    
    /* Allows us to optimize building of queries (ie we don't need to create a new buffer).
       The setting of the *Changed properties to FALSE is an exogenous event: whoever's
       using this object needs to do that. It will probably happen on open. */
    define public event QueryDefinitionChanged signature void (input poQueryDefinition as IQueryDefinition,
                                                               input poEventArgs as QueryDefinitionEventArgs).
                           
    define public property QueryBlockType as QueryBlockTypeEnum no-undo get. set.
    define public property NumBuffers as integer no-undo get.
    
    @todo(task="refactor", action="make oo-ish").
    /*
    /* buffers are ordered, keyed on nameIList or IMap?  */
    define public property Buffers as IList no-undo get. private set.
    define public property Joins as ICollection no-undo get. private set.
    define public property Filters as ICollection no-undo get. private set.
    /* sorting is ordered */
    define public property Sorts as IList no-undo get. private set.
    */
    
    /** Indicates whether the query can join to tables outside of this query definition. This may
        happen in some cases; for instance when dealing with DataSourceQuery objects which are used
        for DATA-SOURCE queries for ProDataSets.
        
        An external join is assumed to apply only to the 2nd (JoinBuffer) buffer in the QueryJoin. */        
    define public property AllowExternalJoins as logical no-undo get. set.
    
    /* Old-school */
    method public void ClearAll().
    method public void ClearBuffers().
    method public void ClearFilters().
    method public void ClearSort().
    method public void ClearJoins().
    
    method public void SetBuffers(input pcBuffer as character extent, input pcTable as character extent).
    method public void SetBuffers(input pcBuffer as character extent).
    
    method public void AddBuffer(input pcBuffer as character).
    method public void AddBuffer(input pcBuffer as character, input pcTable as character).    
    method public void AddBuffer(input pcBuffer as character,
                                 input pcTable as character,
                                 input poQueryType as QueryTypeEnum,
                                 input poLockMode as LockModeEnum).
    
    method public void AddBuffer(input poQueryBuffer as QueryBuffer).
    
    method public void RemoveBuffer(input pcBuffer as character).
    method public void RemoveBuffer(input poQueryBuffer as QueryBuffer).
    
    /* IQuery will use these methods when constructing an ABL query */
    method public character extent GetBufferList().
    method public character extent GetBufferList(output pcTables as char extent,
                                                 output poQueryTypes as QueryTypeEnum extent,
                                                 output poLockModes as LockModeEnum extent).
    
    /** Returns the buffers in the definition. 
        
        @return QueryBuffer[] An ordered array of buffers in this definition. */
    method public QueryBuffer extent GetQueryBuffers().

    method public void SetBufferTable(input pcBuffer as character, input pcTable as character).
    method public void SetBufferLockMode(input pcBuffer as character, input poLockMode as LockModeEnum).   /* OpenEdge.System.Core.LockModeEnum  */
    method public void SetBufferQueryType(input pcBuffer as character, input poQueryType as QueryTypeEnum). /* OpenEdge.System.Core.QueryTypeEnum */
    
    method public character GetBufferTable(input pcBuffer as character).
    method public LockModeEnum GetBufferLockMode(input pcBuffer as character).    /* OpenEdge.System.Core.LockModeEnum */
    method public QueryTypeEnum GetBufferQueryType(input pcBuffer as character).
    
    @todo(task="Refactor AddFilter to have type-specific signatures; remove need to pass DataTypeEnum. ").
    /** Filter the query per the arguments.
        
        @param character The buffer name being filtered 
        @param character The buffer field being filtered
        @param OperatorEnum The operator (=,>, etc)
        @param String The string value for the filter.
        @param DataTypeEnum The datatype being stored in the string parameter.
        @param JoinEnum The join type (and/or etc) for the filter. */
    method public void AddFilter (input pcBufferName as character,
                                  input pcFieldName as character,
                                  input poOperator as OperatorEnum,
                                  input poFieldValue as String,
                                  input poFieldType as DataTypeEnum,
                                  input poJoinType as JoinEnum).
    
    /** Filter the query per the arguments.
                    
        @param QueryFilter The query filter used to filter the query. */                                  
    method public void AddFilter (input poQueryFilter as QueryFilter).
    
    /** Removes a filter clause from then definition.
        
        @param QueryFilter The query filter used to filter the query. */
    method public void RemoveFilter (input poQueryFilter as QueryFilter).
    
    /** Create a join between 2 buffers in this definition.
        
        @param character The first buffer name in the join
        @param character The first buffer field in the join
        @param OperatorEnum The operator (=,>, etc)
        @param character The second buffer name in the join
        @param character The second buffer field in the join
        @param JoinEnum The join type (and/or etc) for the filter. */
    method public void AddJoin (input pcBufferName as character,
                                input pcFieldName as character,
                                input poOperator as OperatorEnum,
                                input pcJoinBufferName as character,
                                input pcJoinFieldName as character,
                                input poJoinType as JoinEnum).

    /** Create a join between 2 buffers in this definition.
    
        @param QueryJoin Parameters for the join. */    
    method public void AddJoin(input poQueryJoin as QueryJoin).

    /** Removes a join between 2 buffers in this definition.
    
        @param QueryJoin Parameters for the join. */    
    method public void RemoveJoin(input poQueryJoin as QueryJoin).

    /** Add a sort condition to the definition.
    
        @param character The buffer being sorted
        @param character The field being sorted
        @param SortDirection The direction of the sort. */
    method public void AddSort (input pcBufferName as character,
                                input pcFieldName as character,
                                input poSortDirection as SortDirectionEnum).

    /** Add a sort condition to the definition.
        
        @param character The buffer being sorted
        @param character The field being sorted
        @param SortDirection The direction of the sort.
        @param integer The ordinal position of the sort phrase for the buffer. */
    method public void AddSort (input pcBufferName as character,
                                input pcFieldName as character,
                                input poSortDirection as SortDirectionEnum,
                                input piPosition as integer).
    
    /** Add a sort condition to the definition.
        
        @param QuerySort Parameters for the sort. */ 
    method public void AddSort(input poQuerySort as QuerySort).
    
    /** Removes a sort condition to the definition.
        
        @param QuerySort Parameters for the sort. */ 
    method public void RemoveSort(input poQuerySort as QuerySort).
    
    /** Returns the complete query string (ready for QUERY-PREPARE).
        
        @param longchar The complete query prepare string. */
    method public longchar GetQueryString().
    
    
    /** Returns the complete query string (ready for QUERY-PREPARE).
        
        @param character[] An array of buffer names for which 
               return a where clause that filters and joins between all
               buffers.
        @return longchar The query clause string. */
    method public longchar GetQueryString(input pcBufferName as character extent).
    
    /** Returns all of the query elements for the query.
        
        @return Object[] An array of the elements that make up this query. */
    method public Object extent GetQueryElements().
    
    /** Returns sort information for all buffers in the definition.
        
        @return longchar A complete sort string for all buffers in the definition. */
    method public longchar GetSort().
    
    /** Returns sort information.
        
        @param character The buffer name for which to retrieve sort information
        @return longchar A complete sort string for the specified buffer. */
    method public longchar GetSort(input pcBufferName as character).
    
    /** Returns the Sort information for the given buffer.
        
        @param character The buffer name for which to retrieve sort information
        @return QuerySort[] An ordered array of sort parameters */
    method public QuerySort extent GetQuerySort(input pcBufferName as character).
    
    /** Returns the Sort information for all buffers. 
        
        @return QuerySort[] An ordered array of sort parameters */    
    method public QuerySort extent GetQuerySort().
    
    /** Returns the filter criteria for a buffer, in string form. This
        could be used as-is for a WHERE clause.
        
        @param character The buffer name 
        @return longchar The where-clause-compatible string. */
    method public longchar GetFilter(input pcBufferName as character).
    
    /** Returns the filters applicable to a buffer.
       
        @param character The buffer name
        @return QueryFilter[] An array of query filter objects that
                apply to this buffer. */
    method public QueryFilter extent GetQueryFilter(input pcBufferName as character).

    /** Returns the filters applicable to all the buffers in the query.
       
        @return QueryFilter[] An array of query filter objects that apply 
                to all the buffers. The filters are ordered by buffer order. */
    method public QueryFilter extent GetQueryFilters().

    /** Returns the joins applicable to a buffer.
        
        @param character The buffer name
        @return QueryJoin[] An array of query filter objects that
                apply to this buffer. */
    method public QueryJoin extent GetQueryJoin(input pcBufferName as character).
    
    /** Returns the filters applicable to all the buffers in the query.
       
        @return QueryJoin [] An array of query filter objects that apply 
                to all the buffers. The filters are ordered by buffer order. */
    method public QueryJoin extent GetQueryJoins().

end interface.
