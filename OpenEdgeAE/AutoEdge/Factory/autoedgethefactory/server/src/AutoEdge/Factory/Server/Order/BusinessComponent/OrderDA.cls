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
    File        : OrderDA
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 08 16:22:31 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.DataAccess.StandardDataAccess.
using OpenEdge.DataSource.DataSourceEventArgs.
using OpenEdge.DataSource.IDataSource.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.CallbackNameEnum.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.String.

class AutoEdge.Factory.Server.Order.BusinessComponent.OrderDA inherits StandardDataAccess: 
    
    constructor public OrderDA (input poDataSources as IMap):
        super (input poDataSources).
    end constructor.
    
    constructor public OrderDA (  ):
        super ().
    end constructor.
    
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
    method override public character extent ResolveFieldName (input pcSourceTable as character, input pcSourceField as character):        
        define variable cFieldName as character extent 2 no-undo.

        /* default is a simple mapping from eTable to Table */
        assign cFieldName[1] = pcSourceField
               cFieldName[2] = substring(pcSourceTable, 2).
        
        case pcSourceTable:
            when 'eOrder' then
            case pcSourceField:
                when 'OrderStatus' then
                    assign cFieldName[1] = 'Code'
                           cFieldName[2] = 'StatusDetail'.
                when 'DealerCode' then
                    assign cFieldName[1] = 'Code'
                           cFieldName[2] = 'Dealer'.
                when 'SalesrepCode' then
                    assign cFieldName[1] = 'Code'
                           cFieldName[2] = 'Salesrep'.
            end case.   /* eOrder */
            when 'eOrderLine' then
            case pcSourceField:
                when 'OrderLineStatus' then
                    assign cFieldName[1] = 'Code'
                           cFieldName[2] = 'StatusDetail'.
            end case.   /* eOrderLine */
            when 'eItem' then
            case pcSourceField:
                when 'ItemType' then
                    assign cFieldName[1] = 'Name'
                           cFieldName[2] = 'ItemType'.
                when 'Description' then
                    assign cFieldName[1] = 'Description'
                           cFieldName[2] = 'Item'.
            end case.   /* eOrder */
            when 'eComponentItem' then
            case pcSourceField:
                when 'Quantity' then
                    assign cFieldName[1] = 'Qty'
                           cFieldName[2] = 'ComponentItem'.
            end case.   /* eComponentItem */
        end case.
        
        return cFieldName.
    end method.
    
    method override public QueryFilter extent ResolveFilter(input poSourceFilter as QueryFilter):
        define variable oFilter as QueryFilter extent no-undo.
        
        /* eOrder.CustNum <-> Customer.CustNum is relatively simply, but we show an example of 
           resolving a query filter, rather than just the name. If we had to do some data type 
           conversion, we'd do it here */
        if poSourceFilter:BufferName eq 'eOrder' and poSourceFilter:FieldName eq 'CustomerNum' then
        do:
            extent(oFilter) = 1.
            oFilter[1] = new QueryFilter('Customer',
                                         'CustNum',
                                         poSourceFilter:Operator,
                                         poSourceFilter:FieldValue,
                                         DataTypeEnum:Integer,
                                         poSourceFilter:JoinType).
        end.
        else
            oFilter = super:ResolveFilter(input poSourceFilter).
        
        return oFilter.            
    end method.
        
    
    /** Add ABL callbacks to a buffer handle for an action.
        
        @param handle The buffer on which to attach the callback
        @param ServiceMessageActionEnum The action being performed.
        @param IDataSource The datasource used to operate on the buffer/handle */
    method override protected void AddBufferCallbacks(input phBuffer as handle,
                                                      input poServiceMessageAction as ServiceMessageActionEnum,
                                                      input poDataSource as IDataSource):            /* Example below */
            if poServiceMessageAction:Equals(ServiceMessageActionEnum:FetchData) then                
            do:
                case phBuffer:table:
                    when 'eFinishedItem' or when 'eComponentItem' then
                        phBuffer:set-callback(CallbackNameEnum:AfterRowFill:ToString(),
                                              substitute('&1AfterRowFillCallback', phBuffer:name),
                                              this-object).
                end case.
            end.
            else
            if poServiceMessageAction:Equals(ServiceMessageActionEnum:SaveData) then
            do:
                case phBuffer:table:
                    when 'eOrder' then 
                        poDataSource:BeforeSaveTransaction:Subscribe(OrderBeforeSaveTransactionHandler).
                end case.
            end.
    end method.

	method override protected void RemoveBufferCallbacks(input phBuffer as handle,
	                                                     input poServiceMessageAction as ServiceMessageActionEnum,
	                                                     input poDataSource as IDataSource):
        super:RemoveBufferCallbacks(phBuffer, poServiceMessageAction, poDataSource).
            	                                                         
        if poServiceMessageAction:Equals(ServiceMessageActionEnum:FetchData) then                
        do:
            case phBuffer:table:
                when 'eFinishedItem' or when 'eComponentItem' then
                    phBuffer:set-callback(CallbackNameEnum:AfterRowFill:ToString(), ?, this-object).
            end case.
        end.
        else
        if poServiceMessageAction:Equals(ServiceMessageActionEnum:SaveData) then
        do:
            case phBuffer:table:
                when 'eOrder' then 
                    poDataSource:BeforeSaveTransaction:Unsubscribe(OrderBeforeSaveTransactionHandler).
            end case.
        end.
	end method.
    
    method public void eComponentItemAfterRowFillCallback(input dataset-handle phDataset):
        define variable hBuffer as handle no-undo.
        
        hBuffer = phDataset:get-buffer-handle('eComponentItem').
        
        AddChildItems(hBuffer::ItemId, phDataset).
    end method.
    
    method public void eOrderlineAfterRowFillCallback(input dataset-handle phDataset):
        define variable hOLine as handle no-undo.
        define variable hOrder as handle no-undo.
        define variable hDBBuffer as handle no-undo.
        
        define buffer lbCustomer for Customer.
                
        hOLine = phDataset:get-buffer-handle('eOrderLine').
        /*
                hOrder = phDataset:get-buffer-handle('eOrder').
        
        hOrder:find-first(' where eOrder.OrderId = ' + quoter(hOLine::Orderid)).
        
        find lbCustomer where
             lbCustomer.TenantId = hDBBuffer::TenantId and
             lbCustomer.CustomerId = hOrder::CustomerId
             no-lock no-error.
        /*save discoiunt per customer */                
        */
        
        AddChildItems(hOLine::ItemId, phDataset).
    end method.
    
    method public void eFinishedItemAfterRowFillCallback(input dataset-handle phDataset):
        define variable hBuffer as handle no-undo.
        
        hBuffer = phDataset:get-buffer-handle('eFinishedItem').
        
        AddChildItems(hBuffer::ItemId, phDataset).
    end method.
    
    method protected void AddChildItems(input pcItemId as character,
                                        input phDataset as handle):
        define variable hBuffer as handle no-undo.
        define variable hDBBuffer as handle no-undo.
        define variable oDS as IDataSource no-undo.
        define variable cItemTypeId as character no-undo.
        
        hBuffer = phDataset:get-buffer-handle('eItem').
        
        hBuffer:find-first(' where eItem.ItemId eq ' + quoter(pcItemId) ) no-error.
        if not hBuffer:available then
        do transaction:
            hBuffer:buffer-create().
            
            @todo(task="implement", action="generic using datasource!").
            
            hDBBuffer = hBuffer:data-source:get-source-buffer(1).
            hDBBuffer:find-first(substitute(' where &1.ItemId eq ', hDBBuffer:name) + quoter(pcItemId), no-lock) /*no-error*/.
            hBuffer:buffer-copy(hDBBuffer).
            cItemTypeId = hDBBuffer::ItemTypeId.
            
            hDBBuffer = hBuffer:data-source:get-source-buffer(2).
            hDBBuffer:find-first(substitute(' where &1.ItemTypeId eq ', hDBBuffer:name) + quoter(cItemTypeId), no-lock) /*no-error*/.
            hBuffer:buffer-copy(hDBBuffer).
            
            hBuffer:buffer-release().
        end.             
    end method.
    
    method public void OrderBeforeSaveTransactionHandler(input poSender as IDataSource,
                                                         input poEventArgs as DataSourceEventArgs):
        /* EXAMPLE message 'order handler' poEventArgs:RowKey[1]. */
    end method. 

end class.
