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
    File        : MVPUserControl
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Jan 08 15:07:12 EST 2009
    Notes       : This class should be abstract, but the Visual Designer needs
                  a user control to inherit from a concrete class in order to 
                  paint it on the canvas.  
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.View.IView.
using OpenEdge.PresentationLayer.View.IComponentContainer.
using OpenEdge.PresentationLayer.View.IContainedView.
using OpenEdge.PresentationLayer.Presenter.IPresenter.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.

using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
 
using System.Windows.Forms.Control.
using Progress.Windows.UserControl.
using Progress.Lang.Class.

using System.ComponentModel.*.
using Progress.Util.*.

class OpenEdge.PresentationLayer.View.GuiForDotNet.MVPUserControl  /* abstract */
        inherits UserControl
        implements IContainedView, IView, IComponent :
    
    define public property Presenter as IPresenter no-undo get. set.
    define public property PresenterService as class Class no-undo get. set.
     
    define public property ComponentInfo as IComponentInfo no-undo get. private set.

    method public void Initialize():
        InitializeChildViews(this-object).
        
        SubscribeEvents().
        SetBindings().
    end method.
    
    method protected void InitializeChildViews(poControl as Control):
        define variable oChildControl as Control no-undo.
        define variable oContainedView as IContainedView no-undo.
        define variable iExtent as int no-undo.
        define variable oComponentViews as IContainedView extent no-undo.
        
        do iExtent = 0 to poControl:Controls:Count - 1:
            oChildControl = poControl:Controls[iExtent].
                                                                                            
            if type-of(oChildControl, IContainedView) then
            do:
                oContainedView = cast(oChildControl, IContainedView).
                /* At this point, this UC or Inherited Control doesn't know who its Presenter is.
                   This form, however, does. */
                cast(oChildControl, IView):Presenter = Presenter:AssociateContainedView(oContainedView).
                /* And now initialize ... */
                cast(oChildControl, IComponent):Initialize().
            end.
            else
            /* Recurse into child controls, but only if they're not
               our Components. MVP IComponent objects will do this
               from their own Initialize() calls. We're just walking the UI
               tree here - NOT the MVP tree, as it were, since that happens
               via the block above. This recursion is for cases where a User
               Controls or an Inherited control appears on a .NET Panel or
               other container, like a toolbar dock. */
                InitializeChildViews(oChildControl).
        end.
        
        /** In certain cases (for instance, with the UltraToolbarsManager) there are 
           components that aren't part of the Form's Controls collection, and thuse
           aren't aquired by the code above. If a MVPForm wants them to act as 
           Contained Views, it needs make them implement IComponentContainer. **/
        if type-of(poControl, IComponentContainer) then
        do:
            oComponentViews = cast(poControl, IComponentContainer):GetContainedViewComponents() no-error.
            
            do iExtent = 1 to extent(oComponentViews):
                oContainedView = oComponentViews[iExtent].
                if valid-object(oContainedView) then
                do:
                    /* At this point, this component doesn't know who its Presenter is. This control, however, does. */
                    cast(oContainedView, IView):Presenter = this-object:Presenter:AssociateContainedView(oContainedView).
                    /* And now initialize ... */
                    cast(oContainedView, IComponent):Initialize().
                end.
            end.    /* extent loop */
        end.    /* component container */
    end method.
        
    method private void InitializeComponent ( ):
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:SuspendLayout().
        /*  */
        /* MVPUserControl */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(6, 13).
        this-object:Name = "MVPUserControl".
        this-object:Size = new System.Drawing.Size(298, 300).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.
    
    @method(virtual="true").
    method protected void SubscribeEvents():
    end method.

    @method(virtual="true").
    method protected void UnsubscribeEvents():        
    end method.
    
    method public void DestroyComponent():
        UnsubscribeEvents().
    end method. 
    
    @method(virtual="true").
    method protected void SetBindings():
    end method.
    
    @method(abstract="true").
    method public /* abstract */ void DataRefreshed(poModelService as IComponentInfo,
                                                    pcQuery as char,                                                     
                                                    poModelAction as ModelActionEnum):
    end method.

    @method(abstract="true").
    method public /* abstract */ void SaveData (poModelService as IComponentInfo, pcBuffer as char):
    end method.
    
    @method(abstract="true").
    method public /* abstract */ void DataFetched(poModelService as IComponentInfo, plNewData as logical):
    end method.

    method public void SetPresenterService(poService as class Class):
        this-object:PresenterService = poService.
    end method.
    
    method public void ShowEmbedded(poParentView as Progress.Lang.Object ):
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    end method.

    method public void CreateComponent():
    end method.

    method public void ShowView(  ):
        this-object:Show().
    end method.
    
    method public void HideView(  ):
        this-object:Hide().
    end method.

    method public void CloseView(  ):
        /* does nothing */
    end method.
    
end class.
