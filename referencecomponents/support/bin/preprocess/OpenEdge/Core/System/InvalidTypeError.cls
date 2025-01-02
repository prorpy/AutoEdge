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
    File        : InvalidTypeError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Jul 08 10:10:06 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.InvalidTypeError.
using Progress.Lang.Error.

class OpenEdge.Core.System.InvalidTypeError inherits ApplicationError: 

    define override protected property ErrorText as longchar no-undo get. set.
    define override protected property ErrorTitle as character no-undo get. set.
        
    constructor public InvalidTypeError(pcArgs1 as char, pcArgs2 as char, pcArgs3 as char):
        define variable oUnknown as Error no-undo.
        this-object(?,pcArgs1,pcArgs2,pcArgs3).
    end constructor.
    
    constructor public InvalidTypeError(poErr as Error, pcArgs1 as char, pcArgs2 as char, pcArgs3 as char):
        this-object(poErr).
        
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
        AddMessage(pcArgs3, 3).
    end constructor.
    
    constructor public InvalidTypeError(poErr as Error):
        super(poErr).

        ErrorText = 'The &1 &2 does not implement &3'.
        ErrorTitle = 'Invalid Type Error'.
    end constructor.
    
    constructor public InvalidTypeError():
        define variable oUnknown as Error no-undo.
        this-object(oUnknown).
    end constructor.
    
end class.
