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
    File        : ItemOptionTableDS
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

class AutoEdge.Factory.Server.Order.BusinessComponent.ItemOptionTableDS inherits StandardDataSource: 
    
    define override protected property PrimaryTable as handle no-undo
        get():
            if not valid-handle(PrimaryTable) then
                create buffer PrimaryTable for table buffer ItemOption:handle.
            
            return PrimaryTable.
        end get.
        set.
    
    constructor public ItemOptionTableDS(input poComponentInfo as IComponentInfo ):
        super (input poComponentInfo).
    end constructor.
    
    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable hItemOptionBuffer as handle no-undo.
        define variable hItemBuffer as handle no-undo.
        define variable hChildItemBuffer as handle no-undo.
        define variable hChildItemTypeBuffer as handle no-undo.
        
        if not ABLDataSources:ContainsKey(ServiceMessageActionEnum:FetchData) then
        do:
            create data-source hABLDataSource.
            oDSQuery = new DataSourceQuery(hABLDataSource).
            ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).
            
            /* Make sure we have a uniquely-named buffer, for those cases where this datasource object's instances' 
               lifecycles overlap. The ABL requires only a single named buffer/data-source set at a time. */
            create buffer hItemOptionBuffer for table buffer ItemOption:handle
                buffer-name substitute('ItemOption_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).

            hABLDataSource:add-source-buffer(hItemOptionBuffer, hItemOptionBuffer:keys).

            create buffer hItemBuffer for table buffer Item:handle
                buffer-name substitute('Item_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
            
            hABLDataSource:add-source-buffer(hItemBuffer, hItemBuffer:keys).
            oDSQuery:Definition:AddJoin(hItemBuffer:name, 'ItemId',
                                        OperatorEnum:IsEqual,
                                        hItemOptionBuffer:name, 'ItemId',
                                        JoinEnum:And).
            
            create buffer hChildItemBuffer for table buffer Item:handle
                buffer-name substitute('ChildItem_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
            hABLDataSource:add-source-buffer(hChildItemBuffer, hChildItemBuffer:keys).
            oDSQuery:Definition:AddJoin(hChildItemBuffer:name, 'ItemId',
                                        OperatorEnum:IsEqual,
                                        hItemOptionBuffer:name, 'ChildItemId',
                                        JoinEnum:And).
            
            create buffer hChildItemTypeBuffer for table buffer ItemType:handle
                buffer-name substitute('ChildItemType_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
                             
            hABLDataSource:add-source-buffer(hChildItemTypeBuffer, hChildItemTypeBuffer:keys).
            oDSQuery:Definition:AddJoin(hChildItemTypeBuffer:name, 'ItemTypeId',
                                        OperatorEnum:IsEqual,
                                        hChildItemBuffer:name, 'ItemTypeId',
                                        JoinEnum:And).
            
            /* We're ready to parse the ABLDatasource and construct the query definition.
               
               This is the query definition we'll always use. There should not be any user- or request- specific
               filtering/joining in this definition, since we don't know what the lifespan of this datasource object 
               is. The SaveData or FetchData request will be done on the behest of a user and so will add it's own 
               filters (like tenancy) to the query that is used to service the request. */
             cast(oDSQuery, DataSourceQuery):Initialize().
        end.
        
        /* let the simple save be created */
        super:CreateDataStore().
    end method.
    
    method override protected void AttachDataStoreToTarget(input poAction as ServiceMessageActionEnum):
        define variable hABLDataSource as handle no-undo.
        define variable hItemBuffer as handle no-undo.
        define variable hChildItemTypeBuffer as handle no-undo.
        define variable hChildItemBuffer as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable cPairsList as character no-undo.
        define variable hBuffer as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        case poAction:
            when ServiceMessageActionEnum:FetchData then
            do:
                assign oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery)
                       hABLDataSource = oDSQuery:ABLDataSource
                       hABLDataSource:prefer-dataset = true.
                       iMax = hABLDataSource:num-source-buffers.
                do iLoop = 1 to iMax:
                    hBuffer = hABLDataSource:get-source-buffer(iLoop).
                    case hBuffer:table:
                        when 'Item' then
                        do:
                            if hBuffer:name begins 'Child' then
                                hChildItemBuffer = hBuffer.
                            else
                                hItemBuffer = hBuffer.
                        end.
                        when 'ItemType' then hChildItemTypeBuffer = hBuffer.
                    end case.
                end.
                
                cPairsList = '&1.ItemNum,&2.ItemNum'
                           + ',&1.ChildItemNum,&3.ItemNum'
                           + ',&1.ChildType,&4.Name'.
                cPairsList = substitute(cPairsList,
                                           TargetBuffer:name,
                                           hItemBuffer:name,
                                           hChildItemBuffer:name,
                                           hChildItemTypeBuffer:name).
                TargetBuffer:attach-data-source(hABLDataSource, cPairsList).
                AttachedActions:Add(poAction).
            end.
            otherwise
                super:AttachDataStoreToTarget(poAction).
        end case.
    end method.    
    
end class.
