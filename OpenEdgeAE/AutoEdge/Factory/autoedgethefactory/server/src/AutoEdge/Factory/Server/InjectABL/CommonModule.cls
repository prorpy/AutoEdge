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
    File        : ServerCommonModule
    Purpose     : Server-side Common bindings
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Dec 01 16:15:19 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.InjectABL.BusinessComponentModule.
using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.

using Progress.Lang.Class.

class AutoEdge.Factory.Server.InjectABL.CommonModule inherits BusinessComponentModule: 
    
    constructor public CommonModule():
        super ().
    end constructor.
    
    method override public void Load():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        
        /* the tenant manager's lifecycle matches the security manager's */
        oBindingSyntax = Bind('OpenEdge.CommonInfrastructure.Common.ITenantManager').
        oBindingSyntax
            :To('AutoEdge.Factory.Server.Common.CommonInfrastructure.TenantManager')
            :Using(InjectABLServiceProviderType)
            :InScope(Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope'),
                     ManagerScopeEnum:ServiceManager)
            :OnServerSession().

        /* scopes the security manager's lifecycle to the service manager's */
        oBindingSyntax = Bind(SecurityManager:ISecurityManagerType).
        oBindingSyntax
            :To('AutoEdge.Factory.Server.Common.CommonInfrastructure.SecurityManager')
            :Using(InjectABLServiceProviderType)
            :InScope(Class:GetClass('OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope'),
                     ManagerScopeEnum:ServiceManager)
            :OnServerSession().

        LoadEntities().
    end method.
    
    method protected void LoadEntities():
        define variable cDSName as character extent no-undo.
        define variable cConcreteDS as character extent no-undo.
        define variable cDataSourceKey as character extent no-undo.
        
        assign extent(cDSName) = 1
               extent(cConcreteDS) = extent(cDSName)
               extent(cDataSourceKey) = extent(cDSName)
               
               cDSName[1] = 'UserLoginDataSource'
               cConcreteDS[1] = 'AutoEdge.Factory.Server.Common.BusinessComponent.UserTableDS'
               cDataSourceKey[1] = 'eUserLogin'
               .
        BindBusinessEntity(
            'UserLogin', 'AutoEdge.Factory.Server.Common.BusinessComponent.UserLoginEntity',
            'UserLoginDA', 'AutoEdge.Factory.Server.Common.BusinessComponent.UserLoginDA',
            cDSName, cDataSourceKey, cConcreteDS).
            
        assign cDSName[1] = 'DealerDataSource'
               cDataSourceKey[1] = 'eDealer'
               cConcreteDS[1] = 'AutoEdge.Factory.Server.Common.BusinessComponent.DealerTableDS'.
        
        BindBusinessEntity(
            'Dealer', 'AutoEdge.Factory.Server.Common.BusinessComponent.DealerEntity',
            'DealerDA', 'AutoEdge.Factory.Server.Common.BusinessComponent.DealerDA',
            cDSName, cDataSourceKey, cConcreteDS).
    end method.
    
end class.
