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
    File        : OrderModule
    Purpose     : Client-side Order bindings
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Dec 01 16:15:19 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Parameters.IParameter.
using OpenEdge.Core.InjectABL.Binding.Parameters.Parameter.
using OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule.

using Progress.Lang.Class.

class AutoEdge.Factory.Client.InjectABL.OrderModule inherits InjectionModule: 
    define protected property IServiceProviderType as class Class no-undo get. set.
    
    constructor public OrderModule (  ):
        super ().
        
        assign IServiceProviderType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider').
    end constructor.
    
    method protected void LoadServices():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        
        /* Bind as a service adapter. the server-side bindings will translate this into a IServiceProvider
           object capable of doing something useful. */
        oBindingSyntax = Bind(IServiceProviderType).
        oBindingSyntax
            :Named('Order')
            :To('OpenEdge.CommonInfrastructure.Client.AppServerServiceAdapter')
            :WithPropertyValue('AppServerName', 'asAutoEdgeTheFactory')
            :OnThinClientSession().

        /* Bind as a service adapter. the server-side bindings will translate this into a IServiceProvider
           object capable of doing something useful. */
        oBindingSyntax = Bind(IServiceProviderType).
        oBindingSyntax
            :Named('OrderCapture')
            :To('OpenEdge.CommonInfrastructure.Client.AppServerServiceAdapter')
            :WithPropertyValue('AppServerName', 'asAutoEdgeTheFactory')
            :OnThinClientSession().

        /* Bind as a service adapter. the server-side bindings will translate this into a IServiceProvider
           object capable of doing something useful. */
        oBindingSyntax = Bind(IServiceProviderType).
        oBindingSyntax
            :Named('VehicleOptions')
            :To('OpenEdge.CommonInfrastructure.Client.AppServerServiceAdapter')
            :WithPropertyValue('AppServerName', 'asAutoEdgeTheFactory')
            :OnThinClientSession().
    end method.
    
    method protected void LoadUI():
        /* Use local variables oBS as bug workaround */
        define variable oBindingSyntax as IBindingSyntax no-undo.
        oBindingSyntax = Bind('OpenEdge.CommonInfrastructure.Common.IApplicationStart').
        oBindingSyntax
            :To('AutoEdge.Factory.Client.Order.PresentationLayer.DealerReview')
            :OnThinClientSession().
    end method.
    
    method override public void Load(  ):
        LoadServices().
        LoadUI().
    end method.
    
end class.
