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
    File        : TableRequestTypeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    @author hdaniels
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum. 
using OpenEdge.Lang.EnumMember. 

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum final inherits EnumMember: 
    define public static property Default as TableRequestTypeEnum no-undo get. private set.
    
    define public static property First    as TableRequestTypeEnum no-undo get. private set.
    define public static property Next     as TableRequestTypeEnum no-undo get. private set.
    define public static property Prev     as TableRequestTypeEnum no-undo get. private set.
    define public static property Last     as TableRequestTypeEnum no-undo get. private set.
    
    /** position request resort/reopen to current key */
    define public static property Position as TableRequestTypeEnum no-undo get. private set.
    
    /** search in resultset */
    define public static property Search   as TableRequestTypeEnum no-undo get. private set.
    
    /** For child tables = default defined by dataset relation (to not use All on a child 
        requires advanced data request management). Logically this is possibly more of a 
        jointype, but it will never conflict with the other options */
    define public static property All      as TableRequestTypeEnum no-undo get. private set.
    
    /** For dataset requests, only get this table, and none of its child tables (unless they have
        their own TableRequests) */
    define public static property NoChildren as TableRequestTypeEnum no-undo get. private set.
    
    /** No Operation. We do nothing for this table. This state may be set when the client has all
        records, or for some other reason. */
    define public static property None     as TableRequestTypeEnum no-undo get. private set.
    
    constructor static TableRequestTypeEnum():
         TableRequestTypeEnum:First    = new TableRequestTypeEnum('First').
         TableRequestTypeEnum:Next     = new TableRequestTypeEnum('Next').
         TableRequestTypeEnum:Prev     = new TableRequestTypeEnum('Prev').
         TableRequestTypeEnum:Last     = new TableRequestTypeEnum('Last').
         TableRequestTypeEnum:Position = new TableRequestTypeEnum('Position').
         TableRequestTypeEnum:Search   = new TableRequestTypeEnum('Search').
         TableRequestTypeEnum:All      = new TableRequestTypeEnum('All').
         TableRequestTypeEnum:NoChildren = new TableRequestTypeEnum('NoChildren').
         TableRequestTypeEnum:None     = new TableRequestTypeEnum('None').
                  
         TableRequestTypeEnum:Default  = TableRequestTypeEnum:All.
    end constructor.
    
    constructor public TableRequestTypeEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
    method static public TableRequestTypeEnum EnumFromString(input pcName as character):
        define variable oEnum as TableRequestTypeEnum no-undo.
        
        case pcName:
            when TableRequestTypeEnum:First:ToString() then oEnum = TableRequestTypeEnum:First.
            when TableRequestTypeEnum:Next:ToString() then oEnum = TableRequestTypeEnum:Next.
            when TableRequestTypeEnum:Prev:ToString() then oEnum = TableRequestTypeEnum:Prev.
            when TableRequestTypeEnum:Last:ToString() then oEnum = TableRequestTypeEnum:Last.
            when TableRequestTypeEnum:Position:ToString() then oEnum = TableRequestTypeEnum:Position.
            when TableRequestTypeEnum:Search:ToString() then oEnum = TableRequestTypeEnum:Search.
            when TableRequestTypeEnum:All:ToString() then oEnum = TableRequestTypeEnum:All.
            when TableRequestTypeEnum:None:ToString() then oEnum = TableRequestTypeEnum:None.            
        end case.
        
        return oEnum.
    end method.
        
end class.
