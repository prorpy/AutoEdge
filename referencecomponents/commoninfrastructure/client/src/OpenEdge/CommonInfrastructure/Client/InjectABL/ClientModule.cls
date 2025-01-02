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
    Notes       : * This is a client-side-only module (by virtue of Propath/naming),
                    and so the OnClientSession() binding is probably not strictly necessary.
                    However, it's useful to have.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.SecurityManager.

using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.
using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Conditions.IConditionSyntax.
using Progress.Lang.Class.

class OpenEdge.CommonInfrastructure.Client.InjectABL.ClientModule inherits InjectionModule: 
    
    constructor public ClientModule():
        super().
    end constructor.
    
    method override public void Load():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        define variable oConditionSyntax as IConditionSyntax no-undo.
        
        /**  SecurityManager handles context, login, etc. Its lifecycle scoped to the service manager's.
             We have a client manager, a server manager and a service adapter for getting from the
             former to the latter, across session boundaries. 

             Server-side binding is done per-application, since we currently have no generic auth code */
        oBindingSyntax = Bind(SecurityManager:ISecurityManagerType).
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Client.SecurityManager')
            :Using('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider')
            :InScope(Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope'),
                     ManagerScopeEnum:ServiceManager)
            :OnThinClientSession().
             
        /* We can either bind the whole manager as a service, or we can bind the individual services.
           We have an example of both here. */
        oBindingSyntax = Bind('OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider').
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Client.SecurityManagerServiceAdapter')
            :Named(SecurityManager:ISecurityManagerType:TypeName)
            :OnThinClientSession()
            :WithPropertyValue('AppServerName', 'asAutoEdgeTheFactory')
            :WithPropertyValue('Service', SecurityManager:ISecurityManagerType:TypeName).
        
        oBindingSyntax = Bind('OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider').
        oBindingSyntax
            :To('OpenEdge.CommonInfrastructure.Client.SecurityManagerServiceAdapter')
            :Named('SecurityManager.UserLogin')
            :OnThinClientSession()
            :WithPropertyValue('AppServerName', 'asAutoEdgeTheFactory')
            :WithPropertyValue('Service', 'SecurityManager.UserLogin').
    
    end method.
    
end class.
