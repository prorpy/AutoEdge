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
    File        : IBusinessEntity
    Purpose     : 
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Wed Feb 10 01:08:16 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.DataAccess.IDataAccess.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.

interface OpenEdge.BusinessComponent.Entity.IBusinessEntity:
    
    /** The DataAccess object for this entity.
        The SetDataAccess method is a workaround for the lack of dynamic
        property invocation in the ABL.     */
    define public property DataAccess as IDataAccess no-undo get. set.
    method public void SetDataAccess (input poDataAccess as IDataAccess).
    
    /** Retrieve data according to the request, and
        
        @param IFetchRequest parameter for the request (query, batch/page, etc) */
    method public void FetchData(input poRequest as IFetchRequest).   
    
    /** Response complement method for FetchData above.
        
        @param character The message id for the request/response
        @return IFetchResponse */
    method public IFetchResponse GetData(input pcMessageId as longchar).
    
    /** Commit the data to the DataSource(s) through the DataAccess object.
        
        @param ISaveRequest The Save request parameter object for this request.
        @return ISaveReponse A save request parameter object. */
    method public ISaveResponse SaveData(input poChanges as ISaveRequest).
    
    /** Defines the entity in terms of the schema that the underlying prodataset or
        temp-tables will have. This is useful for example for binding UI before any data
        is requested.
        
        @param IFetchRequest The request object for the entity definition.
        @return IFetchResponse */
    method public IFetchResponse FetchSchema(input poDefineRequest as IFetchRequest).
    
end interface.
