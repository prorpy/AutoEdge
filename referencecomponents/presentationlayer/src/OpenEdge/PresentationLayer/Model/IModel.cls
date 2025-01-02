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
    File        : IModel
    Purpose     : Interface defining Models in the MVP Triad. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Dec 18 15:51:15 EST 2008
    Notes       : * The Commit*() and Fetch*() calls are for this model only. 
                    The Build() calls are to enable bundling by the presenter
                    (typically).
  ---------------------------------------------------------------------- */
using OpenEdge.PresentationLayer.Model.IModel.
using OpenEdge.PresentationLayer.Model.IModelQueryCollection.
using OpenEdge.PresentationLayer.Model.IModelQuery.
using OpenEdge.PresentationLayer.Model.IModelEventHandler.
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.IComponent.

using OpenEdge.Core.System.EventArgs.
using OpenEdge.Core.System.IQueryDefinition.
using Progress.Lang.Object.

interface OpenEdge.PresentationLayer.Model.IModel /* inherits IComponent */:
    
    /** (mandatory) The name of the service from which this Model gets its data */
    define public property ServiceName as character no-undo get.
    
    /** (mandatory) A collection for ModelQueries associated with this Model. 
        Creation is done via the CreateQuery() API. */
    define public property ModelQueries as IModelQueryCollection no-undo get.
    
    /** Return a handle to which the UI will bind for a specific query.
        
        @param character A query name
        @return handle The handle to which the view will bind the UI    */
    method public handle GetBindingHandle(input pcQueryName as character).
    
@region(name="Events").    
    /** Fired after a record has been added to the model.
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataAdd signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is added to the model. 
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */        
    define public event DataAddError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
    /** Fired after a record has been removed
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataDelete signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is deleted from the model
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataDeleteError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).

    /** Fired after a record has been saved to the model (local save, 
        not a commit).
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataSave signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is saved locally
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataSaveError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
    /** Event fired after the Model received its response from a FetchData() 
        service request. 
    
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataCommitted signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).
    
    /** This event fires when an error occurs when data is saved to a service.
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataCommitError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).    
    
    /** Event fired after the Model received its response from a SaveData() 
        service request. 
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event DataFetched signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs when data is fetched from a service.
    
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event DataFetchError signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
    /** Event fired after the Model received its response from a service request.
        Individual events like DataFetched above will also fire.
        
        @param IComponent The Model sending the event
        @param EventArgs Arguments pertinent to the event   */
    define public event ServiceRequestCompleted signature void (input poSender as IComponent, input poEventArgs as ModelActionEventArgs).

    /** This event fires when an error occurs on a service request.
        
        @param IComponent The model sending the events.  
        @param ModelErrorEventArgs Arguments containing the detail of the error.    */    
    define public event ServiceRequestError  signature void (input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs).
    
@region(name="service message requests").    
    /** Fetch data for all tables. The Fetch() calls are for this model only,
        the Build() calls are to enable bundling by the presenter (typically). */
    method public void FetchData().
    
    /** Fetch data for all specified tables.
        @param character An array of tables names in the Model for which to fetch data. */ 
    method public void FetchData(input pcTables as character extent).
    
    /** Fetches data necessary to satisfy all queries in the Model.
        If there are no queries defined, no data will be retrieved. */
    method public void FetchDataForQueries().
    
    /** Retrieves data for the tables specifed by the named queries.   
            
        @param character An array of query names in the Model for whose table to
                           which to fetch data. */
    method public void FetchDataForQueries(input pcQuery as character extent).
    
    /** A general build request method for all tables in the model. This will
        
        @param ServiceMessageActionEnum The message type (Fetch, FetchSchema, Save etc)  
        @return IServiceRequest The completed request for all tables in the Model
      */
    method public IServiceRequest BuildRequest(input poServiceMessageAction as ServiceMessageActionEnum).
    
/** not sure  
/* Fetch data for a table request (including children)  */
method public void FetchDataForQueries(input poTableRequest as ITableRequest). 
method public void FetchDataForQueries(input pcTables as character extent). 
**/
    
    /** Commits all modified data in the Model */
    method public void CommitData().

    /** Commits all modified data for the specified in the Model.
        
        @param character An array of table names.   */    
    method public void CommitData(input pcTables as character extent).
    
