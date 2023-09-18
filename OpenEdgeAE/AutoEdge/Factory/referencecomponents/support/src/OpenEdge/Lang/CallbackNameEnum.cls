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
    File        : CallbackNameEnum
    Purpose     : Enumeration of ABL callback types, including ProDataSets,
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 07 13:48:05 EDT 2009
    Notes       : * Taken from ABL documentation
  ----------------------------------------------------------------------*/
routine-level on error undo , throw.

using OpenEdge.Lang.CallbackNameEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.CallbackNameEnum final inherits EnumMember:
    
    /* Web Services */
    define public static property RequestHeader  as CallbackNameEnum no-undo get. private set.
    define public static property ResponseHeader as CallbackNameEnum no-undo get. private set.
    
    /* ProDataSet, Buffer */
    define public static property BeforeFill     as CallbackNameEnum no-undo get. private set.
    define public static property AfterFill      as CallbackNameEnum no-undo get. private set.
    
    /* Buffer */
    define public static property BeforeRowFill  as CallbackNameEnum no-undo get. private set.
    define public static property AfterRowFill   as CallbackNameEnum no-undo get. private set.
    define public static property RowCreate      as CallbackNameEnum no-undo get. private set.
    define public static property RowDelete      as CallbackNameEnum no-undo get. private set.
    define public static property RowUpdate      as CallbackNameEnum no-undo get. private set.
    define public static property FindFailed     as CallbackNameEnum no-undo get. private set.
    define public static property Syncronize     as CallbackNameEnum no-undo get. private set.

    /* Query */
    define public static property OffEnd         as CallbackNameEnum no-undo get. private set.
    
    constructor static CallbackNameEnum():
        CallbackNameEnum:RequestHeader = new CallbackNameEnum('request-header').
        CallbackNameEnum:ResponseHeader = new CallbackNameEnum('response-header').
        CallbackNameEnum:BeforeFill = new CallbackNameEnum('before-fill').
        CallbackNameEnum:AfterFill = new CallbackNameEnum('after-fill').
        CallbackNameEnum:BeforeRowFill = new CallbackNameEnum('before-row-fill').
        CallbackNameEnum:AfterRowFill = new CallbackNameEnum('after-row-fill').
        CallbackNameEnum:RowCreate = new CallbackNameEnum('row-create').
        CallbackNameEnum:RowDelete = new CallbackNameEnum('row-delete').
        CallbackNameEnum:RowUpdate = new CallbackNameEnum('row-update').
        CallbackNameEnum:FindFailed = new CallbackNameEnum('find-failed').
        CallbackNameEnum:Syncronize = new CallbackNameEnum('syncronize').
        CallbackNameEnum:OffEnd = new CallbackNameEnum('OFF-END').            
    end constructor.

    constructor public CallbackNameEnum( input pcName as character ):
        super (input pcName).
    end constructor.
    
end class.
