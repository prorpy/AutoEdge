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
    File        : ObjectInputError
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Dec 21 14:03:44 EST 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.Util.ObjectInputError.
using Progress.Lang.Error.

class OpenEdge.Core.Util.ObjectInputError inherits ApplicationError:    
    define static public property TYPE as character no-undo init 'type' get.
    define static public property BYTE as character no-undo init 'byte' get.
    define static public property STREAM_VERSION as character no-undo init 'stream version' get.
    define static public property BYTE_ORDER as character no-undo init 'byte order' get.
    define static public property MD5_VALUE as character no-undo init 'r-code MD5 value' get.
    define static public property VALUE as character no-undo init 'value' get.
    define static public property CLASS_REFERENCE as character no-undo init 'class reference' get.
    define static public property ABL_VERSION as character no-undo init 'ABL version' get.
    define static public property API_CALL as character no-undo init 'API call' get.
    
    define override protected property ErrorTitle as character init 'Object Input Error' no-undo get. set. 
    define override protected property ErrorText as longchar init 'Invalid &1 encountered. Expecting &2 at position &3' no-undo get. set.
    
    constructor public ObjectInputError (pcArg1 as char, pcArg2 as char, pcArg3 as char):
        define variable oUnknown as Error no-undo.
        this-object(oUnknown,pcArg1,pcArg2,pcArg3).
    end constructor.
   
    constructor public ObjectInputError (poErr as Error, pcArg1 as char, pcArg2 as char, pcArg3 as char):
        this-object(poErr).
        AddMessage(pcArg1, 1).
        AddMessage(pcArg2, 2).
        AddMessage(pcArg3, 3).
    end constructor.
    
    constructor public ObjectInputError():
        define variable oUnknown as Error no-undo.
        this-object(oUnknown).
    end constructor.
    
    constructor public ObjectInputError(poErr as Error):
       super(poErr).
       ErrorTitle = 'Object Input Error'.
       ErrorText = 'Invalid &1 encountered. Expecting &2 at position &3'.
    end constructor.
        
end class.
