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
    File        : InvalidCallError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 13 12:38:37 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.

class OpenEdge.Core.System.InvalidCallError inherits ApplicationError:
        
    define override protected property ErrorTitle as character no-undo get. set.
    define override protected property ErrorText as longchar no-undo get. set.
    
    constructor public InvalidCallError():
        super().
        
        ErrorTitle = 'Invalid Call Error'.
        ErrorText = 'Invalid &1 call: &2'.
    end constructor.
    
    constructor public InvalidCallError(pcArgs1 as char, pcArgs2 as char):
        this-object().
        
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.
    
end class.
