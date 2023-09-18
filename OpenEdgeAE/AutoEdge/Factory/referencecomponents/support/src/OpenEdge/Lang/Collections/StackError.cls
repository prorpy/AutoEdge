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
    File        : StackError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jan 05 14:44:07 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.StackError.
using Progress.Lang.AppError.

class OpenEdge.Lang.Collections.StackError inherits AppError: 
    define static public property OVERFLOW as character init 'Stack overflow' no-undo get.
    define static public property UNDERFLOW as character init 'Stack underflow' no-undo get.
    define static public property RESIZE as character init 'Stack resize smaller than contents' no-undo get.
    
    constructor public StackError():
        super().
    end constructor.

    constructor public StackError (pcArg1 as char):
        this-object().
        AddMessage(pcArg1, 1).
    end constructor.
    
end class.
