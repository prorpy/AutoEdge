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
/*------------------------------------------------------------------------
    File        : ComponentItemTableDS
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Mar 02 08:49:27 EST 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.DataSource.StandardDataSource.
using OpenEdge.DataSource.DataSourceQuery.
using OpenEdge.DataAccess.IDataAccess.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.IQuery.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.OperatorEnum.

class AutoEdge.Factory.Server.Order.BusinessComponent.ComponentItemTableDS inherits StandardDataSource: 
    
    define override protected property PrimaryTable as handle no-undo
        get():
            if not valid-handle(PrimaryTable) then
                create buffer PrimaryTable for table buffer Component:handle.
            
            return PrimaryTable.
        end get.
        set.
    
    constructor public ComponentItemTableDS(input poComponentInfo as IComponentInfo ):
        super (input poComponentInfo).
    end constructor.
    
    method override protected void AttachDataStoreToTarget(input poAction as ServiceMessageActionEnum):
        define variable hABLDataSource as handle no-undo.
        define variable hComponentItemBuffer as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable cPairsList as character no-undo.
        
        case poAction:
            when ServiceMessageActionEnum:FetchData or when ServiceMessageActionEnum:SaveData then
            do:
                assign oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery)
                       hABLDataSource = oDSQuery:ABLDataSource
                       hABLDataSource:prefer-dataset = true
                       hComponentItemBuffer = oDSQuery:GetTableBuffer('ComponentItem').
                cPairsList  = '&1.Quantity,&2.Qty'.
                TargetBuffer:attach-data-source(hABLDataSource,
                                substitute(cPairsList,
                                           TargetBuffer:name,
                                           hComponentItemBuffer:name)).
                AttachedActions:Add(poAction).
            end.
            otherwise
                super:AttachDataStoreToTarget(poAction).
        end case.
    end method.    
    
    method override protected void UpdateRow(input phABLDatasource as handle,
                                             input piBufferIndex as integer,
                                             input poDataSourceQuery as DataSourceQuery,
                                             input phSourceBuffer as handle ):
        define variable hDbBuffer as handle no-undo.
        define variable dOldPrice as decimal no-undo.
        define variable dNewPrice as decimal no-undo.

        dOldPrice = CalculateComponentItemPrice(
                        phSourceBuffer:after-buffer::TenantId,
                        phSourceBuffer:after-buffer::FinishedItemId,
                        phSourceBuffer:after-buffer::ItemId).

        super:UpdateRow(input phABLDatasource, input piBufferIndex, input poDataSourceQuery, input phSourceBuffer).

        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
        dNewPrice = CalculateComponentItemPrice(
                        hDbBuffer::TenantId,
                        hDbBuffer::FinishedItemId,
                        hDbBuffer::ItemId).

        UpdateOrderLinePrice(hDbBuffer::TenantId,
                             hDbBuffer::FinishedItemId,
                             dOldPrice,
                             dNewPrice).
    end method.

    method override protected void DeleteRow(input phABLDatasource as handle,
                                             input piBufferIndex as integer,
                                             input poDataSourceQuery as DataSourceQuery,
                                             input phSourceBuffer as handle ):
        define variable hDbBuffer as handle no-undo.
        define variable dOldPrice as decimal no-undo.

        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
        dOldPrice = CalculateComponentItemPrice(
                            hDbBuffer::TenantId,
                            hDbBuffer::FinishedItemId,
                            hDbBuffer::ItemId).

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
        define buffer lbOrderLine for OrderLine.
        define buffer lbItem for Item.

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
                             CalculateComponentItemPrice(
                                    hDbBuffer::TenantId,
                                    hDbBuffer::FinishedItemId,
                                    hDbBuffer::ItemId)).
    end method.

    method protected decimal CalculateComponentItemPrice(input pcTenantId as character,
                                                         input pcFinishedItemId as character,
                                                         input pcItemId as character):
        define variable dPrice as decimal no-undo.

        define buffer lbComponentItem for ComponentItem.
        define buffer lbItem for Item.

        find lbComponentItem where
             lbComponentItem.TenantId eq pcTenantId and
             lbComponentItem.FinishedItemId eq pcFinishedItemId and
             lbComponentItem.ItemId eq pcItemId
             no-lock no-error.
        if available lbComponentItem then
            find lbItem where
                 lbItem.ItemId eq lbComponentItem.ItemId and
                 lbItem.TenantId eq lbComponentItem.TenantId
                 no-lock no-error.
        if available lbItem then
            dPrice = lbItem.Price * lbComponentItem.Qty.

        return dPrice.
    end method.

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
end class.
