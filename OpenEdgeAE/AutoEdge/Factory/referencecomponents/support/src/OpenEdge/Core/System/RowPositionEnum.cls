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
    File        : RowPositionEnum
    Purpose     : Enumerates the relative position of a row within a query. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Mar 20 16:53:01 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.RowPositionEnum. 
using OpenEdge.Lang.EnumMember. 

class OpenEdge.Core.System.RowPositionEnum final inherits EnumMember: 
    
    /** None means no records in the query. */
    define public static property None           as RowPositionEnum no-undo get. private set.
    define public static property IsFirst        as RowPositionEnum no-undo get. private set.
    define public static property IsLast         as RowPositionEnum no-undo get. private set.
    define public static property IsFirstAndLast as RowPositionEnum no-undo get. private set.
    define public static property NotFirstOrLast as RowPositionEnum no-undo get. private set.
    
    constructor static RowPositionEnum():
        RowPositionEnum:None = new RowPositionEnum('None').
        RowPositionEnum:IsFirst = new RowPositionEnum('IsFirst').
        RowPositionEnum:IsLast = new RowPositionEnum('IsLast').
        RowPositionEnum:IsFirstAndLast = new RowPositionEnum('IsFirstAndLast').
        RowPositionEnum:NotFirstOrLast = new RowPositionEnum('NotFirstOrLast').        
    end constructor.

    constructor public RowPositionEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
end class.
