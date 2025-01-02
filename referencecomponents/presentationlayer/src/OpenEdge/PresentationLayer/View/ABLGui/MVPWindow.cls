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
    File        : MVPWindow
    Purpose     : ABL Window general view portion of MVP triad. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Feb 20 10:42:09 EST 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.View.EventLoopModeEnum.
using OpenEdge.PresentationLayer.View.IView.
using OpenEdge.PresentationLayer.View.IContainerView.
using OpenEdge.PresentationLayer.View.IContainedView.
using OpenEdge.PresentationLayer.View.IComponentContainer.
using OpenEdge.PresentationLayer.View.EventLoopModeEnum.
using OpenEdge.PresentationLayer.Presenter.IPresenter.
using OpenEdge.PresentationLayer.Common.CloseReasonEnum.
using OpenEdge.PresentationLayer.Common.DialogResultEnum.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.

using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.Core.System.InvalidActionError.
 
using Progress.Lang.Object.

class OpenEdge.PresentationLayer.View.ABLGui.MVPWindow abstract 
        implements IContainerView, IView, IComponent  : 

    /** Stores what the event loop mode is for this View. Values from
        OpenEdge.PresentationLayer.View.EventLoopModeEnum */
    define protected property EventLoopMode as EventLoopModeEnum  no-undo get. set.
    define protected property WindowHandle as handle no-undo get. set.
    
    define public property Presenter as IPresenter no-undo 
        get.
        set (poPresenter as IPresenter):
            /* Saves making the function call in the getter */
            Presenter = poPresenter.
                        
            if valid-handle(WindowHandle) then
                dynamic-function('setPresenter' in WindowHandle, poPresenter).
        end set.

    define public property ComponentInfo as OpenEdge.CommonInfrastructure.Common.IComponentInfo no-undo 
    get():
        undo, throw new Progress.Lang.AppError("Property getter for ComponentInfo has not been implemented").
    end get.
    private set(input arg as OpenEdge.CommonInfrastructure.Common.IComponentInfo):
        undo, throw new Progress.Lang.AppError("Property setter for ComponentInfo has not been implemented").        
    end set.
     
    
    method public void DestroyComponent():
        run DestroyComponent in WindowHandle.
        
        delete object WindowHandle no-error.
    end method.
                    
    method public void Create():
    end method.
    
    method public void Initialize():
        run InitializeObject in WindowHandle.
        
        InitializeChildViews().
        
        SubscribeEvents().
        SetBindings().
    end method.
    
    method protected void InitializeChildViews():
        run InitializeChildViews in WindowHandle.
    end method.
    
    method protected void SubscribeEvents():
        run SubscribeEvents in WindowHandle no-error.
    end method.

    method protected void UnsubscribeEvents():
        run UnsubscribeEvents in WindowHandle no-error.
    end method.
    
    method public void ShowModal(  ):
        BeginEventLoop(EventLoopModeEnum:Modal).
    end method.
    
    method public void ShowEmbedded(poParent as Object ):
        /* Not supported for ABL Gui windows */
        return error new InvalidActionError('ShowEmbedded() not not supported'). 
    end method.

    method public void BeginEventLoop(poEventLoopMode as EventLoopModeEnum):
        run BeginEventLoop in WindowHandle (poEventLoopMode).
    end method.
    
    method public void EndEventLoop():
        run EndEventLoop in WindowHandle.
    end method.
    
    method public void SetBindings ():
        run SetBindings in WindowHandle.
    end method.
    
    constructor public MVPWindow():
        super().
    end constructor.

    method public void DataFetched(pcModel as char, plNewData as logical):
        run DataFetched in WindowHandle (pcModel, plNewData).
    end method.
    
    method public void SaveData (pcModel as char, pcTable as char):
        run SaveData in WindowHandle (pcModel, pcTable).
    end method.

    method public void ShowView(  ):
        run ViewObject in WindowHandle.
    end method.

    method public void HideView(  ):
        run HideObject in WindowHandle.
    end method.

    method public void CloseView(  ):
        run DestroyObject in WindowHandle.
    end method.

    method public void DataRefreshed(poModelService as IComponentInfo, pcQuery as character, poModelAction as ModelActionEnum):
        run DataRefreshed in WindowHandle (poModelService, pcQuery, poModelAction).
    end method.

    method public void DataFetched(poModelService as IComponentInfo, plNewData as logical):
        run DataFetched in WindowHandle (poModelService, plNewData).
    end method.

    method public void SaveData(poModelService as IComponentInfo, pcBuffer as character):
        run SaveData in WindowHandle (poModelService, pcBuffer). 
    end method.

    method public void CreateComponent(  ):
        run CreateObjects in WindowHandle.
    end method.
    
end class.
