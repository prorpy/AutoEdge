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
    File        : ModelActionEnum
    Purpose     : Enumeration of actions a model can perform.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Oct 28 12:27:03 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Common.ModelActionEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.PresentationLayer.Common.ModelActionEnum final inherits EnumMember:
    
    /* Local Actions */ 
    define static public property Add    as ModelActionEnum no-undo get. private set.
    define static public property Save   as ModelActionEnum no-undo get. private set.
    define static public property Delete as ModelActionEnum no-undo get. private set.
    
    define static public property Navigate as ModelActionEnum no-undo get. private set.
    
    /* Service actions */
    define static public property Fetch  as ModelActionEnum no-undo get. private set.
    define static public property Commit as ModelActionEnum no-undo get. private set.
    
    constructor static ModelActionEnum():
        ModelActionEnum:Add = new ModelActionEnum('Add').
        ModelActionEnum:Save = new ModelActionEnum('Save').
        ModelActionEnum:Delete = new ModelActionEnum('Delete').
        
        ModelActionEnum:Navigate = new ModelActionEnum('Navigate').
        
        ModelActionEnum:Fetch = new ModelActionEnum('Fetch').
        ModelActionEnum:Commit = new ModelActionEnum('Commit').
    end constructor.

    constructor public ModelActionEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
end class.
