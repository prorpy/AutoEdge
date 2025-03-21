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
    File        : ServerConnectionError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 20 15:09:25 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using Progress.Lang.Error.

class OpenEdge.CommonInfrastructure.Common.Connection.ServerConnectionError inherits ApplicationError: 
    define override protected property ErrorText as longchar no-undo get. set.
    define override protected property ErrorTitle as character no-undo get. set.
            
    constructor public ServerConnectionError(pcArgs1 as char, pcArgs2 as longchar):
        this-object(?, pcArgs1, pcArgs2).
    end constructor.
    
    constructor public ServerConnectionError (poErr as Error, pcArgs1 as char, pcArgs2 as longchar):
        this-object(poErr).
        
        AddMessage(pcArgs1, 1).
        AddMessage(string(pcArgs2), 2).
    end constructor.
    
    constructor public ServerConnectionError (poErr as Error):
        super(poErr).
        
        ErrorText = 'Unable to connect to server &1 with connection string &2'.
        ErrorTitle = 'Server Connection Error'.
    end constructor.
    
    constructor public ServerConnectionError():
        define variable oUnknown as Error no-undo.
        this-object(oUnknown).
    end constructor.
    
end class.
