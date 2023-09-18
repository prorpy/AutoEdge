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
    File        : ManagerScopeEnum
    Purpose     : CommonInfrastructure Scope enumeration. Used with 
                  OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScope.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Jun 07 09:03:40 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum.
using OpenEdge.Core.InjectABL.Lifecycle.StandardScopeEnum.

class OpenEdge.CommonInfrastructure.Common.InjectABL.ManagerScopeEnum inherits StandardScopeEnum:
     
    define static public property ServiceManager as ManagerScopeEnum no-undo get. private set.
    define static public property SecurityManager as ManagerScopeEnum no-undo get. private set.
    define static public property ConnectionManager as ManagerScopeEnum no-undo get. private set.
    
    constructor static ManagerScopeEnum():
        ManagerScopeEnum:ServiceManager  = new ManagerScopeEnum(OpenEdge.CommonInfrastructure.Common.ServiceManager:IServiceManagerType:TypeName).
        ManagerScopeEnum:SecurityManager = new ManagerScopeEnum(OpenEdge.CommonInfrastructure.Common.SecurityManager:ISecurityManagerType:TypeName).
        ManagerScopeEnum:ConnectionManager = new ManagerScopeEnum(OpenEdge.CommonInfrastructure.Common.ConnectionManager:IConnectionManagerType:TypeName).
    end constructor.
    
    constructor private ManagerScopeEnum(input pcName as character):
        super(pcName).
    end constructor.
    
end class.
