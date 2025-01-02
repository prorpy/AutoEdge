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
    File        : IService
    Purpose     : Interface definition for base OERA Service
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Apr 15 14:59:18 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.

interface OpenEdge.CommonInfrastructure.Common.IService /* inherits IComponent */:
      
    /** (mandatory) Stores a reference to the session's Service Manager */
    define public property ServiceManager as IServiceManager no-undo get.
    
end interface.
