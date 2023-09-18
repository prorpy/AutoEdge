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
    File        : VehicleDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Jan 27 19:09:19 EST 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using AutoEdge.Factory.Server.Order.BusinessComponent.ItemTableDS.

using OpenEdge.DataSource.StandardDataSource.
using OpenEdge.DataSource.DataSourceQuery.
using OpenEdge.DataAccess.IDataAccess.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryFilter.

using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.String.

class AutoEdge.Factory.Server.Order.BusinessComponent.VehicleDataSource inherits ItemTableDS: 
    
	constructor public VehicleDataSource (input poComponentInfo as IComponentInfo):
		super (input poComponentInfo).
	end constructor.
    
    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable hItemBuffer as handle no-undo.
        define variable hItemTypeBuffer as handle no-undo.
        define variable hTenantBuffer as handle no-undo.

        create data-source hABLDataSource.
        oDSQuery = new DataSourceQuery(hABLDataSource).
        ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).
        
        create buffer hItemBuffer for table buffer Item:handle
            buffer-name substitute('Item_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
        
        hABLDataSource:add-source-buffer(hItemBuffer, hItemBuffer:keys).

        create buffer hTenantBuffer for table buffer Tenant:handle
            buffer-name substitute('Tenant_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).

        hABLDataSource:add-source-buffer(hTenantBuffer, hTenantBuffer:keys).

        oDSQuery:Definition:AddJoin(hTenantBuffer:name, 'TenantId',
                                    OperatorEnum:IsEqual,
                                    hItemBuffer:name, 'TenantId',
                                    JoinEnum:And).
                                    
        create buffer hItemTypeBuffer for table buffer ItemType:handle
            buffer-name substitute('ItemType_&1-&2',
                         string(hABLDataSource),
                         string(int(ServiceMessageActionEnum:FetchData))).
        hABLDataSource:add-source-buffer(hItemTypeBuffer, hItemTypeBuffer:keys).
        
        oDSQuery:Definition:AddJoin(hItemTypeBuffer:name, 'ItemTypeId',
                                    OperatorEnum:IsEqual,
                                    hItemBuffer:name, 'ItemTypeId',
                                    JoinEnum:And).
        /* only show vehicle-type items, not other things */
        oDSQuery:Definition:AddFilter(hItemTypeBuffer:name, 'Name',
                                      OperatorEnum:Begins,
                                      new String('Vehicle-'),
                                      DataTypeEnum:Character,
                                      JoinEnum:And).
        
        /* We're ready to parse the ABLDatasource and construct the query definition */
        cast(oDSQuery, DataSourceQuery):Initialize().

        /* simple save from defaults */
        
        super:CreateDataStore().
    end method.
    
    method override protected void AttachDataStoreToTarget(input poServiceMessageAction as ServiceMessageActionEnum):
        define variable hABLDataSource as handle no-undo.
        define variable cPairsList as character no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable hItemTypeBuffer as handle no-undo.
        define variable hItemBuffer as handle no-undo.
        define variable hTenantBuffer as handle no-undo.
        
        case poServiceMessageAction:
            when ServiceMessageActionEnum:FetchData then
            do:
                /* find the buffer for the Tenant table and add it to the pairs list,
                   so that we can populate the 'eVehicle.Brand' field with the tenant name */
                oDSQuery = cast(ABLDataSources:Get(poServiceMessageAction), DataSourceQuery).
                
                hABLDataSource = oDSQuery:ABLDataSource. 
                hABLDataSource:prefer-dataset = true.
                hTenantBuffer = oDSQuery:GetTableBuffer('Tenant').
                hItemTypeBuffer = oDSQuery:GetTableBuffer('ItemType').
                hItemBuffer = oDSQuery:GetTableBuffer('Item').
                
                cPairsList =  '&1.Brand,&2.Name'
                           + ',&1.Description,&4.Description'
                           + ',&1.VehicleType,&3.Name'
                           + ',&1.VehicleName,&4.ItemName'.
                
                TargetBuffer:attach-data-source(hABLDataSource,
                                substitute(cPairsList,
                                           TargetBuffer:name,
                                           hTenantBuffer:name,
                                           hItemTypeBuffer:name,
                                           hItemBuffer:name)).
                AttachedActions:Add(poServiceMessageAction).
            end.
            otherwise
                super:AttachDataStoreToTarget(poServiceMessageAction).
        end case.
    end method.
    
end class.
