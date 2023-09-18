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
    File        : StandardBusinessEntity
    Purpose     : Standard ProDataSet-based business entity 
    Syntax      : 
    Description : 
    @author pjudge
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataAccess.IDataAccess.

using OpenEdge.BusinessComponent.Entity.BusinessEntity.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Lang.CallbackNameEnum.

class OpenEdge.BusinessComponent.Entity.StandardBusinessEntity inherits BusinessEntity:
    @todo(task="implement", action="BE schema in XSD? PDS? ").
    
    define protected property DatasetHandle as handle no-undo
        get():
            if not valid-handle(this-object:DatasetHandle) then
                CopyStaticDataset(output dataset-handle DatasetHandle).
            
            return DatasetHandle.
        end.
        private set.
    
    @todo(task="refactor", action="investigate this mechanism. use property or just make Copy...() abstract?").    
    define protected property StaticDatasetHandle as handle no-undo get. private set.

    constructor public StandardBusinessEntity(input poComponentInfo as IComponentInfo,
                                              input poDAO as IDataAccess ):
        super(input poComponentInfo, input poDAO).
    end constructor.

    constructor public StandardBusinessEntity(input poComponentInfo as IComponentInfo ):
        super(input poComponentInfo).
    end constructor.

    method override public void FetchData(poRequest as IFetchRequest):
        /* We assume new data appending requests would possibly need 
           direction to MERGE or APPEND in fill */
        poRequest:SetMessageData(DatasetHandle, DataFormatEnum:ProDataSet).
        
        super:FetchData(poRequest).                        
    end method.
    
    /* Override example */
    method override public ISaveResponse SaveData(input poRequest as ISaveRequest):
        define variable oSaveResponse as ISaveResponse no-undo.
        
        /* Make any pre-save BusinessEntity validation calls here. No need for a generic
          'dataset+PreSave' name, since each BE will add its own overrides. 
          
          The DataAccess and DataSources take care of ProDataSet- and Buffer-level events/
          callbacks if needed. */
        
        oSaveResponse = super:SaveData(poRequest).
        
        /* make post-save BusinessEntity  validation calls here */
        
        return oSaveResponse.
    end method.
    
    method override public IFetchResponse FetchSchema(input poDefineRequest as IFetchRequest):
        define variable oFetchSchemaResponse as IFetchResponse no-undo.
        
        oFetchSchemaResponse = new FetchResponse(poDefineRequest).
        oFetchSchemaResponse:SetMessageData(DatasetHandle, DataFormatEnum:ProDataSet).
        
        return oFetchSchemaResponse.
    end method.
    
    method protected handle CopyStaticDataset (output dataset-handle phDataset):
        phDataset = StaticDatasetHandle.
    end method.
    
end class.
