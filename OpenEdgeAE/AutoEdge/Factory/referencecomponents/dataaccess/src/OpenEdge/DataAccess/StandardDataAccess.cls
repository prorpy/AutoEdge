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
    File        : StandardDataAccess
    Purpose     : Standard DataAccess object for filling ProDataSet-based business components.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Aug 24 15:04:40 EDT 2010
    Notes       : 
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataAccess.IDataAccess.
using OpenEdge.DataSource.IDataSource.
using OpenEdge.DataSource.DataSource.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.

using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryDefinition.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.QueryJoin.
using OpenEdge.Core.System.QuerySort.
using OpenEdge.Core.System.InvalidValueSpecifiedError.

using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.TypedCollection.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.FillModeEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.String.


using Progress.Lang.Object.
using Progress.Lang.Class.

class OpenEdge.DataAccess.StandardDataAccess use-widget-pool abstract
        implements IDataAccess:
    
    /** */
    define protected property DatasetHandle as handle no-undo get. set.
    
    /** */
    define protected property FetchAllTables as logical no-undo get. set.
    
    /** A map of the IDataSource objects that this DataAccess objects knows about. */
    define public property DataSources as IMap no-undo get. private set.
    
    /* The datasources currently in use for the current request */
    
    /* [futures] This data access object could be servicing multiple concurrent requests. The 
       moCurrent* variables could (should?) be made into maps so that we can find the relevant
       objects. */
    define private variable moCurrentRequest as IServiceRequest no-undo.
    define private variable moCurrentRequestDataSources as ICollection no-undo.
    
    constructor public StandardDataAccess():
        this-object(new TypedMap(String:Type, DataSource:IDataSourceType)).
    end constructor.
    
    constructor public StandardDataAccess(input poDataSources as IMap):
        super().
        
        assign DataSources = poDataSources
               moCurrentRequestDataSources = new TypedCollection(DataSource:IDataSourceType)
               FetchAllTables = false.
    end constructor.
    
    /** Helper method for adding DataSource objects from InjectABL. It's also perfectly legitimate to
        add/remove these in the DataSources property directly.
        
        @param character The name of the datasource
        @param IDataSource The datasource object.   */
    method public void AddDataSource(input pcName as character, input poDataSource as IDataSource).
        DataSources:Put(new String(pcName), poDataSource).
    end method.
    
    /** Response complement method for FetchData above.
        
        @param character The message id for the request/response
        @return IFetchResponse */
    method public IFetchResponse GetData(input pcMessageId as longchar):
        define variable oIterator as IIterator no-undo.
        define variable oFetchResponse as IFetchResponse no-undo.
        define variable oTableResponse as ITableResponse no-undo.
        define variable oDataSource as IDataSource no-undo.
        
        if moCurrentRequest:MessageId ne pcMessageId then
            undo, throw new InvalidValueSpecifiedError('message id', ' for GetData() request').
        
        oFetchResponse = new FetchResponse(cast(moCurrentRequest, IFetchRequest)).
        oFetchResponse:SetMessageData(DatasetHandle, DataFormatEnum:ProDataSet).
        
        oIterator = moCurrentRequestDataSources:Iterator().
        do while oIterator:HasNext():
            oDataSource = cast(oIterator:Next(), IDataSource).
            oTableResponse = oDataSource:GetData().
            
            /* Create an entry for the request buffer. We do this here since this is the
               only place that we know that we're making a request for a particular table/buffer. */
            oFetchResponse:TableResponses:Put(oTableResponse:TableName, oTableResponse).
            
            /* cascade error flag up. */
            if oTableResponse:HasError then
                oFetchResponse:HasError = true.
        end.
        
        /* also check for errors in dataset FILL operation  */
        if this-object:DatasetHandle:error then
            oFetchResponse:ErrorText = substitute('Dataset &1 Error for &2',
                        moCurrentRequest:ActionType:ToString(),
                        moCurrentRequest:Service).
        
        return oFetchResponse.
        finally:
            moCurrentRequestDataSources:Clear().
            moCurrentRequest = ?.
        end finally.
    end method.
    
    method public ISaveResponse SaveData(input poRequest as ISaveRequest):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable oDataSource as IDataSource no-undo.
        define variable oTableResponse as ITableResponse no-undo.
        define variable oSaveResponse as ISaveResponse no-undo.
        
        moCurrentRequest = poRequest.
        oSaveResponse = new SaveResponse(poRequest).
        poRequest:GetMessageData(output DatasetHandle).
        
        AddDatasetCallbacks(DatasetHandle,
                            /* Should be SaveData or something similar. You'd expect. */
                            poRequest:ActionType).
        
        /* only loop through the tables that actually have changed data. */
        iMax = extent(poRequest:TableNames).
        do iLoop = 1 to iMax:
            oDataSource = cast(DataSources:Get(new String(poRequest:TableNames[iLoop]))
                            , IDataSource).
            if valid-object(oDataSource) then
            do:
                hBuffer = DatasetHandle:get-buffer-handle(poRequest:TableNames[iLoop]).
                AddBufferCallbacks(hBuffer, poRequest:ActionType, oDataSource).
                
                /* Saves for all data in the data target (buffer in this case). 
                   hBuffer is the after-table. */
                oDataSource:SetDataTarget(hBuffer).
                
                oDataSource:Prepare(poRequest:ActionType,
                                    CreateDefaultTableRequest(hBuffer:name),
                                    this-object).
                oTableResponse = oDataSource:SaveData().
                
                /* Add the table response to the total response */
                oSaveResponse:TableResponses:Put(new String(oTableResponse:TableName), oTableResponse).
                
                /* cascade error flag up to message from tableresponse */                
                if oTableResponse:HasError then
                    assign oSaveResponse:HasError = true
                           oSaveResponse:ErrorText = oSaveResponse:ErrorText + '|' + oTableResponse:TableName. 
            end.
        end.        
        RemoveAllCallbacks(DatasetHandle, poRequest:ActionType).
        
        if oSaveResponse:HasError then
            oSaveResponse:ErrorText = left-trim(oSaveResponse:ErrorText, '|').
        
        /* Add the data to the message */
        oSaveResponse:SetMessageData(DatasetHandle, DataFormatEnum:ProDataSet).
        
        return oSaveResponse.
        finally:
            moCurrentRequestDataSources:Clear().
            moCurrentRequest = ?.
        end finally.
    end method.
    
    method public void FetchData(input poRequest as IFetchRequest):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable oTableRequest as ITableRequest no-undo.
        define variable oDataSource as IDataSource no-undo.
        define variable oServiceMessage as IServiceMessage no-undo. 
        
        oServiceMessage = poRequest.
        oServiceMessage:GetMessageData(output DatasetHandle).
        
        /* Keep a record of the current request, for use in constructing the response in GetData(). */
        moCurrentRequest = poRequest.
        
        AddDatasetCallbacks(DatasetHandle, poRequest:ActionType). 
        
        /* Clean out just to be sure.*/
        moCurrentRequestDataSources:Clear().
        
        /* If there are no individual table requests, and we're not already getting all tables,
           get 'em all. This somewhat a-typical, since we'll usually filter the fetch request 
           for at least one table (a/the top-level buffer) in the ProDataSet */
        FetchAllTables = poRequest:TableRequests:IsEmpty().
        
        /* If a top-level buffer has a TableRequestType of 'All', then
           fetch all of the tables according to the relations. */
        iMax = DatasetHandle:num-top-buffers.
        do iLoop = 1 to iMax while not FetchAllTables:
            oTableRequest = poRequest:TableRequests:Get(Datasethandle:get-top-buffer(iLoop):name).
            if valid-object(oTableRequest) then
                FetchAllTables = oTableRequest:TableRequestType:Equals(TableRequestTypeEnum:All).
        end.
        
        /* If there are no individual table requests, and we're not already getting all tables,
           get 'em all. This somewhat a-typical, since we'll usually filter the fetch request 
           for at least one table (a/the top-level buffer) in the ProDataSet */
        if not FetchAllTables then
            FetchAllTables = poRequest:TableRequests:IsEmpty().
        
        iMax = DatasetHandle:num-buffers.
        do iLoop = 1 to iMax:
            hBuffer = DatasetHandle:get-buffer-handle(iLoop).
            
            oTableRequest = poRequest:TableRequests:Get(hBuffer:name).
            if not valid-object(oTableRequest) and FetchAllTables then
                oTableRequest = CreateDefaultTableRequest(hBuffer:name).
            
            if valid-object(oTableRequest) and
               not oTableRequest:TableRequestType:Equals(TableRequestTypeEnum:None) then
            do:
                oDataSource = cast(DataSources:Get(new String(oTableRequest:TableName)), IDataSource).
                if valid-object(oDataSource) then
                do:
                    moCurrentRequestDataSources:Add(oDataSource).
                    
                    oDataSource:SetDataTarget(hBuffer).
                    oDataSource:Prepare(oServiceMessage:ActionType,
                                        oTableRequest,
                                        this-object).
                    AddBufferCallbacks(hBuffer, poRequest:ActionType, oDataSource).
                end.
            end.    /* valid tablerequest */
        end.    /* buffer loop */
        
        /* Get data into this dataset */
        if moCurrentRequestDataSources:Size gt 0 then
        do:
            AddDatasetCallbacks(DatasetHandle, poRequest:ActionType).
            PerformFetch(FetchAllTables).
            RemoveDatasetCallbacks(DatasetHandle, poRequest:ActionType).
        end.
    end method.
    
    /** Fetch/retrieve data from the datasource, and populate the business entity with 
        it.
        
        @param logical Fetch all tables in the Dataset? */ 
    method protected void PerformFetch(input plFetchAllTables as logical):
        define variable oIterator as IIterator no-undo.
        
        /* If we want to get all tables, */
        if plFetchAllTables then
            DatasetHandle:fill().
        else
        do:
            oIterator = moCurrentRequestDataSources:Iterator().
            do while oIterator:HasNext():
                cast(oIterator:Next(), IDataSource):FetchData().
            end.
        end.
    end method.
    
    /** Removes all the callbacks on a dataset and its buffers, for a given action. 
        
        @param handle The dataset handle for which to remove the callbacks.
        @param ServiceMessageActionEnum The action being performed.     */
    method protected void RemoveAllCallbacks(input phDatasetHandle as handle,
                                             input poServiceMessageAction as ServiceMessageActionEnum):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable oDataSource as IDataSource no-undo.
        
        iMax = phDatasetHandle:num-buffers.
        do iLoop = 1 to iMax:
            hBuffer = phDatasetHandle:get-buffer-handle(iLoop).
            oDataSource = cast(DataSources:Get(new String(hBuffer:name)), IDataSource).
            
            RemoveBufferCallbacks(hBuffer, 
                                  poServiceMessageAction,
                                  oDataSource).
        end.
        
        RemoveDatasetCallbacks(phDatasetHandle, poServiceMessageAction).
    end method.
    
    /** Add ABL callbacks to a buffer handle for an action.
        
        @param handle The buffer on which to attach the callback
        @param ServiceMessageActionEnum The action being performed.
        @param IDataSource The datasource used to operate on the buffer/handle */
    method protected void AddBufferCallbacks(input phBuffer as handle,
                                             input poServiceMessageAction as ServiceMessageActionEnum,
                                             input poDataSource as IDataSource):
            /* Example below */
            case poServiceMessageAction:
                when ServiceMessageActionEnum:FetchData then
                do:
                    /* GetDataSource(phBuffer:name):BeforeRowFill:Subscribe(XXX).*/
