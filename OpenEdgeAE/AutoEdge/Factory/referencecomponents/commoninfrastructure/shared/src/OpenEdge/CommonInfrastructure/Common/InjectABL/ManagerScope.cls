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
    File        : ManagerScope
    Purpose     : InjectABL scopes for Common Infrastructure Managers, per manager.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 18 11:51:06 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope.
using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.

using OpenEdge.Core.InjectABL.Lifecycle.StandardScope.
using OpenEdge.Core.InjectABL.Lifecycle.StandardScopeEnum.
using OpenEdge.Core.InjectABL.Lifecycle.ILifecycleContext.

using OpenEdge.Lang.Assert.
using Progress.Lang.Object.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope inherits StandardScope:
    method static public Object GetScope(poContext as ILifecycleContext,
                                         poScope as ManagerScopeEnum):
        define variable oScope as Object no-undo.
        
        Assert:ArgumentIsValidType(poScope:Name). 
        oScope = poContext:Kernel:Get(Class:GetClass(poScope:Name)).
        
        return oScope.
    end method.
    
end class.
