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
    File        : CommonModule
    Purpose     : AutoEdge|TheFactory Shared bindings
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Dec 01 16:15:19 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.

using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using Progress.Lang.Class.

class AutoEdge.Factory.Client.InjectABL.CommonModule inherits InjectionModule: 
    define protected property IServiceProviderType as class Class no-undo get. set.
    define protected property InjectABLServiceProviderType as class Class no-undo get. set.
    
    constructor public CommonModule (  ):
        super ().
        assign IServiceProviderType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider')
               InjectABLServiceProviderType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ServiceProvider').
    end constructor.
    
    method override public void Load():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        
        /* scopes the security manager's lifecycle to the service manager's */
        oBindingSyntax = Bind(SecurityManager:ISecurityManagerType).
        oBindingSyntax
            :To('AutoEdge.Factory.Client.Common.CommonInfrastructure.SecurityManager')
            :Using(InjectABLServiceProviderType)
            :InScope(Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope'),
                     ManagerScopeEnum:ServiceManager)
            :OnThinClientSession().
        
        LoadServices().        
    end method.
    
    method protected void LoadServices():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        
    end method.
    
end class.
