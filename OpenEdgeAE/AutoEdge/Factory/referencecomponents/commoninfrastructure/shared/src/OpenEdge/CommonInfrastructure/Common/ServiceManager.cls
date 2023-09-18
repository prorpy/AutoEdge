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
    File        : ServiceManager
    Purpose     : The ServiceManager provides access into a session's services.
                  Services are things that are exposed internally to the application
                  - such as a ContextManager - and also externally such as to a WebService.
                  These services can be composed of Components (and are in fact specialised
                  Components).
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 18 14:41:08 EST 2010
    Notes       : * The ServiceManager bootstraps the session.
                  * The ServiceManager is a special type, and is not itself a service
                    or component (even though other services/components usually are).
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceTypeEnum.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.IService.
using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.Component.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentCollection.
using OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.ComponentInfo.
using OpenEdge.CommonInfrastructure.Common.Component.
using OpenEdge.CommonInfrastructure.Common.IManager.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.

using OpenEdge.Core.InjectABL.Binding.IBinding.
using OpenEdge.Core.InjectABL.Binding.IBindingCollection.
using OpenEdge.Core.InjectABL.Binding.Parameters.Routine.
using OpenEdge.Core.InjectABL.Binding.Parameters.Parameter.
using OpenEdge.Core.InjectABL.Binding.Parameters.IParameter.
using OpenEdge.Core.InjectABL.ICache.
using OpenEdge.Core.InjectABL.Lifecycle.ILifecycleContext. 
using OpenEdge.Core.InjectABL.IKernel.

