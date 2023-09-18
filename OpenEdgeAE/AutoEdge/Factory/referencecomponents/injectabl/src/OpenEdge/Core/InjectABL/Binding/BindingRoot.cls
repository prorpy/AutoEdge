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
    File        : BindingRoot
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Mar 02 11:56:07 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Binding.IBindingRoot.
using OpenEdge.Core.InjectABL.Binding.IBinding.
using OpenEdge.Core.InjectABL.Binding.Binding.
using OpenEdge.Core.InjectABL.Binding.IBindingCollection.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.

class OpenEdge.Core.InjectABL.Binding.BindingRoot abstract 
        implements IBindingRoot:
    
    /** A collection of bindings, keyed by the service they bind to. */
    define abstract public property Bindings as IMap no-undo get.
    
    /** Declares a binding from the service to itself.        
        @param character The service to bind. */
    method public IBindingSyntax Bind(input pcService as char):
        Assert:ArgumentIsValidType(pcService).
        return this-object:Bind(Class:GetClass(pcService)).
    end method.
    
    /** Declares a binding from the service to itself.        
        @param Class The service to bind. */    
    method public IBindingSyntax Bind(input poService as class Class):
        define variable oBinding as IBinding no-undo.
        
        Assert:ArgumentNotNull(poService, 'Service').
        
        oBinding = new Binding(poService).
        AddBinding(oBinding).
        
        return CreateBindingBuilder(oBinding).
    end method.
    
    /** Unregisters all bindings for the specified service.
        
        @param Class The service to unbind. */    
    method public void Unbind(poService as class Class):
        define variable oBindings as ICollection no-undo.
        define variable oIterator as IIterator no-undo.
        
        assign oBindings = cast(Bindings:Get(poService), ICollection)
               oIterator = oBindings:Iterator().
        do while oIterator:HasNext():
            RemoveBinding(cast(oIterator:Next(), IBinding)).
        end.
    end method.

    /** Unregisters all bindings for the specified service.
        
        @param character The service to unbind. */
    method public void Unbind(pcService as char):
        Assert:ArgumentIsValidType(pcService).
        
        Unbind(Class:GetClass(pcService)).
    end method.
    
    /** Removes any existing bindings for the specified service, and declares a new one.
        
        @param character The service to re-bind. **/
    method public IBindingSyntax Rebind(pcService as character):
        Assert:ArgumentIsValidType(pcService).
        
        return Rebind(Class:GetClass(pcService)).
    end method.

    /** Removes any existing bindings for the specified service, and declares a new one.
        
        @param Class The service to re-bind. **/
    method public IBindingSyntax Rebind(poService as class Class):
        Unbind(poService).
        return Bind(poService).
    end method.
    
    /** Registers the specified binding.
        
        @param IBinding The binding to add. */    
    method abstract public void AddBinding(poBinding as IBinding).

    /** Unregisters the specified binding.
        @param IBinding The binding to remove. */
    method abstract public void RemoveBinding(poBinding as IBinding).
    
    method abstract protected IBindingSyntax CreateBindingBuilder(poBinding as IBinding).
    
end class.
