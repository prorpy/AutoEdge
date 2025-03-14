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
    File        : SerializationModeEnum
    Purpose     : Enumeration of WRITE-*() and READ-*() method modes.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Oct 12 14:17:26 EDT 2010
    Notes       : * Based on the ABL documentation 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.SerializationModeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.SerializationModeEnum inherits EnumMember final:

    define static public property File as SerializationModeEnum  no-undo get. private set.
    define static public property Stream as SerializationModeEnum  no-undo get. private set.
    define static public property StreamHandle as SerializationModeEnum  no-undo get. private set.
    define static public property Memptr as SerializationModeEnum  no-undo get. private set.
    define static public property Handle as SerializationModeEnum  no-undo get. private set.
    define static public property LongChar as SerializationModeEnum  no-undo get. private set.
    
    constructor static SerializationModeEnum():
        SerializationModeEnum:File = new SerializationModeEnum('File').
        SerializationModeEnum:Stream = new SerializationModeEnum('Stream').
        SerializationModeEnum:StreamHandle = new SerializationModeEnum('Stream-Handle').
        SerializationModeEnum:Memptr = new SerializationModeEnum('Memptr').
        SerializationModeEnum:Handle = new SerializationModeEnum('Handle').
        SerializationModeEnum:LongChar = new SerializationModeEnum('Longchar').
    end constructor.
    
    constructor public SerializationModeEnum(input pcName as character):
        super (input pcName).
    end constructor.     

    method static public SerializationModeEnum EnumFromString(input pcWriteMode as character):
        define variable oMember as SerializationModeEnum no-undo.
        
        case pcWriteMode:
            when SerializationModeEnum:File:ToString()         then oMember = SerializationModeEnum:File.
            when SerializationModeEnum:Stream:ToString()       then oMember = SerializationModeEnum:Stream.
            when SerializationModeEnum:StreamHandle:ToString() then oMember = SerializationModeEnum:StreamHandle.
            when SerializationModeEnum:Memptr:ToString()       then oMember = SerializationModeEnum:Memptr.
            when SerializationModeEnum:Handle:ToString()       then oMember = SerializationModeEnum:Handle.
            when SerializationModeEnum:LongChar:ToString()     then oMember = SerializationModeEnum:LongChar.
        end case.
                
        return oMember.   
    end method.
    
end class.
