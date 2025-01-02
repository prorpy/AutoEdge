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
    File        : BufferFieldMismatchError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Jul 08 10:39:12 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.BufferFieldMismatchError.
using OpenEdge.Core.System.ApplicationError.
using Progress.Lang.Error.

class OpenEdge.Core.System.BufferFieldMismatchError inherits ApplicationError: 

    define override protected property ErrorText as longchar no-undo get. set.
    define override protected property ErrorTitle as character no-undo get. set.
    
    constructor public BufferFieldMismatchError(pcArgs1 as char, pcArgs2 as char):
        this-object().
        
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.
    
    constructor public BufferFieldMismatchError():
        super().
        
        this-object:ErrorTitle = 'Buffer Field Mismatch Error'.
        this-object:ErrorText = 'The buffers being compared have different fields. Buffer 1: &1; buffer 2: &2.'.
    end constructor.


end class.
