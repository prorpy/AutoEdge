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
/*------------------------------------------------------------------------
   File        : UpdatePanelPresenter
   Purpose     : 
   Syntax      : 
   Description : 
   @author pjudge
   Created     : Thu Feb 26 14:18:30 EST 2009
   Notes       : 
 ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.  
using OpenEdge.PresentationLayer.Presenter.DataboundPresenter.
using OpenEdge.PresentationLayer.Presenter.IDataboundPresenter.
using OpenEdge.PresentationLayer.Presenter.IUpdatePanelPresenter.
using OpenEdge.PresentationLayer.Model.IModel.
using OpenEdge.PresentationLayer.View.IUpdatePanelView.
using OpenEdge.PresentationLayer.Common.ActionStateEnum.
using OpenEdge.PresentationLayer.Common.UndoActionEventArgs.
using OpenEdge.PresentationLayer.Common.ISelectToolbarAction.
using OpenEdge.PresentationLayer.Common.ToolbarActionEventArgs.
using OpenEdge.PresentationLayer.Common.UpdatePanelEventArgs.

using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.

using OpenEdge.Core.System.IQuery.
using OpenEdge.Lang.EnumMember.

using Progress.Lang.Class.

class OpenEdge.PresentationLayer.Presenter.UpdatePanelPresenter inherits DataboundPresenter
    implements ISelectToolbarAction, IUpdatePanelPresenter:
    
    define private property moUndoActionModel as IModel no-undo
        get():
            return GetModel(Class:GetClass('OpenEdge.PresentationLayer.Model.UndoActionModel')).
        end get.
    
    define private variable mcUndoActionQuery as character no-undo.
    define private variable mcUndoActionTable as character no-undo init 'eAction'.
    define protected property UndoActionOrder as integer no-undo
        get():
            UndoActionOrder = UndoActionOrder + 1.
        end get.
        private set.
                                      
    define public property ModelService as IComponentInfo no-undo get. set.
    define public property QueryName as char no-undo get. set.
    define public property TableName as char no-undo 
        get.
        set (pcTableName as char):
            if pcTableName ne ? then
            do:
                TableName = pcTableName.
                if valid-object(this-object:View) and type-of(this-object:View, IUpdatePanelView) then
                    cast(this-object:View, IUpdatePanelView):TableNameChange(pcTableName).
            end.
        end set.

    define public property CommitAction as UpdateActionEnum no-undo
        get ():
            if not valid-object(CommitAction) then
                CommitAction = UpdateActionEnum:Commit.
            
            return CommitAction.
        end get. 
        set. 

    define public property DeleteAction as UpdateActionEnum no-undo
        get ():
            if not valid-object(DeleteAction) then
                DeleteAction = UpdateActionEnum:Commit.
            return DeleteAction.
        end get. 
        set.
        
    constructor public UpdatePanelPresenter(input poComponentInfo as IComponentInfo):
        super(input poComponentInfo).
    end constructor.
    
    constructor public UpdatePanelPresenter(input poComponentInfo as IComponentInfo, poModel as IModel extent):
        super(poComponentInfo, poModel).
    end constructor.
    
    method override public void Initialize():
        define variable oQueryDefinition as IQuery no-undo.
        
        super:Initialize().
        
        /****
        oQueryDefinition = new QueryDefinition().
        oQueryDefinition:AddBuffer(mcUndoActionTable).
        
        oQueryDefinition:AddSort(mcUndoActionTable,
                              'QueryName',
                              SortDirectionEnum:Default,
                              1).
        oQueryDefinition:AddSort(mcUndoActionTable,
                              'BufferName',
                              SortDirectionEnum:Default,
                              2).
        oQueryDefinition:AddSort(mcUndoActionTable,
                              'Order',
                              SortDirectionEnum:Default,
                              3).
        
        this-object:GetQuery(mcUndoActionModel,
                             oQueryDefinition,
                             true,  /* create abl query */
                             input-output mcUndoActionQuery).
        this-object:OpenQuery(mcUndoActionModel, mcUndoActionQuery).
        /* there should be no data in here at this point */
        ***/
        
        if valid-object(ParentPresenter) and 
            type-of(ParentPresenter, IDataboundPresenter) then
        do:            
            cast(ParentPresenter, IDataboundPresenter):UpdatePanelStateChanged:Subscribe(this-object:UpdatePanelStateChangedHandler).            
        /*            cast(ParentPresenter, IDataboundPresenter):AddUndoAction:Attach:Subscribe(this-object:AddUndoActionHandler).*/
        end.
    end method.
       
    method public void SelectToolbarAction (poArgs as ToolbarActionEventArgs):
        define variable iAction as integer no-undo.
        
        poArgs:GetArgValue('Action', output iAction).
        
        case UpdateActionEnum:EnumFromValue(iAction):
            when UpdateActionEnum:Add then
                cast(ParentPresenter, IDataboundPresenter):AddRecord(ModelService, QueryName, TableName).
            when UpdateActionEnum:Delete then
                do:
                    /* Always (do the local) Delete */
                    cast(ParentPresenter, IDataboundPresenter):DeleteRecord(ModelService, QueryName, TableName).
                
                    if DeleteAction eq UpdateActionEnum:Commit then
                        cast(ParentPresenter, IDataboundPresenter):CommitData(ModelService).
                end.
            when UpdateActionEnum:Save then
                cast(ParentPresenter, IDataboundPresenter):SaveRecord(ModelService, QueryName, TableName).
            when UpdateActionEnum:Commit then
                do:
                    /* Commit does a Save first, do no need to do one here. */
                    if CommitAction eq UpdateActionEnum:Commit then 
                        cast(ParentPresenter, IDataboundPresenter):CommitData(ModelService).
                    else
                        cast(ParentPresenter, IDataboundPresenter):SaveRecord(ModelService, QueryName, TableName).
                end.
            when UpdateActionEnum:Undo then
                UndoAction().
        end case.
    end method.
    
    method public void UpdatePanelStateChangedHandler (poSender as IComponent, poEventArgs as UpdatePanelEventArgs):        
        define variable oStates      as ActionStateEnum extent 5 no-undo.
        define variable oActions     as UpdateActionEnum extent 5 no-undo.
        
        define variable oAddState    as ActionStateEnum no-undo.
        define variable oDeleteState as ActionStateEnum no-undo.
        define variable oCancelState as ActionStateEnum no-undo.
        define variable oCommitState as ActionStateEnum no-undo.
        define variable oSaveState   as ActionStateEnum no-undo.
        
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.

        if ModelService eq poEventArgs:ModelService then
