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
    File        : ContainedObject
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Feb 20 14:41:33 EST 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.  
  
using OpenEdge.PresentationLayer.View.IView.
using OpenEdge.PresentationLayer.View.IContainedView.
using OpenEdge.PresentationLayer.Presenter.IPresenter.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.

using OpenEdge.CommonInfrastructure.Common.IComponentInfo.   
using OpenEdge.CommonInfrastructure.Common.IComponent.

using OpenEdge.Lang.ABLSession.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.PresentationLayer.View.ABLGui.ContainedObject abstract
        implements IContainedView, IView, IComponent  : 

    define protected property WindowHandle as handle no-undo get. set.
    
    define public property AllowDestroyComponent as logical initial true no-undo get. set.
    define public property PresenterName as character no-undo get. set.
        
    define public property Presenter as IPresenter no-undo 
        get. 
        set (poPresenter as IPresenter):
            Presenter = poPresenter.
            if valid-handle(WindowHandle) then
                dynamic-function('setPresenter' in WindowHandle, poPresenter).
        end set.

    define public property PresenterService as class Class no-undo get. set. 
    define public property ComponentInfo as IComponentInfo no-undo get. private set.

    method public void Create():
        run CreateObjects in WindowHandle.
    end method.
    
    method public void Initialize():

        run EnableObject in WindowHandle.
                        
        InitializeChildViews().
                
        SubscribeEvents().
        SetBindings().
    end method.

    method public void InitializeChildViews():
        run InitializeChildViews in WindowHandle.
    end method.        
    
    method public void SubscribeEvents():
/*        run SubscribeEvents in WindowHandle.*/
/***
        /* Standard events that we always want to catch. */
        this-object:FormClosed:Subscribe(this-object:View_FormClosed).
**/        
        @todo(task="What others? Resize? Load? ").
    end method.   
            
    method public void DestroyComponent():
    end method. 
    
    method public abstract void SetBindings ().
    
    method protected handle GetRunningObject (pcName as char):
        define variable hObject as handle no-undo.
        
        hObject = ABLSession:Instance:GetFirstRunningProc(pcName).
        /* Start if not found */
        if not valid-handle(hObject) then
            run value(pcName) persistent set hObject.
                
        return hObject.
    end method.
    
    method public abstract void DataRefreshed(pcModel as char, pcQuery as char, poModelAction as ModelActionEnum).
    
    method public abstract void DataFetched(pcModel as char, plNewData as logical).
    
    method public abstract void SaveData (pcModel as char, pcTable as char).

    method public void SetPresenterService(poService as class Class):
        PresenterService = poService.
    end method.

    method public void ShowEmbedded(poParentView as Object ):
    end method.

    method public void ShowView(  ):
    end method.

    method public void HideView(  ):
    end method.

    method public void CloseView(  ):
    end method.

    method public void DataRefreshed(poModelService as IComponentInfo, pcQuery as character, poModelAction as ModelActionEnum):

    end method.

    method public void DataFetched(poModelService as IComponentInfo, plNewData as logical):
        
    end method.

    method public void SaveData(poModelService as IComponentInfo, pcBuffer as character):

    end method.

    method public void CreateComponent(  ):

    end method.
    
end class.
