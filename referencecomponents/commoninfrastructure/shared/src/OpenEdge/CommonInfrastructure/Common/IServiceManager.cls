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
    File        : IServiceManager
    Purpose     : The ServiceManager provides access into a session's services.
                  Services are things that are exposed internally to the application
                  - such as a ContextManager - and also externally such as to a WebService.
                  These services can be composed of Components (and are in fact specialised
                  Components).
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 18 14:22:47 EST 2010
    Notes       : * The ServiceManager bootstraps the session.
                  * The ServiceManager is a special type, and is not itself a service
                    or component (even though other services/components usually are).               
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.IService.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.ServiceTypeEnum.
using OpenEdge.Core.InjectABL.IKernel.
using Progress.Lang.Class.

interface OpenEdge.CommonInfrastructure.Common.IServiceManager /* inherits IManager */:
    /** (mandatory) Contains the InjectABL kernel that's responsible for mapping 
        services (in the sense of Interfaces) to concrete instances. */
    define public property Kernel as IKernel no-undo get.
    
    /** General creation code; constructors should only be used for property setting, 
        not for any more complex wiring.  */
    method public void CreateComponent().
    
    /** Not InitializeComponent, since the Gui for .NET uses that name already, 
       as a PRIVATE member, and we want to have only 1 IComponent interface. */
    method public void Initialize().
    
    /** General destruction code that can be called outside of the destructor
        if needed (but will also be called from within the dtor). */
    method public void DestroyComponent().
    
    @todo(doc="change sig in uml/doc ").
    @todo(doc="Add all below to OERA UML").
    
    /** Starts and returns a running instance of a service
        
        @param ServiceTypeEnum The component type; ignored when InjectABL used,
               since we work off interfaces, which are unique within the application.
        @param character The name of the service (interface name in InjectABL)
        @return IService An IService instance of the requested service */
    method public IService StartService(input poServiceType as ServiceTypeEnum,
                                        input pcServiceName as character).
    
    /** Starts and returns a service as specified by a type/class. Typically
        an interface type name.
        
        @param Class The class of the service to start 
        @return IService The running instance of the requested service */
    method public IService StartService(input poService as class Class).
    
    /** Starts and returns a service as specified by a type/class. Typically
        an interface type name.
                
        @param Class The class of the service to start
        @param character An instance name for the service. InjectABL allows us
               to have mulitple bindings for a single type, specialised by instance name. 
        @return IService The running instance of the requested service */
    method public IService StartService(input poService as class Class,
                                        input pcInstanceName as character).
    
    /** Returns an instance of a service, if one exists. May AutoStart
        an instance.
        @param poService The class of the service to start 
        @return An IService instance of the requested service */
    method public IService GetService(input poService as class Class).

    /** Returns an instance of a service, if one exists.
        
        @param Class The class of the service to start
        @param character An instance name for the service. InjectABL allows us
               to have mulitple bindings for a single type, specialised by instance name. 
        @return IService The running instance of the requested service */
    method public IService GetService(input poService as class Class,
                                      input pcInstanceName as character).
    
    /** Stops a running service.
        @param poServiceInstance A running service instance */
    method public void StopService(input poServiceInstance as IService).
    
    /** Finds (and starts if needed) an IServiceProvider which applies to the service name passed as 
        an argument. 
    
        The client-side service provider is typically a service adapter, which talks across a session boundary
        to a service interface. That service interface talks to the server-side service provider and asks it 
        to perform a task ("service a request").
       
        The server-side service provider is typically a business component such as a business entity, task or 
        workflow.
        
        @param character The name of the service for which we need to perform a request.
        @return IServiceProvider An object capable of serviving that request.   */
    method public IServiceProvider GetServiceProvider(input pcService as character).
    
end interface.