/**    need these?
    /** Commits data for the tables specifed by the named queries.   
        
        @param character An array of query names in the Model for whose table to
                           which to fetch data. */
    method public void CommitDataForQueries(input pcQuery as character extent).    
**/
   
@region(name="Query manipulation").
    /** Create a default query for table
        
        @param character A name to use for the query  (optional)
        @param character The table on which to create the query. More complex queries should use
                         IQueryDefinition.
        @return IModelQuery The created query. The name of this query the input name, 
                             since that is optional.  */    
    method public IModelQuery CreateQuery(input pcQueryName as character,
                                          input pcTableName as character).

    /** Create a query with the specified definition.
        
        @param IQueryDefinition The definition (buffers, joins etc) for the query.
        @param handle An existing ABL query (from a ProDataset/ProBindingSource for example)
        @param character A name to use for the query (optional).
        @return IModelQuery The created query. The name of this query the input name, 
                             since that is optional.  */    
    method public IModelQuery CreateQuery(input poQueryDefinition as IQueryDefinition,
                                          input phQuery as handle,
                                          input pcQueryName as character).
    
    /** Create a query with the specified definition.
        
        @param character A name to use for the query (optional).
        @param IQueryDefinition The definition (buffers, joins etc) for the query.
        @return IModelQuery The created query. The name of this query the input name, 
                             since that is optional.  */    
    method public IModelQuery CreateQuery(input pcQueryName as character,
                                          input poQueryDefinition as IQueryDefinition).
    
@region(name="Local record operations").
    /** Add a record locally to the Model
        
        @param character The name of the table in the Model to which to add a record.
        @return character The unique record key of the newly-added record.  */
    method public character AddRecord(input pcTableName as character).
    
    /** Save a record locally to the Model. 
        
        @param character The name of the table in the Model being saved.
        @param character The unique record key of the record.  */
    method public void SaveRecord(input pcTableName as character, input pcRecordKey as character).

    /** Delete a record locally from the Model. 
        
        @param character The name of the table in the Model being deleted.
        @param character The unique record key of the record.  */    
    method public void DeleteRecord(input pcTableName as character, input pcRecordKey as character).
    
@region(name="Validation").
    /** Local/client-side field-level validation for a field in the model. If the validation
        fails, an error will be thrown.
        
        @param ModelActionEnum The action being performed on the record.
        @param character The name of the table/buffer in the model
        @param character The Record key for the record.
        @param character The field name being validated.        */
    method public void ValidateField(input poAction as ModelActionEnum,
                                     input pcTableName as character,
                                     input pcRecordKey as character,
                                     input pcFieldName as character).

    /** Local/client-side record- or row-level validation for a field in 
        the model. If the validation fails, an error will be thrown.
        
        @param ModelActionEnum The action being performed on the record.
        @param character The name of the table/buffer in the model
        @param character The Record key for the record.          */
    method public void ValidateRow (input poAction as ModelActionEnum,
                                    input pcTableName as character,
                                    input pcRecordKey as character).
    

@region(name="Field get/set operations").
    /** Retrieve field values from the Model.
        
        @param character The name of the table in the model
        @param character A unique key used to find the relevant record
        @param character The name of the field whose value to extract.
        @param output-character The field value.             */
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as character).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as character extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as longchar).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pcValue as longchar extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output phValue as handle).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output phValue as handle extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as integer).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as integer extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as int64).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output piValue as int64 extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pdValue as decimal).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output pdValue as decimal extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as date).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as date extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime-tz).    
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output ptValue as datetime-tz extent).    
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output prValue as raw).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output prValue as raw extent).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output poValue as Object).
    method public void GetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, output poValue as Object extent).

    /** Set a field's value from the Model.
        
        @param character The name of the table in the model
        @param character A unique key used to find the relevant record
        @param character The name of the field whose value to extract.
        @param character The field value.             */
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as character).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as character extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as longchar).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pcValue as longchar extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input phValue as handle).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input phValue as handle extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as integer).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as integer extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as int64).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input piValue as int64 extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pdValue as decimal).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input pdValue as decimal extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as date).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as date extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime-tz).    
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input ptValue as datetime-tz extent).    
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input prValue as raw).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input prValue as raw extent).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input poValue as Object).
    method public logical SetValue(input pcTableName as character, input pcRecordKey as character,  input pcFieldName as character, input poValue as Object extent).
        
end interface.
