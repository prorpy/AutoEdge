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
    File        : QueryTypeEnum
    Purpose     : Query type enumeration - each, first etc 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 07 10:27:16 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.QueryTypeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.QueryTypeEnum inherits EnumMember:
    
    define public static property Default as QueryTypeEnum no-undo get. private set.
    define public static property Each    as QueryTypeEnum no-undo get. private set.
    define public static property First   as QueryTypeEnum no-undo get. private set.
    define public static property Last    as QueryTypeEnum no-undo get. private set.
    
    constructor static QueryTypeEnum():
        QueryTypeEnum:Each  = new QueryTypeEnum('Each').
        QueryTypeEnum:First = new QueryTypeEnum('First').
        QueryTypeEnum:Last  = new QueryTypeEnum('Last').
        
        QueryTypeEnum:Default = QueryTypeEnum:Each.
    end constructor.

    constructor public QueryTypeEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
    method public static QueryTypeEnum EnumFromString(pcQueryType as char):        
        define variable oMember as QueryTypeEnum no-undo.
        
        case pcQueryType:
            when QueryTypeEnum:Each:ToString() then oMember = QueryTypeEnum:Each. 
            when QueryTypeEnum:First:ToString() then oMember = QueryTypeEnum:First.
            when QueryTypeEnum:Last:ToString() then oMember = QueryTypeEnum:Last.
        end.
        
        return oMember.
    end method.
    
end class.
