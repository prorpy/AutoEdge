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
    File        : ComponentKernel
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 18 10:35:43 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.Core.InjectABL.StandardKernel.
using OpenEdge.Core.InjectABL.Binding.Modules.IInjectionModuleCollection.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentKernel inherits StandardKernel: 

    constructor public ComponentKernel():
        super().
    end constructor. 
    
    constructor public ComponentKernel(poModules as IInjectionModuleCollection):
        super(poModules).
    end constructor.

    constructor protected ComponentKernel(poComponents as OpenEdge.Core.InjectABL.ComponentContainer, 
                                     poModules as IInjectionModuleCollection,
                                     poSettings as OpenEdge.Core.InjectABL.KernelSettings):
        super(poComponents, poModules, poSettings).

    end constructor.
        
    method protected override void AddComponents():
        super:AddComponents().
        
        /* Lifecycle */
        Components:Add(Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.ILifecycleStrategy'),
                       Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentLifecycleStrategy')).
    end method.
    
end class.
