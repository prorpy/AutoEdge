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
    File        : Binding
    Purpose     : 
    Syntax      : Contains information about a service registration.
    Description : 
    @author pjudge
    Created     : Wed Mar 03 14:28:18 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Binding.Binding.
using OpenEdge.Core.InjectABL.Binding.IBinding.
using OpenEdge.Core.InjectABL.Binding.BindingTargetEnum.
using OpenEdge.Core.InjectABL.Lifecycle.StandardScope.
using OpenEdge.Core.InjectABL.Lifecycle.StandardScopeEnum.
using OpenEdge.Core.InjectABL.Lifecycle.IProvider.
using OpenEdge.Core.InjectABL.Lifecycle.StandardProvider.
using OpenEdge.Core.InjectABL.Lifecycle.ILifecycleContext.

using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.IOModeEnum.
using OpenEdge.Lang.Collections.ObjectStack.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.TypedCollection.
using OpenEdge.Lang.Assert.
using Progress.Lang.ParameterList.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.Core.InjectABL.Binding.Binding implements IBinding: 
    /** Gets the service type that is controlled by the binding. */
    define public property Service as class Class no-undo get. private set.
    
    /** Gets or sets the condition defined for the binding. */
    define public property Condition as ObjectStack no-undo get. set. 
    
    /** Gets a value indicating whether the binding has a condition associated with it. */
    define public property IsConditional as logical no-undo
        get():            
            return (valid-object(Condition) and Condition:Size gt 0).
        end get.
    
    /** Gets or sets the type of target for the binding. */
    define public property Target as BindingTargetEnum no-undo get. set.
    
    /** Gets or sets the callback that returns the object that will act as the binding's scope. */
    define public property Scope as StandardScopeEnum no-undo get. set.
    define public property ScopeCallbackType as class Class no-undo
        get():
            if not valid-object(ScopeCallbackType) then
                ScopeCallbackType = Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.StandardScope').
            
            return ScopeCallbackType.
        end get.
        set.
    
    /** Gets or sets the callback that returns the provider that should be used by the binding. */
    define public property ProviderType as class Class no-undo 
        get():
            /* Default to StandardProvider */
            if not valid-object(ProviderType) then
                ProviderType = Class:GetClass('OpenEdge.Core.InjectABL.Lifecycle.StandardProvider').
            
            return ProviderType.
        end get.
        set.
    
    /** The target type of the binding. Must be a concrete class. */
    define public property TargetType as class Class no-undo get.
        set(poTargetType as class Class):
            Assert:ArgumentNotAbstract(poTargetType).
            
            TargetType = poTargetType.            
        end set.
    
    /** Gets the parameters defined for the binding. */
    define public property Arguments as ICollection no-undo get. private set.
    
    /** Gets or sets the optional name defined for the binding. */
    define public property Name as character no-undo get. set.
    
    constructor public Binding(poService as class Class):
        Assert:ArgumentNotNull(poService, "service").
        
        /* Binding defaults to self-binding */
        
        assign Service = poService
               Arguments = new TypedCollection(Class:GetClass('OpenEdge.Core.InjectABL.Binding.Parameters.Routine'))
               Scope = StandardScopeEnum:Transient.
    end constructor.
    
    /** Gets the provider for the binding.
        
        @return IProvider The provider to use.    */        
    method public IProvider GetProvider():
        define variable oProvider as IProvider no-undo.
        
        oProvider = StandardProvider:GetProvider(this-object:ProviderType, this-object:Service).
        
        return oProvider.
    end method.
    
    /** Gets the scope for the binding, if any.
        @param context The context.
        @return The object that will act as the scope, or unknown if the service is transient.
     */
    method public Object GetScope(poContext as ILifecycleContext):
        Assert:ArgumentNotNull(poContext, "context").
        
        /** Unfortunately, we can't do any type-checking, since the GetScope() call is
            make statically. */
        return dynamic-invoke(ScopeCallbackType:TypeName, 'GetScope', poContext, Scope).
    end method.
    
    /** Determines whether the specified request satisfies the conditions defined on this binding.
        @param request The request.
        @return <c>True</c> if the request satisfies the conditions. otherwise <c>false</c>.
     */
    method public logical Matches(poBinding as IBinding):
        define variable lMatches as logical no-undo.
        
        Assert:ArgumentNotNull(poBinding, "binding").
        
        return lMatches.
    end method.
    
    method override public Object Clone():
        define variable oClone as IBinding no-undo.
        define variable oPL as ParameterList no-undo.
                
        oPL = new ParameterList(1).
        oPL:SetParameter(1,
                         DataTypeEnum:Class:ToString(),
                         IOModeEnum:Input:ToString(),
                         this-object:Service).
        
        assign oClone = cast(this-object:GetClass():New(oPL), IBinding)
               
               oClone:Condition = cast(this-object:Condition:Clone(), ObjectStack)
               oClone:Target = this-object:Target
               oClone:Scope = this-object:Scope
               oClone:ScopeCallbackType = this-object:ScopeCallbackType
               oClone:ProviderType = this-object:ProviderType
               oClone:TargetType = this-object:TargetType
               oClone:Name = this-object:Name.
        
        /* Create a new set of arguments, but keep the actual arguments the same
           (ie this is a reasonably shallow copy)  */
        oClone:Arguments:Add(this-object:Arguments).
        
        return oClone. 
    end method.
    
end class.
