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
    File        : StandardDataSource
    Purpose     : DataSource that populates a BE based on an ABL DB Table
    Syntax      :
    Description :
    @author hdaniels
    Created     : Thu Feb 11 20:09:22 EST 2010
    Notes       : * The QueryDefinition of this datasource is the 'base query';
                    the TableRequest adds to it for filtering.
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataSource.DataSource.
using OpenEdge.DataAccess.IDataAccess.
using OpenEdge.DataSource.DataSourceEventArgs.
using OpenEdge.DataSource.DataSourceEventEnum.
using OpenEdge.DataSource.DataSourceQuery.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.

using OpenEdge.Core.System.Query.
using OpenEdge.Core.System.QueryBuffer.
using OpenEdge.Core.System.QuerySort.
using OpenEdge.Core.System.QueryFilter.
using OpenEdge.Core.System.QueryJoin.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryDefinition.
using OpenEdge.Core.System.ITableOwner.
using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.ArgumentError.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.InvalidValueSpecifiedError.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.QueryBlockTypeEnum.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.LockModeEnum.
using OpenEdge.Lang.QueryTypeEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.FillModeEnum.
using OpenEdge.Lang.RowStateEnum.
using OpenEdge.Lang.String.

using Progress.Lang.SysError.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.DataSource.StandardDataSource abstract use-widget-pool inherits DataSource:

    define protected property SecurityManager as ISecurityManager no-undo
        get():
            if not valid-object(SecurityManager) then
                SecurityManager = cast(cast(ABLSession:Instance:SessionProperties:Get(OpenEdge.CommonInfrastructure.Common.ServiceManager:IServiceManagerType)
                                        , IServiceManager)
                                        :GetService(OpenEdge.CommonInfrastructure.Common.SecurityManager:ISecurityManagerType)
                                    , ISecurityManager).
            return SecurityManager.
        end get.
        set.

    /** The primary DB table that this IDataSource reads and writes to and from. There
        might be more than one source buffer for the ABL DATA-SOURCE, but this one is
        this IDataSource object's reason for existence (basically). */
    define abstract protected property PrimaryTable as handle no-undo get. set.

    /** The default field name in the schmema used to apply a tenant filter. By default,
        this is used with the Primary table; subsidiary tables should join off the primary
        table's values, although there's no requirement for that (ie they could also build
        their own tenant filters, in slightly different ways if needed). The defaults should
        suffice for most cases. I think. */
    define protected property TenantFilterFieldName as character no-undo get. set.

    /** The standard datasource populates buffers; this property makes it easier to access those
        buffers. */
    define protected property TargetBuffer as handle no-undo
        get():
            if not valid-handle(TargetBuffer) then
                TargetBuffer = ConvertTargetToHandle().
            return TargetBuffer.
        end get.
        set.

    /** The ABL DATA-SOURCE handles being used */
    define protected property ABLDataSources  as IMap no-undo
        get():
            if not valid-object(ABLDataSources) then
                ABLDataSources = new Map().
            return ABLDataSources.
        end get.
        set.

    define protected property AttachedActions as ICollection no-undo
        get():
            if not valid-object(AttachedActions) then
                AttachedActions = new Collection().
            return AttachedActions.
        end get.
        set.

    constructor public StandardDataSource(input poComponentInfo as IComponentInfo):
        super (input poComponentInfo).

        TenantFilterFieldName = 'TenantId'.
    end constructor.

    /** Prepare with query, batchsize and more.

        @param ServiceMessageActionEnum The action that we're preparing the datasource for.
               We may have different actions based on whether this is a Fetch or a Save.
        @param ITableRequest Parameters for the fetch (query modifications, page size etc).
        @param IDataAccess The DataAccess object making this request. The DAO can be used to
               resolve table- or field name mappings (from the Business Entity names to the
               Data Source names.           */
    method override public void Prepare(input poAction as ServiceMessageActionEnum,
                                        input poRequest as ITableRequest,
                                        input poDAO as IDataAccess):

        super:Prepare(poAction, poRequest, poDAO).

        case poAction:
            when ServiceMessageActionEnum:FetchData then PrepareFetchData(poAction, poRequest, poDAO).
            when ServiceMessageActionEnum:SaveData then PrepareSaveData(poAction, poRequest, poDAO).
        end case.
    end method.

    /** Specific handling for FetchData requests.

        @param ITableRequest The current request
        @param IDataAccess The data access object making the request */
    method protected void PrepareFetchData(input poAction as ServiceMessageActionEnum,
                                           input poRequest as ITableRequest,
                                           input poDAO as IDataAccess):
        define variable cWhereClause as character no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable cResolvedFieldName as character extent no-undo.
        define variable hDataSourceBuffer as handle no-undo.

        HandleDataTarget:fill-mode = poRequest:FillMode:ToString().

        /* We want to add any extra filter/paging etc data from the request to the base query */
        oDSQuery = cast(ABLDataSources:Get(poAction), IQuery).

        FilterQueryPerRequest(poAction, cast(oDSQuery, DataSourceQuery), poRequest, poDAO).

        /* If there is more than one buffer in the query, set the QUERY attribute on the ABL DATA-SOURCE.
           If not, we'll set the FILL-WHERE-STRING if applicable. In all likelihood, we will have some form
           of filtering in 10.2B at any rate, because of multi-tenancy having to be enforced in the application
           (ie here) */
        if oDSQuery:Definition:NumBuffers gt 1 then
        do:
            cast(oDSQuery, DataSourceQuery):ABLDataSource:query = oDSQuery:QueryHandle.
            AttachDataStoreToTarget(poAction).
            cast(oDSQuery, DataSourceQuery):Prepare(poAction).
        end.
        else
        do:
            AttachDataStoreToTarget(poAction).

            /* Resovle business entity's eCustomer -> Customer */
            cResolvedFieldName = poDAO:ResolveFieldName(poRequest:TableName, '').

            /* Resolved table name needs to be resolved again to the buffer name being used in the
               datasource. Customer -> Customer_1243-5678 */
            hDataSourceBuffer = cast(oDSQuery, DataSourceQuery):GetTableHandle(cResolvedFieldName[2]).
            cWhereClause = oDSQuery:Definition:GetFilter(hDataSourceBuffer:name).

            /*cResolvedFieldName[2]).*/
            if cWhereClause ne '' then
            do:                
                if cast(oDSQuery, DataSourceQuery):ABLDataSource:fill-where-string eq ? then
                    cast(oDSQuery, DataSourceQuery):ABLDataSource:fill-where-string = ' where ' + cWhereClause.
                else
                    cast(oDSQuery, DataSourceQuery):ABLDataSource:fill-where-string = cast(oDSQuery, DataSourceQuery):ABLDataSource:fill-where-string 
                                                                                    + ' and ' + cWhereClause. 
            end.
        end.
    end method.

    /** Specific handling for SaveData requests.

        @param ITableRequest The current request
        @param IDataAccess The data access object making the request */
    method protected void PrepareSaveData(input poAction as ServiceMessageActionEnum,
                                          input poRequest as ITableRequest,
                                          input poDAO as IDataAccess):
        AttachDataStoreToTarget(poAction).
        /* we'll prepare later */
    end method.

    /** Perform fetch: populate the previously-passed buffer from the
        physical data store.

        The caller needs to call GetData() afterwards if they want
        any additional information about the fetch call (stuff that's
        in ITableContext).

        Note:
            - this method will not be called when Datasets are involved,
        since the FILL() method will probably be called instead. The code below
        is for illustrative purposes.
            - there are no events (before-fill etc) fired since this code
        doesn't use prodataset; we should therefor create our own events and
        fire them if we so desire.          */
    method override public void FetchData():
        define variable lAvailable as logical no-undo.
        define variable cRowKey as character extent no-undo.
        define variable oDSQuery as IQuery no-undo.
        define variable hABLDataSource as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.

        /* If the target buffer is part of a ProDataSet, we can use FILL() on the
           buffer and get the use any callbacks that are in place. */
        if valid-handle(TargetBuffer:dataset) then
            TargetBuffer:fill().
        else
        do on error undo, throw:
            assign oDSQuery = cast(ABLDataSources:Get(CurrentActionType), IQuery)
                   hABLDataSource = cast(oDSQuery, DataSourceQuery):ABLDataSource
                   iMax = hABLDataSource:num-source-buffers.

            oDSQuery:Open().

            lAvailable = oDSQuery:GetFirst().
            if lAvailable then
                OnBeforeFill().

            do while lAvailable:
                cRowKey = oDSQuery:GetCurrentRowKey().
                TargetBuffer:buffer-create().

                /* Get values and populate this-object:HandleDataTarget */
                OnBeforeRowFill(cRowKey).
                do iLoop = 1 to iMax:
                    TargetBuffer:buffer-copy(hABLDataSource:get-source-buffer(iLoop)).
                end.
                OnAfterRowFill(cRowKey).

                TargetBuffer:buffer-release().
                lAvailable = oDSQuery:GetNext().
            end.
            OnAfterFill().
            
            finally:
                oDSQuery:Close().
            end finally.
        end.
    end method.

    /** Called on completion of a data fetch request, typically by the data access object.

        @return ITableContext - the context for the request (num records, position etc). */
    method override public ITableResponse GetData():
        define variable oTC as ITableContext no-undo.
        define variable hBuffer as handle no-undo.
        define variable oDSQuery as IQuery no-undo.

        /* pop the target buffer into the context. not the 'database table' */
        oTC = new TableContext(CurrentTableResponse:TableName, TargetBuffer).
        CurrentTableResponse:TableContext = oTC.

        /* update the context with the results of the fetch */
        oDSQuery = cast(ABLDataSources:Get(CurrentActionType), IQuery).

        oTC:PageSize = oDSQuery:NumRows.
        oTC:FuzzyPageSize = not oDSQuery:Definition:QueryBlockType:Equals(QueryBlockTypeEnum:Preselect).

        return CurrentTableResponse.
        finally:
            /* go back to the base definition */
            oDSQuery:Close().
            oDSQuery:Reset().

            DisposeRequest().
        end finally.
    end method.

    /** Saves all records in the buffer argument to the physical data store. This
        buffer comes from the DataAccess object.

        This SaveData() call saves all records for a given table/buffer.

        @return ITableResponse The response to the save operation. */
    method override public ITableResponse SaveData():
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable hBeforeBuffer as handle no-undo.
        define variable hBeforeQry as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.

        /* we know we want to deal with a handle */
        hBuffer = TargetBuffer.
        hBeforeBuffer = hBuffer:before-buffer.

        create query hBeforeQry.
        hBeforeQry:set-buffers(hBeforeBuffer).
        hBeforeQry:query-prepare(' for each ' + hBeforeBuffer:name ).
        hBeforeQry:query-open().
        hBeforeQry:get-first().

        oDSQuery = cast(ABLDataSources:Get(CurrentActionType), DataSourceQuery).

        do while not hBeforeQry:query-off-end:
            /* Find the after-table row for this before-table row so that
               the validation logic can look at it (SAVE-ROW-CHANGES doesn't
               need it; it can do this on its own). If it's a Delete, then
               there *is* no after-table row.

               if not hBeforeBuffer:row-state eq RowStateEnum:Deleted:Value then
               hBuffer:find-by-rowid(hBeforeBuffer:after-rowid).

               The RowKey we use is the row key for the Business Entity table and
               not the DB table. */

            if not hBeforeBuffer:row-state eq RowStateEnum:Deleted:Value then
                hBuffer:find-by-rowid(hBeforeBuffer:after-rowid).
            else
                hBuffer = hBeforeBuffer.

            SaveSingleRow(CurrentTableResponse,   /* for errors */
                          hBeforeBuffer,    /* contains changed data */
                          oDSQuery,         /* datasource/datastore query (ie how to find DB record) */
                          Query:GetBufferRowKey(hBuffer) ).  /* row keys of source (ie prodataset actual buffer) */

            hBeforeQry:get-next().
        end.

        return CurrentTableResponse.
        finally:
            hBeforeQry:query-close().

            delete object hBeforeQry no-error.
            delete object hBeforeBuffer no-error.
            hBeforeBuffer = ?.

            /* go back to the base definition */
            cast(ABLDataSources:Get(ServiceMessageActionEnum:SaveData), IQuery):Reset().
            
            DisposeRequest().
        end finally.
    end method.

    /** Constructs a where clause for saving a record to the database.

        @param integer The ordinal position of the buffer in the datasource. Usually (?) 1.
        @param character The source buffer's keys.
        @param handle The source/prodataset before buffer
        @return character A WHERE clause for the datasource buffer  */
    method protected character BuildBufferKeyClause(input pcDatasourceBufferName as character,
                                                    input poDSQuery as DataSourceQuery,
                                                    input phSourceBuffer as handle):
        define variable oFilters as ICollection no-undo.
        define variable oIterator as IIterator no-undo.
        define variable oFilter as QueryFilter no-undo.
        define variable cWhereString as character no-undo.
        define variable cFieldValue as character no-undo.
        define variable hField as handle no-undo.
        define variable cResolvedFieldNames as character extent no-undo.

        /* get the base where string */
        cWhereString = ' where '
                     + cast(poDSQuery, IQuery):Definition:GetFilter(pcDatasourceBufferName).
        if cWhereString eq ? or cWhereString eq '' then
            cWhereString = ' where true '.

        oFilters = cast(poDSQuery:SourceKeyFilters:Get(new String(pcDatasourceBufferName)), ICollection).
        oIterator = oFilters:Iterator().
        do while oIterator:HasNext():
            oFilter = cast(oIterator:Next(), QueryFilter).

            /* first try to get the value from the source buffer */
            cResolvedFieldNames = CurrentDAO:ResolveFieldName(pcDatasourceBufferName, oFilter:FieldName).
            hField = phSourceBuffer:buffer-field(cResolvedFieldNames[1]) no-error.

            if valid-handle(hField) then
                cFieldValue = hField:buffer-value.

            /* The key filters have a &1 as a field value, for just this purpose. */
            cWhereString = cWhereString + substitute(oFilter:ToString(), cFieldValue).
        end.

        return cWhereString.
    end method.

    /** Adds a row to the DB.

        @param handle The ABL datasource object
        @param integer The current buffer index (in the DATA-SOURCE)
        @param DataSourceQuery The query used for this operation
        @param handle The source (typically before-image) buffer handle. */
    method protected void AddRow(input phABLDatasource as handle,
                                 input piBufferIndex as integer,
                                 input poDataSourceQuery as DataSourceQuery,
                                 input phSourceBuffer as handle):
        define variable hDbBuffer as handle no-undo.

        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).

        hDbBuffer:buffer-create().

        /* The BUFFER-COPY is cool in that it respects the DATA-SOURCE attach mappings. Except when there are 'EXCEPT' values */
        hDbBuffer:buffer-copy(phSourceBuffer:after-buffer, TenantFilterFieldName).

        if poDataSourceQuery:HasTenantFilter(hDbBuffer:name) then
            AddTenantKeys(hDbBuffer).

        AddPrimaryKeys(hDbBuffer, phSourceBuffer).
        UpdateForeignKeys(hDbBuffer, phSourceBuffer).
    end method.

    @method(virtual="true").
    /** Add any primary key values that aren't in the source dataset/temp-table

        @param handle The DB buffer being operated on
        @param handle The source (typically before-image) buffer handle. */
    method protected void AddPrimaryKeys(input phDbBuffer as handle,
                                         input phSourceBuffer as handle):
    end method.

    @method(virtual="true").
    /** Update (add or modify) any foreign key values that aren't easily
        mappable from the source dataset/temp-table

        @param handle The DB buffer being operated on
        @param handle The source (typically before-image) buffer handle. */
    method protected void UpdateForeignKeys(input phDbBuffer as handle,
                                            input phSourceBuffer as handle):
    end method.

    /** Add tenant key values to the DB buffer

        @param handle The DB buffer being added. */
    method protected void AddTenantKeys(input phDbBuffer as handle):
        define variable hField as handle no-undo.

        hField = phDbBuffer:buffer-field(TenantFilterFieldName) no-error.
        error-status:error = no.
        if valid-handle(hField) and SecurityManager:IsManagedSession then
            hField:buffer-value = cast(SecurityManager:CurrentUserContext:TenantId:Get(new String(phDbBuffer:dbname))
                                    , String):Value.
    end method.

    /** Deletes a DB row.

        @param handle The ABL datasource object
        @param integer The current buffer index (in the DATA-SOURCE)
        @param DataSourceQuery The query used for this operation
        @param handle The source (typically before-image) buffer handle. */
    method protected void DeleteRow(input phABLDatasource as handle,
                                    input piBufferIndex as integer,
                                    input poDataSourceQuery as DataSourceQuery,
                                    input phSourceBuffer as handle):

        /* build the where string */
        phABLDataSource:save-where-string(piBufferIndex) = BuildBufferKeyClause(
                                    phABLDataSource:get-source-buffer(piBufferIndex):name,   /* for identification */
                                    poDataSourceQuery, /* for filters */
                                    phSourceBuffer).    /* for data */
        /* do save
        phSourceBuffer:save-row-changes(piBufferIndex).
        */
    end method.

    /** Modifies a DB row

        @param handle The ABL datasource object
        @param integer The current buffer index (in the DATA-SOURCE)
        @param DataSourceQuery The query used for this operation
        @param handle The source (typically before-image) buffer handle. */
    method protected void UpdateRow(input phABLDatasource as handle,
                                    input piBufferIndex as integer,
                                    input poDataSourceQuery as DataSourceQuery,
                                    input phSourceBuffer as handle):
        define variable hDbBuffer as handle no-undo.

        /* build the where string */
        hDbBuffer = phABLDatasource:get-source-buffer(piBufferIndex).
        phABLDataSource:save-where-string(piBufferIndex) = BuildBufferKeyClause(
                                    hDbBuffer:name,   /* for identification */
                                    poDataSourceQuery, /* for filters */
                                    phSourceBuffer).    /* for data */
        /* do save */
        phSourceBuffer:save-row-changes(piBufferIndex).
        UpdateForeignKeys(hDbBuffer, phSourceBuffer).
    end method.

    /** Save data for the current row to the database.

        @param ITableResponse The table response object for this save request. Used in case of errors.

        @param handle The buffer containing the date being saved (the source buffer).
               This is usually the before-image buffer from the Business Entity.

        @param DataSourceQuery The query used to find the actual for the ABL Data-source

        @param character The key field values for the source buffer above. We don't derive these from
               the source buffer since if it is indeed the BEFORE-BUFFER, the keys are the ROWID used
               to get to the AFTER-BUFFER, and NOT the keys on the actual Business Entity buffer.   */
    method protected void SaveSingleRow(input poTableResponse as ITableResponse,
                                        input phSourceBuffer as handle,
                                        input poDSQuery as DataSourceQuery,
                                        input pcSourceRowKey as character):

        define variable iBufferIndex as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oFilter as QueryFilter no-undo.
        define variable hTargetBuffer as handle no-undo.
        define variable hABLDataSource as handle no-undo.
        define variable cRowKey as character extent 1 no-undo.

        cRowKey[1] = pcSourceRowKey.

        OnBeforeSaveTransaction(cRowKey).
        if phSourceBuffer:error then
            poTableResponse:ErrorText:Put(
                    new String(cRowKey[1]),
                    new String(phSourceBuffer:error-string)).
        else
        do transaction on error undo, throw:
            OnBeforeSave(cRowKey).
            /* errors can be raised by setting the error flag or by throwing an error. */
            if phSourceBuffer:error then
                poTableResponse:ErrorText:Put(
                        new String(cRowKey[1]),
                        new String(phSourceBuffer:error-string)).
            else
            do:
                assign hABLDataSource = cast(ABLDataSources:Get(CurrentActionType), DataSourceQuery):ABLDataSource
                       iMax = hABLDataSource:num-source-buffers.
                do iBufferIndex = 1 to iMax:
                    case RowStateEnum:ValueToEnum(phSourceBuffer:row-state):
                        when RowStateEnum:Created then AddRow(hABLDataSource, iBufferIndex, poDSQuery, phSourceBuffer).
                        when RowStateEnum:Deleted then DeleteRow(hABLDataSource, iBufferIndex, poDSQuery, phSourceBuffer).
                        when RowStateEnum:Modified then UpdateRow(hABLDataSource, iBufferIndex, poDSQuery, phSourceBuffer).
                    end case.
                end.

                if phSourceBuffer:error then
                    poTableResponse:ErrorText:Put(
                            new String(cRowKey[1]),
                            new String(phSourceBuffer:error-string)).
                else
                do:
                    OnAfterSave(cRowKey).

                    if phSourceBuffer:error then
                        poTableResponse:ErrorText:Put(
                                new String(cRowKey[1]),
                                new String(phSourceBuffer:error-string)).
                end.
            end.    /* error */
            finally:
                /* always release the buffers being updated */
                do iBufferIndex = 1 to iMax:
                    hABLDataSource:get-source-buffer(iBufferIndex):buffer-release().
                end.
            end finally.
        end.    /* transaction */

        OnAfterSaveTransaction(cRowKey).
        if phSourceBuffer:error then
            poTableResponse:ErrorText:Put(
                    new String(cRowKey[1]),
                    new String(phSourceBuffer:error-string)).

        /* If the DataSource validation events throw an error, make sure to add
           the error to the the buffer and response object. */

        /** catch and propogate any ABL errors */
        catch eSysErr as SysError:
            phSourceBuffer:error = true.
            phSourceBuffer:error-string = eSysErr:GetMessage(1).

            poTableResponse:ErrorText:Put(
                    new String(cRowKey[1]),
                    new String(phSourceBuffer:error-string)).
        end catch.
        finally:
            if phSourceBuffer:error then
                phSourceBuffer:rejected = true.
        end finally.
    end method.

    /** Override to ensure that we only allow handles - buffers or datasets - as data types here.  */
    method override public void SetDataTarget(input pcData as longchar,
                                              input poDataTargetFormat as DataFormatEnum,
                                              input poDataTargetType as DataTypeEnum):
        if not poDataTargetFormat:Equals(DataFormatEnum:ProDataSet) and
           not poDataTargetFormat:Equals(DataFormatEnum:TempTable) then
                undo, throw new ArgumentError(
                        'The StandardDataSource only supports ProDataSets and Temp-tables for data targets',
                        'StandardDataSource:SetDataTarget:input poDataTargetFormat as DataFormatEnum').

        super:SetDataTarget(pcData, poDataTargetFormat, poDataTargetType).
    end method.

    /* this could be pushed up */
    method protected handle ConvertTargetToHandle():
        define variable hTarget as handle no-undo.

        case DataTargetType:
            when DataTypeEnum:Handle then
            do:
                case DataTargetFormat:
                    when DataFormatEnum:ProDataSet then
                        hTarget = HandleDataTarget:get-buffer-handle(CurrentTableResponse:TableName).
                    when DataFormatEnum:TempTable then
                        hTarget = HandleDataTarget.
                end case.
            end.    /* handle */
            /* other need to be implemented */
            when DataTypeEnum:Memptr then .
            when DataTypeEnum:ProgressLangObject then .
            when DataTypeEnum:LongChar then .
        end case.

        return hTarget.
    end method.

    method protected void FilterQueryPerRequest(input poAction as ServiceMessageActionEnum,
                                                input poQuery as DataSourceQuery,
                                                input poRequest as ITableRequest,
                                                input poDAO as IDataAccess):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oBuffer as QueryBuffer no-undo.
        define variable oResolvedSort as QuerySort extent no-undo.
        define variable oResolvedFilter as QueryFilter extent no-undo.
        define variable oResolvedJoin as QueryJoin extent no-undo.
        define variable oElements as Object extent no-undo.
        define variable oQueryDefinition as IQueryDefinition no-undo.
        define variable hDataSourceBuffer as handle no-undo.
        define variable hDataSourceJoinBuffer as handle no-undo.
        define variable cResolvedFieldName as character extent no-undo.
        define variable iInnerMax as integer no-undo.
        define variable iInnerLoop as integer no-undo.

        assign oElements = cast(poRequest, IQueryDefinition):GetQueryElements()
               iMax = extent(oElements)
               oQueryDefinition =  poQuery:Definition.

        do iLoop = 1 to iMax:
            case oElements[iLoop]:GetClass():
                /* This block should create buffers for all buffers in the query,
                   including mapped ones. */
                when Class:GetClass('OpenEdge.Core.System.QueryBuffer') then
                do:
                    oBuffer = cast(oElements[iLoop], QueryBuffer).

                    /* Resolve any mapping between DB and ProDataSet */
                    cResolvedFieldName = poDAO:ResolveFieldName(oBuffer:Name, '').
                    /* [PJ] eOrder -> Order */
                    hDataSourceBuffer = poQuery:GetTableHandle(cResolvedFieldName[2]).
                    /* [PJ] Order -> Order_1234-5678 */

                    /* Use handle:NAME since the table name is what's returned in from ResolveFieldName() */
                    oQueryDefinition:AddBuffer(
                        hDataSourceBuffer:name,
                        hDataSourceBuffer:table,
                        oBuffer:QueryType,
                        oBuffer:LockMode).
                end.    /* buffers */
                when Class:GetClass('OpenEdge.Core.System.QueryFilter') then
                do:
                    oResolvedFilter = poDAO:ResolveFilter(cast(oElements[iLoop], QueryFilter)).
                    iInnerMax = extent(oResolvedFilter).
                    do iInnerLoop = 1 to iInnerMax:
                        /* assume that the resolved filter has the resolved table name */
                        hDataSourceBuffer = poQuery:GetTableHandle(oResolvedFilter[iInnerLoop]:BufferName).

                        /* GetTableBuffer */
                        /* We don't know whether the mapping resolved to a different DB table for this table/field
                           combo, so try to add the buffer to the QueryDefinition again. It will only be added if
                           it doesn't already exist in the QueryDefinition. */
                        oQueryDefinition:AddBuffer(hDataSourceBuffer:name, hDataSourceBuffer:table).

                        hDataSourceBuffer = poQuery:GetTableHandle(oResolvedFilter[iInnerLoop]:BufferName).
                        /* [PJ] StatusDetail -> StatusDetail_1234-5678 */
                        /* [PJ] Order -> Order_1234-5678 */

                        oResolvedFilter[iInnerLoop]:BufferName = hDataSourceBuffer:name.

                        /* Add new filter clause to the DB query */
                        oQueryDefinition:AddFilter(oResolvedFilter[iInnerLoop]).
                    end.
                end.    /* filters */
                when Class:GetClass('OpenEdge.Core.System.QueryJoin') then
                do:
                    oResolvedJoin = poDAO:ResolveJoin(cast(oElements[iLoop], QueryJoin)).
                    iInnerMax = extent(oResolvedJoin).
                    do iInnerLoop = 1 to iInnerMax:
                        /*  LHS */
                        hDataSourceBuffer = poQuery:GetTableHandle(oResolvedJoin[iInnerLoop]:BufferName).
                        oResolvedJoin[iInnerLoop]:BufferName = hDataSourceBuffer:name.

                        /* We don't know whether the mapping resolved to a different DB table for this table/field
                           combo, so try to add the buffer to the QueryDefinition again. It will only be added if
                           it doesn't already exist in the QueryDefinition. */
                        oQueryDefinition:AddBuffer(hDataSourceBuffer:name, hDataSourceBuffer:table).

                        /*  RHS */
                        hDataSourceBuffer = poQuery:GetTableHandle(oResolvedJoin[iInnerLoop]:JoinBufferName).
                        oResolvedJoin[iInnerLoop]:JoinBufferName = hDataSourceBuffer:name.

                        /* We don't know whether the mapping resolved to a different DB table for this table/field
                           combo, so try to add the buffer to the QueryDefinition again. It will only be added if
                           it doesn't already exist in the QueryDefinition. */
                        oQueryDefinition:AddBuffer(hDataSourceBuffer:name, hDataSourceBuffer:table).

                        /* Add new join clause to the DB query */
                        oQueryDefinition:AddJoin(oResolvedJoin[iInnerLoop]).
                    end.
                end.    /* joins */
                when Class:GetClass('OpenEdge.Core.System.QuerySort') then
                do:
                    oResolvedSort = poDAO:ResolveSort(cast(oElements[iLoop], QuerySort)).
                    iInnerMax = extent(oResolvedSort).
                    do iInnerLoop = 1 to iInnerMax:
                        hDataSourceBuffer = poQuery:GetTableHandle(oResolvedSort[iInnerLoop]:BufferName).
                        oResolvedSort[iInnerLoop]:BufferName = hDataSourceBuffer:name.

                        /* We don't know whether the mapping resolved to a different DB table for this table/field
                           combo, so try to add the buffer to the QueryDefinition again. It will only be added if
                           it doesn't already exist in the QueryDefinition. */
                        oQueryDefinition:AddBuffer(hDataSourceBuffer:name, hDataSourceBuffer:table).

                        /* add new sort phrase to query */
                        oQueryDefinition:AddSort(oResolvedSort[iInnerLoop]).
                    end.
                end.    /* sort */
            end case.   /* element type */
        end.    /* loop */
    end method.

    /** Adds filtering by tenant to the current datasource for an action. This is done per
        request, and not just once, since the user may vary per request, and we have no idea
        of this Datasource object's lifespan.

        @param ServiceMessageActionEnum The current request's action type. */
    method override protected void AddTenantFilter(input poAction as ServiceMessageActionEnum):
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable oFilter as QueryFilter no-undo.
        define variable hField as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable oTenantId as IMap no-undo.

        /* always try to filter by tenant */
        if SecurityManager:IsManagedSession then
        do:
            oTenantId = SecurityManager:CurrentUserContext:TenantId.
            oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery).
            iMax = oDSQuery:ABLDataSource:num-source-buffers.
            do iLoop = 1 to iMax:
                assign hField = ?
                       oFilter = ?
                       hBuffer = oDSQuery:ABLDataSource:get-source-buffer(iLoop).

                /* no-error since this field may not exist */
                hField = hBuffer:buffer-field(TenantFilterFieldName) no-error.
                error-status:error = no.
                if valid-handle(hField) then
                    oFilter = new QueryFilter(
                                    hBuffer:name,
                                    TenantFilterFieldName,
                                    OperatorEnum:IsEqual,
                                    cast(oTenantId:Get(new String(hBuffer:dbname)), String),
                                    DataTypeEnum:LongChar,
                                    JoinEnum:And).
                if valid-object(oFilter) then
                    oDSQuery:AddTenantFilter(oFilter).
            end.
        end.    /* managed session */
    end method.

    /** Removes filtering by tenant for a given action. 
        
        @param ServiceMessageActionEnum The current request's action type. */
    method override protected void RemoveTenantFilter(input poAction as ServiceMessageActionEnum).
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable oFilter as QueryFilter no-undo.
        define variable hField as handle no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable oTenantId as IMap no-undo.
            
        /* always try to filter by tenant */
        if SecurityManager:IsManagedSession then
        do:
            oTenantId = SecurityManager:CurrentUserContext:TenantId.
            oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery).
            iMax = oDSQuery:ABLDataSource:num-source-buffers.
            do iLoop = 1 to iMax:
                assign hField = ?
                       oFilter = ?
                       hBuffer = oDSQuery:ABLDataSource:get-source-buffer(iLoop).

                /* no-error since this field may not exist */
                hField = hBuffer:buffer-field(TenantFilterFieldName) no-error.
                error-status:error = no.
                if valid-handle(hField) then
                    oDSQuery:RemoveTenantFilter(hBuffer:name).
            end.
        end.    /* managed session */
    end method.
    
    method override protected void CreateDataStore():
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.
        define variable hBuffer as handle no-undo.

        if not ABLDataSources:ContainsKey(ServiceMessageActionEnum:FetchData) then
        do:
            create data-source hABLDataSource.
            /* Create a buffer with a unique name, since we don't know where this DataSource will be used,
               nor how. So to aviod error 12298 we give the buffer a unique name */
            create buffer hBuffer for table PrimaryTable
                buffer-name substitute('&1_&2-&3',
                             PrimaryTable:name,
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:FetchData))).
            hABLDataSource:add-source-buffer(hBuffer, hBuffer:keys).
            oDSQuery = new DataSourceQuery(hABLDataSource).
            ABLDataSources:Put(ServiceMessageActionEnum:FetchData, oDSQuery).

            oDSQuery:Initialize().
        end.

        /* Use a simple datasource using the PrimaryTable and its keys */
        if not ABLDataSources:ContainsKey(ServiceMessageActionEnum:SaveData) then
        do:
            create data-source hABLDataSource.
            /* Create a buffer with a unique name, since we don't know where this DataSource will be used,
               nor how. So to avoid error 12298 we give the buffer a unique name */
            create buffer hBuffer for table PrimaryTable
                buffer-name substitute('&1_&2-&3',
                             PrimaryTable:name,
                             string(hABLDataSource),
                             string(int(ServiceMessageActionEnum:SaveData))).
            hABLDataSource:add-source-buffer(hBuffer, hBuffer:keys).
            oDSQuery = new DataSourceQuery(hABLDataSource).
            ABLDataSources:Put(ServiceMessageActionEnum:SaveData, oDSQuery).

            oDSQuery:Initialize().
        end.
    end method.

    method override protected void DeleteDataStore():
        define variable oIterator as IIterator no-undo.
        define variable oAction as ServiceMessageActionEnum no-undo.

        oIterator = ABLDataSources:KeySet:Iterator().

        do while oIterator:HasNext():
            oAction = cast(oIterator:Next(), ServiceMessageActionEnum).

            /* detach first, just in case */
            DetachDataStoreFromTarget(oAction).
            delete object cast(ABLDataSources:Remove(oAction), DataSourceQuery):ABLDataSource no-error.
        end.
    end method.

    method override protected void AttachDataStoreToTarget(input poAction as ServiceMessageActionEnum):
        define variable hABLDataSource as handle no-undo.
        define variable oDSQuery as DataSourceQuery no-undo.

        oDSQuery = cast(ABLDataSources:Get(poAction), DataSourceQuery).
        hABLDataSource = oDSQuery:ABLDataSource.

        hABLDataSource:prefer-dataset = true.
        TargetBuffer:attach-data-source(hABLDataSource).

        AttachedActions:Add(poAction).
    end method.

    method override protected void DetachDataStoreFromTarget(input poServiceMessageAction as ServiceMessageActionEnum):
        if AttachedActions:Contains(poServiceMessageAction) then
        do:
            TargetBuffer:detach-data-source().
            AttachedActions:Remove(poServiceMessageAction).
        end.
    end method.

    method protected void OnBeforeRowFill(input pcRowKey as character extent,
                                          input phSourceBuffer as handle,
                                          input phTargetBuffer as handle):

        OnBeforeRowFill(new DataSourceEventArgs(
                        DataSourceEventEnum:BeforeSaveTransaction,
                        this-object:DataTargetFormat,
                        this-object:DataTargetType,
                        GetDataTarget(),
                        pcRowKey)).
    end method.

	method override public void ClearDataTarget():
		super:ClearDataTarget().
		TargetBuffer = ?.
	end method.

	/** Returns the next opaque ID value for key values. This
	    defaults to a GUID but could be anything.

	    @param character The DB table name for which to retrieve a key value.

	    @return character A new opaque id for a key value.     */
	method protected character GetNextOpaqueId(input pcTableName as character):
	    return guid(generate-uuid).
    end method.

end class.
