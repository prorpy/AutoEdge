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
    File        : ActionStateEnum
    Purpose     : Enumeration for various complementary states for actions.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Mar 25 14:29:10 EDT 2009
    Notes       : 
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Common.ActionStateEnum.
using OpenEdge.Lang.FlagsEnum.

class OpenEdge.PresentationLayer.Common.ActionStateEnum inherits FlagsEnum:
    
    define public static property Enable  as ActionStateEnum no-undo get. private set.
    define public static property Disable as ActionStateEnum no-undo get. private set.
    define public static property View    as ActionStateEnum no-undo get. private set.
    define public static property Hide    as ActionStateEnum no-undo get. private set.
    
    constructor static ActionStateEnum():
        ActionStateEnum:Enable = new ActionStateEnum(1).
        ActionStateEnum:Disable = new ActionStateEnum(2).
        ActionStateEnum:Hide = new ActionStateEnum(4).
        ActionStateEnum:View = new ActionStateEnum(8).
    end constructor.
    
    constructor public ActionStateEnum (input piValue as integer):
        super(input piValue).
    end constructor.
        
end class.
