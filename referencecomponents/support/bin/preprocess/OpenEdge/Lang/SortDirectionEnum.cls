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
    File        : SortDirectionEnum
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 12 17:14:09 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.SortDirectionEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.SortDirectionEnum final inherits EnumMember: 
    
    define public static property Default    as SortDirectionEnum no-undo get. private set.
    define public static property Ascending  as SortDirectionEnum no-undo get. private set.
    define public static property Descending as SortDirectionEnum no-undo get. private set.
    
    constructor static SortDirectionEnum():
        /* Values taken from INDEX-INFORMATION() method doc, for easy ABL conversion.
           Note that they start at ZERO not 1. */
        SortDirectionEnum:Ascending = new SortDirectionEnum(0, 'Ascending').
        SortDirectionEnum:Descending = new SortDirectionEnum(1, 'Descending').
        
        SortDirectionEnum:Default = SortDirectionEnum:Ascending.        
    end constructor.

    constructor public SortDirectionEnum ( input piValue as integer, input pcName as character ):
        super (input piValue, input pcName).
    end constructor.
    
    method static public SortDirectionEnum EnumFromString(pcSortDirection as character):
        define variable oMember as SortDirectionEnum no-undo.
        
        case pcSortDirection:
            when SortDirectionEnum:Ascending:ToString() then oMember = SortDirectionEnum:Ascending.
            when SortDirectionEnum:Descending:ToString() then oMember = SortDirectionEnum:Descending.
        end case.
        
        return oMember.
    end method.

    method static public SortDirectionEnum EnumFromValue(piSortDirection as integer):
        define variable oMember as SortDirectionEnum no-undo.
        
        case piSortDirection:
            when SortDirectionEnum:Ascending:Value then oMember = SortDirectionEnum:Ascending.
            when SortDirectionEnum:Descending:Value then oMember = SortDirectionEnum:Descending.
        end case.
                
        return oMember.
    end method.
                
end class.
