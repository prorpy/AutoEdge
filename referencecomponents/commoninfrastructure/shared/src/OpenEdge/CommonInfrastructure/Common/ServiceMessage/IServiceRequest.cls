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
    File        : IServiceRequest
    Purpose     : General interface for a service message request.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jun 08 10:00:22 EDT 2010
    Notes       : * This interface exists to provide signatures and to clarify
                    the type of ServiceMessage being used. It is specialised by
                    operation (fetch, save).
  --------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.

interface OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest inherits IServiceMessage:  
    
end interface.
