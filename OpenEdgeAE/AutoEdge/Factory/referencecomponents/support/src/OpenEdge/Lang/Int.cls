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
@todo(task="implement", action="complete this shadow object").
/*------------------------------------------------------------------------
    File        : Int
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 27 08:22:29 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Int.
using OpenEdge.Lang.ABLPrimitive.

class OpenEdge.Lang.Int:
    define public property Value as int64 no-undo get. private set.
    
    constructor public Int(piValue as int64):
        super().
        this-object:Value = piValue.
    end constructor.

    constructor public Int(piValue as int):
        super().
        this-object:Value = piValue.
    end constructor.
    
end class.
