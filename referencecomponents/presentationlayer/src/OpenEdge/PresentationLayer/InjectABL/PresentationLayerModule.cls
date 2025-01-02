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
    File        : PresentationLayerModule
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Apr 23 09:27:56 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope.
using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Conditions.IConditionSyntax.
using Progress.Lang.Class.

class OpenEdge.PresentationLayer.InjectABL.PresentationLayerModule inherits InjectionModule:
    constructor protected PresentationLayerModule (  ):
        super ().
    end constructor.
    
    method override public void Load():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        define variable oConditionSyntax as IConditionSyntax no-undo.
        define variable oModel as class Class extent no-undo.
        define variable oPresenter as class Class extent no-undo.
        
        oBindingSyntax = Bind('OpenEdge.PresentationLayer.Presenter.INavigationPanelPresenter').
        oBindingSyntax:To('OpenEdge.PresentationLayer.Presenter.NavigationPanelPresenter')
            :InTransientScope()
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
            .
        
        oBindingSyntax = Bind('OpenEdge.PresentationLayer.View.INavigationPanel').
        oBindingSyntax:To('OpenEdge.PresentationLayer.View.GuiForDotNet.NavigationPanel')
            :WithPropertyValue('PresenterService', Class:GetClass('OpenEdge.PresentationLayer.Presenter.INavigationPanelPresenter'))
            .
        
        @todo(task="implement", action="can potentially override WithMethodValue(AddModel with a custom constraint/api").
        
        oBindingSyntax = Bind('OpenEdge.PresentationLayer.Presenter.IUpdatePanelPresenter').
        oBindingSyntax:To('OpenEdge.PresentationLayer.Presenter.UpdatePanelPresenter')
            :InTransientScope()
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
            :WithMethodValue('AddModel',
                             Class:GetClass('OpenEdge.PresentationLayer.Model.UndoActionModel'),
                             Class:GetClass('Progress.Lang.Class'))
            .
        
        @todo(task="implement", action="Add constraint for UI types"). 
        oBindingSyntax = Bind('OpenEdge.PresentationLayer.View.IUpdatePanelView').
        oBindingSyntax:To('OpenEdge.PresentationLayer.View.GuiForDotNet.UpdatePanel')
            :WithPropertyValue('PresenterService', Class:GetClass('OpenEdge.PresentationLayer.Presenter.IUpdatePanelPresenter'))
            .
        
        /** We don't have to use an interface (although we really should).  */
        oBindingSyntax = Bind('OpenEdge.PresentationLayer.Model.UndoActionModel').
        oBindingSyntax:ToSelf()
            :InTransientScope()
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
/*            :WithPropertyValue('ServiceName','OpenEdge.BusinessComponent.Entity.IBusinessEntity')*/
            .
    end method.
    
end class.
