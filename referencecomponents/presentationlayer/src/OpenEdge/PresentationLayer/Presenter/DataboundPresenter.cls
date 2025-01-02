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
    File        : DataboundPresenter
    Purpose     : A data-aware Presenter. Not all Presenters need to be data aware;
                  they may simply perform actions locally. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Mar 06 14:12:00 EST 2009
    Notes       : * The Models collection property is protected since only the 
                    Presenter may talk directly to the Model object. Note that 
                    while a ProBindingSource talks directly to the dataset/query 
                    in the Model, it doesn't actually talk directly to the Model
                    as an object.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Presenter.IDataboundPresenter.
using OpenEdge.PresentationLayer.Presenter.DataboundPresenter.
using OpenEdge.PresentationLayer.Presenter.Presenter.
using OpenEdge.PresentationLayer.Model.IModel.
using OpenEdge.PresentationLayer.Model.Model.
using OpenEdge.PresentationLayer.Model.IModelQuery.
using OpenEdge.PresentationLayer.Model.IModelEventHandler.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.
using OpenEdge.PresentationLayer.View.IView.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.NavigationPanelEventArgs.
using OpenEdge.PresentationLayer.Common.UpdatePanelEventArgs.
using OpenEdge.PresentationLayer.Common.UndoActionEventArgs.
using OpenEdge.PresentationLayer.Common.DataFetchEventArgs.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageConsumerCollection.

using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager. 
using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.
using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.
using OpenEdge.CommonInfrastructure.Common.IServiceCollection.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.ComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.EventArgs.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Core.System.IQuery.
using OpenEdge.Lang.FindTypeEnum.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ICollection.
 using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.String.

