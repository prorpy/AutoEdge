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
    File        : UserTableDS
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 22 10:08:26 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataSource.StandardDataSource.
using OpenEdge.DataSource.DataSourceQuery.
using OpenEdge.DataAccess.IDataAccess.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.IQueryDefinition.

using OpenEdge.Lang.LockModeEnum.
using OpenEdge.Lang.QueryTypeEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.String.

class AutoEdge.Factory.Server.Common.BusinessComponent.UserTableDS use-widget-pool inherits StandardDataSource: 
    define override protected property PrimaryTable as handle no-undo 
        get():
            if not valid-handle(PrimaryTable) then
                PrimaryTable = buffer ApplicationUser:handle.
            return PrimaryTable.
        end get.
    set.
    
    constructor public UserTableDS(input poComponentInfo as IComponentInfo):
        super (input poComponentInfo).
    end constructor.
    
    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable hUserBuffer as handle no-undo.
        define variable hLocaleBuffer as handle no-undo.
        define variable oDSQuery as IQuery no-undo.
        
        create data-source hABLDataSource.
        oDSQuery = new DataSourceQuery(hABLDataSource).
        ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).
        
        create buffer hUserBuffer for table buffer ApplicationUser:handle
                buffer-name substitute('ApplicationUser_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
        hABLDataSource:add-source-buffer(hUserBuffer, hUserBuffer:keys).
        
        create buffer hLocaleBuffer for table buffer Locale:handle
                buffer-name substitute('Locale_&1-&2',
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
        
        hABLDataSource:add-source-buffer(hLocaleBuffer, hLocaleBuffer:keys).
        oDSQuery:Definition:AddJoin('ApplicationUser', 'LocaleId',
                                    OperatorEnum:IsEqual,
                                    'Locale', 'LocaleId',
                                    JoinEnum:And).
        
        /* We're ready to parse the ABLDatasource and construct the query definition.
            
           This is the query definition we'll always use. There should not be any user- or request- specific
           filtering/joining in this definition, since we don't know what the lifespan of this datasource object 
           is. The SaveData or FetchData request will be done on the behest of a user and so will add it's own 
           filters (like tenancy) to the query that is used to service the request. */
        cast(oDSQuery, DataSourceQuery):Initialize().
        
        super:CreateDataStore().
    end method.

    method override protected void AttachDataStoreToTarget(input poServiceMessageAction as ServiceMessageActionEnum):
        define variable hABLDataSource as handle no-undo.
        define variable hLocaleBuffer as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        
        case poServiceMessageAction:
            when ServiceMessageActionEnum:FetchData then
            do:
                oDSQuery = cast(ABLDataSources:Get(poServiceMessageAction), DataSourceQuery). 
                hABLDataSource = oDSQuery:ABLDataSource. 
                hABLDataSource:prefer-dataset = true.
                hLocaleBuffer = oDSQuery:GetTableBuffer('Locale').
                
                TargetBuffer:attach-data-source(hABLDataSource,
                        substitute('&1.LocaleName,&2.Name',
                                    TargetBuffer:name,
                                    hLocaleBuffer:name)).
                
                AttachedActions:Add(poServiceMessageAction).
            end.
            otherwise
                super:AttachDataStoreToTarget(poServiceMessageAction).
        end case.
    end method.
    
end class.
