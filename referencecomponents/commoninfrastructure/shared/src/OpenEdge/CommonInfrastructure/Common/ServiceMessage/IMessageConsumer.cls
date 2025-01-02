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
    File        : IMessageConsumer
    Purpose     : Interface defined for a message consumer: someone who acts on
                  a response from a service request
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Apr 26 14:55:42 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.

interface OpenEdge.CommonInfrastructure.Common.ServiceMessage.IMessageConsumer:
    
    /** Method called upon completion of the action for the ServiceMessage. 
        The actual action type is contained within the response.
        
        @param IServiceResponse The response to the request.      */
    method public void ReceiveMessageResponse(input poResponse as IServiceResponse).
    
end interface.
