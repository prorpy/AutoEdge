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
/*-----------------------------------------------------------------------
    File        : Presenter
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Dec 11 11:31:52 EST 2007
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Presenter.IPresenter.
using OpenEdge.PresentationLayer.View.EventLoopModeEnum.
using OpenEdge.PresentationLayer.View.IView.
using OpenEdge.PresentationLayer.View.IContainerView.
using OpenEdge.PresentationLayer.View.IContainedView.
using OpenEdge.PresentationLayer.Common.CloseReasonEnum.
using OpenEdge.PresentationLayer.Common.DialogResultEnum.

using OpenEdge.CommonInfrastructure.Common.IServiceCollection.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.IService.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.ComponentInfo.
using OpenEdge.CommonInfrastructure.Common.DestroyComponentError.

using OpenEdge.Core.System.InvalidActionError.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Core.System.NotFoundError.

using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.PresentationLayer.Presenter.Presenter abstract inherits Service 
        implements IPresenter:
    
    /** This only really works because the ABL is single-threaded and only 1 Presenter can be doing any 1 thing at a time */
    define public static property IsInvokingView as logical no-undo get. protected set.
    
    define public property ParentPresenter as IPresenter no-undo get. set.
    define protected property ChildPresenters as IServiceCollection no-undo get. private set.
    
    define public property View as IView no-undo 
        protected get.
        set(poView as IView):
            this-object:View = poView.
            if valid-object(this-object:View) then
                this-object:View:Presenter = this-object.
        end set.
    
    define public property HasView as logical no-undo 
        get():
            return valid-object(this-object:View).
        end get.
    
    constructor public Presenter(poComponentInfo as IComponentInfo): 
        super(poComponentInfo).
    end constructor.
    
    /** Use method since we can't (yet) set properties via reflection */
    method public void SetView(poView as IView):
        this-object:View = poView.
    end method.
    
    method public void AddChildPresenter(poPresenter as IPresenter extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        Assert:ArgumentNotNull(poPresenter, 'Child presenters').
        
        if not valid-object(ChildPresenters) then 
            ChildPresenters = new IServiceCollection().
        
        iMax = extent(poPresenter).            
        do iLoop = 1 to iMax:
            AddChildPresenter(poPresenter[iLoop]).
        end.
    end method.
        
    method public void AddChildPresenter(poPresenter as IPresenter):
        define variable oService as IService no-undo.
        
        Assert:ArgumentNotNull(poPresenter, 'Child presenter').
        
        if not valid-object(ChildPresenters) then
            ChildPresenters = new IServiceCollection().
        oService = cast(poPresenter, IService).
        
        ChildPresenters:Put(cast(cast(oService, IComponent):ComponentInfo, IComponentInfo), oService).
    end method.
    
    method override public void Initialize():
        define variable oComponent as IComponent no-undo.
        define variable oIterator as IIterator no-undo.
        
        if valid-object(ChildPresenters) then
        do:
            oIterator = cast(ChildPresenters, IMap):Values:Iterator().
            do while oIterator:HasNext():
                oComponent = cast(oIterator:Next(), IComponent).
                oComponent:Initialize().
            end.
        end.
        
        if valid-object(this-object:View) then
            cast(this-object:View, IComponent):Initialize(). 
        
        /* Typically these things happen after the view
           is init'ed. Could go into Presenter:Init() but
           there are times where InitView happens independently
           as per associated views. In those cases we need
           to run the post-init processing independently. 
         */
        Secure().
        Personalize().
        Translate().
    end method.
    
    method protected void Secure():
    end method.
    
    method protected void Personalize():
    end method.
    
    method protected void Translate():
    end method.
    
    /** Starts a child Presenter and associates it with this Presenter.
        @param poPresenter The type (service) of the Presenter to invoke
     */
    method public void CreateChildPresenter (poPresenter as class Class):
        AddChildPresenter(cast(ServiceManager:StartService(poPresenter), IPresenter)).
    end method.
    
    method public IPresenter GetChildPresenter(poPresenterService as IComponentInfo):
        return cast(ChildPresenters:Get(poPresenterService), IPresenter).
    end method.
            
    method public IPresenter GetChildPresenter (poPresenterService as class Class):
        return GetChildPresenter(new ComponentInfo(poPresenterService)).
    end method.
    
    /** CanCloseView() call that's made from a View's event handlers/triggers. This method
        can be implemented/overridden to decide whether the closing should take place.
        
        @param piDialogResult OpenEdge.PresentationLayer.View.DialogResultEnum
        @param piCloseReason OpenEdge.PresentationLayer.System.CloseReasonEnum
        
        @return Whether the view can continue closing      */
    @method(virtual="True").
    method public logical CanCloseView(poDialogResult as DialogResultEnum, poCloseReason as CloseReasonEnum):
        return true.
    end method.
    
    /** If a Presenter's View is closed, we consider the Presenter's work done,
        and so the Presenter is destroyed. The Presenter and View can be considered
        co-dependent, and while a Presenter doesn't require a View, if it has one,
        it shares the lifecycle of that View.
        
        Note that this isn't the case for Models,
        where the lifespan of Model and Presenter aren't interdependent.         */
    method protected void CloseView():
        /* If this presenter has a parent (as would happen in
           MDI windows although not limited to that), let the
           parent shut the child down. */
        if valid-object(ParentPresenter) then
            ParentPresenter:DestroyChildPresenter(this-object).
        else
            DestroyComponent().
                
        /* If the destroy fails for some reason, report on it here,
           and halt the shutdown. */
        catch oException as DestroyComponentError:
            oException:ShowError().
        end catch.
    end method.
    
    method override public void DestroyComponent():
        super:DestroyComponent().
        
        DestroyView().
        DestroyChildPresenters().
    end method.
    
    method protected void DestroyChildPresenters():
        /** Empty the child presenters collection. Releasing the
            reference will let the GC take it's course
            (unless there's a cached or singleton component). */
        if valid-object(ChildPresenters) then
            ChildPresenters:Clear().
    end method.
    
    method protected void DestroyView():
        if valid-object(this-object:View) then
        do:
            cast(this-object:View, IComponent):DestroyComponent().
            this-object:View = ?.
        end.
    end method.
    
    method public void DestroyChildPresenter(poPresenter as IPresenter):
        ChildPresenters:Remove(poPresenter).
    end method.
    
    /* speaking to the view */
    method public void ShowView():
        if valid-object(this-object:View) then
            this-object:View:ShowView().                    
    end method.
    
    /* Show as MDI child */
    method public void ShowEmbedded(poParentView as Object):
        Assert:ArgumentNotNull(this-object:View, 'View').
        
        cast(this-object:View, IContainedView):ShowEmbedded(poParentView).
    end method.
    
    method public void HideView():
        Assert:ArgumentNotNull(this-object:View, 'View').
        
        this-object:View:HideView().
    end method.
    
    method public void ShowModal(): 
        Assert:ArgumentNotNull(this-object:View, 'View').
        
        cast(this-object:View, IContainerView):ShowModal().
    end method.
    
    method public void BeginEventLoop(poShowMode as EventLoopModeEnum):
        Assert:ArgumentNotNull(this-object:View, 'View').
        
        cast(this-object:View, IContainerView):BeginEventLoop(poShowMode).
    end method.
    
    method public void EndEventLoop():
        Assert:ArgumentNotNull(this-object:View, 'View').
        
        cast(this-object:View, IContainerView):EndEventLoop().
    end method.
    
    method public IPresenter AssociateContainedView(poView as IContainedView):
        define variable oPresenter as IPresenter no-undo.
        define variable oIterator as IIterator no-undo.
                
        oIterator = ChildPresenters:Values:Iterator().
        do while oIterator:HasNext():
            oPresenter = cast(oIterator:Next(), IPresenter).            
            
            if not oPresenter:GetClass():IsA(poView:PresenterService) then
                next.
            
            /* Get the first matching presenter that doesn't have an associated view. */
            if not oPresenter:HasView then
                leave.
            
            /* Set as unknown on each iteration so that we can be sure
               that if we have a valid reference to a presenter, that it's the 
               right one. */
            oPresenter = ?.
        end.
        
        if not valid-object(oPresenter) then
            return error new NotFoundError(poView:PresenterService:TypeName, this-object:ComponentInfo:InstanceName).
        
        oPresenter:View = cast(poView, IView).
        
        return oPresenter.
    end method.

end class.
