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
/* *------------------------------------------------------------------------
    File        : ITableOwner
    Purpose     :        
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Aug 04 11:28:51 EDT 2009
    Notes       : * An implementation of this interface is required by an IQuery object
                    in order to create a buffer (or buffers) for the query to use. 
  ---------------------------------------------------------------------- */

interface OpenEdge.Core.System.ITableOwner:
    
    /** @param character A table or buffer name. The implementer will
        know how to interpret the name. The name passed in is the name
        that the query will use together with its IQueryDefinition.
        
        @return A buffer handle corresponding to the requested name. */
    method public handle GetTableHandle (input pcTableName as character).
    
end interface.
