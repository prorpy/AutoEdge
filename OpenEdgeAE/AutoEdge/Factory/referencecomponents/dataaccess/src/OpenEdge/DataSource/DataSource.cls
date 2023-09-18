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
    File        : DataSource
    Purpose     : Default Datasource 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 11 20:09:22 EST 2010
    Notes       :  
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataSource.DataSource.
using OpenEdge.DataSource.IDataSource.
using OpenEdge.DataAccess.IDataAccess.
using OpenEdge.DataSource.DataSourceEventArgs.
using OpenEdge.DataSource.DataSourceEventEnum.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ITenantManager.
using OpenEdge.CommonInfrastructure.Common.Component.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.Query.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.ITableOwner.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.ArgumentError.
 
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.FillModeEnum.
using OpenEdge.Lang.RowStateEnum.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.Assert.
using Progress.Lang.AppError.
using Progress.Lang.Object.
using Progress.Lang.Class.

class OpenEdge.DataSource.DataSource abstract use-widget-pool inherits Component
        implements IDataSource:
    
    /** Type used for InjectABL binding */
    define static public property IDataSourceType as class Class no-undo get. private set.
    
    /** The data transport type for this message. These may differ for request and response. */
    define protected property DataTargetFormat as DataFormatEnum no-undo get. private set.
    define protected property DataTargetType as DataTypeEnum no-undo get. private set.
    
    /** Individual data target types. Manipulated by SetDataTarget(), and GetDataTarget() */
    define protected property HandleDataTarget as handle   no-undo get. private set.
    define protected property MemptrDataTarget as memptr   no-undo get. private set.
    define protected property LongCharDataTarget as longchar no-undo get. private set.    
    define protected property ObjectDataTarget as Object   no-undo get. private set.
    
    /** The table request object that's currently being processed. 
    define protected property CurrentTableRequest as ITableRequest no-undo get. set.
    */
    
    /** The table response object that's currently being processed. */
    define protected property CurrentTableResponse as ITableResponse no-undo get. set.
    
    /** The DataAccess object making the current request. */
    define protected property CurrentDAO as IDataAccess no-undo get. set.
    
    /** The type of request currently underway making the current request. */ 
    define protected property CurrentActionType as ServiceMessageActionEnum no-undo get. set.
    
    /** The default Page or batch size for this datasource. Can be overridden
        by the page size on the table request. */
    define public property PageSize as integer no-undo get. set.
    
    /** The default fill mode for the data fetch (merge etc) for this datasource. */
    define public property FillMode as FillModeEnum no-undo
        get():
            if not valid-object(FillMode) then
                FillMode = FillModeEnum:Default.
            
            return FillMode.
        end get.
        set.
    
    /* DataSource Fetch/Fill events */
    define public event BeforeFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event BeforeRowFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterRowFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterFill signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    
    /* DataSource Save/Commit events */
    define public event BeforeSave            signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event BeforeSaveTransaction signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterSaveTransaction  signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    define public event AfterSave             signature void(input poSender as IDataSource, input poEventArgs as DataSourceEventArgs).
    
    constructor static DataSource():
        DataSource:IDataSourceType = Class:GetClass('OpenEdge.DataSource.IDataSource').
    end constructor.
    
    constructor public DataSource(input poComponentInfo as IComponentInfo):
        super(input poComponentInfo).
    end constructor.
    
    destructor public DataSource ():
        DestroyComponent().
    end destructor.
    
    /** Creates the actual datasource - this could be an ABL datasource, or some other 
        mechanism (XML or a service or something else). These are specific to each 
        datasource instance, and thus is abstract. 
        
        For example, for an ABL/ProDataSet data source:
            
            <code>
            
            CREATE DATA-SOURCE srcCar.
            </code>
      */
    method abstract protected void CreateDataStore().
    /** Deletes the datastore once done. */
    method abstract protected void DeleteDataStore().
        
    /** Attaches the actual datastore - this could be an ABL datasource, or some other 
        mechanism (XML or a service or something else). These are specific to each 
        datasource instance, and thus is abstract. 
        
        For example, for an ABL/ProDataSet data source:           
            <code>
            DATA-SOURCE srcCar:HANDLE:prefer-dataset = TRUE.
            hBuffer:ATTACH-DATA-SOURCE(DATA-SOURCE srcCar:HANDLE,"").
            </code>
        
        @param ServiceMessageActionEnum The action being performed (fetch/save). */
    method abstract protected void AttachDataStoreToTarget(input poAction as ServiceMessageActionEnum).
    
    /** Detaches the datastore from the datatarget
    
        @param ServiceMessageActionEnum The action being performed (fetch/save).    */
    method abstract protected void DetachDataStoreFromTarget(input poAction as ServiceMessageActionEnum).
    
    /** Prepare with query, batchsize and more.
    
        Very important note: If the datasource query is modified, the order of operations for 
                making sure the query is correct and works is
                (1) ASSIGN the data-source query handle to the customised query,
                (2) ATTACH the datasource, and
                (3) PREPARE the custom query. 
                
                You also need to manually/explicity add the parent join phrase.
        
        @param ServiceMessageActionEnum The action that we're preparing the datasource for. 
               We may have different actions based on whether this is a Fetch or a Save.
        @param ITableRequest Parameters for the fetch (query modifications, page size etc).
        @param IDataAccess The DataAccess object making this request. The DAO can be used to
               resolve table- or field name mappings (from the Business Entity names to the 
               Data Source names.           */
    method public void Prepare(input poAction as ServiceMessageActionEnum,
                               input poRequest as ITableRequest,
                               input poDAO as IDataAccess):
        Assert:ArgumentNotNull(poAction, 'Action Type').
        Assert:ArgumentNotNull(poRequest, 'Table Request').
        Assert:ArgumentNotNull(poDAO, 'Data Access Object').
        
        assign CurrentDAO = poDAO
               CurrentTableResponse = new TableResponse(poRequest:TableName)
               CurrentActionType = poAction.
        
        /* filter by tenant */
        AddTenantFilter(poAction).
    end method.
    
    method protected void DisposeRequest():
        RemoveTenantFilter(CurrentActionType).
        ClearDataTarget().
        
        assign CurrentTableResponse = ?
               CurrentActionType = ?
               CurrentDAO = ?.
    end method.
    
    /** Adds filtering by tenant for a given action. 
        
        @param ServiceMessageActionEnum The current request's action type. */
    method abstract protected void AddTenantFilter(input poAction as ServiceMessageActionEnum).

    /** Removes filtering by tenant for a given action. 
        
        @param ServiceMessageActionEnum The current request's action type. */
    method abstract protected void RemoveTenantFilter(input poAction as ServiceMessageActionEnum).
    
    /** This SetDataTarget override is provided since the bulk of datatargets in ABL
        will be buffers (possibly datasets).
        
        An exception will be thrown if the handle has a type of anything other than 
        'buffer' or 'dataset'.  
        
        @param handle A buffer or dataset handle that is the data target. */
    method public void SetDataTarget(input phData as handle):
        define variable oDataTargetFormat as DataFormatEnum no-undo.
        
        case phData:type:
            when 'buffer' then oDataTargetFormat = DataFormatEnum:TempTable.
            when 'dataset' then oDataTargetFormat = DataFormatEnum:ProDataSet.
            otherwise 
                undo, throw new ArgumentError('Handle must be buffer or dataset', 'DataSource:SetDataTarget:phData').
        end case.
        
        SetDataTarget(string(phData), oDataTargetFormat, DataTypeEnum:Handle).
    end method.
    
    /** SetDataTarget() methods are called by the DataAccess object, to specify 
        the target for the DataSource's operations (usually the fill/fetch). 
        
        This data is formatted per the DataTargetFormat above;
        and is stored in the message as either LONGCHAR, MEMPTR, HANDLE or P.L.O. */
    method public void SetDataTarget(input pcData as longchar,
                                     input poDataTargetFormat as DataFormatEnum,
                                     input poDataTargetType as DataTypeEnum):
        assign DataTargetFormat = poDataTargetFormat
               DataTargetType = poDataTargetType.
                
        case poDataTargetType:
            when DataTypeEnum:Handle then HandleDataTarget = widget-handle(string(pcData)).
            when DataTypeEnum:Memptr then copy-lob pcData to MemptrDataTarget.
            when DataTypeEnum:ProgressLangObject then ObjectDataTarget = ABLSession:Instance:ResolveWeakReference(integer(pcData)).
            when DataTypeEnum:LongChar then LongCharDataTarget = pcData.
        end case.
    end method.
    
    /** Clears the Datatarget and associated properties */
    method public void ClearDataTarget():
        assign HandleDataTarget = ?
               ObjectDataTarget = ?
               LongCharDataTarget = ?
               
               DataTargetFormat = ?
               DataTargetType = ?
               .
        set-size(MemptrDataTarget) = 0.
    end method.
    
    /** A helper for retrieving the data target in longchar form again. Performs
        the inverse of the SetDataTarget() method; this is basically just a STRING()
        of the value or reference.
        
        @return longchar A longchar representation of the data target. */
    method public longchar GetDataTarget():
        define variable cValue as longchar no-undo.
        
        case DataTargetType:
            when DataTypeEnum:Handle then cValue = string(HandleDataTarget).
            when DataTypeEnum:Memptr then copy-lob MemptrDataTarget to cValue.
            when DataTypeEnum:ProgressLangObject then cValue = string(integer(ObjectDataTarget)).
            when DataTypeEnum:LongChar then cValue = LongCharDataTarget.
        end case.
        
        return cValue.
    end method.
    
    /** Perform fetch: populate the data target from the physical data store. */        
    method abstract public void FetchData().
    
    /** Called on completion of a data fetch request, typically by the data access object.
        @return ITableResponse The response to the fetch operation. */
    method abstract public ITableResponse GetData().
    
    /** Saves all records in the buffer argument to the physical data store. This
        buffer comes from the DataAccess object.
        
        @return ITableResponse The response to the save operation. */
    method abstract public ITableResponse SaveData().
    
    /* Save events */
    method protected void OnBeforeSaveTransaction(input pcRowKey as character extent):
        OnBeforeSaveTransaction(new DataSourceEventArgs(
                        DataSourceEventEnum:BeforeSaveTransaction,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,
                        GetDataTarget(),
                        pcRowKey)).
    end method.
    
    method protected void OnBeforeSaveTransaction(input poArgs as DataSourceEventArgs):
        this-object:BeforeSaveTransaction:Publish(this-object, poArgs).
    end method.
    
    method protected void OnBeforeSave (input pcRowKey as character extent):
        OnBeforeSave(new DataSourceEventArgs(
                        DataSourceEventEnum:BeforeSave,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,                        
                        GetDataTarget(),
                        pcRowKey)).
    end method.
    
    method protected void OnBeforeSave (input poArgs as DataSourceEventArgs):
        this-object:BeforeSave:Publish(this-object, poArgs).
    end method.
    
    method protected void OnAfterSave(input pcRowKey as character extent):
        OnAfterSave(new DataSourceEventArgs(
                        DataSourceEventEnum:AfterSave,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,                        
                        GetDataTarget(),
                        pcRowKey)).
    end method.
    
    method protected void OnAfterSave(input poArgs as DataSourceEventArgs):
        this-object:AfterSave:Publish(this-object, poArgs).
    end method.
    
    method protected void OnAfterSaveTransaction(input pcRowKey as character extent):
        OnAfterSaveTransaction(
                new DataSourceEventArgs(
                        DataSourceEventEnum:AfterSaveTransaction,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,                        
                        GetDataTarget(),
                        pcRowKey)).
    end method.
    
    method protected void OnAfterSaveTransaction(input poArgs as DataSourceEventArgs):
        this-object:AfterSaveTransaction:Publish(this-object, poArgs).
    end method.

    method protected void OnBeforeFill():
        define variable cDummy as character extent no-undo.
        
        OnBeforeFill(new DataSourceEventArgs(
                        DataSourceEventEnum:BeforeFill,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,                        
                        GetDataTarget(),
                        cDummy)).
    end method.

    method protected void OnBeforeFill(input poArgs as DataSourceEventArgs):
        this-object:BeforeFill:Publish(this-object, poArgs).
    end method.

    method protected void OnBeforeRowFill(input pcRowKey as character extent):
        OnBeforeRowFill(
                new DataSourceEventArgs(
                        DataSourceEventEnum:BeforeRowFill,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,                        
                        GetDataTarget(),
                        pcRowKey)).
    end method.

    method protected void OnBeforeRowFill(input poArgs as DataSourceEventArgs):
        this-object:BeforeRowFill:Publish(this-object, poArgs).
    end method.
    
    method protected void OnAfterRowFill(input pcRowKey as character extent):
        OnAfterRowFill(
                new DataSourceEventArgs(
                        DataSourceEventEnum:AfterRowFill,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,                        
                        GetDataTarget(),
                        pcRowKey)).
    end method.

    method protected void OnAfterRowFill(input poArgs as DataSourceEventArgs):
        this-object:AfterRowFill:Publish(this-object, poArgs).
    end method.
    
    method protected void OnAfterFill():
        define variable cDummy as character extent no-undo.
        
        OnAfterFill(new DataSourceEventArgs(
                        DataSourceEventEnum:AfterFill,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,                        
                        GetDataTarget(),
                        cDummy)).
    end method.

    method protected void OnAfterFill(input poArgs as DataSourceEventArgs):
        this-object:AfterFill:Publish(this-object, poArgs).
    end method.

    method override public void CreateComponent(  ):
        super:CreateComponent().
        
        CreateDataStore().
    end method.

    method override public void DestroyComponent(  ):
        super:DestroyComponent().

        DeleteDataStore().
        ClearDataTarget().
    end method.
    
end class.
