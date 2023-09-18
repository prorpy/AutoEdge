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
    File        : ComponentTypeEnum
    Purpose     : Enumeration of server-side component types
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 20 12:12:37 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Server.ComponentTypeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.CommonInfrastructure.Server.ComponentTypeEnum inherits OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum:
     
    define public static property DataAccessObject  as ComponentTypeEnum no-undo get. private set.
    define public static property DataSourceObject  as ComponentTypeEnum no-undo get. private set.
    
    constructor static ComponentTypeEnum():
        ComponentTypeEnum:DataAccessObject = new ComponentTypeEnum('DataAccessObject').
        ComponentTypeEnum:DataSourceObject = new ComponentTypeEnum('DataSourceObject').
    end constructor.

    constructor public ComponentTypeEnum(pcName as character ):
        super(pcName).
    end constructor.

end class.
