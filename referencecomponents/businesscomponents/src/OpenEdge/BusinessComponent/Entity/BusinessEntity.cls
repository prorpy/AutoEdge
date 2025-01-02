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
    File        : BusinessEntity
    Purpose     : General Business entity class. The Business Entity is the primary
                  unit of business logic and data in the OERA.
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Fri Aug 14 23:38:08 EDT 2009
    Notes       : * This class is abstract class since the Business Entity's 
                    data store could be a prodataset, temp-table or some other 
                    construct.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.Entity.BusinessEntity.
using OpenEdge.BusinessComponent.Entity.IBusinessEntity.
using OpenEdge.DataAccess.IDataAccess.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.

using OpenEdge.CommonInfrastructure.Common.Service.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Lang.Assert.
using Progress.Lang.Class.

class OpenEdge.BusinessComponent.Entity.BusinessEntity abstract inherits Service 
        implements IBusinessEntity:
    
    define static public property IBusinessEntityType as class Class no-undo get. private set.            
    
    define public property DataAccess as IDataAccess no-undo get. set.
    method public void SetDataAccess (input poDataAccess as IDataAccess):
        DataAccess = poDataAccess.
    end method.
    
    constructor static BusinessEntity():        
        BusinessEntity:IBusinessEntityType = Class:GetClass('OpenEdge.BusinessComponent.Entity.IBusinessEntity').
    end constructor.

    constructor public BusinessEntity(input poComponentInfo as IComponentInfo):
        super(poComponentInfo).
    end constructor.
        
    constructor public BusinessEntity(input poComponentInfo as IComponentInfo,
                                      input poDAO as IDataAccess):
        super(poComponentInfo).
        
        Assert:ArgumentNotNull(poDAO, 'Data Access Object').
        DataAccess = poDAO.
    end constructor.
    
    method public void FetchData(poRequest as IFetchRequest):
        DataAccess:FetchData(poRequest).
    end method.
    
    /** Response complement method for FetchData above.
        
        @param character The message id for the request/response
        @return IFetchResponse */
    method public IFetchResponse GetData(input pcMessageId as longchar):
        return DataAccess:GetData(pcMessageId).
    end method.
    
    method public ISaveResponse SaveData(poChanges as ISaveRequest):
        return DataAccess:SaveData(poChanges).
    end method.
    
    /* Abstract since we don't know the data store (temp-table, prodataset, etc). */
    method abstract public IFetchResponse FetchSchema(input poDefineRequest as IFetchRequest).
    
end class.
