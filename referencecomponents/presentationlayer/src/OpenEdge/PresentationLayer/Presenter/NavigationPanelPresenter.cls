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
    File        : NavigationPanelPresenter
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 05 15:43:38 EST 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Presenter.INavigationPanelPresenter. 
using OpenEdge.PresentationLayer.Presenter.NavigationPanelPresenter.
using OpenEdge.PresentationLayer.Presenter.Presenter.
using OpenEdge.PresentationLayer.Presenter.IDataboundPresenter.
using OpenEdge.PresentationLayer.Common.NavigationActionEnum.
using OpenEdge.PresentationLayer.View.INavigationPanelView.
using OpenEdge.PresentationLayer.Common.ISelectToolbarAction.
using OpenEdge.PresentationLayer.Common.ToolbarActionEventArgs.
using OpenEdge.PresentationLayer.Common.NavigationPanelEventArgs.
using OpenEdge.PresentationLayer.Common.ActionStateEnum.
using OpenEdge.PresentationLayer.Common.NavigationActionEnum.

using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponent.

using OpenEdge.Core.System.RowPositionEnum.
using Progress.Lang.Class.

class OpenEdge.PresentationLayer.Presenter.NavigationPanelPresenter inherits Presenter
        implements INavigationPanelPresenter, ISelectToolbarAction:
        
    define public property ModelService as IComponentInfo no-undo get. set.          
    define public property QueryName as char no-undo get. set.

    constructor public NavigationPanelPresenter(input poComponentInfo as IComponentInfo):
        super(input poComponentInfo).
    end constructor.

    method override public void Initialize():
        super:Initialize().
                        
        if valid-object(ParentPresenter) and 
           type-of(ParentPresenter, IDataboundPresenter) then
            cast(ParentPresenter, IDataboundPresenter):NavigationPanelStateChanged:Subscribe(this-object:NavigationPanelStateChangedHandler).
    end method.
    
    /* ISelectToolbarAction events */
    method public void SelectToolbarAction (poArgs as ToolbarActionEventArgs):
        define variable iAction as integer no-undo.
        
        poArgs:GetArgValue('Action', output iAction).
        
        case NavigationActionEnum:EnumFromValue(iAction):
            when NavigationActionEnum:First then
                cast(ParentPresenter, IDataboundPresenter):GetFirst(ModelService, QueryName).
            when NavigationActionEnum:Prev then
                cast(ParentPresenter, IDataboundPresenter):GetPrev(ModelService, QueryName).
            when NavigationActionEnum:Next then
                cast(ParentPresenter, IDataboundPresenter):GetNext(ModelService, QueryName).
            when NavigationActionEnum:Last then
                cast(ParentPresenter, IDataboundPresenter):GetLast(ModelService, QueryName).
        end case.
    end method.
                
    method public void NavigationPanelStateChangedHandler (poSender as IComponent, poEventArgs as NavigationPanelEventArgs):
        define variable oStates as ActionStateEnum extent 4 no-undo.
        define variable oActions as NavigationActionEnum extent 4 no-undo.
        
        /* Only navigate for the current model */
        if ModelService eq poEventArgs:ModelService and
           QueryName eq poEventArgs:QueryName then
        do:
            assign oActions[1] = NavigationActionEnum:First
                   oActions[2] = NavigationActionEnum:Prev
                   oActions[3] = NavigationActionEnum:Next
                   oActions[4] = NavigationActionEnum:Last.
            
            if poEventArgs:RowPosition eq RowPositionEnum:None then
                oStates = ActionStateEnum:Disable.
            else
                assign oStates[1] = (if poEventArgs:RowPosition eq RowPositionEnum:IsFirst or
                                        poEventArgs:RowPosition eq RowPositionEnum:IsFirstAndLast then
                                        ActionStateEnum:Disable
                                     else ActionStateEnum:Enable)
                       oStates[2] = (if poEventArgs:RowPosition eq RowPositionEnum:IsFirst or
                                        poEventArgs:RowPosition eq RowPositionEnum:IsFirstAndLast then
                                        ActionStateEnum:Disable 
                                     else ActionStateEnum:Enable)
                       oStates[3] = (if poEventArgs:RowPosition eq RowPositionEnum:IsLast or
                                        poEventArgs:RowPosition eq RowPositionEnum:IsFirstAndLast then
                                        ActionStateEnum:Disable
                                     else ActionStateEnum:Enable)
                       oStates[4] = (if poEventArgs:RowPosition eq RowPositionEnum:IsLast or
                                        poEventArgs:RowPosition eq RowPositionEnum:IsFirstAndLast then
                                        ActionStateEnum:Disable
                                     else ActionStateEnum:Enable).
            
            if type-of(this-object:View, INavigationPanelView) then
                cast(this-object:View, INavigationPanelView):NavigationStateChange(oActions, oStates).
        end.
    end method.
                      
end class.
