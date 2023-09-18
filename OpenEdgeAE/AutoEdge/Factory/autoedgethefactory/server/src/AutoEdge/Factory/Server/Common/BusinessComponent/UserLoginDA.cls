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
    File        : UserLoginDA
    Purpose     : DataAccess object for User Logins
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 22 10:08:00 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.DataSource.IDataSource.
using OpenEdge.DataAccess.StandardDataAccess.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.CallbackNameEnum.

class AutoEdge.Factory.Server.Common.BusinessComponent.UserLoginDA inherits StandardDataAccess: 

    constructor public UserLoginDA(input poDataSources as IMap ):
        super (input poDataSources).
    end constructor.
        
    constructor public UserLoginDA (  ):
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
        
        /* field */
        cFieldName[1] = pcSourceField.
        
        /* table */
        case pcSourceTable:
            when 'eUserLogin' then cFieldName[2] = 'ApplicationUser'.
        end case.

        return cFieldName.
    end method.
    
    /** Add ABL callbacks to a buffer handle for an action.
    
        @param handle The buffer on which to attach the callback
        @param ServiceMessageActionEnum The action being performed.
        
        @return Logical value indicating whether there are any callbacks set for the buffer */
    method override protected void AddBufferCallbacks(input phBuffer as handle,
                                                      input poServiceMessageAction as ServiceMessageActionEnum,
                                                      input poDataSource as IDataSource):
            /* Example below */
            case poServiceMessageAction:
                when ServiceMessageActionEnum:FetchData then
                do:
                     phBuffer:set-callback(CallbackNameEnum:AfterRowFill:ToString(), 'AfterRowFillCallback', this-object).
                end.
            end case.
    end method.
    
    method override protected void RemoveBufferCallbacks(input phBuffer as handle,
                                                         input poServiceMessageAction as ServiceMessageActionEnum,
                                                         input poDataSource as IDataSource):
        super:RemoveBufferCallbacks(phBuffer, poServiceMessageAction, poDataSource).
            case poServiceMessageAction:
                when ServiceMessageActionEnum:FetchData then
                do:
                     phBuffer:set-callback(CallbackNameEnum:AfterRowFill:ToString(), ?, this-object).
                end.
            end case.
    end method.    
    
    method public void AfterRowFillCallback(input dataset-handle phEntity):
        define variable hBuffer as handle no-undo.
        define variable hField as handle no-undo.
        define variable hDBBuffer as handle no-undo.
        
        hBuffer = phEntity:get-buffer-handle('eUserLogin').
        hField = hBuffer:buffer-field('UserCategory').
        
        /* user category */
        hDBBuffer = hBuffer:data-source:get-source-buffer(1).
        
        if hDBBuffer::CustomerId ne '' then
            hField:buffer-value = hField:buffer-value + ',Customer'. 
        if hDBBuffer::EmployeeId ne '' then
            hField:buffer-value = hField:buffer-value + ',Employee'. 
        if hDBBuffer::SupplierId ne '' then
            hField:buffer-value = hField:buffer-value + ',Supplier'. 
        hField:buffer-value = left-trim(hField:buffer-value, ',').
    end method.
        
end class.
