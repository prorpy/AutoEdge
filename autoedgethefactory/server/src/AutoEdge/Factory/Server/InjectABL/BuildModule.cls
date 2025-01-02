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
    File        : ServerBuildModule
    Purpose     : Server-side Build bindings
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Dec 01 16:15:19 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.InjectABL.BusinessComponentModule.
using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Parameters.IParameter.
using OpenEdge.Core.InjectABL.Binding.Parameters.Parameter.

using Progress.Lang.Class.

class AutoEdge.Factory.Server.InjectABL.BuildModule inherits BusinessComponentModule:
     
    constructor public BuildModule():
        super ().
    end constructor.

    /** BUSINESS WORKFLOWS **/
    method public void LoadWorkflows():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        define variable oArgs as IParameter extent no-undo.

        /* binding for webservices exposure */
        oBindingSyntax = Bind(IServiceProviderType).
        oBindingSyntax
            :Named("BuildVehicle")
            :To("AutoEdge.Factory.Server.Build.BusinessComponents.StandardBuild")
            :WithConstructorArgument(oArgs)
            :Using(InjectABLServiceProviderType).
        
        /* internal binding (for sub-IWorkFlow exposure) */
        oBindingSyntax = Bind(IWorkStepType).
        oBindingSyntax
            :Named("BuildVehicle")
            :To("AutoEdge.Factory.Server.Build.BusinessComponents.StandardBuild")
            :WithConstructorArgument(oArgs)
            :Using(InjectABLServiceProviderType). 
        
        /** BUSINESS WORKSTEPS **/
        BindWorkStep("BuildVehicle::ProcessComponents", "AutoEdge.Factory.Server.Build.BusinessComponents.ProcessComponents", "").
        BindWorkStep("BuildVehicle::AssembleChassis", "AutoEdge.Factory.Server.Build.BusinessComponents.AssembleChassis", "").
        BindWorkStep("BuildVehicle::AssembleBody", "AutoEdge.Factory.Server.Build.BusinessComponents.AssembleBody", "").
        BindWorkStep("BuildVehicle::PaintVehicle", "AutoEdge.Factory.Server.Build.BusinessComponents.PaintVehicle", "").
        BindWorkStep("BuildVehicle::AssembleInterior", "AutoEdge.Factory.Server.Build.BusinessComponents.AssembleInterior", "").
        BindWorkStep("BuildVehicle::MateAssembledComponents", "AutoEdge.Factory.Server.Build.BusinessComponents.MateAssembledComponents", "").
        /* complete vehicle has a BizLogic decorator */
        BindWorkStep("BuildVehicle::CompleteVehicleBuild",
                     "AutoEdge.Factory.Server.Build.BusinessComponents.CompleteVehicleBuild",
                     'AutoEdge.Factory.Server.Build.BusinessComponents.BizLogicCompleteVehicleBuild').
    end method.
    
    method override public void Load(  ):
        LoadWorkflows().
    end method.
    
end class.