using OpenEdge.Core.System.NotFoundError.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Collection.
using OpenEdge.Lang.RoutineTypeEnum.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ServiceManager
        implements IServiceManager, IComponent:
    /** Use this property in lieu of having to say Class:GetClass('....IServiceManager') every time */
    define static public property IServiceManagerType as class Class no-undo get. private set.
    define static public property IServiceProviderType as class Class no-undo get. private set.
    
    /** (mandatory) Stores information about the component, such as a developer-defined instance name
        so as to be able to uniquely identify the component.   */
    define public property ComponentInfo as IComponentInfo no-undo
        get():
            if not valid-object(ComponentInfo) then
                ComponentInfo = new ComponentInfo(
                                    ServiceManager:IServiceManagerType,
                                    this-object:GetClass():TypeName,
                                    ComponentTypeEnum:ServiceManager,
                                    true).
            return ComponentInfo.                                    
        end get.
        protected set.
    
    /** InjectABL Dependency injection/Inversion of Control container. */
    define public property Kernel as IKernel no-undo get. private set.
    
    constructor static ServiceManager():
        ServiceManager:IServiceManagerType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.IServiceManager').
        ServiceManager:IServiceProviderType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider').
    end constructor.
 
    constructor public ServiceManager(input poKernel as IKernel):
        super().
        
        this-object:Kernel = poKernel.
    end constructor.
    
    /** General creation code; constructors should only be used for property setting, 
        not for any more complex wiring.  */
    method public void CreateComponent():
    end method.
    
    /** Not InitializeComponent, since the Gui for .NET uses that name already, 
       as a PRIVATE member, and we want to have only 1 IComponent interface. */
    method public void Initialize():
        StartServices().
    end method.
    
    /** General destruction code that can be called outside of the destructor
        if needed (but will also be called from within the dtor). */
    method public void DestroyComponent():
        StopServices().
    end method.
    
    method protected void StartServices():
        StartService(ConnectionManager:IConnectionManagerType).
    end method.
    
    method protected void StopServices():
        
        /* Also stop objects that are scoped to the Service Manager, although  
           any registered services should be stopped already anyway. */
        cast(Kernel:Components:Get(Class:GetClass('OpenEdge.Core.InjectABL.ICache')), ICache):Clear(this-object).
        
        StopService(GetService(ConnectionManager:IConnectionManagerType)).
    end method.
    
    /** Starts a service
        @param poServiceType component type; ignored when InjectABL used, since we work off interfaces, which are
               unique within the application.
        @param pcComponentName 
        @return An IComponent instance of the requested service */
    method public IService StartService(input poServiceType as ServiceTypeEnum,
                                        input pcServiceName as character):
        return StartService(Class:GetClass(pcServiceName)).
    end method.
    
    /** Starts a service using the InjectABL dependency injection container.
        @param poComponent The class of the service to start 
        @return An IComponent instance of the requested service */
    method public IService StartService(input poService as class Class):
        return StartService(poService, ''). 
    end method.
    
    @todo(task="question", action="do we want local caching?").
    /** Starts and returns a service as specified by a type/class. Typically
        an interface type name.
                
        @param Class The class of the service to start
        @param character An instance name for the service. InjectABL allows us
               to have mulitple bindings for a single type, specialised by instance name. 
        @return IService The running instance of the requested service */
    method public IService StartService(input poService as class Class,
                                        input pcInstanceName as character):
        return cast(StartComponent(poService, pcInstanceName), IService).
    end method.
    
    /** Returns an instance of a service, if one exists. May AutoStart
        an instance.
        @param poService The class of the service to start 
        @return An IService instance of the requested service */    
    method public IService GetService(input poService as class Class):
        return GetService(poService, '').
    end method.
    
    /** Returns an instance of a service, if one exists.
        
        @param Class The class of the service to start
        @param character An instance name for the service. InjectABL allows us
               to have mulitple bindings for a single type, specialised by instance name. 
        @return IService The running instance of the requested service */
    method public IService GetService(input poService as class Class,
                                      input pcInstanceName as character):
        define variable oService as IService no-undo.

        oService = StartService(poService, pcInstanceName).
        
        @todo(task="implement", action=" need to figure out the autostart setting").
        /*if Kernel:IsCached(poService, pcInstanceName) then
            oService = cast(Kernel:Get(poService, pcInstanceName), IService).*/
        
        return oService.
    end method.
    
    /** Stops a running service.
        @param poComponent A running component instance */
    method public void StopService(input poServiceInstance as IService):
        if valid-object(poServiceInstance) then
            StopComponent(cast(poServiceInstance, IComponent)).
    end method.
    
    method protected IComponent StartComponent(input poComponent as class Class,
                                               input pcInstanceName as character ):
        return cast(Kernel:Get(poComponent, pcInstanceName), IComponent).
    end method.
    
    method protected void StopComponent(input poComponentInstance as IComponent):
        define variable lReleased as logical no-undo.
        
        /* Component only released if cached. If it's not cached, we need to
           manually 'deactivate' it (aka DestroyComponent). */
        if valid-object(poComponentInstance) then
        do:
            lReleased = Kernel:Release(poComponentInstance).
            
            if not lReleased then
                poComponentInstance:DestroyComponent().
        end.
    end method.
    
    /** Finds (and starts if needed) an IServiceProvider which applies to the service name passed as 
        an argument. 
    
        The client-side service provider is typically a service adapter, which talks across a session boundary
        to a service interface. That service interface talks to the server-side service provider and asks it 
        to perform a task ("service a request").
       
        The server-side service provider is typically a business component such as a business entity, task or 
        workflow.
        
        @param character The name of the service for which we need to perform a request.
        @return IServiceProvider An object capable of serviving that request.   */
    method public IServiceProvider GetServiceProvider(input pcService as character):
        define variable oServiceProvider as IServiceProvider no-undo.
        
        oServiceProvider = cast(Kernel:Get(ServiceManager:IServiceProviderType, pcService), IServiceProvider).
        
        /* Make sure we've set the service name correctly. */
        if valid-object(oServiceProvider) then
            oServiceProvider:SetService(pcService).
        
        return oServiceProvider.
    end method.
    
end class.
