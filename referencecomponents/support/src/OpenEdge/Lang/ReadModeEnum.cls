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
    Append        : ReadModeEnum
    Purpose     : Enumeration of READ-*() method modes.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Oct 12 14:26:03 EDT 2010
    Notes       : * Based on the ABL documentation
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.ReadModeEnum. 
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.ReadModeEnum inherits EnumMember final: 
    
    define static public property Append as ReadModeEnum  no-undo get. private set.
    define static public property Empty as ReadModeEnum  no-undo get. private set.
    define static public property Merge as ReadModeEnum  no-undo get. private set.
    define static public property Replace as ReadModeEnum  no-undo get. private set.
    define static public property Default as ReadModeEnum  no-undo get. private set.
    
    constructor static ReadModeEnum():
        ReadModeEnum:Append = new ReadModeEnum('Append').
        ReadModeEnum:Empty = new ReadModeEnum('Empty').
        ReadModeEnum:Merge = new ReadModeEnum('Empty-Handle').
        ReadModeEnum:Replace = new ReadModeEnum('Replace').
        ReadModeEnum:Default = ReadModeEnum:Merge. 
    end constructor.
    
    constructor public ReadModeEnum(input pcName as character):
        super (input pcName).
    end constructor.     

    method static public ReadModeEnum EnumFromString(pcReadMode as character):
        define variable oMember as ReadModeEnum no-undo.
        
        case pcReadMode:
            when ReadModeEnum:Append:ToString()  then oMember = ReadModeEnum:Append.
            when ReadModeEnum:Empty:ToString()   then oMember = ReadModeEnum:Empty.
            when ReadModeEnum:Merge:ToString()   then oMember = ReadModeEnum:Merge.
            when ReadModeEnum:Replace:ToString() then oMember = ReadModeEnum:Replace.
        end case.
        
        return oMember.   
    end method.
end class.
