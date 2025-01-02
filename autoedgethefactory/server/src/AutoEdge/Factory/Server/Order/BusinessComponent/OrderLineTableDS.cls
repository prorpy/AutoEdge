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
    File        : OrderLineTableDS
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Feb 21 15:54:10 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataSource.DataSourceEventArgs.
using OpenEdge.DataSource.StandardDataSource.
using OpenEdge.DataSource.DataSourceQuery.
using OpenEdge.DataAccess.IDataAccess.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.IQuery.

using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.String.

class AutoEdge.Factory.Server.Order.BusinessComponent.OrderLineTableDS inherits StandardDataSource: 

    define override protected property PrimaryTable as handle no-undo
        get():
            if not valid-handle(PrimaryTable) then
                PrimaryTable = buffer OrderLine:handle.
            return PrimaryTable.
        end get.
        set.

    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable hOrderLineBuffer as handle no-undo.
        define variable hStatusBuffer as handle no-undo.
        
        create data-source hABLDataSource.
        oDSQuery = new DataSourceQuery(hABLDataSource).
        ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).
        
        /* Make sure we have a uniquely-named buffer, for those cases where this datasource object's instances' 
           lifecycles overlap. The ABL requires only a single named buffer/data-source set at a time. */
        create buffer hOrderLineBuffer for table buffer OrderLine:handle
            buffer-name substitute('OrderLine_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
        
        hABLDataSource:add-source-buffer(hOrderLineBuffer, hOrderLineBuffer:keys).
        
        create buffer hStatusBuffer for table buffer StatusDetail:handle
            buffer-name substitute('StatusDetail_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
                         
        hABLDataSource:add-source-buffer(hStatusBuffer, hStatusBuffer:keys).
        oDSQuery:Definition:AddJoin(hStatusBuffer:name, 'StatusDetailId',
                                    OperatorEnum:IsEqual,
                                    hOrderLineBuffer:name, 'StatusId',
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
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable hStatusBuffer as handle no-undo.
        define variable hOLineBuffer as handle no-undo.
        define variable cPairsList as character no-undo.
        
        case poAction:
            when ServiceMessageActionEnum:FetchData then
            do:
                assign oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery)
                       hABLDataSource = oDSQuery:ABLDataSource
                       hABLDataSource:prefer-dataset = true
                       hOLineBuffer = oDSQuery:GetTableBuffer('OrderLine')
                       hStatusBuffer = oDSQuery:GetTableBuffer('StatusDetail').
                
                cPairsList = '&1.OrderLineStatus,&2.Code'.
                TargetBuffer:attach-data-source(hABLDataSource,
                            substitute(cPairsList,
                                       TargetBuffer:name,
                                       hStatusBuffer:name,
                                       hOLineBuffer:name)).
                AttachedActions:Add(poAction).
            end.    /* fetchdata */
            when ServiceMessageActionEnum:SaveData then
            do:
                assign oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery)
                       hABLDataSource = oDSQuery:ABLDataSource
                       hABLDataSource:prefer-dataset = true
                       hOLineBuffer = oDSQuery:GetTableBuffer('OrderLine').

                cPairsList = '&1.Quantity,&2.Qty'.
                TargetBuffer:attach-data-source(hABLDataSource,
                            substitute(cPairsList,
                                       TargetBuffer:name,
                                       hOLineBuffer:name)).
                AttachedActions:Add(poAction).
            end.    /* savedata */
            otherwise
                super:AttachDataStoreToTarget(poAction).
        end case.
    end method.
    
    method override protected void AddRow(input phABLDatasource as handle,
                                          input piBufferIndex as integer,
                                          input poDataSourceQuery as DataSourceQuery,
                                          input phSourceBuffer as handle ):
        define variable hDbBuffer as handle no-undo.
        
        define buffer lbStatus for StatusDetail.
        define buffer lbFinishedItem for FinishedItem.
        define buffer lbItem for Item.
        
        super:AddRow(input phABLDatasource, input piBufferIndex, input poDataSourceQuery, input phSourceBuffer).
        
        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
        
        find lbStatus where
             lbStatus.Code = phSourceBuffer:after-buffer::OrderLineStatus
             no-lock no-error.
        if available lbStatus then
            hDbBuffer::StatusId = lbStatus.StatusDetailId.
    end method.
    
	constructor public OrderLineTableDS ( input poComponentInfo as IComponentInfo):
		super (input poComponentInfo).
	end constructor.
	
end class.
