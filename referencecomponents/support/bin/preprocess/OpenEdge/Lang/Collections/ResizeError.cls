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
    File        : ResizeError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Jun 14 11:49:06 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using Progress.Lang.Error.

class OpenEdge.Lang.Collections.ResizeError inherits ApplicationError: 
    define override protected property ErrorTitle as character no-undo get. set. 
    define override protected property ErrorText as longchar no-undo get. set.
    
    constructor public ResizeError ( ):
        define variable oUnknown as Error no-undo.
        this-object(oUnknown).
    end constructor.
    
    constructor public ResizeError (poErr as Error):
       super(poErr).      
       ErrorTitle = 'Collection Resize Error'.
       ErrorText = '&1 resize &2 than its contents'.       
    end constructor.
    
    constructor public ResizeError (poErr as Error, pcArgs1 as char, pcArgs2 as char):
        this-object(poErr).
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.
    
    constructor public ResizeError (pcArgs1 as char, pcArgs2 as char):
        define variable oUnknown as Error no-undo.
        this-object(oUnknown,pcArgs1,pcArgs2).
    end constructor.

end class.