using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.PresentationLayer.Presenter.DataboundPresenter abstract inherits Presenter 
                    implements IDataboundPresenter, IMessageConsumer, IModelEventHandler:
    
    /* Events */
    define public event NavigationPanelStateChanged signature void (poComponent as IComponent, poEventArgs as NavigationPanelEventArgs).
    define public event UpdatePanelStateChanged signature void (poComponent as IComponent, poEventArgs as UpdatePanelEventArgs).
    define public event AddUndoAction signature void (poComponent as IComponent, poEventArgs as UndoActionEventArgs).
    
    /** A set of Models that this Presenter uses. */
    define protected property Models as IServiceCollection no-undo get. set.
    
    /** The ServicemessageManager is used plentifully; we keep it as a property so that
        we can get it whenever needed, without fuss. */
    define protected property ServiceMessageManager as IServiceMessageManager no-undo
        get():
            if not valid-object(ServiceMessageManager) then
                ServiceMessageManager = cast(ServiceManager:GetService(OpenEdge.CommonInfrastructure.Common.ServiceMessageManager:IServiceMessageManagerType)
                                          , IServiceMessageManager).
            
            return ServiceMessageManager.
        end get.
        private set.
    
    /* A collection (Map) of the grouped requests. We have a map of these requests since we
       could have more than one series of request being executed at any given time. The map 
       stores the ServiceMessageConsumerCollection and is keyed by the RequestKey. This is an 
       integer value and is an arbitrary, unique value. */
    define protected property ServiceRequests as IMap no-undo get. private set.
    
    constructor public DataboundPresenter(input poComponentInfo as IComponentInfo):
        super(input poComponentInfo).
    end constructor.
    
    constructor public DataboundPresenter(input poComponentInfo as IComponentInfo,
                                          input poModel as IModel extent):
        this-object(poComponentInfo).
        
        AddModel(poModel).
    end constructor.

    method override public void CreateComponent(  ):
        super:CreateComponent().
        
        Models = new IServiceCollection().        
        ServiceRequests = new TypedMap(
                              String:Type, 
                              Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageConsumerCollection')).
    end method.
    
    /** Add a Model to the Presenter.
        
        @param IModel The IModel being added to the Presenter. */
    method public void AddModel(input poModel as IModel):
        Assert:ArgumentNotNull(poModel, 'Model').
        
        Models:Put(cast(poModel, IComponent):ComponentInfo, poModel).
    end method.
    
    /** Add a Model to the Presenter.
        
        @param IModel An array of IModel being added to the Presenter. */    
    method public void AddModel(input poModel as IModel extent):
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        Assert:ArgumentNotNull(poModel, 'Models').
        
        iMax = extent(poModel).
        do iLoop = 1 to iMax:
            AddModel(poModel[iLoop]).
        end.
    end method.
    
    method public void ClearSelection(poModelService as IComponentInfo, pcQueryName as character ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    /* Commits data for all Models that the Presenter knows about. Creates and executes a
       single bundle for all. */
    method public void CommitData(  ):
        BuildAndExecuteRequests(ServiceMessageActionEnum:SaveData,
                              cast(Models:KeySet:ToArray(), IComponentInfo)).
    end method.

    /* Commits data for the specified Model. */
    method public void CommitData(poModelService as IComponentInfo):
        define variable oComponentInfo as IComponentInfo extent 1 no-undo.
        
        oComponentInfo[1] = poModelService.
        BuildAndExecuteRequests(ServiceMessageActionEnum:SaveData, oComponentInfo).
    end method.
    
    /** Commits data for the specified Models. Executes a single bundle/request for these. */
    method public void CommitData(poModelService as IComponentInfo extent ):
        BuildAndExecuteRequests(ServiceMessageActionEnum:SaveData, poModelService).
    end method.
    
    method public void CreateQuery(poModelService as IComponentInfo,
                                   pcQueryName as character,
                                   poQueryDefinition as IQueryDefinition):
        define variable oModel as IModel no-undo.
        define variable oModelQuery as IModelQuery no-undo.
        
        oModel = GetModel(poModelService).
        oModelQuery = oModel:CreateQuery(pcQueryName, poQueryDefinition).
        
        cast(oModelQuery, IQuery):QueryOpened:Subscribe(this-object:QueryOpenedHandler).
        cast(oModelQuery, IQuery):QueryClosed:Subscribe(this-object:QueryOpenedHandler).
        cast(oModelQuery, IQuery):QueryRepositioned:Subscribe(this-object:QueryOpenedHandler).
    end method.
    
    method public void CreateQuery(poModelService as IComponentInfo,
                                   pcQueryName as character,
                                   pcTableName as character ):
        define variable oModel as IModel no-undo.
        define variable oModelQuery as IModelQuery no-undo.
        
        oModel = GetModel(poModelService).
        oModelQuery = oModel:CreateQuery(pcQueryName, pcTableName).
        
        cast(oModelQuery, IQuery):QueryOpened:Subscribe(this-object:QueryOpenedHandler).
        cast(oModelQuery, IQuery):QueryClosed:Subscribe(this-object:QueryOpenedHandler).
        cast(oModelQuery, IQuery):QueryRepositioned:Subscribe(this-object:QueryOpenedHandler).

    end method.

    method public void DataReceivedHandler(poComponent as IComponent,poEventArgs as EventArgs ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    method public void DeselectCurrentRow(poModelService as IComponentInfo, pcQueryName as character ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    method public void DeselectRow(poModelService as IComponentInfo, pcQueryName as character, pcRowKey as character extent):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.


    method public integer GetNumSelectedRows(poModelService as IComponentInfo, pcQueryName as character ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    method public logical GetRowAtKey(poModelService as IComponentInfo,pcQuery as character, pcRowKey as character extent):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.
    
    method public logical GetRowAtPosition(poModelService as IComponentInfo,pcQuery as character,piPos as integer ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    method public logical GetRowWhere(poModelService as IComponentInfo,pcQuery as character,poQueryDefinition as OpenEdge.Core.System.IQueryDefinition,poFindType as FindTypeEnum):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    method public character extent GetSelectedRowKey(poModelService as IComponentInfo, pcQueryName as character,piSelect as integer ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    method public void OnNavigationPanelStateChanged (poEventArgs as NavigationPanelEventArgs):
        NavigationPanelStateChanged:Publish(cast(this-object, IComponent), poEventArgs).
    end method.
    
    method public void OnUpdatePanelStateChanged (poEventArgs as UpdatePanelEventArgs):
        UpdatePanelStateChanged:Publish(cast(this-object, IComponent), poEventArgs). 
    end method.
    
    method public void OnAddUndoAction (poEventArgs as UndoActionEventArgs):
        AddUndoAction:Publish(cast(this-object, IComponent), poEventArgs).
    end method.
    
    method public void QueryClosedHandler(poQuery as IQuery,poEventArgs as EventArgs ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.
    
    method public void QueryOpenedHandler(poQuery as IQuery,poEventArgs as EventArgs ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.
    
    method public void QueryRepositionedHandler(poQuery as IQuery,poEventArgs as EventArgs ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.
    
    method public void SelectCurrentRow(poModelService as IComponentInfo, pcQueryName as character ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.
    
    method public void SelectRow(poModelService as IComponentInfo, pcQueryName as character, pcRowKey as character extent):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.
    
    method override public void Initialize():
        InitializeModels().
        
        super:Initialize().
    end method.
    
    method protected void InitializeModels():
        define variable oIterator as IIterator no-undo. 
        
        /* collect all the requests */
        oIterator = Models:Values:Iterator().
        do while oIterator:HasNext():
            InitializeModel(cast(oIterator:Next(), IModel)).
        end.
        
        BuildAndExecuteRequests(ServiceMessageActionEnum:FetchSchema,
                              cast(Models:KeySet:ToArray(), IComponentInfo)).        
    end method.
    
    method protected void InitializeModel(poModel as IModel):
        /* As presenter, we want/need to be notified of the Model's events. */
        Model:SubscribeModelEvents(poModel, this-object).        
    end method.
    
    method public IModel GetModel(poModelService as IComponentInfo):
        return cast(Models:Get(poModelService), IModel).
    end method.
                
    method public IModel GetModel (poModelService as class Class):
        return GetModel(new ComponentInfo(poModelService)).
    end method.
    
    method override public void DestroyComponent():
        define variable oIterator as IIterator no-undo.
        define variable oModel  as IModel no-undo.
        
        super:DestroyComponent().
        
        if valid-object(Models) then
        do:
            oIterator = Models:Values:Iterator().
            do while oIterator:HasNext():
                oModel = cast(oIterator:Next(), IModel).
                
                Model:UnsubscribeModelEvents(oModel, this-object).
                
                /* Remove the model from the  collection. Releasing the reference 
                   will let the GC take it's course (unless there's a cached or 
                   singleton component, which is possible with Models). */
                Models:Remove(oModel).
            end.
        end.
        
        /* Clear out the messages we know about */
        cast(ServiceRequests:Get(new String('1')), ServiceMessageConsumerCollection):ReleaseMessages().
    end method.
    
    /** General method to construct and execute a message bundle for the specified models.
        
        @param ServiceMessageActionEnum The action being performed (Fetch, FetchSchema, Save, etc)
        @param IComponentInfo An array of identifying information about the Models on which to act. */
    method protected void BuildAndExecuteRequests(input poMessageAction as ServiceMessageActionEnum,
                                                  input poModelService as IComponentInfo extent):
        define variable oModel as IModel no-undo.
        define variable oRequests as IServiceRequest extent no-undo.
        define variable oModelRequest as IServiceRequest no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cRequestKey as character no-undo.
        define variable oMessages as ServiceMessageConsumerCollection no-undo.
        
        extent(oRequests) = extent(poModelService).
        
        oMessages = new ServiceMessageConsumerCollection(). 
        
        ServiceRequests:Put(new String(oMessages:RequestGroupKey), oMessages).
        
        /* collect all the requests */
        iMax = extent(poModelService).
        do iLoop = 1 to iMax:
            oModel = GetModel(poModelService[iLoop]).
            oModelRequest = oModel:BuildRequest(poMessageAction).
            oRequests[iLoop] = oModelRequest.
            
            /* Maintain a map of requests and their consumers/models */
            oMessages:AddMessage(
                    cast(oModelRequest, IServiceMessage):MessageId,
                    cast(oModel, IMessageConsumer)).
        end.
        
        /* Execute the request */
        ServiceMessageManager:ExecuteRequest(this-object, oRequests).                        
    end method.
    
    /* Speaking to the Model, getting data */
    /** Fetches data for all Models. Executes a single bundle/request for
        all the models that this Presenter knows about. */
    method public void FetchData():
        BuildAndExecuteRequests(ServiceMessageActionEnum:FetchData,
                              cast(Models:KeySet:ToArray(), IComponentInfo)).
    end method.
          
    /** Fetches data for the specified Models. Executes a single bundle/request for these. */    
    method public void FetchData (poModelService as IComponentInfo extent):
        BuildAndExecuteRequests(ServiceMessageActionEnum:FetchData, poModelService).
    end method.
    
    /* Fetches data for the specified Model. */
    method public void FetchData (poModelService as IComponentInfo):
        define variable oComponentInfo as IComponentInfo extent 1 no-undo.
        
        oComponentInfo[1] = poModelService.
        BuildAndExecuteRequests(ServiceMessageActionEnum:FetchData, oComponentInfo).
    end method.
       
    method public handle GetBindingHandle(poModelService as IComponentInfo, pcQueryName as character):
        return GetModel(poModelService):GetBindingHandle(pcQueryName).
    end method.
    
    method public void OpenQuery(poModelService as IComponentInfo, pcQuery as character):
        cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):Open().
    end method.
    
    method public void CloseQuery(poModelService as IComponentInfo, pcQuery as character):
        cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):Close().
    end method.        
        
    method public void ReopenQuery(poModelService as IComponentInfo, pcQuery as character):
        cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):Reopen().
    end method.
                
    method public logical GetFirst(poModelService as IComponentInfo, pcQuery as character):
        define variable lAvailable as logical no-undo.
        
        lAvailable = cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):GetFirst().
        DataRefresh(new ModelActionEventArgs(poModelService, ModelActionEnum:Navigate)).
        
        return lAvailable.
    end method.
    
    method public logical GetPrev(poModelService as IComponentInfo, pcQuery as character):
        define variable lAvailable as logical no-undo.
        
        lAvailable = cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):GetPrev().
        DataRefresh(new ModelActionEventArgs(poModelService, ModelActionEnum:Navigate)).
        
        return lAvailable.
    end method.
    
    method public logical GetNext(poModelService as IComponentInfo, pcQuery as character):
        define variable lAvailable as logical no-undo.
        
        lAvailable = cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):GetNext().
        DataRefresh(new ModelActionEventArgs(poModelService, ModelActionEnum:Navigate)).
        
        return lAvailable.
    end method.
    
    method public logical GetLast(poModelService as IComponentInfo, pcQuery as character):
        define variable lAvailable as logical no-undo.
        
        lAvailable = cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):GetLast().
        DataRefresh(new ModelActionEventArgs(poModelService, ModelActionEnum:Navigate)).
        
        return lAvailable.
    end method.
    
    method public IQueryDefinition GetQueryDefinition(poModelService as IComponentInfo, pcQuery as character):
        return cast(GetModel(poModelService):ModelQueries:Get(pcQuery), IQuery):Definition.
    end method.
    
    method public IModelQuery GetQuery(poModelService as IComponentInfo, pcQuery as character):
        return GetModel(poModelService):ModelQueries:Get(pcQuery).
    end method.
    
    method public void DeleteQuery(poModelService as IComponentInfo, pcQuery as character).
        GetModel(poModelService):ModelQueries:Remove(pcQuery).
    end method.
    
    /* Get values from Model */ 
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output pcValue as character ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output pcValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output pcValue as char extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output pcValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output ptValue as date ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output ptValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output ptValue as date extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output ptValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output ptValue as datetime ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output ptValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output ptValue as datetime extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output ptValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output ptValue as datetime-tz ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output ptValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output ptValue as datetime-tz extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output ptValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output pdValue as decimal ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output pdValue).
    end method.

    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output pdValue as decimal extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output pdValue).
    end method.

    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output phValue as handle ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output phValue).
    end method.

    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output phValue as handle extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output phValue).
    end method.

    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output piValue as integer ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output piValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output piValue as integer extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output piValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output piValue as int64 ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output piValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output piValue as int64 extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output piValue).
    end method.
    
    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output pcValue as longchar ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output pcValue).
    end method.

    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output pcValue as longchar extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output pcValue).
    end method.

    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output prValue as raw ):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output prValue).
    end method.

    method public void GetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, output prValue as raw extent):
        GetModel(poModelService):GetValue(pcRecordKey, pcBufferName, pcFieldName, output prValue).
    end method.

    method public void DataFetchedHandler (input poSender as IComponent, input poEventArgs as ModelActionEventArgs):
        DataFetched(poEventArgs).
    end method.
    
    method public void DataAddHandler (poSender as IComponent, poEventArgs as ModelActionEventArgs):
        DataRefresh(poEventArgs).
    end method.
    
    method public void DataDeleteHandler (poSender as IComponent, poEventArgs as ModelActionEventArgs):
        DataRefresh(poEventArgs).
    end method.
    
    method public void DataSaveHandler(poSender as IComponent, poEventArgs as ModelActionEventArgs):
        DataRefresh(poEventArgs).
    end method.
    
    method public void DataCommitHandler(poSender as IComponent, poEventArgs as ModelActionEventArgs):
        DataRefresh(poEventArgs).
    end method.

    method public void DataAddErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    method public void DataDeleteErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    method public void DataSaveErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    method public void DataCommittedHandler( input poSender as IComponent, input poEventArgs as ModelActionEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    method public void DataCommitErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    method public void DataFetchErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    method public void ServiceRequestCompletedHandler( input poSender as IComponent, input poEventArgs as ModelActionEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    method public void ServiceRequestErrorHandler( input poComponent as IComponent, input poEventArgs as ModelErrorEventArgs ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    
    method protected void DataFetched(poEventArgs as ModelActionEventArgs):
        define variable oView as IView no-undo.
        
        oView = this-object:View.
        if valid-object(oView) then
            oView:DataFetched(poEventArgs:ModelService, true).
    end method.
    
    method protected void DataRefresh (poEventArgs as ModelActionEventArgs):
        define variable oModel      as IModel    no-undo.
        define variable oView       as IView     no-undo.
        define variable cCurrentRow as character extent no-undo.
        
        oModel = GetModel(poEventArgs:ModelService).
        oView = this-object:View.
        
@todo(task="implement", action="").
/**        
        /* The view knows which queries it's navigating, and will decide
           if anything needs to be done. Note that the query on which the
           operation was performed has already been updated if needed. */
        if valid-object(oView) then           
            oView:DataRefreshed(poEventArgs:ModelService,
                poEventArgs:QueryName,
                poEventArgs:ModelAction).
        
        NavigationPanelStateChanged:Publish(cast(this-object, IComponent),
            new NavigationPanelEventArgs(
            poEventArgs:ModelService,
            poEventArgs:QueryName,
            cast(oModel:ModelQueries:Get(poEventArgs:QueryName), IQuery):RowPosition)).
        
        UpdatePanelStateChanged:Publish(cast(this-object, IComponent),
            new UpdatePanelEventArgs(
            poEventArgs:ModelService,
            poEventArgs:QueryName,
            poEventArgs:TableName)).
**/            
    end method.
        
    method public character AddRecord(poModelService as IComponentInfo, pcQuery as char, pcTable as character):
        define variable oModel        as IModel    no-undo.
        define variable cCurrentRow   as character extent no-undo.
        define variable cNewRecordKey as character no-undo.
        
        /* AddRecord also reopens the query */
        oModel = GetModel(poModelService).
        cNewRecordKey = oModel:AddRecord(pcTable).
        
        cCurrentRow = cast(oModel:ModelQueries:Get(pcQuery), IQuery):GetCurrentRowKey().
        AddUndoAction:Publish(cast(this-object, IComponent),
            new UndoActionEventArgs(poModelService,
            pcQuery,
            pcTable,
            cCurrentRow,
            UpdateActionEnum:Add)).
        
/*        oModel:OnDataAdd(new ModelActionEventArgs(pcModel, pcQuery, pcTable, cCurrentRow)).*/
        
        return cNewRecordKey.
    end method.
    
    method public void SaveRecord(poModelService as IComponentInfo, pcQuery as char, pcBuffer as character):
        define variable cErrorBuffer as character extent no-undo.
        define variable iLoop        as integer   no-undo.
        define variable oModel       as IModel    no-undo.
        define variable oQuery       as IQuery    no-undo.
        define variable cCurrentRow  as character extent no-undo.
        
        /* Does a local update of the model from the view. Basically writes screen
           values to Model's temp-tables. Validates the local changes.
           
           Commit saves the record to the DB */
        
        /* Get values from the screen into the dataset */
        oModel = GetModel(poModelService).
        
        this-object:View:SaveData(poModelService, pcBuffer).
        oModel:SaveRecord(pcQuery, pcBuffer).

/***        
        cErrorBuffer = oModel:ErrorBuffer no-error.
                                                
        if extent(cErrorBuffer) ne ? then
        do iLoop = 1 to extent(cErrorBuffer):
            /* Only notify of the table we're working on. */
            if pcBuffer eq ? or cErrorBuffer[iLoop] eq pcBuffer then
                DataSaveError:Publish(cast(this-object, IComponent), oModel:ProcessModelErrors(cErrorBuffer[iLoop])).
        end.
****/

        oQuery = cast(oModel:ModelQueries:Get(pcQuery), IQuery).
        cCurrentRow = oQuery:GetCurrentRowKey().
        oQuery:Reopen(cCurrentRow).
        
        AddUndoAction:Publish(cast(this-object, IComponent),
            new UndoActionEventArgs(
                poModelService,
                pcQuery,
                pcBuffer,
                cCurrentRow,
                UpdateActionEnum:Save) ).
        
/*        oModel:OnDataSave(new ModelActionEventArgs(pcModel, pcQuery, pcBuffer, cCurrentRow)).*/
    end method.
    
    /* Delete is local, like Save */
    method public void DeleteRecord(poModelService as IComponentInfo, pcQuery as char, pcTable as character):
        define variable cCurrentRow as character extent no-undo.
        define variable oModel      as IModel    no-undo.
        
        oModel = GetModel(poModelService).
        cCurrentRow = cast(oModel:ModelQueries:Get(pcQuery), IQuery):GetCurrentRowKey().
        
        /*        oQuery = GetQuery(pcQuery).                */
        /*        hQuery  = cast(oQuery, IQuery):QueryHandle.*/
        /*        iRow = max(hQuery:current-result-row - 1, 1).*/
        
/*        oModel:DeleteRecord(pcQuery, pcTable).*/
    end method.
    
    method public void RecordDeletedHandler(poSender as IComponent, poEventArgs as ModelActionEventArgs):
        define variable oModel as IModel no-undo.

        @todo(task="Refresh all queries").
        /*        hQuery:delete-result-list-entry().         */
        /*        cast(oQuery, IQuery):RepositionQuery(iRow).*/

                               
        /*
        AddUndoAction:Publish(cast(this-object, IComponent),
            new UndoActionEventArgs(
            poEventArgs:ModelService,
            poEventArgs:QueryName,
            poEventArgs:TableName,
            poEventArgs:CurrentRowKey,
            UpdateActionEnum:Delete)).
        */
        
        /*        oModel:OnDataDelete(new ModelActionEventArgs(pcModel, pcQuery, pcTable, cCurrentRow)).*/
        
        oModel = cast(poSender, IModel).
/*        oModel:OnDataDelete(poEventArgs).*/
    end method.
         
    method public void UndoAction(poModelService as IComponentInfo, pcQuery as char, pcTable as char, poAction as UpdateActionEnum, pcCurrentRowKey as char extent):
        /* find row 
        @todo(task="undo the action (delete, revert, etc)").
        
        DataRefresh(new ModelActionEventArgs(poModelService, pcQuery, pcTable)).
        */
    end method.
        
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, pcValue as character):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, pcValue).
    end method.
        
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, pcValue as char extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, pcValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, pcValue as longchar):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, pcValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, pcValue as longchar extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, pcValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, phValue as handle):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, phValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, phValue as handle extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, phValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, piValue as integer):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, piValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, piValue as integer extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, piValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, piValue as int64):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, piValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, piValue as int64 extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, piValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, pdValue as decimal):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, pdValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, pdValue as decimal extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, pdValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, ptValue as date):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, ptValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, ptValue as date extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, ptValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, ptValue as datetime):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, ptValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, ptValue as datetime extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, ptValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, ptValue as datetime-tz):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, ptValue).
    end method.

    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, ptValue as datetime-tz extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, ptValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, prValue as raw):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, prValue).
    end method.

    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, prValue as raw extent):
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, prValue).
    end method.
    
    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, poValue as Object).
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, poValue).
    end method.

    method public logical SetValue(poModelService as IComponentInfo, pcRecordKey as char, pcBufferName as char, pcFieldName as char, poValue as Object extent).
        GetModel(poModelService):SetValue(pcRecordKey, pcBufferName, pcFieldName, poValue).
    end method.
    
    /* IMessageConsumer implementations */
    /** Method called upon completion of the action for the ServiceMessage. 
        The actual action type is contained within the response.
        
        @param IServiceResponse The response to the request.      */
    method public void ReceiveMessageResponse(input poResponse as IServiceResponse):
        define variable oModelConsumer as IMessageConsumer /*extent*/ no-undo.
        define variable cMessageId as character extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cRequestKey as character no-undo.
        define variable oIterator as IIterator no-undo.
        define variable oMQ as IModelQuery no-undo.
        define variable oMessages as ServiceMessageConsumerCollection no-undo.
        
        cRequestKey = ServiceMessageConsumerCollection:GetMessageRequestGroupKey(cast(poResponse, IServiceMessage):MessageId).
        oMessages = cast(ServiceRequests:Get(new String(cRequestKey)), ServiceMessageConsumerCollection).
        
        /* tell the actual consumer that we got a response, and pass it on. */
        oMessages
           :ResponseReceived(cast(poResponse, IServiceMessage):MessageId)
               :ReceiveMessageResponse(poResponse).
        
        /* Tell the model to reopen its queries, or do whatever it needs to after 
           the whole request has completed. */
        if oMessages:OutstandingMessages eq 0 then
        do:
            cMessageId = oMessages:GetMessages().
            iMax = extent(cMessageId).
            
            /* We no longer need this request collection */
            ServiceRequests:Remove(new String(cRequestKey)).
            
            do iLoop = 1 to iMax:
                oModelConsumer = oMessages:GetMessageConsumer(cMessageId[iLoop]).
                
                /* We're completely done with this message, get rid of it. */
                oMessages:RemoveMessage(cMessageId[iLoop]).
                
                /* Reopen queries if necessary. The individual ReceiveMessageResponse() calls will
                   have set this flag. */
                oIterator = cast(oModelConsumer, IModel):ModelQueries:Values:Iterator().
                do while oIterator:HasNext():
                    oMQ = cast(oIterator:Next(), IModelQuery).
                    if oMQ:RequiresReopen then
                        cast(oMq, IQuery):Reopen().
               end.
           end.
        end.
    end method.
    
end class.
