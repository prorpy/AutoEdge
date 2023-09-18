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
    File        : DoesNotExistError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jul 07 16:56:09 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.DoesNotExistError.
using Progress.Lang.Error.

class OpenEdge.Core.System.DoesNotExistError inherits ApplicationError: 

    define override protected property ErrorText as longchar no-undo get. set.
    define override protected property ErrorTitle as character no-undo get. set.
        
    constructor public DoesNotExistError(poErr as Error, pcArgs1 as char):
        this-object(poErr).    
        AddMessage(pcArgs1, 1).
    end constructor.
    
    constructor public DoesNotExistError(pcArgs1 as char):
        define variable oUnknown as Error no-undo.
        this-object(oUnknown,pcArgs1).
    end constructor.
    
        
    constructor public DoesNotExistError(poErr as Error):
        super (poErr).
        
        this-object:ErrorTitle = 'Does Not Exist Error'.
        this-object:ErrorText = 'The &1 specified does not exist'.
    end constructor.
    
    constructor public DoesNotExistError():
        define variable oUnknown as Error no-undo.
        this-object(oUnknown).     
    end constructor.

end class.
