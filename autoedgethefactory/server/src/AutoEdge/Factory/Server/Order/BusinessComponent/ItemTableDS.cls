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
    File        : ItemTableDS
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Jan 20 14:23:13 EST 2011
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
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.OperatorEnum.

class AutoEdge.Factory.Server.Order.BusinessComponent.ItemTableDS use-widget-pool inherits StandardDataSource: 

    define override protected property PrimaryTable as handle no-undo
        get():
            if not valid-handle(PrimaryTable) then
                create buffer PrimaryTable for table buffer Item:handle.
            
            return PrimaryTable.
        end get.
        set.
    
    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable hItemBuffer as handle no-undo.
        define variable hItemTypeBuffer as handle no-undo.
        
        if not ABLDataSources:ContainsKey(ServiceMessageActionEnum:FetchData) then
        do:
            create data-source hABLDataSource.
            oDSQuery = new DataSourceQuery(hABLDataSource).
            ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).
            
            /* Make sure we have a uniquely-named buffer, for those cases where this datasource object's instances' 
               lifecycles overlap. The ABL requires only a single named buffer/data-source set at a time. */
            create buffer hItemBuffer for table buffer Item:handle
                buffer-name substitute('Item_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
            
            hABLDataSource:add-source-buffer(hItemBuffer, hItemBuffer:keys).
            
            create buffer hItemTypeBuffer for table buffer ItemType:handle
                buffer-name substitute('ItemType_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
                             
            hABLDataSource:add-source-buffer(hItemTypeBuffer, hItemTypeBuffer:keys).
            oDSQuery:Definition:AddJoin(hItemTypeBuffer:name, 'ItemTypeId',
                                        OperatorEnum:IsEqual,
                                        hItemBuffer:name, 'ItemTypeId',
                                        JoinEnum:And).
            
            /* We're ready to parse the ABLDatasource and construct the query definition.
               
               This is the query definition we'll always use. There should not be any user- or request- specific
               filtering/joining in this definition, since we don't know what the lifespan of this datasource object 
               is. The SaveData or FetchData request will be done on the behest of a user and so will add it's own 
               filters (like tenancy) to the query that is used to service the request. */
            cast(oDSQuery, DataSourceQuery):Initialize().
        end.    /* doesn't have datasource already */
        
        /* let the simple save be created */
        super:CreateDataStore().
    end method.
    
    method override protected void AttachDataStoreToTarget(input poAction as ServiceMessageActionEnum):
        define variable hABLDataSource as handle no-undo.
        define variable hItemTypeBuffer as handle no-undo.
        define variable hItemBuffer as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable cPairsList as character no-undo.
        
        case poAction:
            when ServiceMessageActionEnum:FetchData then
            do:
                oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery).
                hItemTypeBuffer = oDSQuery:GetTableBuffer('ItemType').
                hItemBuffer = oDSQuery:GetTableBuffer('Item').
                
                hABLDataSource = oDSQuery:ABLDataSource.
                hABLDataSource:prefer-dataset = true.
                
                /* explicitly map the eItem.Description field to the Item table since it also appears in ItemType */
                cPairsList = '&1.ItemType,&2.Name'
                           + ',&1.Description,&3.Description'.
                
                TargetBuffer:attach-data-source(hABLDataSource,
                                substitute(cPairsList, 
                                           TargetBuffer:name,
                                           hItemTypeBuffer:name,
                                           hItemBuffer:name)).
                AttachedActions:Add(poAction).
            end.
            otherwise
                super:AttachDataStoreToTarget(poAction).
        end case.
    end method.
    
    constructor public ItemTableDS(input poComponentInfo as IComponentInfo ):
        super (input poComponentInfo).
    end constructor.
    
end class.
