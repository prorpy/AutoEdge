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
    File        : ComponentLifecycleStrategy
    Purpose     : Lifecycle management strategy for IComponent objects
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Mar 05 08:00:21 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponent.

using OpenEdge.Core.InjectABL.Lifecycle.LifecycleStrategy.
using OpenEdge.Core.InjectABL.Lifecycle.ILifecycleContext.

using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentLifecycleStrategy inherits LifecycleStrategy: 
    
    constructor public ComponentLifecycleStrategy ():
        super().
    end constructor.
    
    method override public void Activate(poContext as ILifecycleContext, poInstance as Object):
        define variable lIsComponent as logical no-undo.
        
        super:Activate(poContext, poInstance).
        
        lIsComponent = type-of(poInstance, IComponent).
        if lIsComponent then
        do:
            dynamic-invoke(poInstance, 'CreateComponent').
            dynamic-invoke(poInstance, 'Initialize').
        end.
                    
    end method.
    
    method override public void Deactivate(poContext as ILifecycleContext, poInstance as Object):
        define variable lIsComponent as logical no-undo.
        
        super:Deactivate(poContext, poInstance).
        
        lIsComponent = type-of(poInstance, IComponent).
        if lIsComponent then
            dynamic-invoke(poInstance, 'DestroyComponent').
    end method.
    
end class.
