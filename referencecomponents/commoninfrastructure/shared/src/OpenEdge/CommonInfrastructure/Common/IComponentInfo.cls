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
    File        : IComponentInfo
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Feb 23 13:49:11 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum.

using Progress.Lang.Class.

interface OpenEdge.CommonInfrastructure.Common.IComponentInfo:
    /** The Service type that this service implements. This could be 
        the concrete type, or one of the interfaces the component 
        implements.
        
        Typically defaults to the concrete type when the component is
        not started as a service (or interface by InjectABL).   */
    define public property Service as class Class no-undo get.
    
    /** Whether the component is auto-started when it is requested, or whether
        it should be explicitly started first.  */
    define public property AutoStart as logical no-undo get.
    
    /** Instance name for the running component. Optionally a unique value, although
        often (usually?) just the typename of the component instance . */
    define public property InstanceName as character no-undo get.
    
    /** The component type (per ComponentTypeEnum) */
    define public property ComponentType as ComponentTypeEnum no-undo get. set.
    
end interface.
