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
    File        : ArgumentError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 13 12:43:45 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using Progress.Lang.Error.

class OpenEdge.Core.System.ArgumentError inherits ApplicationError: 

    define override protected property ErrorTitle as character no-undo get. private set. 
    define override protected property ErrorText as longchar no-undo get. private set.

    constructor public ArgumentError(poInnerError as Error):
        super(poInnerError).
        
        ErrorTitle = 'Argument Error'.
        ErrorText = '&1 (name &2)'.
    end constructor.
    
    constructor public ArgumentError(pcArgs1 as char, pcArgs2 as char):
        this-object(?, pcArgs1, pcArgs2).
    end constructor.
    
    constructor public ArgumentError(poInnerError as Error, pcArgs1 as char, pcArgs2 as char):
        this-object(poInnerError).
        
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.

end class.
