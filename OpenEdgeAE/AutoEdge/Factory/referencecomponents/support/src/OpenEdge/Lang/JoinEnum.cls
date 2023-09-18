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
    File        : JoinEnum
    Purpose     : Enumeration of ABL join types 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 12 15:03:46 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.JoinEnum final inherits EnumMember:
     
    define public static property None as JoinEnum no-undo get. private set.
    define public static property And  as JoinEnum no-undo get. private set.
    define public static property Or   as JoinEnum no-undo get. private set.
    define public static property Not  as JoinEnum no-undo get. private set.
    
    constructor static JoinEnum():
        JoinEnum:None = new JoinEnum('none').
        JoinEnum:And  = new JoinEnum('and').
        JoinEnum:Or   = new JoinEnum('or').
        JoinEnum:Not  = new JoinEnum('not').
    end constructor.

    constructor public JoinEnum ( input pcName as character ):
        super (input pcName).
    end constructor.

    method static public JoinEnum EnumFromString (input pcName as character):
        define variable oEnum as JoinEnum no-undo.
        
        case pcName:
            when JoinEnum:None:ToString() then oEnum = JoinEnum:None.
            when JoinEnum:And:ToString() then oEnum = JoinEnum:And.
            when JoinEnum:Or:ToString() then oEnum = JoinEnum:Or.
            when JoinEnum:Not:ToString() then oEnum = JoinEnum:Not.
        end case.
        
        return oEnum.
    end method.
    
end class.