/*                     ohBuffer:set-callback(CallbackNameEnum:BeforeRowFill:ToString(), 'XXX', this-object).*/
                end.
            end case.
    end method.
    
    /** Remove ABL callbacks from a buffer handle for an action.
    
        @param handle The dataset from which to remove the callback
        @param ServiceMessageActionEnum The action being performed. */
    method protected void RemoveBufferCallbacks(input phBuffer as handle,
                                                input poServiceMessageAction as ServiceMessageActionEnum,
                                                input poDataSource as IDataSource):
    end method.
    
    /** Add ABL callbacks to a buffer handle for an action.
    
        @param handle The dataset on which to attach the callback
        @param ServiceMessageActionEnum The action being performed.
        
        @return Logical value indicating whether there are any callbacks set for the buffer */
    method protected void AddDatasetCallbacks(input phDataset as handle,
                                              input poServiceMessageAction as ServiceMessageActionEnum):
        /* DatasetHandle:set-callback(CallbackNameEnum:AfterFill:ToString(), 'someThinG', this-object). */
    end method.
    
    /** Remove ABL callbacks from a dataset handle for an action.
    
        @param handle The dataset from which to remove the callback
        @param ServiceMessageActionEnum The action being performed. */            
    method protected void RemoveDatasetCallbacks(input phDataset as handle,
                                                 input poServiceMessageAction as ServiceMessageActionEnum):
    end method.
    
    /** Resolves a field name from the Business Entity into a physical field name in the
        DataSource. The values passed in here are usually taken from the ITableRequest that's
        part of the IServiceRequest.
        
        @param character A table name in the business entity (not resolved)
        @param character A field name in the business entity
        @return character[] The [db.][table.]field name in the datasource. If the array has an extent
                of 1, then it's a field in the input table; if 2 then in the same Db.
                [1] = FieldName
                [2] = TableName
                [3] = DB Name               */
    method public character extent ResolveFieldName (input pcSourceTable as character, input pcSourceField as character):        
        define variable cFieldName as character extent 2 no-undo.
        
        assign cFieldName[1] = pcSourceField
               cFieldName[2] = pcSourceTable.
        
        return cFieldName.
    end method.
    
    /** Resolves a query filter on the data access/entity ("eTable.Field = 'someValue' ") to a filter on the 
        DB/datasource ("Table.Field = 'someValue'). This is typically for more complex transformations than
        just a simple field and/or table name mappes: for example, where one filter in the entity maps to
        multiple filters in the DB.
        
        @param QueryFilter The source/business entity filter to transform. 
        @return QueryFilter[] The filter clause(s) on the DB query that the source filter resolves to */
    method public QueryFilter extent ResolveFilter(input poSourceFilter as QueryFilter):
        define variable oResolvedFilter as QueryFilter extent 1 no-undo.
        define variable cResolvedFieldName as character extent no-undo.
        
        /* Resolve any mapping between DB and ProDataSet*/
        cResolvedFieldName = ResolveFieldName(poSourceFilter:BufferName, poSourceFilter:FieldName).
        /* [PJ] eOrder.OrderStatus -> StatusDetail.Code */
        /* [PJ] eOrder.OrderNum -> Order.OrderNum */
        
        /* Use handle:NAME since the table name is what's returned in from ResolveFieldName() */
        oResolvedFilter[1] = new QueryFilter(
                                    cResolvedFieldName[2],
                                    cResolvedFieldName[1],
                                    poSourceFilter:Operator,
                                    poSourceFilter:FieldValue,
                                    poSourceFilter:FieldType,
                                    poSourceFilter:JoinType).
        
        return oResolvedFilter.
    end method.

    /** Resolves a query Join on the data access/entity ("eTable.Field = eTable2.Field") to a Join on the 
        DB/datasource ("Table.Field = dbTable2.Field"). This is typically for more complex transformations than
        just a simple field and/or table name mappes: for example, where one Join in the entity maps to
        multiple Joins in the DB.
        
        @param QueryJoin The source/business entity Join to transform.
        @return QueryJoin[] The Join clause(s) on the DB query that the source Join resolves to */
    method public QueryJoin extent ResolveJoin(input poSourceJoin as QueryJoin).
        define variable oResolvedJoin as QueryJoin extent 1 no-undo.
        define variable cResolvedFieldName as character extent no-undo.
        define variable cResolvedJoinFieldName as character extent no-undo.
        
        /* Resolve any mapping between DB and ProDataSet*/
        cResolvedFieldName = ResolveFieldName(poSourceJoin:BufferName, poSourceJoin:FieldName).
        cResolvedJoinFieldName = ResolveFieldName(poSourceJoin:JoinBufferName, poSourceJoin:JoinFieldName).
        
        oResolvedJoin[1] = new QueryJoin(
                                cResolvedFieldName[2],
                                cResolvedFieldName[1],
                                poSourceJoin:Operator,
                                cResolvedJoinFieldName[2],
                                cResolvedJoinFieldName[1],
                                poSourceJoin:JoinType).
        
        return oResolvedJoin.
    end method.
    
    /** Resolves a query sort on the data access/entity ("by eTable.Field ") to a sort on the 
        DB/datasource ("By Table.Field"). This is typically for more complex transformations than
        just a simple field and/or table name mappings
        
        @param QuerySort The source/business entity sort to transform.
        @return QuerySort[] The sort clause(s) on the DB query that the source sort resolves to */
    method public QuerySort extent ResolveSort(input poSourceSort as QuerySort).
        define variable oResolvedSort as QuerySort extent 1 no-undo.
        define variable cResolvedFieldName as character extent no-undo.
        
        oResolvedSort[1] = new QuerySort(
                                cResolvedFieldName[2],
                                cResolvedFieldName[1],
                                poSourceSort:Direction).
        
        return oResolvedSort.
    end method.      
    
    method protected ITableRequest CreateDefaultTableRequest(input pcBufferName as character):
        return new TableRequest(pcBufferName).
    end method.
    
end class.
