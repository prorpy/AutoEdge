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
    File        : IntegerStack
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jan 05 13:50:43 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.IntegerStack.
using OpenEdge.Lang.Collections.Stack.

class OpenEdge.Lang.Collections.IntegerStack inherits Stack:
        
    constructor public IntegerStack(piDepth as integer):
        super (piDepth).
    end constructor.
    
    constructor public IntegerStack():
    end constructor.
    
    method public void Push(piValue as integer):
        PrimitivePush(string(piValue)).
    end method.
    
    method public integer Peek():
        return integer(PrimitivePeek()).
    end method.
    
    method public integer Pop():
        return integer(PrimitivePop()).
    end method.
    
end class.
