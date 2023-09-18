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
/*-----------------------------------------------------------------------
    File        : ObjectOutputError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Dec 21 14:03:44 EST 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.Util.ObjectOutputError.
using Progress.Lang.Error.

class OpenEdge.Core.Util.ObjectOutputError inherits ApplicationError:
    define static public property STREAM as character no-undo init 'stream' get.
    define static public property TYPE as character no-undo init 'type' get.
    define static public property API_CALL as character no-undo init 'API call' get.
    define static public property ARRAY_SIZE as character no-undo init 'array size' get.
    define static public property DB_REFS as character no-undo init 'references to database fields' get.
    
    define override protected property ErrorTitle as character no-undo get. set. 
    define override protected property ErrorText as longchar no-undo get. set.
    
    constructor public ObjectOutputError ( ):
        define variable oUnknown as Error no-undo.
        this-object(oUnknown).
    end constructor.
    
    constructor public ObjectOutputError (poErr as Error):
       super(poErr).      
       ErrorTitle = 'Object Output Error'.
       ErrorText = 'Invalid &1 encountered. Expecting &2'.       
    end constructor.
   
    constructor public ObjectOutputError (poErr as Error, pcArgs1 as char, pcArgs2 as char):
        this-object(poErr).
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.
    
    constructor public ObjectOutputError (pcArgs1 as char, pcArgs2 as char):
        define variable oUnknown as Error no-undo.
        this-object(oUnknown,pcArgs1,pcArgs2).
    end constructor.
    
end class.
