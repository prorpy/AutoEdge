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
/* ------------------------------------------------------------------------
    File        : ComponentInfo
    Purpose     : Information about a specific component instance
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Feb 23 13:56:35 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum.

using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.ComponentInfo implements IComponentInfo:
    
    /** Use this property in lieu of having to say Class:GetClass('....IServiceManager') every time */
    define static public property IComponentInfoType as class Class no-undo get. private set. 
    
    /** The Service type that this service implements. This could be 
        the concrete type, or one of the interfaces the component 
        implements.
        
        Typically defaults to the concrete type when the component is
        not started as a service (or interface by InjectABL).   */
    define public property Service as class Class no-undo get. private set.
    
    /** Instance name for the running component. Optionally a unique value, although
        often (usually?) just the typename of the component instance . */
    define public property InstanceName as character no-undo
        get():
            if InstanceName  eq ? or InstanceName eq '' then
                InstanceName = Service:TypeName.
            
            return InstanceName. 
        end get.
        private set.
    
    /** The component type (per ComponentTypeEnum) */
    define public property ComponentType as ComponentTypeEnum no-undo get. set.
    
    /** Whether the component is auto-started when it is requested, or whether
        it should be explicitly started first. The default is TRUE. */
    define public property AutoStart as logical no-undo get. private set.
    
    constructor static ComponentInfo():
        ComponentInfo:IComponentInfoType = Class:GetClass('OpenEdge.CommonInfrastructure.Common.IComponentInfo').
    end constructor.
    
    constructor public ComponentInfo(poService as class Class):
        this-object(poService,
                    poService:TypeName,
                    ComponentTypeEnum:ApplicationComponent,
                    true).         
    end constructor.

    constructor public ComponentInfo(poService as class Class, pcInstanceName as character):
        this-object(poService,
                    pcInstanceName,
                    ComponentTypeEnum:ApplicationComponent,
                    true).         
    end constructor.
    
    constructor public ComponentInfo(input poService as class Class,
                                     input pcInstanceName as character,
                                     input poComponentType as ComponentTypeEnum,
                                     input plAutoStart as logical):
        Assert:ArgumentNotNull(poService, 'Service').
        Assert:ArgumentNotNull(poComponentType, 'Component type').
        
        assign InstanceName = pcInstanceName
               ComponentType = poComponentType
               Service = poService
               AutoStart = plAutoStart. 
    end constructor.
    
    method override public logical Equals(p0 as Object):
       define variable lEqual as logical no-undo.
       define variable oCompareTo as ComponentInfo no-undo.
       
       /* Either objects are identical, or they have the same
          component type and instance names. */
       lEqual = super:Equals(p0).
       
       if not lEqual then
            assign oCompareTo = cast(p0, ComponentInfo)
                   lEqual = this-object:ComponentType:Equals(oCompareTo:ComponentType)
                            and this-object:InstanceName eq oCompareTo:InstanceName
                            and this-object:Service:Equals(oCompareTo:Service).                                    
       return lEqual.
    end method.

end class.
