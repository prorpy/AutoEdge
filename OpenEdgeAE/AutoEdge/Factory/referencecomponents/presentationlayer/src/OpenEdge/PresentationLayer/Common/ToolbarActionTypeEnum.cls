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
    File        : ToolbarActionTypeEnum
    Purpose     : Enumeration of toolbar action types. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri May 01 16:39:43 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Common.ToolbarActionTypeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.PresentationLayer.Common.ToolbarActionTypeEnum final inherits EnumMember:
    
    define public static property Default   as ToolbarActionTypeEnum no-undo get. private set.
    define public static property Label     as ToolbarActionTypeEnum no-undo get. private set.
    define public static property Separator as ToolbarActionTypeEnum no-undo get. private set.
    define public static property Group     as ToolbarActionTypeEnum no-undo get. private set.
    define public static property Toggle    as ToolbarActionTypeEnum no-undo get. private set.
    define public static property Option    as ToolbarActionTypeEnum no-undo get. private set.
    define public static property Launch    as ToolbarActionTypeEnum no-undo get. private set.
    define public static property Event     as ToolbarActionTypeEnum no-undo get. private set.
    
    constructor static ToolbarActionTypeEnum():
        ToolbarActionTypeEnum:Label = new ToolbarActionTypeEnum('Label').
        ToolbarActionTypeEnum:Separator = new ToolbarActionTypeEnum('Separator').
        ToolbarActionTypeEnum:Group = new ToolbarActionTypeEnum('Group').
        ToolbarActionTypeEnum:Toggle = new ToolbarActionTypeEnum('Toggle').
        ToolbarActionTypeEnum:Option = new ToolbarActionTypeEnum('Option').
        ToolbarActionTypeEnum:Launch = new ToolbarActionTypeEnum('Launch').
        ToolbarActionTypeEnum:Event = new ToolbarActionTypeEnum('Event').
        
        ToolbarActionTypeEnum:Default = ToolbarActionTypeEnum:Event.
    end constructor.

    constructor public ToolbarActionTypeEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
            
end class.
