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
    File        : ProcessInstanceStateEnum
    Purpose     : Enumeration or process instance states
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Nov 24 13:28:56 EST 2010
    Notes       : * As per Savvion documentation
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.ProcessInstanceStateEnum.
using OpenEdge.Lang.EnumMember.


class OpenEdge.Lang.BPM.ProcessInstanceStateEnum inherits EnumMember: 
    
    define static public property Created as ProcessInstanceStateEnum no-undo get. private set.
    define static public property Activated as ProcessInstanceStateEnum no-undo get. private set.
    define static public property Suspended as ProcessInstanceStateEnum no-undo get. private set.
    define static public property Complete as ProcessInstanceStateEnum no-undo get. private set.

    constructor static ProcessInstanceStateEnum():
        ProcessInstanceStateEnum:Created = new ProcessInstanceStateEnum('PI_CREATED').
        ProcessInstanceStateEnum:Activated = new ProcessInstanceStateEnum('PI_ACTIVATED').
        ProcessInstanceStateEnum:Suspended = new ProcessInstanceStateEnum('PI_SUSPENDED').
        ProcessInstanceStateEnum:Created = new ProcessInstanceStateEnum('PI_COMPLETE').
    end constructor.
    
    constructor public ProcessInstanceStateEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
    method static public ProcessInstanceStateEnum EnumFromString(input pcName as character):
        define variable oEnum as ProcessInstanceStateEnum no-undo.
        case pcName:
            when ProcessInstanceStateEnum:Created:ToString() then oEnum = ProcessInstanceStateEnum:Created.
            when ProcessInstanceStateEnum:Activated:ToString() then oEnum = ProcessInstanceStateEnum:Activated.
            when ProcessInstanceStateEnum:Suspended:ToString() then oEnum = ProcessInstanceStateEnum:Suspended.
            when ProcessInstanceStateEnum:Complete:ToString() then oEnum = ProcessInstanceStateEnum:Complete.
        end case.
        return oEnum.
    end method. 

end class.
