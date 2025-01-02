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
   File        : MVPForm
   Purpose     : ABL Form which is the base View
   Syntax      : 
   Description : 
   @author pjudge
   Created     : Wed Dec 24 12:00:08 EST 2008
   Notes       : This class should be abstract, but the Visual Designer needs
                 a form to inherit from a concrete class in order to paint it
                 on the canvas. 
 ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.View.IView.
using OpenEdge.PresentationLayer.View.IContainerView.
using OpenEdge.PresentationLayer.View.IContainedView.
using OpenEdge.PresentationLayer.View.GuiForDotNet.MVPForm.
using OpenEdge.PresentationLayer.View.IComponentContainer.
using OpenEdge.PresentationLayer.View.EventLoopModeEnum.
using OpenEdge.PresentationLayer.View.GuiForDotNet.FormsEnumHelper.
using OpenEdge.PresentationLayer.View.EventLoopModeEnum.
using OpenEdge.PresentationLayer.Presenter.IPresenter.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.
 
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using System.Windows.Forms.Control.
using System.Windows.Forms.FormClosingEventArgs.
using System.Windows.Forms.FormClosedEventArgs.
using System.Windows.Forms.CloseReason.
using System.ComponentModel.LicenseManager.
using System.ComponentModel.LicenseUsageMode.

using Progress.Windows.Form.
using Progress.Util.EnumHelper.
using Progress.Lang.Object.
using Progress.Lang.Class.

/* Ideally this class would be abstract, but the Visual Designer requires that a class' parent
   (ie this) be able to be instantiated (concrete). And so it is. */