/*            QueryName eq poEventArgs:QueryName and*/
        do:
            iMax = extent(poEventArgs:TableName).
            
            do iLoop = 1 to iMax:
                if TableName eq poEventArgs:TableName[iLoop] then
                do:
                /*
                            case poEventArgs:ModelState:
                                when ModelStateEnum:Add then
                                    assign 
                                        iAddState    = UpdateActionEnum:Disable
                                        iDeleteState = UpdateActionEnum:Disable
                                        iCancelState = UpdateActionEnum:Enable
                                        iCommitState = UpdateActionEnum:Enable
                                        iSaveState   = UpdateActionEnum:Enable.
                                when ModelStateEnum:ReadOnly then
                                    assign 
                                        iAddState    = UpdateActionEnum:Disable
                                        iDeleteState = UpdateActionEnum:Disable
                                        iCancelState = UpdateActionEnum:Disable
                                        iCommitState = UpdateActionEnum:Disable
                                        iSaveState   = UpdateActionEnum:Disable.
                                otherwise
                                assign 
                                    iAddState    = UpdateActionEnum:Enable
                                    iDeleteState = UpdateActionEnum:Enable
                                    iCancelState = UpdateActionEnum:Enable
                                    iCommitState = UpdateActionEnum:Enable
                                    iSaveState   = UpdateActionEnum:Enable.
                            end case.
                            */
                
                    assign 
                        oActions[1] = UpdateActionEnum:Add
                        oActions[2] = UpdateActionEnum:Delete
                        oActions[3] = UpdateActionEnum:Commit
                        oActions[4] = UpdateActionEnum:Save
                        oActions[5] = UpdateActionEnum:Undo.
                    
                    oStates = ActionStateEnum:Enable.
                    if type-of(this-object:View, IUpdatePanelView) then            
                        cast(this-object:View, IUpdatePanelView):UpdateStateChange(oActions, oStates).
                    
                    leave.                    
                end.
            end.
        end.
    end method.
        
    method public void AddUndoActionHandler (poSender as IComponent, poEventArgs as UndoActionEventArgs):
        define variable cNewRecordKey as character no-undo.
        define variable cRowKey       as character extent 18 no-undo.
        define variable iExtent       as integer   no-undo.
        define variable oComponentInfo  as IComponentInfo no-undo.
        
        /* Add to the model */
        oComponentInfo = cast(cast(moUndoActionModel, IComponent):ComponentInfo, IComponentInfo).
        cNewRecordKey = AddRecord(oComponentInfo, mcUndoActionQuery, mcUndoActionTable).
        
        do iExtent = 1 to extent(poEventArgs:RecordKey):
            cRowKey[iExtent] = poEventArgs:RecordKey[iExtent].
        end.
        
        SetValue(oComponentInfo, cNewRecordKey, mcUndoActionTable, 'RecordKey', cRowKey).               
        SetValue(oComponentInfo, cNewRecordKey, mcUndoActionTable, 'QueryName', poEventArgs:QueryName).
        SetValue(oComponentInfo, cNewRecordKey, mcUndoActionTable, 'ModelService', poEventArgs:ModelService).
        SetValue(oComponentInfo, cNewRecordKey, mcUndoActionTable, 'BufferName', poEventArgs:BufferName).
        SetValue(oComponentInfo, cNewRecordKey, mcUndoActionTable, 'UndoActionType', poEventArgs:UndoActionType).
        
        poEventArgs:Order = UndoActionOrder.
        SetValue(oComponentInfo, cNewRecordKey, mcUndoActionTable, 'Order', poEventArgs:Order).
        
        CommitData(oComponentInfo).
    end method.
    
    method protected void UndoAction ():
        define variable iAction        as integer   no-undo.
        define variable cCurrentRowKey as character extent no-undo.        
        define variable cRecordKey     as character no-undo.
        define variable oComponentInfo  as IComponentInfo no-undo.
        
        oComponentInfo = cast(cast(moUndoActionModel, IComponent):ComponentInfo, IComponentInfo).
                        
        cRecordKey = cast(GetModel(oComponentInfo):ModelQueries:Get(mcUndoActionQuery), IQuery):GetCurrentBufferKey(mcUndoActionTable).
        
        GetValue(oComponentInfo, cRecordKey, mcUndoActionTable,
            'UndoActionType', output iAction). 

        GetValue(oComponentInfo, cRecordKey, mcUndoActionTable,
            'RecordKey', output cCurrentRowKey). 
        
        cast(ParentPresenter, IDataboundPresenter):UndoAction(
            ModelService, QueryName, TableName,
            UpdateActionEnum:EnumFromValue(iAction),
            cCurrentRowKey ).
        
        /* Remove the undo action. */
        DeleteRecord(oComponentInfo, mcUndoActionQuery, mcUndoActionTable).
        CommitData(oComponentInfo).
    end method.
    
end class.
