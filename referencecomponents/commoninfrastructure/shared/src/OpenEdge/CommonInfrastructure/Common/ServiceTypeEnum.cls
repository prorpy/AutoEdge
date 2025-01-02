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
    File        : ServiceTypeEnum
    Purpose     : Lists known components in reference components. These are
                  the common/shared service types.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 18 14:26:28 EST 2010
    Notes       : * Not final because we have client- and server-specific
                    service types.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum.

class OpenEdge.CommonInfrastructure.Common.ServiceTypeEnum inherits ComponentTypeEnum:
    
    /** Common Infrastructure */
    define public static property Manager as ServiceTypeEnum no-undo get. private set.
    
    /** Non-specified application services (shouldn't be many of these though) */
    define public static property AppService as ServiceTypeEnum no-undo get. private set.
    
    constructor static ServiceTypeEnum ():
        ServiceTypeEnum:Manager = new ServiceTypeEnum('Manager').
        ServiceTypeEnum:AppService = new ServiceTypeEnum('AppService').
    end constructor.
    
    constructor public ServiceTypeEnum (pcName as character):
        super(pcName).
    end constructor.
    
end class.
