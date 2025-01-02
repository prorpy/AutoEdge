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
    File        : IDataAccess
    Purpose     : Interface for data access objects. Does not specify the 
                  format in which the data is stored.
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Wed Feb 10 01:08:16 EST 2010
    Notes       : * DataAccess objects are responsible for  field- and table-
                    name mappings between the business entity and the data source
                    objects. The BE might work with 'eEmployee' and the DS with 'employee';
                    this mapping is held in the DA.
  ---------------------------------------------------------------------- */
using OpenEdge.DataSource.IDataSource.
using OpenEdge.DataSource.DataSourceQuery.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.

using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.QueryJoin.
using OpenEdge.Core.System.QuerySort.
using OpenEdge.Lang.Collections.IMap.

interface OpenEdge.DataAccess.IDataAccess:
    
    /** A map of the IDataSource objects that this DataAccess objects knows about. */
    define public property DataSources as IMap no-undo get.
    
    /** Helper method for adding DataSource objects from InjectABL
        
        @param character The name of the datasource
        @param IDataSource The datasource object.   */
    method public void AddDataSource(input pcName as character, input poDataSource as IDataSource).
    
    /** Data retrieval method. This is simply a call to fetch. The response
        is retreived via the GetData() method.
        
        @param IFetchRequest The fetch request service message which defines
        parameters for the request.         */
    method public void FetchData(input poRequest as IFetchRequest).

    /** The response to a data retrieval request made in FetchData.
        @param character The message id for the request/response
        @return IFetchResponse */
    method public IFetchResponse GetData(input pcMessageId as longchar).
    
    /** A call to save data in the data source. 
        
        @param ISaveRequest The request message
        @return ISaveResponse The response message  */
    method public ISaveResponse SaveData(input poRequest as ISaveRequest).
    
    /** Resolves table and field names from the Business Entity into a physical table and field 
        names in the DataSource. The values passed in here are usually taken from the ITableRequest 
        that's part of the IServiceRequest.
        
        @param character A table name in the business entity (ie. not resolved)
        @param character A field name in the business entity (ie. not resolved).
        @return character[] The [db.][table.]field name in the datasource. If the array has an extent
                of 1, then it's a field in the input table; if 2 then in the same Db.
                [1] = FieldName
                [2] = TableName
                [3] = DB Name               */
    method public character extent ResolveFieldName (input pcSourceTable as character,
                                                     input pcSourceField as character).
    
    /** Resolves a query filter on the data access/entity ("eTable.Field = 'someValue' ") to a filter on the 
        DB/datasource ("Table.Field = 'someValue'). This is typically for more complex transformations than
        just a simple field and/or table name mappes: for example, where one filter in the entity maps to
        multiple filters in the DB.
        
        @param QueryFilter The source/business entity filter to transform. 
        @return QueryFilter[] The filter clause(s) on the DB query that the source filter resolves to */
    method public QueryFilter extent ResolveFilter(input poSourceFilter as QueryFilter).

    /** Resolves a query Join on the data access/entity ("eTable.Field = eTable2.Field") to a Join on the 
        DB/datasource ("Table.Field = dbTable2.Field"). This is typically for more complex transformations than
        just a simple field and/or table name mappes: for example, where one Join in the entity maps to
        multiple Joins in the DB.
        
        @param QueryJoin The source/business entity Join to transform.
        @return QueryJoin[] The Join clause(s) on the DB query that the source Join resolves to */
    method public QueryJoin extent ResolveJoin(input poSourceJoin as QueryJoin).

    /** Resolves a query sort on the data access/entity ("by eTable.Field ") to a sort on the 
        DB/datasource ("By Table.Field"). This is typically for more complex transformations than
        just a simple field and/or table name mappings
        
        @param QuerySort The source/business entity sort to transform.
        @return QuerySort[] The sort clause(s) on the DB query that the source sort resolves to */
    method public QuerySort extent ResolveSort(input poSourceSort as QuerySort).
    
end interface.
