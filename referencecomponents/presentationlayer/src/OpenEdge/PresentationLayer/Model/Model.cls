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
    File        : Model
    Purpose     : Abstract Model - without any care about the physical datastore. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Apr 10 11:47:12 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Model.IModel.
using OpenEdge.PresentationLayer.Model.IModelEventHandler.
using OpenEdge.PresentationLayer.Model.IModelReadOnly.
using OpenEdge.PresentationLayer.Model.IModelQuery.
using OpenEdge.PresentationLayer.Model.ModelQuery.
using OpenEdge.PresentationLayer.Model.IModelQueryCollection.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.

using OpenEdge.CommonInfrastructure.Client.ServiceTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableContext.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo. 
using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.

using OpenEdge.Core.System.ITableOwner.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.QueryDefinition.
using OpenEdge.Core.System.IQuery.
using OpenEdge.Core.System.AccessViolationError.

using OpenEdge.Lang.Assert.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.String.
using Progress.Lang.Object.
using Progress.Lang.Class.

class OpenEdge.PresentationLayer.Model.Model abstract inherits Service 
    implements IModel, ITableOwner, IMessageConsumer:
    
    /** (mandatory) The name of the service from which this Model gets its data */    
    define public property ServiceName as character no-undo get. private set.
    
    /** (mandatory) A collection for ModelQueries associated with this Model. 
         Creation is done via the CreateQuery() API. */
    define public property ModelQueries as IModelQueryCollection no-undo get. private set.
    
    /** (mandatory) A collection of table contexts (ITableContext) for the tables in this Model.
        Basically, Table Context is used to figure out whether we have all the data we need in the 
        model, or whether we need to get more. */
    define protected property TableContexts as IMap no-undo get. private set.
    
    /** The ServiceMessageManager is used plentifully; we keep it as a property so that
        we can get it whenever needed, without fuss. */
    define protected property ServiceMessageManager as IServiceMessageManager no-undo
        get():
            if not valid-object(ServiceMessageManager) then
                ServiceMessageManager = cast(ServiceManager:GetService(OpenEdge.CommonInfrastructure.Common.ServiceMessageManager:IServiceMessageManagerType)
                                          , IServiceMessageManager).
            return ServiceMessageManager.
        end get.
        private set.
    
    /* Events */
    /** Fired after a record has been added to the model.
    
        @param IComponent The Model sending the event
        @param ModelActionEventArgs Arguments pertinent to the event   */
    define public event DataAdd signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).
    
    /** Allows raising of the DataAdd event by derived classes. 
        
        @param ModelActionEventArgs Arguments for the event.  */
    method protected void OnDataAdd(input poEventArgs as ModelActionEventArgs):
        this-object:DataAdd:Publish(this-object, poEventArgs).
    end method.
    
    /** This event fires when an error occurs when data is added to the model. 
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */        
    define public event DataAddError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).

    /** Allows raising of the DataAddError event by derived classes. 
        
        @param ModelErrorEventArgs Arguments for the error event.  */
    method protected void OnDataAddError (input poEventArgs as ModelErrorEventArgs):
        this-object:DataAddError:Publish(this-object, poEventArgs).
    end method.
    
    /** Fired after a record has been removed
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataDelete signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** Allows raising of the DataDelete event by derived classes. 
        
        @param ModelActionEventArgs Arguments for the event.  */
    method protected void OnDataDelete(input poEventArgs as ModelActionEventArgs):
        this-object:DataDelete:Publish(this-object, poEventArgs).
    end method.

    /** This event fires when an error occurs when data is deleted from the model
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataDeleteError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).

    /** Allows raising of the DataDeleteError event by derived classes. 
        
        @param ModelErrorEventArgs Arguments for the error event.  */
    method protected void OnDataDeleteError(input poEventArgs as ModelErrorEventArgs):
        this-object:DataDeleteError:Publish(this-object, poEventArgs).
    end method.

    /** Fired after a record has been saved to the model (local save, 
        not a commit).
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataSave signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** Allows raising of the DataSave event by derived classes. 
        
        @param ModelActionEventArgs Arguments for the event.  */
    method protected void OnDataSave(input poEventArgs as ModelActionEventArgs):
        this-object:DataSave:Publish(this-object, poEventArgs).
    end method.
    
    /** This event fires when an error occurs when data is saved locally
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataSaveError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).

    /** Allows raising of the DataSaveError event by derived classes. 
        
        @param ModelErrorEventArgs Arguments for the error event.  */
    method protected void OnDataSaveError(input poEventArgs as ModelErrorEventArgs):
        this-object:DataSaveError:Publish(this-object, poEventArgs).
    end method.
    
    /** Event fired after the Model received its response from a FetchData() 
        service request. 
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataCommitted signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).
    
    /** Allows raising of the DataCommitted event by derived classes. 
        
        @param ModelActionEventArgs Arguments for the event.  */
    method protected void OnDataCommitted(input poEventArgs as ModelActionEventArgs):
        this-object:DataCommitted:Publish(this-object, poEventArgs).
    end method.
    
    /** This event fires when an error occurs when data is saved to a service.
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataCommitError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).    

    /** Allows raising of the DataCommitError event by derived classes. 
        
        @param ModelErrorEventArgs Arguments for the error event.  */
    method protected void OnDataCommitError(input poEventArgs as ModelErrorEventArgs):
        this-object:DataCommitError:Publish(this-object, poEventArgs).
    end method.
    
    /** Event fired after the Model received its response from a SaveData() 
        service request. 
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataFetched signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** Allows raising of the DataFetched event by derived classes. 
        
        @param ModelActionEventArgs Arguments for the event.  */
    method protected void OnDataFetched(input poEventArgs as ModelActionEventArgs):
        this-object:DataFetched:Publish(this-object, poEventArgs).
    end method.

    /** This event fires when an error occurs when data is fetched from a service.
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataFetchError  signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
        
    /** Allows raising of the DataFetchError event by derived classes. 
        
        @param ModelErrorEventArgs Arguments for the error event.  */
    method protected void OnDataFetchError(input poEventArgs as ModelErrorEventArgs):
        this-object:DataFetchError:Publish(this-object, poEventArgs).
    end method.
    
    /** Event fired after the Model received its response from a service request.
        Individual events like DataFetched above will also fire.
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event ServiceRequestCompleted signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** Allows raising of the ServiceRequestCompleted event by derived classes. 
        
        @param ModelActionEventArgs Arguments for the event.  */
    method protected void OnServiceRequestCompleted(input poEventArgs as ModelActionEventArgs):
        this-object:ServiceRequestCompleted:Publish(this-object, poEventArgs).
    end method.
    
    /** This event fires when an error occurs on a service request.
        
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event ServiceRequestError  signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).

    /** Allows raising of the ServiceRequestError event by derived classes. 
        
        @param ModelErrorEventArgs Arguments for the error event.  */
    method protected void OnServiceRequestError(input poEventArgs as ModelErrorEventArgs):
        this-object:ServiceRequestError:Publish(this-object, poEventArgs).
    end method.

    constructor public Model(input pcServiceName as character,
                             input poComponentInfo as IComponentInfo):
        super(poComponentInfo).
        
        Assert:ArgumentNotNullOrEmpty(pcServiceName, 'Service name').
        
        ServiceName = pcServiceName.
    end constructor.
    
    method public void SetServiceName(input pcServiceName as character):
        Assert:ArgumentNotNullOrEmpty(pcServiceName, 'Service name').
        
        ServiceName = pcServiceName.
    end method.

    method override public void CreateComponent(  ):
        super:CreateComponent().
        
        TableContexts = new TypedMap(String:Type,
                                     Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext')).
        
        ModelQueries = new IModelQueryCollection().
    end method.
    
    method override public void DestroyComponent():
        super:DestroyComponent().
        
        TableContexts:Clear().
        ModelQueries:Clear().
    end method.
    
    /** Subscribe this model query to all the data events in the Model.
        
        @param IModel A model
        @param IModelEventHandler The event listener. */
    method static public void SubscribeModelEvents(input poModel as IModel,
                                                   input poHandler as IModelEventHandler):
        poModel:DataAdd:Subscribe(poHandler:DataAddHandler).
        poModel:DataAddError:Subscribe(poHandler:DataAddErrorHandler).        
        
        poModel:DataDelete:Subscribe(poHandler:DataDeleteHandler).        
        poModel:DataDeleteError:Subscribe(poHandler:DataDeleteErrorHandler).
                
        poModel:DataSave:Subscribe(poHandler:DataSaveHandler).        
        poModel:DataSaveError:Subscribe(poHandler:DataSaveErrorHandler).
                
        poModel:DataCommitted:Subscribe(poHandler:DataCommittedHandler).
        poModel:DataCommitError:Subscribe(poHandler:DataCommitErrorHandler).
        
        poModel:DataFetched:Subscribe(poHandler:DataFetchedHandler).
        poModel:DataFetchError:Subscribe(poHandler:DataFetchErrorHandler).
        
        poModel:ServiceRequestCompleted:Subscribe(poHandler:ServiceRequestCompletedHandler).
        poModel:ServiceRequestError:Subscribe(poHandler:ServiceRequestErrorHandler).
    end method.
    
    /** Unubscribe this model query from all the data events in the Model. 
        
        @param IModel A model
        @param IModelEventHandler The event listener. */
    method static public void UnsubscribeModelEvents(input poModel as IModel,
                                                     input poHandler as IModelEventHandler):
        poModel:DataAdd:Unsubscribe(poHandler:DataAddHandler).
        poModel:DataAddError:Unsubscribe(poHandler:DataAddErrorHandler).        
        
        poModel:DataDelete:Unsubscribe(poHandler:DataDeleteHandler).        
        poModel:DataDeleteError:Unsubscribe(poHandler:DataDeleteErrorHandler).
                
        poModel:DataSave:Unsubscribe(poHandler:DataSaveHandler).        
        poModel:DataSaveError:Unsubscribe(poHandler:DataSaveErrorHandler).
                
        poModel:DataCommitted:Unsubscribe(poHandler:DataCommittedHandler).
        poModel:DataCommitError:Unsubscribe(poHandler:DataCommitErrorHandler).
        
        poModel:DataFetched:Unsubscribe(poHandler:DataFetchedHandler).
        poModel:DataFetchError:Unsubscribe(poHandler:DataFetchErrorHandler).
        
        poModel:ServiceRequestCompleted:Unsubscribe(poHandler:ServiceRequestCompletedHandler).
        poModel:ServiceRequestError:Unsubscribe(poHandler:ServiceRequestErrorHandler).
    end method.
    
    /** Commits all modified data in the Model */
    method public void CommitData():
        CommitData(GetTableNames()).
    end method.
    
    /** Commits all modified data for the specified in the Model.
        
        @param character An array of table names.   */    
    method public void CommitData(input pcTables as character extent):
        define variable oRequests as IServiceRequest extent 1 no-undo.
        
        /* If records have been added to the Model directly (ie not
           using the API), make sure that we're allowed to update */
        if type-of(this-object, IModelReadOnly) then
            undo, throw new AccessViolationError(
                'Model ' + this-object:GetClass():TypeName,
                AccessViolationError:READ_ONLY).
        
        oRequests[1] = cast(BuildSaveRequest(pcTables), IServiceRequest).
        
        ServiceMessageManager:ExecuteRequest(this-object, oRequests).
    end method.
    
    /** Create a query with the specified definition.
        
        @param IQueryDefinition The definition (buffers, joins etc) for the query.
        @param handle An existing ABL query (from a ProDataset/ProBindingSource for example)
        @param character A name to use for the query (optional).
        @return IModelQuery The created query. The name of this query the input name, 
                             since that is optional.  */    
    method public IModelQuery CreateQuery(input poQueryDefinition as IQueryDefinition,
                                          input phQuery as handle,
                                          input pcQueryName as character):
        define variable oMQ as IModelQuery no-undo.
        
        oMQ = cast(ModelQueries:Get(new String(pcQueryName)), IModelQuery).
        if not valid-object(oMQ) then
        do:
            oMQ = new ModelQuery(this-object /*IModel and ITableOwner*/,
                                 pcQueryName,
                                 phQuery,
                                 poQueryDefinition).
            ModelQueries:Put(new String(oMQ:QueryName), oMQ).
        end.
        
        return oMQ.
    end method.
    
    /** Create a default query for table
        
        @param character A name to use for the query  (optional)
        @param character The table on which to create the query. More complex queries should use
                         IQueryDefinition.
        @return IModelQuery The created query. The name of this query the input name, 
                             since that is optional.  */    
    method public IMOdelQuery CreateQuery(input pcQueryName as character, input pcTable as character):
        define variable oQueryDefinition as IQueryDefinition no-undo.
        
        oQueryDefinition = new QueryDefinition().
        oQueryDefinition:AddBuffer(pcTable).
        
        return CreateQuery(pcQueryName, oQueryDefinition).
    end method.
    
    /** Create a query with the specified definition.
        
        @param character A name to use for the query (optional).
        @param IQueryDefinition The definition (buffers, joins etc) for the query.
        @return IModelQuery The created query. The name of this query the input name, 
                             since that is optional.  */    
    method public IModelQuery CreateQuery(input pcQueryName as character, input poQueryDefinition as IQueryDefinition):
        return CreateQuery(poQueryDefinition, ?, pcQueryName).
    end method.
    
    /** Returns a list of table name in the Model. Each datastore has its
        own way of listing these, so the implementation is left to them.
        
        @return character An array of all the table names in this Model. */
    method protected character extent GetTableNames():
        define variable cTables as character extent no-undo.
        define variable iExtent as integer no-undo.
        define variable oIterator as IIterator no-undo.
        
        extent(cTables) = TableContexts:Size.
        oIterator = TableContexts:KeySet:Iterator().
        do while oIterator:HasNext():
            iExtent = iExtent + 1.
            cTables[iExtent] = cast(oIterator:Next(), ITableContext):TableName.
        end.
        
        return cTables.
    end method.
    
    /** Retrieve field values from the Model.
        
        @param character The name of the table in the model
        @param character A unique key used to find the relevant record
        @param character The name of the field whose value to extract.
        @param output-character The field value.             */
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as character).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as character extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as longchar).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as longchar extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output phValue as handle).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output phValue as handle extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as integer).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as integer extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as int64).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as int64 extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pdValue as decimal).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pdValue as decimal extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as date).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as date extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime-tz).    
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime-tz extent).    
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output prValue as raw).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output prValue as raw extent).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output poValue as Object).
    method abstract public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output poValue as Object extent).

    /** Set a field's value from the Model.
        
        @param character The name of the table in the model
        @param character A unique key used to find the relevant record
        @param character The name of the field whose value to extract.
        @param character The field value.             */
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as character).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as character extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as longchar).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as longchar extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input phValue as handle).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input phValue as handle extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as integer).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as integer extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as int64).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as int64 extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pdValue as decimal).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pdValue as decimal extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as date).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as date extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime-tz).    
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime-tz extent).    
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input prValue as raw).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input prValue as raw extent).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input poValue as Object).
    method abstract public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input poValue as Object extent).    
        
    /* Validation */
    /** Local/client-side field-level validation for a field in the model. If the validation
        fails, an error will be thrown.
        
        @param ModelActionEnum The action being performed on the record.
        @param character The name of the table/buffer in the model
        @param character The Record key for the record.
        @param character The field name being validated.        */
    method public void ValidateField(input poAction as ModelActionEnum,
                                     input pcBufferName as character,
                                     input pcRecordKey as character,
                                     input pcFieldName as character):
    end method.
    
    /** Local/client-side record- or row-level validation for a field in 
        the model. If the validation fails, an error will be thrown.
        
        @param ModelActionEnum The action being performed on the record.
        @param character The name of the table/buffer in the model
        @param character The Record key for the record.          */
    method public void ValidateRow (input poAction as ModelActionEnum,
                                    input pcBufferName as character,
                                    input pcRecordKey as character):
    end method.
    
    /** Add a record to the Model. This method is final, and the call is split
        into 3 separate parts: a Before-, a Do- and an AfterAddRecord method. This
        is so that a concrete Model can override parts of the AddRecord behaviour
        easily.
        
        @param character The name of the table in the Model to which to add a record.
        @return character The unique record key of the newly-added record.  */
    method public final character AddRecord(input pcTableName as character):
        define variable cNewRecordKey as character no-undo.
        
        BeforeAddRecord(pcTableName).
        cNewRecordKey = DoAddRecord(pcTableName).
        AfterAddRecord(pcTableName, cNewRecordKey).
        
        return cNewRecordKey.
    end method.
    
    /** Actions performed before we add a record.
        
        @param character The name of the table being added. */
    method protected void BeforeAddRecord(input pcTableName as character):
        if type-of(this-object, IModelReadOnly) then
            undo, throw new AccessViolationError(
                ServiceTypeEnum:Model:ToString() + ' ' + this-object:GetClass():TypeName,
                AccessViolationError:READ_ONLY).
    end method.
    
    /** Perform the actual add of the record to the Model. This is an abstract method
        since the physical Model will know exactly how to add a record (ie buffer in DatasetModel),
        whereas this class has no concept of the physical data store. 
        
        @param The table name of the record being added.
        @return character The record key of the newly-added record.     */
    method abstract protected character DoAddRecord(input pcTableName as character).
    
    /** Actions performed after we add a record.
        
        @param character The name of the table being added.
        @param character The unique key for the newly-added record. */
    method protected void AfterAddRecord(input pcTableName as character, input pcNewRecordKey as char):
        ValidateRow(ModelActionEnum:Add, pcTableName, pcNewRecordKey).
        
        OnDataAdd(new ModelActionEventArgs(
                    cast(this-object, IComponent):ComponentInfo,
                    ModelActionEnum:Add,
                    pcTableName,
                    pcNewRecordKey)).
    end method.
    
    /** Retrieve a unique key for the current row.
        
        @param character A table name
        @return character A unique key for the current record specified by the table name.
                          Typically used when adding or saving records. */
    method abstract protected character GetRecordKey(input pcTableName as character).
        
    /** Save a record locally to the Model. This method is final, and the call is split
        into 3 separate parts: a Before-, a Do- and an AfterSaveRecord method. This
        is so that a concrete Model can override parts of the behaviour easily.
        
        @param character The name of the table in the Model being saved.
        @param character The unique record key of the record.  */
    method public final void SaveRecord(input pcTableName as character, input pcRecordKey as character):
        BeforeSaveRecord(pcTableName, pcRecordKey).
        DoSaveRecord(pcTableName, pcRecordKey).
        AfterSaveRecord(pcTableName, pcRecordKey).
    end method.
    
    /** Actions performed before a record is saved.
        
        @param character The name of the table in the Model being saved.
        @param character The unique record key of the record.  */    
    method protected void BeforeSaveRecord(input pcTableName as character, input pcRecordKey as character):
        if type-of(this-object, IModelReadOnly) then
            undo, throw new AccessViolationError(
                ServiceTypeEnum:Model:ToString() + ' ' + this-object:GetClass():TypeName,
                AccessViolationError:READ_ONLY).
    end method.
    
    /** Perform the actual save of the record to the Model. This is an abstract method
        since the physical Model will know exactly how to save a record (ie buffer in DatasetModel),
        whereas this class has no concept of the physical data store. 

        @param character The name of the table in the Model being saved.
        @param character The unique record key of the record.  */
    method abstract protected void DoSaveRecord(input pcTableName as character, input pcRecordKey as character).
    
    /** Actions performed after a record has been saved.
        
        @param character The name of the table in the Model being saved.
        @param character The unique record key of the record.  */
    method protected void AfterSaveRecord(input pcTableName as character, input pcRecordKey as character):
        OnDataSave(new ModelActionEventArgs(
                    cast(this-object, IComponent):ComponentInfo,
                    ModelActionEnum:Save,
                    pcTableName,
                    pcRecordKey)).
    end method.

    /** Delete a record locally from the Model. This method is final, and the call is split
        into 3 separate parts: a Before-, a Do- and an AfterDeleteRecord method. This
        is so that a concrete Model can override parts of the behaviour easily.
        
        @param character The name of the table in the Model being deleted .
        @param character The unique record key of the record.  */    
    method public final void DeleteRecord(input pcTableName as character, input pcRecordKey as character):
        BeforeDeleteRecord(pcTableName, pcRecordKey).
        DoDeleteRecord(pcTableName, pcRecordKey).
        AfterDeleteRecord(pcTableName, pcRecordKey).
    end method.

    /** Actions performed before a record is deleted. 
        
        @param character The name of the table in the Model being deleted.
        @param character The unique record key of the record.  */
    method protected void BeforeDeleteRecord(input pcTableName as character, input pcRecordKey as character):
        if type-of(this-object, IModelReadOnly) then
            undo, throw new AccessViolationError(
                ServiceTypeEnum:Model:ToString() + ' ' + this-object:GetClass():TypeName,
                AccessViolationError:READ_ONLY).
    end method.
    
    /** Perform the actual delete of the record from the Model. This is an abstract method
        since the physical Model will know exactly how to delete a record (ie buffer in DatasetModel),
        whereas this class has no concept of the physical data store. 

        @param character The name of the table in the Model being deleted
        @param character The unique record key of the record.  */    
    method abstract protected void DoDeleteRecord(input pcTableName as character, input pcRecordKey as character).
    
    /** Actions performed after a record is deleted. 
        
        @param character The name of the table in the Model being deleted.
        @param character The unique record key of the record.  */    
    method protected void AfterDeleteRecord(input pcTableName as character, input pcRecordKey as character):
        OnDataDelete(new ModelActionEventArgs(
                    cast(this-object, IComponent):ComponentInfo,
                    ModelActionEnum:Delete,
                    pcTableName,
                    pcRecordKey)).
    end method.
    
    /** Return a handle to which the UI will bind for a specific query.
        
        @param character A query name
        @return handle The handle to which the view will bind the UI    */
    method public handle GetBindingHandle(input pcQueryName as character):
        return cast(ModelQueries:Get(pcQueryName), IQuery):QueryHandle.
    end method.
    
    /** Fetch data for all tables. */ 
    method public void FetchData():
        FetchData(GetTableNames()).
    end method.
    
    /** Fetch data for the specified tables.
        
        @param character An array of tables names in the Model for which to fetch data. */ 
    method public void FetchData(input pcTables as character extent):
        FetchData(cast(BuildFetchRequest(pcTables), IServiceRequest)).
    end method.
    
    method protected void FetchData(input poRequest as IServiceRequest):
        define variable oRequests as IServiceRequest extent 1 no-undo.
        
        oRequests[1] = poRequest.
        
        ServiceMessageManager:ExecuteRequest(this-object, oRequests).
    end method.
    
    /** Builds a IFetchRequest for the specified tables.
        
        @param Character An array of table names.
        @return IFetchRequest The completed fetch request.  */
    method protected IFetchRequest BuildFetchRequest(input pcTables as character extent):
        define variable oFetchRequest as IFetchRequest no-undo.
        define variable oTableContext as ITableContext no-undo.
        define variable oTableRequest as ITableRequest no-undo.
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        oFetchRequest = new FetchRequest(this-object:ServiceName, ServiceMessageActionEnum:FetchData).
        iMax = extent(pcTables).
        
        do iLoop = 1 to iMax:
            oTableContext = cast(TableContexts:Get(new String(pcTables[iLoop])), ITableContext).
            if not valid-object(oTableContext) then
            do:
                /* Use GetBufferHandle() rather than GetTableHandle() since the latter 
                   is part of the ITableOwner interface implementation and so may change.
                   GetBufferHandle() is restricted to this class. */
                oTableContext = new TableContext(pcTables[iLoop],
                                                 GetBufferHandle(pcTables[iLoop])).
                TableContexts:Put(new String(pcTables[iLoop]), oTableContext).
            end.
            
            /* only get more data if we really need more data */
            oTableRequest = CreateTableRequestFromContext(oTableContext).
            if not oTableRequest:TableRequestType:Equals(TableRequestTypeEnum:None) then
                oFetchRequest:TableRequests:Put(pcTables[iLoop], oTableRequest).
        end.
        
        return oFetchRequest. 
    end method.
    
    /** Builds a save request for the specified tables in the Model. 
        
        @param character An array of table for which to create the save request.
        @return ISaveRequest The complete save request for the model/tables
      */
    method abstract protected ISaveRequest BuildSaveRequest(input pcTables as character extent).
    
    /** Builds a request for the specified tables in the Model. 
        
        @param character An array of table for which to create the save request.
        @return IServiceRequest The complete request for the model/tables */        
    @method(virtual="true").    
    method protected IServiceRequest BuildServiceRequest(input pcTables as character extent):
    end method.
    
    /** Creates the parameter object for the service request (the ITableRequest object).
        
        @return ITableRequest A table request (ie parameters) for the Fetch/Save operation for
                              the specified table context. Returning a null object here.    */
    method protected ITableRequest CreateTableRequestFromContext(input poContext as ITableContext):
        define variable oTR as ITableRequest no-undo.
        
        oTR = new TableRequest(poContext:TableName).
        
        /* If there are 0 remaining pages, then we have all the data, and we don't need to do anything more. */
        if poContext:NumRemainingPages ne 0 then
            oTR:TableRequestType = TableRequestTypeEnum:None.
        else
        do:
            oTR:PageSize = poContext:PageSize.
            @todo(task="implement", action="").
            /* here we'd build a where clause for batching or filtering; this where clause
               could be built on the ModelQuery. without anything here we're just going to do
               a FOR EACH <tablename> */
        end.
        return oTR.
    end method.
    
    method protected void UpdateTableContextFromResponse(input poResponse as ITableResponse):
        define variable oModelTC as ITableContext no-undo.
        
        oModelTC = cast(TableContexts:Get(new String(poResponse:TableName)), ITableContext).
        
        /* use context as-is from response */
        if not valid-object(oModelTC) then
            assign oModelTC = cast(TableContexts:Put(new String(poResponse:TableName), poResponse:TableContext), ITableContext)
                   oModelTC:TableHandle = GetBufferHandle(poResponse:TableName).
        else
            assign oModelTC:NumRemainingPages = poResponse:TableContext:NumRemainingPages
                   oModelTC:NextPosition = poResponse:TableContext:NextPosition
                   oModelTC:PrevPosition = poResponse:TableContext:PrevPosition.
        
        oModelTC:LastUpdateAt = now.
    end method.
    
    /** Fetches data necessary to satisfy all queries in the Model.
        If there are no queries defined, no data will be retrieved. */
    method public void FetchDataForQueries():
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.
        
    /** Retrieves data for the tables specifed by the named queries.
        
        @param character An array of query names in the Model for whose table to
                           which to fetch data. */
    method public void FetchDataForQueries(input pcQuery as character extent):
    end method.
    
    method public IServiceRequest BuildRequest(input poServiceMessageAction as ServiceMessageActionEnum):
        case poServiceMessageAction:
            when ServiceMessageActionEnum:FetchData or when ServiceMessageActionEnum:FetchSchema then
                return cast(BuildFetchRequest(GetTableNames()), IServiceRequest).
            when ServiceMessageActionEnum:SaveData then
                return cast(BuildSaveRequest(GetTableNames()), IServiceRequest).
            otherwise
                return BuildServiceRequest(GetTableNames()).
        end case.
    end method.
    
    /** Receive the Model data from the service message. Each data-specific Model will
        implement this differently, so this method is abstract. 
        
        The actual action (i.e. openquery/closequery) should be handled in DataFetchedHandler, 
        which could be subscribed here or by the presenter (the class should probably implement
        a protected AfterReceiveData hook, since data could need to be manipulated before the
        event fires ) 
        
        @param IFetchResponse The response message from the data fetch request  */
    method abstract protected void ReceiveFetchResponse(input poResponse as IFetchResponse).
    
    /** Receive the Model's schema from the service message. Create the initial table contexts from
        this response. Note that the existing TableContexts will be cleared. 
        
        The actual action (i.e. openquery/closequery) should be handled in DataFetchedHandler, 
        which could be subscribed here or by the presenter (the class should probably implement
        a protected AfterReceiveData hook, since data could need to be manipulated before the
        event fires ) 
        
        @param IFetchResponse The response message from the data fetch request  */
    method protected void ReceiveFetchSchemaResponse(input poResponse as IFetchResponse):
        define variable oIterator as IIterator no-undo.
        define variable oTR as ITableResponse no-undo.
        define variable oTC as ITableContext no-undo.
        
        TableContexts:Clear().
        
        oIterator = poResponse:TableResponses:Values:Iterator().
        do while oIterator:HasNext():
            oTR = cast(oIterator:Next(), ITableResponse).
            
            @todo(task="implement", action="errors").
            if valid-object(oTR:TableContext) then
            do:
                oTC = oTR:TableContext.
                oTC:TableHandle = GetBufferHandle(oTC:TableName).
                TableContexts:Put(new String(oTC:TableName), oTC).
            end.
        end.
    end method.
    
    /** A generic service response callback method.
        
        @param IServiceResponse The response message from the service request  */
    @method(virtual="true").
    method protected void ReceiveServiceResponse(input poResponse as IServiceResponse):
    end method.
    
    /** Receive the Save response (may have data) from the service message. 
        Each data-specific Model will implement this differently, so this 
        method will in all likelihood be overridden. 
        
        @param ISaveResponse The response message from the data save request.   */
    method abstract protected void ReceiveSaveResponse(input poResponse as ISaveResponse).
    
