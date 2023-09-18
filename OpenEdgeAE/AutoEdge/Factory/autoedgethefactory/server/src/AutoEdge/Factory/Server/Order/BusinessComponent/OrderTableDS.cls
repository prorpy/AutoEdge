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
    File        : OrderTableDS
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 08 16:23:04 EST 2010
    Notes       : 
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

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

class AutoEdge.Factory.Server.Order.BusinessComponent.OrderTableDS use-widget-pool inherits StandardDataSource: 
    
    define override protected property PrimaryTable as handle no-undo
        get():
            if not valid-handle(PrimaryTable) then
                PrimaryTable = buffer Order:handle.
            return PrimaryTable.
        end get.
        set.

    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable hOrderBuffer as handle no-undo.
        define variable hStatusBuffer as handle no-undo.
        define variable hCustomerBuffer as handle no-undo.
        define variable hSalesrepBuffer as handle no-undo.
        define variable hEmployeeBuffer as handle no-undo.
        define variable hDealerBuffer as handle no-undo.

        create data-source hABLDataSource.
        oDSQuery = new DataSourceQuery(hABLDataSource).
        ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).
        
        /* Make sure we have a uniquely-named buffer, for those cases where this datasource object's instances' 
           lifecycles overlap. The ABL requires only a single named buffer/data-source set at a time. */
        create buffer hOrderBuffer for table buffer Order:handle
            buffer-name substitute('Order_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
        
        hABLDataSource:add-source-buffer(hOrderBuffer, hOrderBuffer:keys).

        create buffer hStatusBuffer for table buffer StatusDetail:handle
            buffer-name substitute('StatusDetail_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
                         
        hABLDataSource:add-source-buffer(hStatusBuffer, hStatusBuffer:keys).
        oDSQuery:Definition:AddJoin(hStatusBuffer:name, 'StatusDetailId',
                                    OperatorEnum:IsEqual,
                                    hOrderBuffer:name, 'StatusId',
                                    JoinEnum:And).
        
        create buffer hCustomerBuffer for table buffer Customer:handle
            buffer-name substitute('Customer_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).

        hABLDataSource:add-source-buffer(hCustomerBuffer, hCustomerBuffer:keys).
        oDSQuery:Definition:AddJoin(hCustomerBuffer:name, 'CustomerId',
                                    OperatorEnum:IsEqual,
                                    hOrderBuffer:name, 'CustomerId',
                                    JoinEnum:And).
        
        create buffer hSalesrepBuffer for table buffer Salesrep:handle
            buffer-name substitute('Salesrep_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).

        hABLDataSource:add-source-buffer(hSalesrepBuffer, hSalesrepBuffer:keys).
        oDSQuery:Definition:AddJoin(hSalesrepBuffer:name, 'SalesrepId',
                                    OperatorEnum:IsEqual,
                                    hOrderBuffer:name, 'SalesrepId',
                                    JoinEnum:And).

        create buffer hEmployeeBuffer for table buffer Employee:handle
            buffer-name substitute('Employee_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).

        hABLDataSource:add-source-buffer(hEmployeeBuffer, hEmployeeBuffer:keys).
        oDSQuery:Definition:AddJoin(hEmployeeBuffer:name, 'EmployeeId',
                                    OperatorEnum:IsEqual,
                                    hSalesrepBuffer:name, 'EmployeeId',
                                    JoinEnum:And).
        
        create buffer hDealerBuffer for table buffer Dealer:handle
            buffer-name substitute('Dealer_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).

        hABLDataSource:add-source-buffer(hDealerBuffer, hDealerBuffer:keys).
        oDSQuery:Definition:AddJoin(hDealerBuffer:name, 'DealerId',
                                    OperatorEnum:IsEqual,
                                    hEmployeeBuffer:name, 'DealerId',
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
        define variable hCustomerBuffer as handle no-undo.
        define variable hSalesrepBuffer as handle no-undo.
        define variable hEmployeeBuffer as handle no-undo.
        define variable hDealerBuffer as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable cPairsList as character no-undo.
        
        case poAction:
            when ServiceMessageActionEnum:FetchData then
            do:
                oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery).
                hStatusBuffer = oDSQuery:GetTableBuffer('StatusDetail').
                hCustomerBuffer = oDSQuery:GetTableBuffer('Customer').
                hSalesrepBuffer = oDSQuery:GetTableBuffer('Salesrep').
                hDealerBuffer = oDSQuery:GetTableBuffer('Dealer').
                
                @todo(task="implement", action="validate that the target buffer fields exist in the target buffer").
                /* &1 is the eOrder/TargetBuffer; aka businessentity order table*/
                cPairsList = '&1.OrderStatus,&2.Code'
                           + ',&1.CustomerName,&3.Name'
                           + ',&1.CustomerNum,&3.CustNum'
                           + ',&1.SalesrepCode,&4.Code'
                           + ',&1.DealerCode,&5.Code'.
                
                hABLDataSource = oDSQuery:ABLDataSource.
                hABLDataSource:prefer-dataset = true.
                this-object:TargetBuffer:attach-data-source(hABLDataSource,
                            substitute(cPairsList,
                                       TargetBuffer:name,
                                       hStatusBuffer:name,
                                       hCustomerBuffer:name,
                                       hSalesrepBuffer:name,
                                       hDealerBuffer:name)).
                AttachedActions:Add(poAction).
            end.
            otherwise
                /* on save we're just updating the order table */
                super:AttachDataStoreToTarget(poAction).
        end case.
    end method.
    
    method override protected void AddRow(input phABLDatasource as handle,
	                                      input piBufferIndex as integer,
	                                      input poDataSourceQuery as DataSourceQuery,
	                                      input phSourceBuffer as handle ):
        define variable hDbBuffer as handle no-undo.
        define variable iNumSalesReps as integer no-undo.
        
        define buffer lbStatus for StatusDetail.
        define buffer lbCustomer for Customer.
        define buffer lbSalesrep for Salesrep.
        define buffer lbDealer for Dealer.
        define buffer lbDepartment for Department.
        define buffer lbEmployee for Employee.
        
		super:AddRow(input phABLDatasource, input piBufferIndex, input poDataSourceQuery, input phSourceBuffer).
		
		/* we should get the Order table's newly-created record here. */
		hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
		
        find lbStatus where
             lbStatus.Code eq phSourceBuffer:after-buffer::OrderStatus
             no-lock no-error.
        if available lbStatus then
            hDbBuffer::StatusId = lbStatus.StatusDetailId.
        
        find lbCustomer where
             lbCustomer.TenantId eq hDbBuffer::TenantId and
             lbCustomer.CustNum eq phSourceBuffer:after-buffer::CustomerNum
             no-lock no-error.
        if available lbCustomer then
            hDbBuffer::CustomerId = lbCustomer.CustomerId.

        find lbSalesrep where
             lbSalesrep.TenantId eq hDbBuffer::TenantId and
             lbSalesrep.Code eq phSourceBuffer:after-buffer::SalesrepCode
             no-lock no-error.
        
        if available lbSalesrep then
            hDbBuffer::SalesrepId = lbSalesrep.SalesrepId.
        else
        do:
            /* add default */
            find lbDealer where
                 lbDealer.TenantId eq hDbBuffer::TenantId and
                 lbdealer.Code eq phSourceBuffer:after-buffer::DealerCode
                 no-lock no-error.
            if available lbDealer then
                find first lbDepartment where
                           lbDepartment.TenantId eq lbDealer.TenantId and
                           lbDepartment.Name eq 'sales'
                           no-lock no-error.
            if available lbDepartment then
                find first lbEmployee where
                           lbEmployee.DealerId eq lbDealer.DealerId and
                           lbEmployee.DepartmentId eq lbDepartment.DepartmentId and
                           lbEmployee.TenantId eq lbDealer.TenantId
                           no-lock no-error.
            if available lbEmployee then                           
                find first lbSalesrep where
                           lbSalesrep.EmployeeId eq lbEmployee.EmployeeId and
                           lbSalesrep.TenantId eq lbEmployee.TenantId
                           no-lock no-error.
            if available lbSalesrep then
                hDbBuffer::SalesrepId = lbSalesrep.SalesrepId.
        end.
	end method.
	
    constructor public OrderTableDS ( input poComponentInfo as IComponentInfo ):
        super (input poComponentInfo).
    end constructor.
    
end class.
