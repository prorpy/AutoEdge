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
    File        : AgentConnection
    Purpose     : 
    Syntax      : 
    Description : AgentConnection object : this object lives for the lifespan of 
                  an AppServer connection (stateless AppServer).
    @author pjudge
    Created     : Fri Jun 04 15:00:56 EDT 2010
    Notes       : * The instance's lifespan is managed by as AppServer connect/disconnect
                    procedures.
                  * Note that this is meaninless for StateFree AppServers.
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.AgentConnection.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Map.

class OpenEdge.Lang.AgentConnection:
    /** Information regarding connection lifespan. */    
    define public property ActiveSince as datetime-tz no-undo get. private set.
    
    /** A unique identifier for this connection. */
    define public property Id as character no-undo get. private set.
    
    /* A collection of user-defined properties */
    define public property ConnectionProperties as IMap no-undo get. private set.
    
    define static public property Instance as AgentConnection no-undo
        get():
            if not valid-object(Instance) then
                Instance = new AgentConnection().
            return Instance.
        end get.
        private set.
    
    
    constructor private AgentConnection():
        assign this-object:Id = guid(generate-uuid)
               ConnectionProperties = new Map()
               ActiveSince = now.
    end constructor.
    
end class.
