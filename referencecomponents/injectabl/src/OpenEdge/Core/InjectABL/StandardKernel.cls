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
    File        : StandardKernel
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Mar 03 11:23:20 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Binding.Modules.IInjectionModuleCollection.
using OpenEdge.Core.InjectABL.KernelBase.
using OpenEdge.Core.InjectABL.ComponentContainer.
using OpenEdge.Core.InjectABL.KernelSettings.
using Progress.Lang.Class.

class OpenEdge.Core.InjectABL.StandardKernel inherits KernelBase: 
    
    method protected override void AddComponents():
        /* these are mappings */
        
        /* Cache */
        Components:Add(Class:GetClass('OpenEdge.Core.InjectABL.ICache'), 
                       Class:GetClass('OpenEdge.Core.InjectABL.Cache')).

        /* Pipeline */
        Components:Add(Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.IPipeline'),
                       Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.StandardPipeline')).

        Components:Add(Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.ILifecycleStrategy'),
                       Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.PropertyInjectionLifecycleStrategy')).
        Components:Add(Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.ILifecycleStrategy'),
                       Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.MethodInjectionLifecycleStrategy')).
        
        /* Binding */        
        Components:Add(Class:GetClass('OpenEdge.Core.InjectABL.Binding.IBindingResolver'), 
                       Class:GetClass('OpenEdge.Core.InjectABL.Binding.StandardBindingResolver')).
    end method.
    
    constructor public StandardKernel():
        super().
    end constructor.

    constructor public StandardKernel(poModules as IInjectionModuleCollection):
        super(poModules).
    end constructor.
        
    constructor protected StandardKernel (poComponents as ComponentContainer,
                                          poModules as IInjectionModuleCollection,
                                          poSettings as KernelSettings):
        super(poComponents, poModules, poSettings).
    end constructor.
    
end class.
