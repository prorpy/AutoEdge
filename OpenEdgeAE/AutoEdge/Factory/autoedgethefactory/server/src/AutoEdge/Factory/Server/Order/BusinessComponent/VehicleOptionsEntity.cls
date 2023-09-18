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
    File        : VehicleOptionsEntity
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Jan 20 14:01:28 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.Entity.StandardBusinessEntity.
using OpenEdge.DataAccess.IDataAccess.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.

class AutoEdge.Factory.Server.Order.BusinessComponent.VehicleOptionsEntity inherits StandardBusinessEntity:

    /* Each eVehicle is an Item, actually */
    define temp-table eVehicle no-undo
        field Brand as character
        field ItemId as character
        field VehicleName as character
        field Description as character
        field Price as decimal
        field VehicleType as character
        index idx1 as primary unique ItemId
        .
    
    define temp-table eItem no-undo
        field ItemId as character
        field ItemNum as integer
        field ItemName as character
        field ItemType as character
        field Description as character
        field Price as decimal
        index idx1 as primary unique ItemNum
        .
    
    define temp-table eItemOption no-undo
        field ItemId as character
        field ItemNum as integer
        field ChildItemId as character
        field ChildItemNum as integer
        field ChildType as character
        field Quantity as decimal
        field StandardOption as logical
        index idx2 ChildItemNum
        .
    
    define dataset dsVehicleOptions for eVehicle, eItem, eItemOption
        /* get the options for the vehicles */
        data-relation for eVehicle, eItemOption relation-fields (ItemId, ItemId)
        /* single-level series of items and options */
        data-relation for eItemOption, eItem relation-fields (ChildItemId, ItemId)
        .
    
    constructor public VehicleOptionsEntity(input poComponentInfo as IComponentInfo ):
        super (input poComponentInfo).
    end constructor.

    constructor public VehicleOptionsEntity ( input poComponentInfo as IComponentInfo, input poDAO as IDataAccess ):
        super (input poComponentInfo, input poDAO).
    end constructor.

    method override protected handle CopyStaticDataset (output dataset-handle phDataset):
        phDataset = dataset dsVehicleOptions:handle.  
    end method.
    
end class.
