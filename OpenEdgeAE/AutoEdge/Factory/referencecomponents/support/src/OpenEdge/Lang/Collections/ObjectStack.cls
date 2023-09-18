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
    File        : ObjectStack
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jan 05 13:50:43 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.ObjectStack.
using OpenEdge.Lang.Collections.Stack.
using Progress.Lang.Object.

class OpenEdge.Lang.Collections.ObjectStack inherits Stack:
        
    constructor public ObjectStack (poArray as Object extent):
        super(poArray).
    end constructor.
    
    constructor public ObjectStack (piDepth as integer):
        super(piDepth).
    end constructor.

    constructor public ObjectStack():
    end constructor.
    
    method public void Push(poValue as Object):
        super:ObjectPush(poValue).
    end method.
    
    method public Object Peek():
        return super:ObjectPeek().
    end method.
    
    method public Object Pop():
        return super:ObjectPop().
    end method.
    
    method public Object extent ToArray():
        return super:ObjectToArray().
    end method.
    
end class.
