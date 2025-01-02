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
    File        : PriorityEnum
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Nov 24 13:42:31 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.PriorityEnum.
using OpenEdge.Lang.EnumMember.


class OpenEdge.Lang.BPM.PriorityEnum inherits EnumMember:
    define static public property Low as PriorityEnum no-undo get. private set.     
    define static public property Medium as PriorityEnum no-undo get. private set.
    define static public property High as PriorityEnum no-undo get. private set.
    define static public property Critical as PriorityEnum no-undo get. private set.
    
    constructor static PriorityEnum():
        PriorityEnum:Low = new PriorityEnum('Low').
        PriorityEnum:Medium = new PriorityEnum('Medium').
        PriorityEnum:High = new PriorityEnum('High').
        PriorityEnum:Critical = new PriorityEnum('Critical').
    end constructor.

    constructor public PriorityEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
    method static public PriorityEnum EnumFromString(input pcName as character):
        define variable oEnum as PriorityEnum no-undo.
        
        case pcName:
            when PriorityEnum:Low:ToString() then oEnum = PriorityEnum:Low.
            when PriorityEnum:Medium:ToString() then oEnum = PriorityEnum:Medium.
            when PriorityEnum:High:ToString() then oEnum = PriorityEnum:High.
            when PriorityEnum:Critical:ToString() then oEnum = PriorityEnum:Critical.
        end case.
        return oEnum.
    end method.
    
end class.
