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
    File        : InjectionModule
    Purpose     : 
    Syntax      :
    Description : A loadable unit that defines bindings for your application.
    @author pjudge
    Created     : Tue Mar 02 11:08:44 EST 2010 
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Binding.IBindingRoot.
using OpenEdge.Core.InjectABL.Binding.BindingRoot.
using OpenEdge.Core.InjectABL.Binding.IBinding.
using OpenEdge.Core.InjectABL.Binding.Binding.
using OpenEdge.Core.InjectABL.Binding.BindingBuilder.
using OpenEdge.Core.InjectABL.Binding.IBindingSyntax.
using OpenEdge.Core.InjectABL.Binding.Modules.IInjectionModule.
using OpenEdge.Core.InjectABL.IKernel.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.Collections.IList.
using OpenEdge.Lang.Collections.List.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Assert.

class OpenEdge.Core.InjectABL.Binding.Modules.InjectionModule abstract inherits BindingRoot 
        implements IInjectionModule: 

     /** Gets the kernel that the module is loaded into.  */
    define public property Kernel as IKernel no-undo get. protected set.
    
    /** Gets the module's name. Only a single module with a given name can be loaded at one time.  */
    define public property Name as character no-undo
        get():
            return this-object:GetClass():TypeName.
        end get.
        private set.
    
    define override public property Bindings as IMap no-undo get. private set.
         
    constructor public InjectionModule():
        super().
        Bindings = new Map().
    end constructor.
    
    /** Called when the module is loaded into a kernel.
        @param kernel The kernel that is loading the module.
      */
    method public void OnLoad(poKernel as IKernel):
        Assert:ArgumentNotNull(poKernel, "kernel").
        
        Kernel = poKernel.
        Load().
    end.

     /** Called when the module is unloaded from a kernel. 
         
         @param kernel The kernel that is unloading the module.  */
    method public void OnUnload(input poKernel as IKernel):
        define variable oIterator as IIterator.
        define variable oBinding as IBinding.
        
        Assert:ArgumentNotNull(poKernel, "InjectABL kernel").
        
        Unload().
        
        oIterator = Bindings:Values:Iterator().
        do while oIterator:HasNext():
            oBinding = cast(oIterator:Next(), IBinding).
            cast(Kernel, IBindingRoot):RemoveBinding(oBinding).
            Bindings:Remove(oBinding).
        end.
        
        Bindings:Clear().
        Kernel = ?.
    end.
    
     /** Loads the module into the kernel.  */
    method public abstract void Load().

     /** Unloads the module from the kernel.  */
    @method(virtual="true").     
    method public void Unload():
    end method.

     /** Registers the specified binding.
         
         @param binding The binding to add. */
    method override public void AddBinding(input poBinding as IBinding):
        define variable oBindings as IList no-undo.
        
        Assert:ArgumentNotNull(input poBinding, "binding").
        
        cast(Kernel, IBindingRoot):AddBinding(poBinding).
        
        oBindings = cast(Bindings:Get(input poBinding:Service), IList).
        if not valid-object(oBindings) then
        do:
            oBindings = new List().
            Bindings:Put(poBinding:Service, oBindings).
        end.
        
        oBindings:Add(input poBinding).
    end.
    
     /** Unregisters the specified binding.
        @param binding The binding to remove.
       */
    method override public void RemoveBinding(poBinding as IBinding):
        define variable oBindings as IList no-undo.
        
        Assert:ArgumentNotNull(poBinding, "binding").

        cast(Kernel, IBindingRoot):RemoveBinding(poBinding).
        
        oBindings = cast(Bindings:Get(poBinding:Service), IList).
        if valid-object(oBindings) then
        do:
            oBindings:Remove(poBinding).
            if oBindings:IsEmpty() then
                Bindings:Remove(poBinding:Service).
        end.
    end.
    
    method override protected IBindingSyntax CreateBindingBuilder(poBinding as IBinding):
        return new BindingBuilder(poBinding, Kernel).
    end method.
    
end class.
