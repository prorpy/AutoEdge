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
    File        : QueryElementEnum
    Purpose     : Enumeration of elements/component parts of a query 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Sep 02 15:01:39 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.QueryElementEnum.
using OpenEdge.Lang.FlagsEnum.

class OpenEdge.Core.System.QueryElementEnum final inherits FlagsEnum:
    
    define public static property Buffer    as QueryElementEnum no-undo get. private set.
    define public static property Join      as QueryElementEnum no-undo get. private set.
    define public static property Filter    as QueryElementEnum no-undo get. private set.
    define public static property Sort      as QueryElementEnum no-undo get. private set.
    
    constructor static QueryElementEnum():
        QueryElementEnum:Buffer = new QueryElementEnum(1).
        QueryElementEnum:Join = new QueryElementEnum(2).
        QueryElementEnum:Filter = new QueryElementEnum(4).
        QueryElementEnum:Sort = new QueryElementEnum(8).
    end constructor.

    constructor public QueryElementEnum ( input piValue as integer ):
        super (input piValue).
    end constructor.
    
end class.