class OpenEdge.PresentationLayer.View.GuiForDotNet.MVPForm inherits Form
    implements IContainerView, IView, IComponent:
    
    define public property AllowDestroyComponent as logical initial true no-undo get. set.
    
    define public property Presenter as IPresenter no-undo get. set.

    /** Stores information about the component, such as a developer-defined instance name 
        (so as to be able to uniquely identify the component). Set via constructor injection
        in InjectABL. */
    define public property ComponentInfo as IComponentInfo no-undo get. private set.
    
    /* We have an instance variable to keep track of the current instance; the static variable
       is just a toggle used when invoking the form. If using the project's AVM for launch configs,
       we could launch a window from the designer, then a 'proper' one from start.p etc. Each launch
       will have the static variable set (or not). */
    define private variable mlStartedByPresenter as logical no-undo.
    
    /** Stores what the event loop mode is for this View. */
    define protected property EventLoopMode as EventLoopModeEnum no-undo get. set.
    
    constructor public MVPForm(poComponentInfo as IComponentInfo):
        super().
        
        ComponentInfo = poComponentInfo.        
    end constructor.
    
    /* This constructor is only run when we're in the designer (or should only be) */
    constructor public MVPForm():
        super().
        
        mlStartedByPresenter = OpenEdge.PresentationLayer.Presenter.Presenter:IsInvokingView.
    end method.
    
    method private void InitializeComponent ( ):
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:SuspendLayout().
        /*  */
        /* MVPForm */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(297, 267).
        this-object:Name = "MVPForm".
        this-object:Text = "MVPForm".
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.
    
    /* Simply an inverse of the IsInDesignMode() method */
    method static protected logical IsInRuntimeMode():
        return not MVPForm:IsInDesignMode().
    end method.
       
    method static protected logical IsInDesignMode():
        return EnumHelper:AreEqual(LicenseManager:UsageMode, LicenseUsageMode:Designtime).
    end method.
    
    method protected logical InvokedByDesigner():
        define variable iLoop as integer no-undo.
        define variable lFromTypeConstructor as logical no-undo.
                
        iLoop = 1.
        lFromTypeConstructor = false.
        
        do while program-name(iLoop) ne ? and
            lFromTypeConstructor eq false:
            
            assign lFromTypeConstructor = 
                            entry(1, program-name(iLoop), ' ') eq
                                   entry(num-entries(this-object:GetClass():TypeName, '.'), 
                                         this-object:GetClass():TypeName,
                                         '.')
                   iLoop = iLoop + 1. 
        end.
                                       
        /* We only want to init the Presenter if we are launching the form
           from the design surface. If we are invoking it for the 
           design canvas, we don't care about the presenter. */
        return ( mlStartedByPresenter eq false and 
                 MVPForm:IsInRuntimeMode() and
                 /* If this method was called from this type's super, then
                     ignore. This kludgy goodness results because this call will
                     be made from the constructor and as that means that the super
                     goes first. We want the instance being run's type to do this
                     since it has to happen after InitComp. */
                 lFromTypeConstructor eq true).
    end method.
    
    /* The following method is only use for starting a View from the Visual Designer.
       At runtime, the Presenter needs to start the View, Models etc. 
    method protected void InitializeDesignTimePresenter(pcPresenter as char):
        define variable oPresenter as IPresenter no-undo.
        
        if pcPresenter ne '' and InvokedByDesigner() then
        do:
            /* Start the presenter. */
            oPresenter = this-object:Presenter.
            if not valid-object(oPresenter) then
            do:                
                oPresenter = PresenterFactory:GetPresenter(pcPresenter, ?).
                this-object:Presenter = oPresenter.
                                                       
                cast(oPresenter, IComponent):Initialize().
            end.
            
            /* The Presenter should now be Initialized and ready to go.
               This code effectively replaces InitializeView in the Presenter. */
            if valid-object(Presenter) then
            do:
                Presenter:View = this-object.
                this-object:Initialize().
            end.
        end.
    end method.
     */
        
    destructor public MVPForm ():
        /**
        if not mlStartedByPresenter and valid-object(Presenter) then
            Presenter = ?. /* cast(Presenter, IComponent):DestroyComponent().*/
        **/
        
        DestroyComponent().
    end destructor.

    method public void Create():
        /* this is done by the constructor. */
    end method.
    
    method public void Initialize():
        InitializeChildViews(this-object).
        
        SubscribeEvents().
        SetBindings().
    end method.
    
    /** Use StartChildView when starting things like a toolbar manager or the 
        like. 
    method protected IView StartChildView(pcViewName as character):
        define variable oView as IView no-undo.
        
        oView = ViewFactory:GetView(pcViewName, ?).
        
        
        oView:Presenter = Presenter:AssociateContainedView(cast(oView, IContainedView)).
        cast(oView, IComponent):Initialize().
                                
        return oView.         
    end method.
     **/
     
    
    /** This method is called recursively.
           
        @param poControl A Windows Control which is inspected for MVP objects.  
      */
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
           components that aren't part of the Form's Controls collection, and thus
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
                            
    method protected void SubscribeEvents():
        this-object:FormClosing:Subscribe(this-object:View_FormClosing).
    end method.

    method protected void UnsubscribeEvents():
        this-object:FormClosing:Unsubscribe(this-object:View_FormClosing).
    end method.
    
    @method(virtual="true").
    method protected void SetBindings():
    end method.
    
    method private void View_FormClosing(sender as System.Object, e as FormClosingEventArgs):
        /** CloseReason None if closed programatically. In that case, let the form die, since
            odds are that the Presenter is the one doing the programatical killing. Or at least,
            we sincerely hope. */
        if EnumHelper:AreNotEqual(e:CloseReason, CloseReason:None) then
            e:Cancel = not this-object:Presenter:CanCloseView(
                            FormsEnumHelper:DialogResultToABL(DialogResult),
                            FormsEnumHelper:CloseReasonToABL(e:CloseReason) ).
    end method.
    
    method public void ShowEmbedded(poParentView as Object):
        EventLoopMode = EventLoopModeEnum:Embedded.
        
        if type-of(poParentView, Form) then
            this-object:MdiParent = cast(poParentView, Form).
        
        ShowView().
    end method.
    
    method public void ShowModal():
        BeginEventLoop(EventLoopModeEnum:Modal).
    end method.

    method public void ShowView():
        this-object:Show().
    end method.
    
    method public void HideView():
        this-object:Hide().
    end method.
    
    method public void CloseView():        
        EndEventLoop().        
    end method.
    
    method public void BeginEventLoop(poEventLoopMode as EventLoopModeEnum):
        EventLoopMode = poEventLoopMode.
        
        case EventLoopMode:
            when EventLoopModeEnum:NonModalView then
                wait-for System.Windows.Forms.Application:Run(this-object).
            when EventLoopModeEnum:NonModalNone then
                wait-for System.Windows.Forms.Application:Run().
            when EventLoopModeEnum:Modal then
                wait-for this-object:ShowDialog().
        end case.
                
        EventLoopMode = EventLoopModeEnum:None.
    end method.
    
    method public void EndEventLoop():
        /* no loop here */
        if EventLoopMode ne EventLoopModeEnum:None then
        case EventLoopMode:
            when EventLoopModeEnum:Modal or when EventLoopModeEnum:NonModalView then
                this-object:Close().
            when EventLoopModeEnum:NonModalNone then
                System.Windows.Forms.Application:Exit().
        end case.        
    end method.
        
    method public void DestroyComponent():
        EndEventLoop().
        UnsubscribeEvents().
        
        /* only dispose when we're sure we want to kill this off */
        this-object:Dispose().
    end method.
    
    method public void DataRefreshed (poModelService as IComponentInfo, pcQuery as char, poModelAction as ModelActionEnum):
    end method.
    
    method public void DataFetched (poModelService as IComponentInfo, plNewData as log):
    end method.
    
    method public void SaveData (poModelService as IComponentInfo, pcTable as char):
    end method.

    method public void CreateComponent(  ):
    end method.

end class.

