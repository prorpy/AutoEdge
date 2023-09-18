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
    Purpose     : Server-side enumeration of service types, used by the ServiceManager
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Feb 22 11:34:26 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Server.ServiceTypeEnum.

class OpenEdge.CommonInfrastructure.Server.ServiceTypeEnum inherits OpenEdge.CommonInfrastructure.Common.ServiceTypeEnum: 
    
    define public static property BusinessEntity    as ServiceTypeEnum no-undo get. private set.
    define public static property BusinessTask      as ServiceTypeEnum no-undo get. private set.
    define public static property BusinessWorkflow  as ServiceTypeEnum no-undo get. private set.
    
    constructor static ServiceTypeEnum():
        ServiceTypeEnum:BusinessEntity   = new ServiceTypeEnum('BusinessEntity').
        ServiceTypeEnum:BusinessTask     = new ServiceTypeEnum('BusinessTask').
        ServiceTypeEnum:BusinessWorkflow = new ServiceTypeEnum('BusinessWorkflow').
    end constructor.
    
    constructor public ServiceTypeEnum(input pcName as character):
        super(pcName).
    end constructor.
    
end class.
