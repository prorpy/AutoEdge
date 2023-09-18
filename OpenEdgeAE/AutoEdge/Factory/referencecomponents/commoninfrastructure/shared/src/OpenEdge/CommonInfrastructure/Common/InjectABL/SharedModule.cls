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
    File        : CommonInfrastructureModule
    Purpose     : Binding for Common Infrastructure InjectABL services 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Mar 17 09:02:59 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.

using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Conditions.IConditionSyntax.

using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Common.InjectABL.SharedModule inherits InjectionModule: 
    
    constructor public SharedModule():
        super().
    end constructor.
    
    method override public void Load():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        define variable oConditionSyntax as IConditionSyntax no-undo.
        
        /** ServiceManager is always needed.
            
            The binding to IServiceManager can be overridden to the relevant client or 
            server-side implementation based on session.
            
            ServiceManager does not use the ComponentProvider */
        oBindingSyntax = Bind(ServiceManager:IServiceManagerType).
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Common.ServiceManager')
            :InSingletonScope()
            :WithConstructorArgument(Class:GetClass('OpenEdge.Core.InjectABL.IKernel')).
        
        /** ServiceMessageManager handles requests and responses for data. */
        oBindingSyntax = Bind(ServiceMessageManager:IServiceMessageManagerType).
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Common.ServiceMessageManager')
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
            :InScope(Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope'),
                     ManagerScopeEnum:ServiceManager).

        /** ConnectionManager handles service infrastructure connects/disconnects.
            
            It is not scoped to the ServiceManager like other managers are, because
            it needs to be started before and stopped after all the other managers,
            since they depend on it. */
        oBindingSyntax = Bind(ConnectionManager:IConnectionManagerType).
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Common.ConnectionManager')
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
            :InSingletonScope()
            .
    end method.
    
end class.
