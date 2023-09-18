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
/*------------------------------------------------------------------------
    File        : CharacterStack
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jan 05 13:50:43 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.CharacterStack.
using OpenEdge.Lang.Collections.Stack.

class OpenEdge.Lang.Collections.CharacterStack inherits Stack:
    
    constructor public CharacterStack(pcArray as character extent):
        super(pcArray).
    end constructor.
    
    constructor public CharacterStack(piDepth as integer):
        super(piDepth).
    end constructor.
        
    constructor public CharacterStack():
        super().
    end constructor.
    
    method public void Push(pcValue as character):
        PrimitivePush(pcValue).
    end method.
    
    method public character Peek():
        return PrimitivePeek().
    end method.
    
    method public character Pop():
        return PrimitivePop().
    end method.
    
    method public character extent ToArray():
        return PrimitiveToArray().
    end method.
    
end class.
