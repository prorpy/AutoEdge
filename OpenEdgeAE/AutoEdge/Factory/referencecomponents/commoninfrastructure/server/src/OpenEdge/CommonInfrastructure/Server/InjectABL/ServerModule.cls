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
    Notes       : * This is a server-side-only module (by virtue of Propath/naming),
                    and so the OnServerSession() binding is probably not strictly necessary.
                    However, it's useful to have, for clarity if nothing else.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.

using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Conditions.IConditionSyntax.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Server.InjectABL.ServerModule inherits InjectionModule: 
    
    constructor public ServerModule():
        super().
    end constructor.
    
    method override public void Load():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        
        /**  SecurityManager handles context, login, etc. Its lifecycle scoped to the service manager's.
             We have a client manager, a server manager and a service adapter for getting from the
             former to the latter, across session boundaries. 

             Server-side binding will also need to be done per-application, since we currently have no 
             generic auth code */
        /* example only
        oBindingSyntax = Bind(SecurityManager:ISecurityManagerType).
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Server.SecurityManager')
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
            :InScope(Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope'),
                     ManagerScopeEnum:ServiceManager)
            :OnServerSession().
        */
        
        /* scopes the tenant manager's lifecycle to the security manager's */
        oBindingSyntax = Bind('OpenEdge.CommonInfrastructure.Common.ITenantManager').
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Server.TenantManager')
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
            :InScope(Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope'),
                     ManagerScopeEnum:SecurityManager)
            :OnServerSession().
    end method.
    
end class.
