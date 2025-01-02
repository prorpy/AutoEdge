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
    File        : ServiceProvider
    Purpose     : InjectABL provider for objects of type IService.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 07 14:41:39 EDT 2010
    Notes       : * The Create() override adds the common IServiceManager and
                    IComponentInfo overrides to the constructor arguments.                    
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentProvider.

using OpenEdge.Core.InjectABL.Lifecycle.ILifecycleContext.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider inherits ComponentProvider:
    
    constructor public ServiceProvider(poClass as class Class):
        super(poClass).
    end constructor.
    
    method override public Object Create(input poContext as ILifecycleContext):
        define variable oService as Object no-undo.
        
        oService = super:Create(poContext).
        
        /* Service:IServiceType. */
        Assert:ArgumentIsType(oService, Class:GetClass('OpenEdge.CommonInfrastructure.Common.IService')).
        
        return oService.
    end method.
    
end class.
