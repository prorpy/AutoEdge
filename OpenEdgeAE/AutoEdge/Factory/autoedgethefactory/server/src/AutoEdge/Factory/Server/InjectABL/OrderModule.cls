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
    File        : ServerOrderModule
    Purpose     : Server-side Order bindings
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Dec 01 16:15:19 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.InjectABL.BusinessComponentModule.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Parameters.IParameter.
using OpenEdge.Core.InjectABL.Binding.Parameters.Parameter.

using Progress.Lang.Class.

class AutoEdge.Factory.Server.InjectABL.OrderModule inherits BusinessComponentModule: 
    
    constructor public OrderModule (  ):
        super ().
    end constructor.

    /** BUSINESS WORKFLOWS **/
    method protected void LoadEntities():
        define variable cDSName as character extent no-undo.
        define variable cConcreteDS as character extent no-undo.
        define variable cDataSourceKey as character extent no-undo.
        
        /* General order */
        assign extent(cDSName) = ?
               extent(cConcreteDS) = ?
               extent(cDataSourceKey) = ?
        
               extent(cDSName) = 5
               extent(cConcreteDS) = extent(cDSName)
               extent(cDataSourceKey) = extent(cDSName)
               
               cDSName[1] = 'OrderDataSource'
               cConcreteDS[1] = 'AutoEdge.Factory.Server.Order.BusinessComponent.OrderTableDS'
               cDataSourceKey[1] = 'eOrder'
               
               cDSName[2] = 'ComponentItemsDataSource'
               cDataSourceKey[2] = 'eComponentItem'
               cConcreteDS[2] = 'AutoEdge.Factory.Server.Order.BusinessComponent.ComponentItemTableDS'
               
               cDSName[3] = 'OrderLineDataSource'
               cDataSourceKey[3] = 'eOrderLine'
               cConcreteDS[3] = 'AutoEdge.Factory.Server.Order.BusinessComponent.OrderLineTableDS'
               
               cDSName[4] = 'FinishedItemDataSource'
               cDataSourceKey[4] = 'eFinishedItem'
               cConcreteDS[4] = 'AutoEdge.Factory.Server.Order.BusinessComponent.FinishedItemTableDS'

               cDSName[5] = 'ItemDataSource'
               cDataSourceKey[5] = 'eItem'
               cConcreteDS[5] = 'AutoEdge.Factory.Server.Order.BusinessComponent.ItemTableDS'
               .

        BindBusinessEntity(
            'Order', 'AutoEdge.Factory.Server.Order.BusinessComponent.OrderEntity',
            'OrderDA', 'AutoEdge.Factory.Server.Order.BusinessComponent.OrderDA',
            cDSName, cDataSourceKey, cConcreteDS).

        /* Vehicle Brand data */
        assign extent(cDSName) = ?
               extent(cConcreteDS) = ?
               extent(cDataSourceKey) = ?
        
               extent(cDSName) = 3
               extent(cConcreteDS) = extent(cDSName)
               extent(cDataSourceKey) = extent(cDSName)
               
               cDSName[1] = 'VehicleDataSource'
               cDataSourceKey[1] = 'eVehicle'
               cConcreteDS[1] = 'AutoEdge.Factory.Server.Order.BusinessComponent.VehicleDataSource'
               
               cDSName[2] = 'ItemDataSource'
               cDataSourceKey[2] = 'eItem'
               cConcreteDS[2] = 'AutoEdge.Factory.Server.Order.BusinessComponent.ItemTableDS'
               
               cDSName[3] = 'ItemOptionsDataSource'
               cDataSourceKey[3] = 'eItemOption'
               cConcreteDS[3] = 'AutoEdge.Factory.Server.Order.BusinessComponent.ItemOptionTableDS'
               .
        
        BindBusinessEntity(
            'VehicleOptions', 'AutoEdge.Factory.Server.Order.BusinessComponent.VehicleOptionsEntity',
            'VehicleOptionsDA', 'AutoEdge.Factory.Server.Order.BusinessComponent.VehicleOptionsDA',
            cDSName, cDataSourceKey, cConcreteDS).
    end method.
    
    method override public void Load(  ):
        LoadEntities().
    end method.
    
end class.