/** IMessageConsumer implementations **/
    /** Method called upon completion of the action for the ServiceMessage. 
        The actual action type is contained within the response.
        
        @param IServiceResponse The response to the request. */
    method public void ReceiveMessageResponse(input poResponse as IServiceResponse).
        case cast(poResponse, IServiceMessage):ActionType:
            when ServiceMessageActionEnum:FetchData then
               ReceiveFetchResponse(cast(poResponse, IFetchResponse)).
            when ServiceMessageActionEnum:FetchSchema then
               ReceiveFetchSchemaResponse(cast(poResponse, IFetchResponse)).
            when ServiceMessageActionEnum:SaveData then
                ReceiveSaveResponse(cast(poResponse, ISaveResponse)).
            otherwise
                ReceiveServiceResponse(poResponse).
        end case.    
    end method.
    
    /** Find a record in the Model by (unique) key. 
        
        @param character The table name 
        @param character The record key for the record being found.
        @return logical Indicates whether the record specified was found. */    
    method protected logical FindTableByKey(input pcBufferName as character, input pcRecordKey as character):
        return FindTableByKey(GetBufferHandle(pcBufferName), pcRecordKey).
    end method.

    /** Find a record in the Model by (unique) key. 
        
        @param handle A buffer handle in the 
        @param character The record key for the record being found.
        @return logical Indicates whether the record specified was found. */
    method abstract protected logical FindTableByKey(input phBuffer as handle, input pcRecordKey as character):
        
    /** Returns an ABL buffer handle for a table from the physical Model. 
        (See comments on GetTableHandle).
        
        @param character The table name 
        @return handle An ABL buffer handle for the specified table. */    
    method abstract protected handle GetBufferHandle(input pcTableName as character).
    
/* ITableOwner implementation */
    /** GetTableHandle called by IQuery when building 
        a query. We need to enforce that this method exists within
        each of the 'physical' Model classes, so it's just a wrapper
        for the internal abstract GetBufferHandle() call.
        
        @param character The table name 
        @return handle An ABL buffer handle for the specified table. */    
    method final public handle GetTableHandle(input pcTableName as character):
        return GetBufferHandle(pcTableName).
    end method.
    
end class.
