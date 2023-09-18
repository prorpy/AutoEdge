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
    File        : VehicleOptionsDA
    Purpose     : 
    Syntax      : 
    Description : 
    @author  pjudge
    Created     : Thu Jan 20 14:22:03 EST 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataAccess.StandardDataAccess.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.CallbackNameEnum.

class AutoEdge.Factory.Server.Order.BusinessComponent.VehicleOptionsDA inherits StandardDataAccess: 

	constructor public VehicleOptionsDA (input poDataSources as IMap):
		super (input poDataSources).
	end constructor.

	constructor public VehicleOptionsDA (  ):
		super ().
	end constructor.
	
    /** Resolves a field name from the Business Entity into a physical field name in the
        DataSource. The values passed in here are usually taken from the ITableRequest that's
        part of the IServiceRequest.
        
        @param character A table name in the business entity (not resolved)
        @param character A field name in the business entity
        @return character[] The [db.][table.]field name in the datasource. If the array has an extent
                of 1, then it's a field in the input table; if 2 then in the same Db.
                [1] = FieldName
                [2] = TableName
                [3] = DB Name               */
    method override public character extent ResolveFieldName (input pcSourceTable as character, input pcSourceField as character):
        define variable cFieldName as character extent 2 no-undo.
        
        /* defaults  */
        assign cFieldName[1] = pcSourceField
               cFieldName[2] = substring(pcSourceTable, 2).
        
        /* table */
        case pcSourceTable:
            when 'eVehicle' then
            do:
                /* table name */
                cFieldName[2] = 'Item'.
                
                case pcSourceField:
                    when 'VehicleItemNum' then cFieldName[1] = 'ItemNum'.
                    when 'VehicleName' then cFieldName[1] = 'ItemName'. 
                end.
            end.
        end case.
        
        return cFieldName.
    end method.	
    
end class.
