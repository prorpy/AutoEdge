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
    File        : ComponentContainer
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Mar 05 08:39:42 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Lifecycle.*.
using OpenEdge.Core.InjectABL.Binding.Modules.*.
using OpenEdge.Core.InjectABL.*.
using OpenEdge.Lang.Collections.*.
using Progress.Lang.*.

class OpenEdge.Core.InjectABL.ComponentContainer: 
    define public property Size as integer no-undo get. private set.
    define public property Kernel as IKernel no-undo get. private set.
    
    define private temp-table ttMap no-undo
        field KeyMember as Object
        field ValueMember as Object
        field Instance as Object
        index idx1 as primary KeyMember. 
    
    constructor public ComponentContainer(poKernel as IKernel):
        Kernel = poKernel.
    end constructor.
    
    method public logical Add(poKey as class Class, poValue as class Class):
        define buffer lbMap for ttMap.
        
        create lbMap.
        assign lbMap.KeyMember = poKey
               lbMap.ValueMember = poValue
               this-object:Size = this-object:Size + 1.
    end method.
    
    method public void Clear():
        empty temp-table ttMap.
        Size = 0.
    end method.
    
    method public logical Contains(poKey as class Class, poValue as class Class):
       define buffer lbMap for ttMap.
        
       return can-find(lbMap where
             lbMap.KeyMember = poKey and
             lbMap.ValueMember = poValue).
    end method.
        
    method public logical IsEmpty(  ):
        return (Size gt 0).
    end method.
    
    method public logical RemoveAll(poKey as class Class):
        define buffer lbMap for ttMap.
                
        for each lbMap where lbMap.KeyMember = poKey:
            delete lbMap.
            Size = Size - 1.
        end.
        return true.
    end method.
    
    method public logical RemoveFirst(poKey as class Class):
        define buffer lbMap for ttMap.
        
        find first lbMap where lbMap.KeyMember = poKey no-error.
        if available lbMap then
        do:
            delete lbMap.
            Size = Size - 1.
            
            return true.
        end.
        return false.
    end method.

    method public logical RemoveValue(poKey as class Class,
                                      poValue as class Class):
        define buffer lbMap for ttMap.
        
        find first lbMap where 
                   lbMap.KeyMember = poKey and
                   lbMap.ValueMember = poValue 
                   no-error.
        if available lbMap then
        do:
            delete lbMap.
            Size = Size - 1.
            
            return true.
        end.
        return false.
    end method.
        
    method public class Class GetType(poService as class Class):
        define variable oImplentingType as class Class no-undo.
        define buffer lbMap for ttMap.
        
        find first lbMap where  
                   lbMap.KeyMember eq poService 
                   no-error.
        if available lbMap then
            oImplentingType = cast(lbMap.ValueMember, Class).
        
        return oImplentingType.
    end method.
    
    method public Object Get(poService as class Class):
        define variable oImplentingType as class Class no-undo.
        define variable oComponent as Object no-undo.
        
        define buffer lbMap for ttMap.
        
        if poService:IsA('OpenEdge.Core.InjectABL.IKernel') then
            return Kernel.
        
        find first lbMap where
                   lbMap.KeyMember eq poService 
                   no-error.
        if available lbMap then
        do:
            if valid-object(lbMap.Instance) then
                oComponent = lbMap.Instance.
            else
            do:
                oImplentingType = cast(lbMap.ValueMember, Class).
                
                case poService:TypeName:
                    when 'OpenEdge.Core.InjectABL.Lifecycle.IPipeline' then                    
                        oComponent = GetPipeline(oImplentingType).
                    when 'OpenEdge.Core.InjectABL.ICache' then
                        oComponent = GetCache(oImplentingType).
                    otherwise
                        oComponent = oImplentingType:New().
                end case.
                
                lbMap.Instance = oComponent.
            end.
        end.
        
        return oComponent.
    end method.
    
    method protected ICache GetCache(poService as class Class):
        define variable oCache as ICache no-undo.
        
        oCache = dynamic-new(poService:TypeName) (
                    this-object:Get(Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.IPipeline')),
                    Kernel:Settings:CachePruningInterval,
                    Kernel:Settings:CachePruningUnit ).
        
        return oCache.
    end method.
    
    /** Factory method for invoking kernel components. We can't really use the Kernel,
        since these components are central to using the Kernel. We still use dependency
        injection though :) **/
    method protected IPipeline GetPipeline(poService as class Class):
        define variable oStrategies as ILifecycleStrategyCollection no-undo.
        define variable oPipeline as IPipeline no-undo.
        define variable oStrategyType as class Class no-undo.
        
        define buffer lbMap for ttMap.
        
        oStrategies = new ILifecycleStrategyCollection().
        oStrategyType = Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.ILifecycleStrategy').
        
        for each lbMap where lbMap.KeyMember = oStrategyType:
            oStrategies:Add(GetLifecycleStrategy(cast(lbMap.ValueMember, Class))).
        end.
        
        oPipeline = dynamic-new(poService:TypeName) (oStrategies).
        
        return oPipeline.
    end method.
    
    method protected ILifecycleStrategy GetLifecycleStrategy(poService as class Class):
        define variable oStrategy as ILifecycleStrategy no-undo.
        
        oStrategy = dynamic-new(poService:TypeName) ().
        
        return oStrategy. 
    end method.
end class.
