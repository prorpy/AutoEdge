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
    File        : QueryDefinitionEventArgs
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Sep 02 14:50:19 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.EventArgs.
using OpenEdge.Core.System.QueryElementEnum.
using OpenEdge.Core.System.QueryDefinitionOperationEnum.

class OpenEdge.Core.System.QueryDefinitionEventArgs inherits EventArgs: 

    define public property Element   as QueryElementEnum no-undo get. set.
    define public property Operation as QueryDefinitionOperationEnum no-undo get. set.
    define public property Value     as character no-undo get. set.
    
    @todo(task="implement", action="add querybuffer/filter that changed?").
    
    constructor public QueryDefinitionEventArgs():
        super().
    end constructor.
    
    constructor public QueryDefinitionEventArgs(poElement as QueryElementEnum, poOperation as QueryDefinitionOperationEnum):
        this-object(poElement, poOperation, ?).
    end constructor.
        
    constructor public QueryDefinitionEventArgs(poElement as QueryElementEnum, poOperation as QueryDefinitionOperationEnum, pcValue as char):
        this-object().
        
        this-object:Element = poElement.
        this-object:Operation = poOperation.        
        this-object:Value = pcValue.
    end constructor.
    
end class.
