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
    File        : IFetchResponse
    Purpose     : Interface for response for fetch request  
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Tue Feb 09 14:28:13 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponseCollection.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequestCollection.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.

interface OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse inherits IServiceResponse:
    
    /** A collection of individual table responses for this larger request */
    define public property TableResponses as ITableResponseCollection no-undo get.
    
    /** Pre-populates the table response collection from the request's tablerequests */
    method public void InitTableResponseFromRequest(input poRequestCollection as ITableRequestCollection).
    
end interface.
