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
    File        : IServiceProvider
    Purpose     : Provides an interface to an object that services a request.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jun 18 12:54:30 EDT 2010
    Notes       : * This interface can be implemented on the client and the server
                    (by a Service Adapter and a Business Entity, for instance). 
                  * A ServiceAdapter is thus an <i>implementation</i> of this interface.
                  * A single service may map to different implementations depending
                    on whether the code is client or server side; on the client the 
                    implementation will call across an AppServer. On the service, it 
                    will simply call into the business components layer.
                  * Note that this interface has nothing to do with the InjectABL concept 
                    of providers. This interface is a provider of data from a service
                    (OERA Business Component).
                  * A service provider instance is responsible for interacting
                    with a single service.
  --------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.

interface OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider:  
    /** The service for which this provider is currently servicing a request. */
    define public property Service as character no-undo get. set.

    /** External method to dynamically set the service property via InjectABL */
    method public void SetService (input pcService as character).
    
    /** Services a request. The service provider will call ExecuteResponse() in 
        the ServiceMessageManager once it's done with the request and ready with 
        a response (IServiceResponse); typically this will happen in a callback of
        some sort.
        
        @param IServiceRequest An array of requests to service. */
    method public void ExecuteRequest(input poRequest as IServiceRequest extent).
    
    /** Services a request in a synchronous manner. The responses are returned from the
        ExecuteSyncRequest() call, rather than the service provider calling ExecuteResponse() in the
        ServiceMessageManager at a later time.
        
        @param IServiceRequest An array of requests to service.
        @return IServiceResponse An array of responses to the request.  */
    method public IServiceResponse extent ExecuteSyncRequest(input poRequest as IServiceRequest extent).
    
end interface.
