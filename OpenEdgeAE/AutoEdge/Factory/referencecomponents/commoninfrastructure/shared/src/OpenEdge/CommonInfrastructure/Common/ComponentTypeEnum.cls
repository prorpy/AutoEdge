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
    Purpose     : Enumeration of common component types.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 20 10:49:14 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum inherits EnumMember: 
    /** Non-specified application components (shouldn't be many of these though) */
    define public static property ApplicationComponent as ComponentTypeEnum no-undo get. private set.
    
    /** This component is a Service, and so is better described with the ServiceTypeEnum
        members (Common, Client & Server). */
    define public static property Service as ComponentTypeEnum no-undo get. private set.

    /** This component is the ServiceManager for the session. It's not a service nor a manager, strictly speaking. */
    define public static property ServiceManager as ComponentTypeEnum no-undo get. private set.

    constructor static ComponentTypeEnum():
        ComponentTypeEnum:ApplicationComponent = new ComponentTypeEnum('ApplicationComponent').
        ComponentTypeEnum:Service = new ComponentTypeEnum('Service').
        ComponentTypeEnum:ServiceManager = new ComponentTypeEnum('ServiceManager').
    end constructor.
    
    constructor public ComponentTypeEnum(pcName as character):
        super(pcName).
    end constructor.
    
end class.
