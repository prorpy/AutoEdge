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
    File        : ComponentProvider
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 07 14:41:39 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.ComponentInfo. 
using OpenEdge.CommonInfrastructure.Common.ComponentTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Component.

using OpenEdge.Core.InjectABL.Lifecycle.StandardProvider.
using OpenEdge.Core.InjectABL.Lifecycle.ILifecycleContext.
using OpenEdge.Core.InjectABL.Binding.Parameters.IParameter.
using OpenEdge.Core.InjectABL.Binding.Parameters.Parameter.
using OpenEdge.Core.InjectABL.Binding.Parameters.Routine.
using OpenEdge.Core.InjectABL.Binding.Parameters.Parameter.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.RoutineTypeEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class. 
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentProvider inherits StandardProvider:
    
    constructor public ComponentProvider(input poClass as class Class):
        super(poClass).
    end constructor.

    method override public Object Create(input poContext as ILifecycleContext):
        define variable oComponent as Object no-undo.
        define variable oRoutine as Routine no-undo.
        define variable oIterator as IIterator no-undo.
        define variable lHasCtorArgs as logical no-undo.

        oIterator = poContext:Arguments:Iterator().
        do while oIterator:HasNext():
            oRoutine = cast(oIterator:Next(), Routine).
            
            /* We only care about constructors here */
            if not oRoutine:RoutineType:Equals(RoutineTypeEnum:Constructor) then
                next.
            
            /* need at least one constructor */
            lHasCtorArgs = true.
            
            AddCommonArguments(oRoutine, poContext).
        end.
        
        if not lHasCtorArgs then
        do:
            oRoutine = new Routine(poContext:Binding:Service, '', RoutineTypeEnum:Constructor).
            AddCommonArguments(oRoutine, poContext).
            
            poContext:Arguments:Add(oRoutine).
        end.
        
        oComponent = super:Create(poContext).
        
        /* Service:IServiceType. */
        Assert:ArgumentIsType(oComponent, Class:GetClass('OpenEdge.CommonInfrastructure.Common.IComponent')).
        
        return oComponent.
    end method.
    
    method protected void AddCommonArguments(input poRoutine as Routine,
                                             input poContext as ILifecycleContext):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable iOffset as integer no-undo init 1.
        define variable oNewParams as IParameter extent no-undo.
        
        iMax = extent(poRoutine:Parameters) + iOffset.
        if iMax eq ? then
            iMax = iOffset.
        extent(oNewParams) = iMax.
        
        oNewParams[1] = new Parameter(
                            new ComponentInfo(
                                poContext:Binding:Service,
                                poContext:Binding:Name,
                                ComponentTypeEnum:Service,
                                true),
                            ComponentInfo:IComponentInfoType). 
        do iLoop = (iOffset + 1) to iMax:
            oNewParams[iLoop] = poRoutine:Parameters[iLoop - iOffset].
        end.
        
        /* replace old with new */
        extent(poRoutine:Parameters) = ?.
        poRoutine:Parameters = oNewParams.
    end method.
    
end class.
