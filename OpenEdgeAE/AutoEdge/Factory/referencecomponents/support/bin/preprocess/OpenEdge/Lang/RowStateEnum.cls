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
    File        : RowStateEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Aug 25 11:17:38 EDT 2010
    Notes       : * Derived from ABL Decoumentation
     
    Table 58:   Row state values   Compiler constant  Value  Description  
                ROW-UNMODIFIED  0  The row was not modified.  
                ROW-DELETED  1  The row was deleted.  
                ROW-MODIFIED  2  The row was modified.  
                ROW-CREATED  3  The row was created.  

    
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.EnumMember.
using OpenEdge.Lang.RowStateEnum.

class OpenEdge.Lang.RowStateEnum inherits EnumMember final:

    define static public property Unmodified    as RowStateEnum no-undo get. private set.
    define static public property Deleted       as RowStateEnum no-undo get. private set.
    define static public property Modified      as RowStateEnum no-undo get. private set.
    define static public property Created       as RowStateEnum no-undo get. private set.     

    constructor static RowStateEnum():
        RowStateEnum:Unmodified = new RowStateEnum(0, 'ROW-UNMODIFIED').
        RowStateEnum:Deleted = new RowStateEnum(1, 'ROW-DELETED').
        RowStateEnum:Modified = new RowStateEnum(2, 'ROW-MODIFIED').
        RowStateEnum:Created = new RowStateEnum(3, 'ROW-CREATED').
    end constructor.
             
    constructor public RowStateEnum ( input piValue as integer, input pcName as character ):
        super (input piValue, input pcName).
    end constructor.
    
    method static public RowStateEnum ValueToEnum(input piValue as integer):
        define variable oRowStateEnum as RowStateEnum no-undo.
        
        case piValue:
            when RowStateEnum:Deleted:Value then oRowStateEnum = RowStateEnum:Deleted.
            when RowStateEnum:Modified:Value then oRowStateEnum = RowStateEnum:Modified.
            when RowStateEnum:Created:Value then oRowStateEnum = RowStateEnum:Created.              
            otherwise 
                oRowStateEnum = RowStateEnum:Unmodified.
        end case.
        
        return oRowStateEnum.
    end method. 

    method static public RowStateEnum NameToEnum(input pcName as character):
        define variable oRowStateEnum as RowStateEnum no-undo.
        
        case pcName:
            when RowStateEnum:Unmodified:ToString() then oRowStateEnum = RowStateEnum:Unmodified.
            when RowStateEnum:Deleted:ToString() then oRowStateEnum = RowStateEnum:Deleted.
            when RowStateEnum:Modified:ToString() then oRowStateEnum = RowStateEnum:Modified.
            when RowStateEnum:Created:ToString() then oRowStateEnum = RowStateEnum:Created.            
        end case.
        
        return oRowStateEnum.
    end method.

end class.
