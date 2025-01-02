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
    File        : IDataboundPresenter
    Purpose     : Interface for presenter for databound mvp triads
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Mar 06 14:13:18 EST 2009
    Notes       :  
  ---------------------------------------------------------------------- */
using OpenEdge.PresentationLayer.Presenter.IDataboundPresenter.
using OpenEdge.PresentationLayer.Model.IModel.
using OpenEdge.PresentationLayer.Model.IModelQuery.
using OpenEdge.PresentationLayer.Common.ModelErrorEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.NavigationPanelEventArgs.
using OpenEdge.PresentationLayer.Common.UpdatePanelEventArgs.
using OpenEdge.PresentationLayer.Common.UndoActionEventArgs.
using OpenEdge.PresentationLayer.Common.DataFetchEventArgs.

using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.
using OpenEdge.CommonInfrastructure.Common.IComponentCollection.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.Core.System.EventArgs.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Lang.FindTypeEnum.

using Progress.Lang.Class.
using Progress.Lang.Object.

interface OpenEdge.PresentationLayer.Presenter.IDataboundPresenter:
    /** Events */
    define public event NavigationPanelStateChanged signature void (input poComponent as IComponent, input poEventArgs as NavigationPanelEventArgs).
    define public event UpdatePanelStateChanged signature void (input poComponent as IComponent, input poEventArgs as UpdatePanelEventArgs).
    define public event AddUndoAction   signature void (input poComponent as IComponent, input poEventArgs as UndoActionEventArgs).
    
    /** Get individual field values */
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output pcValue as character).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output pcValue as character extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output pcValue as longchar).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output pcValue as longchar extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output phValue as handle).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output phValue as handle extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output piValue as int).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output piValue as int extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output piValue as int64).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output piValue as int64 extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output pdValue as decimal).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output pdValue as decimal extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output ptValue as date).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output ptValue as date extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output ptValue as datetime).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output ptValue as datetime extent).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output ptValue as datetime-tz).    
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output ptValue as datetime-tz extent).    
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output prValue as raw).
    method public void GetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, output prValue as raw extent).
    
    /*
    class ModelBuffer:
        ModelService:IComponentInfo 
        RecordKey:character
        BufferName:character 
    class ModelField:ModelBuffer
        FieldName:character    
    */
    
    /** Set individual field values */
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input pcValue as character).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input pcValue as character extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input pcValue as longchar).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input pcValue as longchar extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input phValue as handle).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input phValue as handle extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input piValue as int).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input piValue as int extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input piValue as int64).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input piValue as int64 extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input pdValue as decimal).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input pdValue as decimal extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input ptValue as date).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input ptValue as date extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input ptValue as datetime).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input ptValue as datetime extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input ptValue as datetime-tz).    
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input ptValue as datetime-tz extent).    
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input prValue as raw).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input prValue as raw extent).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input poValue as Object).
    method public logical SetValue(input poModelService as IComponentInfo, input pcRecordKey as character, input pcBuffer as character, input pcField as character, input poValue as Object extent).
    
    /** Add a Model to the Presenter. 

        @param IModel The IModel being added to the Presenter. */
    method public void AddModel(input poModel as IModel).    
    
    /** Add multiple Models to the Presenter.
         
        @param IModel An array of IModel objects to add to the Presenter */
    method public void AddModel(input poModel as IModel extent).
    
    /** manage selection */
    method public integer GetNumSelectedRows(input poModelService as IComponentInfo, input pcQueryName as character).
    method public character extent GetSelectedRowKey(input poModelService as IComponentInfo, input pcQueryName as character, input piSelect as int).
    
    /* piSelect is selection ordinal - not query */
    method public void ClearSelection(input poModelService as IComponentInfo, input pcQueryName as character).
    method public void SelectCurrentRow(input poModelService as IComponentInfo, input pcQueryName as character).
    method public void SelectRow(input poModelService as IComponentInfo, input pcQueryName as character, input pcRowKey as character extent).
    method public void DeselectCurrentRow(input poModelService as IComponentInfo, input pcQueryName as character).
    method public void DeselectRow(input poModelService as IComponentInfo, input pcQueryName as character, input pcRowKey as character extent).
    
    /** use default query (create a default IQueryDefinition from table ) */
    method public void CreateQuery(input poModelService as IComponentInfo,
                                   input pcQueryName as character,
                                   input pcTableName as character).
    /** These are only meant to be called by another Presenter, NOT any Views */
    method public void CreateQuery(input poModelService as IComponentInfo,
                                   input pcQueryName as character,
                                   input poQueryDefinition as IQueryDefinition).
    
    method public void DeleteQuery(input poModelService as IComponentInfo, input pcQuery as character).
    method public IQueryDefinition GetQueryDefinition(input poModelService as IComponentInfo, input pcQuery as character).
    method public IModelQuery GetQuery(input poModelService as IComponentInfo, input pcQuery as character).
    
    method public void OpenQuery(input poModelService as IComponentInfo, input pcQuery as character).
    method public void ReopenQuery(input poModelService as IComponentInfo, input pcQuery as character).
    method public void CloseQuery(input poModelService as IComponentInfo, input pcQuery as character).    
    
    method public logical GetFirst(input poModelService as IComponentInfo, input pcQuery as character).
    method public logical GetPrev(input poModelService as IComponentInfo, input pcQuery as character).
    method public logical GetNext(input poModelService as IComponentInfo, input pcQuery as character).
    method public logical GetLast(input poModelService as IComponentInfo, input pcQuery as character).
    method public logical GetRowAtKey(input poModelService as IComponentInfo, input pcQuery as character, input pcRowKey as character extent).
    method public logical GetRowAtPosition(input poModelService as IComponentInfo, input pcQuery as character, input piPos as int).
    method public logical GetRowWhere(input poModelService as IComponentInfo,
                                      input pcQuery as character,
                                      input poQueryDefinition as IQueryDefinition,
                                      input poFindType as FindTypeEnum).
    
/* Service operations */    
    /** Fetches data for all Models. Executes a single bundle/request for
        all the models that this Presenter knows about. */
    method public void FetchData (). 
          
    /* Fetches data for the specified Model. */
    method public void FetchData (input poModelService as IComponentInfo).
    
    /** Fetches data for the specified Models. Executes a single bundle/request for these. */    
    method public void FetchData (input poModelService as IComponentInfo extent).
    
    /* Commits data for all Models that the Presenter knows about. Creates and executes a
       single bundle for all. */
    method public void CommitData().
    
    /* Commits data for the specified Model. */
    method public void CommitData(input poModelService as IComponentInfo).
    
    /** Commits data for the specified Models. Executes a single bundle/request for these. */
    method public void CommitData(input poModelService as IComponentInfo extent).
    
/* Model Operations */
    method public character AddRecord(input poModelService as IComponentInfo, input pcQuery as character, pcTable as character).
    method public void SaveRecord(input poModelService as IComponentInfo, input pcQuery as character, pcTable as character).
    method public void DeleteRecord(input poModelService as IComponentInfo, input pcQuery as character, pcTable as character).
    
    method public void UndoAction(input poModelService as IComponentInfo,
                                  input pcQuery as character,
                                  input pcTable as character,
                                  input poAction as UpdateActionEnum,
                                  input pcCurrentRowKey as character extent).
end interface.
