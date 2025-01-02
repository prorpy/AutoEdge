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
    File        : UnsupportedOperationError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Sep 02 13:46:49 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.ErrorSeverityEnum.
using OpenEdge.Core.System.UnsupportedOperationError.
using Progress.Lang.Error.

class OpenEdge.Core.System.UnsupportedOperationError inherits ApplicationError: 

    define override protected property ErrorText as longchar no-undo get. set.
    define override protected property ErrorTitle as character no-undo get. set.
    
    constructor public UnsupportedOperationError (pcArgs1 as char, pcArgs2 as char):
        this-object(?,pcArgs1,pcArgs2).       
    end constructor.

    constructor public UnsupportedOperationError (poErr as Error, pcArgs1 as char, pcArgs2 as char):
        this-object(poErr).
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.
    
    constructor public UnsupportedOperationError(poErr as Error):
        super(poErr).
        
        this-object:Severity = (ErrorSeverityEnum:Debug:Value + ErrorSeverityEnum:Warning:Value).
        this-object:ErrorTitle = 'Unsupported Operation Error'.
        this-object:ErrorText = '&1 is not supported for &2'.
    end constructor.
  
end class.
