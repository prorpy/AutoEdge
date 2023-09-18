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
    File        : DatasetModel
    Description : Model that uses ProDataSets for physical data storage.
    @author pjudge
    Created     : Tue Dec 11 11:31:41 EST 2007
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Model.Model.
using OpenEdge.PresentationLayer.Model.IModelReadOnly.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo. 
using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.IService.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.Util.BufferHelper.
using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.EventArgs.
using OpenEdge.Core.System.QueryDefinition. 
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.AccessViolationError.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.CharacterStack.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.JoinEnum.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.PresentationLayer.Model.DatasetModel abstract inherits Model:
    
    /** Since a ProDataset can only be navigated by a single
        ProBindingSource at a time, we need a facility to clone
        the dataset for the UI.
        
        The Presenter keeps track of which clones it has, and will
        cause them to be removed, as needed. The Presenter needs to 
        do this, since the Model doesn't know anything about the Presenter's
        life-cycle, nor even which Presenters it serves.
        
        When this Model is torn down, it will of course clean up after
        itself, but in cases where the Model is shared, we don't want
        any leaks.  */
    define private temp-table ttDatasetClone no-undo
        field DatasetHandle as handle
        index idx1 as primary unique DatasetHandle.
    
    /** The dataset that contains this Model's data */    
    define protected property MasterDataset as handle no-undo get. set.
    
	constructor public DatasetModel(input pcServiceName as character, input poComponentInfo as IComponentInfo):
		super (input pcServiceName, input poComponentInfo).
	end constructor.

    method override protected void ReceiveFetchSchemaResponse(input poResponse as IFetchResponse):
        /* Pull the dataset into the model before super(), since we need the dataset to be able\
           to work with buffer handles etc. */
        cast(poResponse, IServiceMessage):GetMessageData(output MasterDataset).
        
        super:ReceiveFetchSchemaResponse(input poResponse).
        
        SetCallbacks(MasterDataset).
        
        EnableDatasetForUpdate(MasterDataset).
    end method.
    
    method protected void SetCallbacks(phDataset as handle):
        define variable iLoop as integer no-undo.
        define variable hBuffer as handle no-undo.
                        
        do iLoop = 1 to phDataset:num-buffers:
            hBuffer = phDataset:get-buffer-handle(iLoop).
            SetBufferCallbacks(hBuffer:name, hBuffer).
        end.
    end method.
    
    method protected abstract void SetBufferCallbacks(pcBufferName as char, phBuffer as handle).
    
    /** Creates the master ProDataSet for this Model. Default is to ask the Service for it.
        The ReceiveFetchSchemaResponse() method will receive the dataset response and perform the
        actual create.
        
        This method is usually not called, since a Presenter will typically make a service request
        for schema when the Presenter is initiating. However, we keep this method in a similar vein as
        the FetchData() call (which is also usually similarly overridden/ignored by the Presenter). */
    method protected void CreateMasterDataset():
        define variable oSchemaRequest as IFetchRequest no-undo.
        
        oSchemaRequest = new FetchRequest(this-object:ServiceName, ServiceMessageActionEnum:FetchSchema).
        
        FetchData(cast(oSchemaRequest, IServiceRequest)).
    end method.
    
    method protected void EnableDatasetForUpdate(phDataset as handle):
        define variable iLoop   as integer no-undo.
        define variable hBuffer as handle  no-undo.
        
        if not type-of(this-object, IModelReadOnly) then
        do iLoop = 1 to phDataset:num-buffers:
            hBuffer = phDataset:get-buffer-handle(iLoop).
            hBuffer:table-handle:tracking-changes = true.
        end.
    end method.
        
    method protected void DisableDatasetForUpdate(phDataset as handle):
        define variable iLoop   as integer no-undo.
        define variable hBuffer as handle  no-undo.
        
        do iLoop = 1 to phDataset:num-buffers:
            hBuffer = phDataset:get-buffer-handle(iLoop).
            hBuffer:table-handle:tracking-changes = no.
        end.
    end method.
    
    method protected handle CloneDataset(phDataset as handle):
        define variable iLoop as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable hRelation as handle no-undo.
                
        define buffer lbDataset for ttDatasetClone.
                        
        create lbDataset.
        create dataset lbDataset.DatasetHandle.
        lbDataset.DatasetHandle:Name = phDataset:name.
        
        do iLoop = 1 to phDataset:num-buffers:
            create buffer hBuffer for 
                    table phDataset:get-buffer-handle(iLoop)
                    buffer-name phDataset:get-buffer-handle(iLoop):name.
            
            /* We don't want the buffers deleted when the cloned dataset is cleaned up. */
            lbDataset.DatasetHandle:add-buffer(hBuffer).
            
            /* Set the Auto-Delete to False since we're re-using the buffers from the
               master dataset, and we don't want those to get blown away willy-nilly
               when the cloned dataset is cleaned up.
                
               We MUST do thas /after/ the buffer's been added to the ProDataSet else
               it has no effect. */
            hBuffer:auto-delete = false.
        end.
                
        do iLoop = 1 to phDataset:num-relations:
            hRelation = phDataset:get-relation(iLoop).
            
            lbDataset.DatasetHandle:add-relation(
                    lbDataset.DatasetHandle:get-buffer-handle(hRelation:parent-buffer:name),
                    lbDataset.DatasetHandle:get-buffer-handle(hRelation:child-buffer:name),
                    hRelation:relation-fields,
                    hRelation:reposition,
                    hRelation:nested,
                    hRelation:active,
                    hRelation:recursive,
                    hRelation:foreign-key-hidden ).
        end.
        
        CreateDefaultQueries(lbDataset.DatasetHandle).
        
        return lbDataset.DatasetHandle.
    end method.
    
    method override public void DestroyComponent():
        super:DestroyComponent().
                
        DeleteDatasetClones().
        DeleteMasterDataset().
    end method.
    
    method protected void DeleteMasterDataset():
        define variable iBuffer as integer no-undo.
        
        /* buffers are not set to auto delete, so clean up manually */
        do iBuffer = 1 to MasterDataset:num-buffers:
            delete object MasterDataset:get-buffer-handle(iBuffer).
        end.
        
        delete object MasterDataset no-error.
    end method.
    
    method protected void DeleteDatasetClone(phDataset as handle):
        define buffer lbDataset for ttDatasetClone.
        
        find lbDataset where lbDataset.DatasetHandle = phDataset no-error.
        if available lbDataset then
        do:
            DeleteDatasetQueries(lbDataset.DatasetHandle).
            delete object lbDataset.DatasetHandle no-error.
            delete lbDataset.
        end.
    end method.
    
    method protected void DeleteDatasetQueries(phDataset as handle):
        define variable iNumRelations  as integer no-undo.
        
        if valid-handle(phDataset) then
        do:
            do iNumRelations = 1 to phDataset:num-relations:
                ModelQueries:Remove(string(phDataset:get-relation(iNumRelations):query)).
            end.
            
            ModelQueries:Remove('top-nav-query').
        end.
    end method.        
            
    method protected void DeleteDatasetClones():
        define buffer lbDataset for ttDatasetClone.
        
        for each lbDataset:
            DeleteDatasetQueries(lbDataset.DatasetHandle).
            
            delete object lbDataset.DatasetHandle no-error.
            delete lbDataset.
        end.
        
    end method.
    
    method override protected handle GetBufferHandle (pcTable as char):
        return MasterDataset:get-buffer-handle(pcTable).
    end method.
    
    method override protected character DoAddRecord(input pcTableName as character):
        define variable hBuffer    as handle no-undo.
        define variable cNewRecordKey as character no-undo.

        hBuffer = GetBufferHandle(pcTableName).
        
        do transaction:
            hBuffer:buffer-create().
            
            AssignKeyValues(pcTableName, hBuffer).
            AssignDefaultValues(pcTableName, hBuffer).
            
            cNewRecordKey = GetRecordKey(hBuffer).
            hBuffer:buffer-release().
            
        end.
        
        return cNewRecordKey.
    end method.
    
    method override protected void DoDeleteRecord(input pcTableName as character, input pcRecordKey as character):
        define variable hBuffer as handle  no-undo.
        
        hBuffer = GetBufferHandle(pcTableName).
        /* try to keep the record scope tight ... */
        if FindTableByKey(hBuffer, pcRecordKey) then
        do transaction:
            hBuffer:buffer-delete() no-error.
        end.
    end method.
    
    method override protected void DoSaveRecord(input pcTableName as character, input pcRecordKey as character ):
        define variable hBuffer as handle  no-undo.
        
        hBuffer = GetBufferHandle(pcTableName).
        /* try to keep the record scope tight ... */
        if FindTableByKey(hBuffer, pcRecordKey) then
            hBuffer:buffer-release() no-error.
    end method.
    
    method override protected logical FindTableByKey(input phBuffer as handle, input pcRecordKey as character):
        if pcRecordKey begins 'where' then
            phBuffer:find-unique(pcRecordKey) no-error.
        else
            phBuffer:find-by-rowid(to-rowid(pcRecordKey)) no-error.
        
        return phBuffer:available.
    end method.
    
    /** Each model type will have it's own way of determining a buffer handle
        based on it's internal data storage structures, eg prodataset, temp-table.  */
    method protected handle GetBufferField(input pcBufferName as character,
                                           input pcFieldName as character):
        return GetBufferHandle(pcBufferName):buffer-field(pcFieldName).                                               
    end method.
    
    method override protected character GetRecordKey(input pcTableName as character):
        return GetRecordKey(GetBufferHandle(pcTableName)).
    end method.
    
    method protected character GetRecordKey(phBuffer as handle):
        define variable cRecordKey as char no-undo.
        define variable cKeys as char no-undo.
        define variable iFields as int no-undo.
        
        if phBuffer:available then
        do:
            cKeys = phBuffer:keys.
            if cKeys eq 'Rowid' then
                cRecordKey = string(phBuffer:rowid). 
            else
            do iFields = 1 to num-entries(cKeys):
                cRecordKey = cRecordKey
                           + (if iFields eq 1 then 'where ' else ' and ')
                           + phBuffer:name + '.' + entry(iFields, cKeys)
                           + ' = ' + quoter(phBuffer:buffer-field(entry(iFields, cKeys)):buffer-value)
                           .
            end.    /* key fields */
        end.
        else
            cRecordKey = ?.
        
        return cRecordKey.        
    end method.
    
    /** Lists the names of tables in this Model. By default we list all tables.
    
        @return character An array of table names in this Model */
    method override protected character extent GetTableNames(  ):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cTableNames as character extent no-undo.
        
        iMax = MasterDataset:num-buffers.
        extent(cTableNames) = iMax.
        
        do iLoop = 1 to iMax:
            cTableNames[iLoop] = MasterDataset:get-buffer-handle(iLoop):name.
        end.
        
        return cTableNames.
    end method.
        
    method override protected void ReceiveFetchResponse(input poResponse as IFetchResponse):
        define variable oIterator as IIterator no-undo.
        define variable oTR as ITableResponse no-undo.
        define variable oMEE as ModelActionEventArgs no-undo.
        define variable cTables as character extent no-undo.
        define variable iExtent as integer no-undo.
        define variable hTransportDataset as handle no-undo.
        
        cast(poResponse, IServiceMessage):GetMessageData(output hTransportDataset).
        
        extent(cTables) = poResponse:TableResponses:Values:Size.
        
        oIterator = poResponse:TableResponses:Values:Iterator().
        do while oIterator:HasNext():
            oTR = cast(oIterator:Next(), ITableResponse).
            
            /* check for and deal with errors */       
            if oTR:HasError then
                OnDataFetchError(ExtractTableErrors(oTR)).
            else
            do:
                assign iExtent = iExtent + 1
                       cTables[iExtent] = oTR:TableName.
                /* update the model's table context from the response */
                UpdateTableContextFromResponse(oTR).                       
            end.                       
        end.
        
        DisableDatasetForUpdate(MasterDataset).
        MasterDataset:copy-dataset(hTransportDataset,
                                     true,      /* append */
                                     ?,         /* replace */
                                     true).     /* loose fill */
        EnableDatasetForUpdate(MasterDataset).
        
        OnDataFetched(
            new ModelActionEventArgs(
                    cast(cast(this-object, IComponent):ComponentInfo, IComponentInfo),
                    ModelActionEnum:Fetch,
                    cTables,
                    cast(poResponse, IServiceMessage):MessageId)).
        finally:
            /* At this point, we're done with the transport dataset, and  
               assume that all errors have been dealt with */
            hTransportDataset:empty-dataset().
            delete object hTransportDataset no-error.
        end finally.        
                    
    end method.
    
    /** Receive the Save response (may have data) from the service message.
        
        @param ISaveResponse The response message from the data save request. */
    method override protected void ReceiveSaveResponse(input poResponse as ISaveResponse):
        define variable oIterator as IIterator no-undo.
        define variable oTR as ITableResponse no-undo.
        define variable cTables as character extent no-undo.
        define variable hTransportDataset as handle no-undo.
        
        cast(poResponse, IServiceMessage):GetMessageData(output hTransportDataset).
         
        /* check for and deal with errors */        
        if cast(poResponse, IServiceResponse):HasError then
        do:
            oIterator = poResponse:TableResponses:Values:Iterator().
            do while oIterator:HasNext():
                oTR = cast(oIterator:Next(), ITableResponse).
                if oTR:HasError then
                    OnDataCommitError(ExtractTableErrors(oTR)).
            end.
        end.
        
        /* merge all changes from the transport dataset to the master */
        DisableDatasetForUpdate(MasterDataset).
        
        hTransportDataset:merge-changes(MasterDataset, true).
        
        EnableDatasetForUpdate(MasterDataset).
        
        OnDataCommitted(
                new ModelActionEventArgs(
                    cast(cast(this-object, IComponent):ComponentInfo, IComponentInfo),
                    ModelActionEnum:Commit,
                    cTables,
                    cast(poResponse, IServiceMessage):MessageId)).
        
        finally:
            /* At this point, we're done with the transport dataset, and  
               assume that all errors have been dealt with */
            hTransportDataset:empty-dataset().
            delete object hTransportDataset no-error.
        end finally.        
    end method.
    
    /** Builds a save request for the specified tables in the Model. 
        
        @param character An array of table for which to create the save request.
        @return ISaveRequest The complete save request for the model/tables     */
    method override protected ISaveRequest BuildSaveRequest(input pcTables as character extent):
        define variable oSaveRequest as ISaveRequest no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable iExtent as integer no-undo. 
        define variable cChangedTables as character extent no-undo.
        define variable hTransportDataset as handle no-undo.
        define variable hBuffer as handle no-undo.
        
        /* Check whether we're attempting to update a R-O model */
        if type-of(this-object, IModelReadOnly) then 
        do:
            /* in case someone ignores the Error */
            undo, throw new AccessViolationError(
                'Model ' + this-object:GetClass():TypeName,
                AccessViolationError:READ_ONLY).
        end.
        
        /* Get the change data */
        create dataset hTransportDataset.
        hTransportDataset:create-like(MasterDataset).
        hTransportDataset:get-changes(MasterDataset).
        
        oSaveRequest = new SaveRequest(ServiceName).
        
        /* Put the PDS into the message */
        cast(oSaveRequest, IServiceMessage):SetMessageData(hTransportDataset, DataFormatEnum:ProDataSet).
        
        /* We set the ISaveRequest:TableNames property, but we
           can probably also derive that from the dataset. */
        iMax = extent(pcTables).
        extent(cChangedTables) = iMax.
        do iLoop = 1 to iMax:
            hBuffer = hTransportDataset:get-buffer-handle(pcTables[iLoop]).
            
            /* There will always be records in the before buffer, regardless of the operation.
               The 'after' buffer won't contain deletes. */
            if hBuffer:before-buffer:table-handle:has-records then
                assign iExtent = iExtent + 1
                       cChangedTables[iExtent] = hBuffer:name.
        end.
        
        if iExtent gt 0 then
        do:
            /* Fill the array backwards, since a stack is always LIFO. Order is
               probably not important anyway, but ... */
            extent(oSaveRequest:TableNames) = iExtent.
            do iLoop = 1 to iMax while cChangedTables[iLoop] ne '':
                oSaveRequest:TableNames[iLoop] = cChangedTables[iloop].
            end.
        end.
        
        return oSaveRequest.
    end method.
    
    /* Operations */
            
    /** Assign parent values based on the relation a (child) buffer is part of.
     **/
    method protected void AssignKeyValues (pcTable as char, phBuffer as handle):
        define variable hRelation as handle no-undo.
        define variable iNumFields as integer no-undo.
        
        hRelation = phBuffer:parent-relation.
        
        if valid-handle(hRelation) then
        /* relationfields = parent-field1, child-field1 [, parent-fieldn, child-fieldn ] ...) */
        do iNumFields = 1 to num-entries(hRelation:relation-fields) by 2:
            phBuffer:buffer-field(entry(iNumFields + 1, hRelation:relation-fields)):buffer-value =
                    hRelation:parent-buffer:buffer-field(entry(iNumFields, hRelation:relation-fields)):buffer-value.
        end.                        
    end method.
    
    /** Sset the default (initial) values on create of a record
        in the model. The table name is passed in in case the model is operating 
        on a non-default-ly named buffer. The buffer handle is positioned to the
        newly-created record.
        
        Note that key values are set in AssignKeyValues().
        
        @param character
          */
    method abstract protected void AssignDefaultValues (input pcTableName as character, input phBuffer as handle).
    
    /** Extract error texts from a service response for a given table.  
        
        @param ITableResponse The tableresponse object containin error(s) 
        @return ModelErrorEventArgs Arguments containing the request errors     */    
    method protected ModelErrorEventArgs ExtractTableErrors(input poResponse as ITableResponse):
        define variable hChangeBuffer as handle no-undo.
        define variable hChangeBefore as handle no-undo.
        define variable hChangeAfter as handle no-undo.
        define variable hMasterBuffer as handle no-undo.
        define variable hMasterBefore as handle no-undo.
        define variable hMasterAfter as handle no-undo.
        define variable hQuery as handle no-undo.
        define variable oModelErrorEventArgs as ModelErrorEventArgs no-undo.
        define variable hTransportDataset as handle no-undo.
        
        cast(poResponse, IServiceMessage):GetMessageData(output hTransportDataset).
        
        oModelErrorEventArgs = new ModelErrorEventArgs(poResponse:TableName). 

        hChangeAfter = hTransportDataset:get-buffer-handle(poResponse:TableName).
        hMasterBuffer = MasterDataset:get-buffer-handle(poResponse:TableName).
        /* we want a separate buffer so we don't risk messing up the buffer 
           being viewed/traversed in the View */
        create buffer hMasterAfter for table hMasterBuffer.
        
        if valid-handle(hChangeAfter) then
        do:
            hMasterBefore = hMasterBuffer:before-buffer no-error. 
            create query hQuery.
                                    
            if valid-handle(hMasterBefore) then
            do:
                hChangeBefore = hChangeAfter:before-buffer.

                hQuery:set-buffers(hChangeBefore).
                hQuery:query-prepare('for each ' + hChangeBefore:name ).
                hQuery:query-open().
                hQuery:get-first().
                
                do while hChangeBefore:available:
                    if hChangeBefore:data-source-modified and 
                        hChangeBefore:row-state ne row-deleted then
                    do:
                        hMasterBefore:find-by-rowid(hChangeBefore:origin-rowid).
                        hMasterAfter:find-by-rowid(hMasterBefore:after-rowid).
                        hChangeAfter:find-by-rowid(hChangeBefore:after-rowid).
                        
                        oModelErrorEventArgs:AddErrorRecord(
                            hChangeAfter:rowid,
                            BufferHelper:BufferCompare(hMasterAfter, hChangeAfter),
                            hChangeAfter:error-string).
                    end.    /* record changed */
                    hQuery:get-next().
                end.    /* query loop */
            end.    /* valid masterbefore */
        end.    /* valid changeafter */
        
        return oModelErrorEventArgs.
    end method.

    @todo(task="clean up all child queries").
    /**  
    method public override void RemoveBindingHandle(phBindingHandle as handle):
        if valid-handle(phBindingHandle) and
           phBindingHandle:type eq 'Dataset' then
            DeleteDatasetClone(phBindingHandle).
        else
            /* We can also create 'manual' queries with DatasetModel */
            super:RemoveBindingHandle(phBindingHandle).
    end method.
    **/
        
    method protected void CreateDefaultQueries(phDataset as handle):
        /* Create query records for a dataset's queries. */
        define variable oQueryDefinition as IQueryDefinition no-undo.
        define variable oQuery as IQuery no-undo.
        define variable cQuery as character no-undo. 
        define variable hQuery as handle no-undo.
        define variable iNumRelations as integer no-undo.
        define variable hRelation as handle no-undo.
        define variable iNumFields as integer no-undo.
        
        /* Top-Nav-Query */
        hQuery = phDataset:top-nav-query.
        cQuery = string(phDataset) + '-top-nav-query'.
        
        oQueryDefinition = new QueryDefinition().
        oQueryDefinition:AddBuffer(phDataset:get-top-buffer(1):name).
        CreateQuery(oQueryDefinition, hQuery, cQuery).
        
        /* relations' queries */
        do iNumRelations = 1 to phDataset:num-relations:
            hRelation = phDataset:get-relation(iNumRelations).
            if not hRelation:active then
                next.
            
            oQueryDefinition = new QueryDefinition().
            oQueryDefinition:AddBuffer(hRelation:child-buffer:name).
            
            /* relationfields = parent-field1, child-field1 [, parent-fieldn, child-fieldn ] ...) */
            do iNumFields = 1 to num-entries(hRelation:relation-fields) by 2:
                oQueryDefinition:AddJoin(hRelation:child-buffer:name,
                                        entry(iNumFields, hRelation:relation-fields),
                                        OperatorEnum:IsEqual,
                                        hRelation:parent-buffer:name,
                                        entry(iNumFields + 1, hRelation:relation-fields),
                                        JoinEnum:And).
            end.
            
            /* Use the RELATION as an identifier, and NOT the query. This is so that 
               we can use the same Query object for all the queries that are constructed on the 
               fly by the ProBindingSource. 
               
               We don't have a query for this relation yet, since the actual query used may change
               as the PBS does its creation and destruction. */
            assign hQuery = ?
                   cQuery = string(phDataset) + '-'
                          + 'relation-'  
                          + hRelation:parent-buffer:name + '-'
                          + hRelation:child-buffer:name.
            CreateQuery(oQueryDefinition, hQuery, cQuery).
        end.
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output pcValue as char ):
        FindTableByKey(pcBufferName, pcRecordKey).
        pcValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output pcValue as char extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        pcValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output ptValue as date ):
        FindTableByKey(pcBufferName, pcRecordKey).
        ptValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output ptValue as date extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        ptValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output ptValue as datetime ):
        FindTableByKey(pcBufferName, pcRecordKey).
        ptValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output ptValue as datetime extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        ptValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output ptValue as datetime-tz ):
        FindTableByKey(pcBufferName, pcRecordKey).
        ptValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output ptValue as datetime-tz extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        ptValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output pdValue as decimal ):
        FindTableByKey(pcBufferName, pcRecordKey).
        pdValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output pdValue as decimal extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        pdValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output phValue as handle ):
        FindTableByKey(pcBufferName, pcRecordKey).
        phValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output phValue as handle extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        phValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output piValue as int ):
        FindTableByKey(pcBufferName, pcRecordKey).
        piValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output piValue as int extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        piValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output piValue as int64 ):
        FindTableByKey(pcBufferName, pcRecordKey).
        piValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output piValue as int64 extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        piValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output pcValue as longchar ):
        FindTableByKey(pcBufferName, pcRecordKey).
        pcValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output pcValue as longchar extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        pcValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.
    
    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output prValue as raw ):
        FindTableByKey(pcBufferName, pcRecordKey).
        prValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output prValue as raw extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        prValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output poValue as Object ):
        FindTableByKey(pcBufferName, pcRecordKey).
        poValue = GetBufferField(pcBufferName, pcField):buffer-value.               
    end method.

    method override public void GetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, output poValue as Object extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        poValue = GetBufferField(pcBufferName, pcField):buffer-value.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, pcValue as char):
        FindTableByKey(pcBufferName, pcRecordKey).
        
        /*
        ValidateField(piAction as integer,
                      pcFieldName as character,
                      phBeforeField as handle,
                      phAfterField as handle).
        */
                
        GetBufferField(pcBufferName, pcField):buffer-value = pcValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, pcValue as char extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = pcValue.
    end method.
            
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, pcValue as longchar):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = pcValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, pcValue as longchar extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = pcValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, phValue as handle):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = phValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, phValue as handle extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = phValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, piValue as int):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = piValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, piValue as int extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = piValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, piValue as int64):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = piValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, piValue as int64 extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = piValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, pdValue as decimal):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = pdValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, pdValue as decimal extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = pdValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, ptValue as date):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = ptValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, ptValue as date extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = ptValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, ptValue as datetime):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = ptValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, ptValue as datetime extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = ptValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, ptValue as datetime-tz):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = ptValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, ptValue as datetime-tz extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = ptValue.
    end method.
    
    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, prValue as raw):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = prValue.
    end method.

    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, prValue as raw extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = prValue.
    end method.

    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, poValue as Object):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = poValue.
    end method.

    method override public logical SetValue(input pcBufferName as character, input pcRecordKey as character,  input pcField as character, poValue as Object extent):
        FindTableByKey(pcBufferName, pcRecordKey).
        GetBufferField(pcBufferName, pcField):buffer-value = poValue.
    end method.

end class.
