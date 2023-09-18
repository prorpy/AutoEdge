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
    File        : FinishedItemTableDS
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Feb 21 16:01:06 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataSource.StandardDataSource.
using OpenEdge.DataSource.DataSourceQuery.
using OpenEdge.DataAccess.IDataAccess.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.IQuery.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.JoinEnum.

class AutoEdge.Factory.Server.Order.BusinessComponent.FinishedItemTableDS use-widget-pool inherits StandardDataSource: 

    define override protected property PrimaryTable as handle no-undo
        get():
            if not valid-handle(PrimaryTable) then
                create buffer PrimaryTable for table buffer FinishedItem:handle.
            
            return PrimaryTable.
        end get.
        set.
    
    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable hFinishedItemBuffer as handle no-undo.
        define variable hStatusBuffer as handle no-undo.

        create data-source hABLDataSource.
        oDSQuery = new DataSourceQuery(hABLDataSource).
        ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).
        
        /* Make sure we have a uniquely-named buffer, for those cases where this datasource object's instances' 
           lifecycles overlap. The ABL requires only a single named buffer/data-source set at a time. */
        create buffer hFinishedItemBuffer for table buffer FinishedItem:handle
            buffer-name substitute('FinishedItem_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
        
        hABLDataSource:add-source-buffer(hFinishedItemBuffer, hFinishedItemBuffer:keys).
        
        create buffer hStatusBuffer for table buffer StatusDetail:handle
            buffer-name substitute('StatusDetail_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
                         
        hABLDataSource:add-source-buffer(hStatusBuffer, hStatusBuffer:keys).
        
        oDSQuery:Definition:AddJoin(hStatusBuffer:name, 'StatusDetailId',
                                    OperatorEnum:IsEqual,
                                    hFinishedItemBuffer:name, 'StatusId',
                                    JoinEnum:And).
        
        /* We're ready to parse the ABLDatasource and construct the query definition.
               
               This is the query definition we'll always use. There should not be any user- or request- specific
               filtering/joining in this definition, since we don't know what the lifespan of this datasource object 
               is. The SaveData or FetchData request will be done on the behest of a user and so will add it's own 
               filters (like tenancy) to the query that is used to service the request. */
        cast(oDSQuery, DataSourceQuery):Initialize().
        
        /* let the simple save be created */        
        super:CreateDataStore().
    end method.
    
    method override protected void AttachDataStoreToTarget(input poAction as ServiceMessageActionEnum):
        define variable hABLDataSource as handle no-undo.
        define variable hStatusBuffer as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        
        case poAction:
            when ServiceMessageActionEnum:FetchData then
            do:
                assign oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery)
                       hABLDataSource = oDSQuery:ABLDataSource
                       hABLDataSource:prefer-dataset = true
                       hStatusBuffer = oDSQuery:GetTableBuffer('StatusDetail').

                TargetBuffer:attach-data-source(hABLDataSource,
                            substitute('&1.FinishedItemStatus,&2.Code',
                                       TargetBuffer:name,
                                       hStatusBuffer:name)).
                AttachedActions:Add(poAction).
            end.
            otherwise
                super:AttachDataStoreToTarget(poAction).
        end case.
    end method.

    method override protected void DeleteRow(input phABLDatasource as handle,
                                             input piBufferIndex as integer,
                                             input poDataSourceQuery as DataSourceQuery,
                                             input phSourceBuffer as handle ):
        define variable hDbBuffer as handle no-undo.
        define variable dOldPrice as decimal no-undo.

        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
        dOldPrice = CalculateFinishedItemPrice(
                            hDbBuffer::TenantId,
                            hDbBuffer::FinishedItemId).

        super:DeleteRow(input phABLDatasource, input piBufferIndex, input poDataSourceQuery, input phSourceBuffer).

        UpdateOrderLinePrice(hDbBuffer::TenantId,
                             hDbBuffer::FinishedItemId,
                             dOldPrice,
                             0).
    end method.
    method override protected void AddRow(input phABLDatasource as handle,
                                          input piBufferIndex as integer,
                                          input poDataSourceQuery as DataSourceQuery,
                                          input phSourceBuffer as handle ):
        define variable hDbBuffer as handle no-undo.
        
        define buffer lbStatus for StatusDetail.
        
        super:AddRow(input phABLDatasource, input piBufferIndex, input poDataSourceQuery, input phSourceBuffer).
        
        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
        
        find lbStatus where
             lbStatus.Code = phSourceBuffer:after-buffer::FinishedItemStatus
             no-lock no-error.
        if available lbStatus then
            hDbBuffer::StatusId = lbStatus.StatusDetailId.                                                                                   
        UpdateOrderLinePrice(hDbBuffer::TenantId,
                             hDbBuffer::FinishedItemId,
                             0,
                             CalculateFinishedItemPrice(
                                    hDbBuffer::TenantId,
                                    hDbBuffer::FinishedItemId)).
    end method.
        
    method override protected void UpdateRow( input phABLDatasource as handle, input piBufferIndex as integer, input poDataSourceQuery as OpenEdge.DataSource.DataSourceQuery, input phSourceBuffer as handle ):
        define variable hDbBuffer as handle no-undo.
        define variable dOldPrice as decimal no-undo.
        define variable dNewPrice as decimal no-undo.

        dOldPrice = CalculateFinishedItemPrice(
                        phSourceBuffer:after-buffer::TenantId,
                        phSourceBuffer:after-buffer::FinishedItemId).

        super:UpdateRow(input phABLDatasource, input piBufferIndex, input poDataSourceQuery, input phSourceBuffer).

        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
        dNewPrice = CalculateFinishedItemPrice(
                        hDbBuffer::TenantId,
                        hDbBuffer::FinishedItemId).

        UpdateOrderLinePrice(hDbBuffer::TenantId,
                             hDbBuffer::FinishedItemId,
                             dOldPrice,
                             dNewPrice).
    end method.
    constructor public FinishedItemTableDS(input poComponentInfo as IComponentInfo ):
        super (input poComponentInfo).
    end constructor.
    
    method protected void UpdateOrderLinePrice(input pcTenantId as character,
                                               input pcFinishedItemId as character,
                                               input pdOldPrice as decimal,
                                               input pdNewPrice as decimal):
        define buffer lbOrderLine for OrderLine.

        find lbOrderLine where
             lbOrderLine.FinishedItemId eq pcFinishedItemId and
             lbOrderLine.TenantId eq pcTenantId
             exclusive-lock no-wait no-error.
        if available lbOrderLine then
            lbOrderLine.Price = lbOrderLine.Price
                              - pdOldPrice + pdNewPrice.
    end method.

    method protected decimal CalculateFinishedItemPrice(input pcTenantId as character,
                                                        input pcFinishedItemId as character):
        define variable dPrice as decimal no-undo.

        define buffer lbFinishedItem for FinishedItem.
        define buffer lbItem for Item.

        find lbFinishedItem where
             lbFinishedItem.TenantId eq pcTenantId and
             lbFinishedItem.FinishedItemId eq pcFinishedItemId
             no-lock no-error.
        if available lbFinishedItem then
            find lbItem where
                 lbItem.ItemId eq lbFinishedItem.ItemId and
                 lbItem.TenantId eq lbFinishedItem.TenantId
                 no-lock no-error.
        if available lbItem then
            dPrice = lbItem.Price.

        return dPrice.
    end method.
end class.
