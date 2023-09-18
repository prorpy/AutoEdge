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
    File        : IInjectionModuleCollection
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 04 14:07:31 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Binding.Modules.IInjectionModuleCollection.
using OpenEdge.Core.InjectABL.Binding.Modules.IInjectionModule.

using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.String.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.Core.InjectABL.Binding.Modules.IInjectionModuleCollection inherits TypedMap: 
    
    constructor public IInjectionModuleCollection():
        super(String:Type,
               Class:GetClass('OpenEdge.Core.InjectABL.Binding.Modules.IInjectionModule')).
    end constructor.
    
    constructor public IInjectionModuleCollection(input poMap as IInjectionModuleCollection):
        super (input poMap).
    end constructor.

    method public IInjectionModule Add(input poValue as IInjectionModule):
        return cast(super:Put(input new String(poValue:Name), input poValue), IInjectionModule).
    end method.
    
    method public IInjectionModule Put(input poKey as String, input poValue as IInjectionModule):
        return cast(super:Put(input poKey, input poValue), IInjectionModule).
    end method.
    
    method public IInjectionModule Remove(input poKey as String):
        return cast(super:Remove(input poKey), IInjectionModule).
    end method.
    
    method public IInjectionModule Remove(input pcKey as longchar):
        return cast(super:Remove(input new String(pcKey)), IInjectionModule).
    end method.
    
    method public logical ContainsKey(input poKey as String ):
        return super:ContainsKey(input poKey).
    end method.

    method public logical ContainsKey(input pcKey as longchar):
        return super:ContainsKey(input new String(pcKey)).
    end method.

    method public logical ContainsValue(input poValue as IInjectionModule ):
        return super:ContainsValue(input poValue).
    end method.
    
    method public IInjectionModule Get(input poKey as String ):
        return cast(super:Get(input poKey), IInjectionModule).
    end method.

    method public IInjectionModule Get(input pcKey as longchar):
        return cast(super:Get(input new String(pcKey)), IInjectionModule).
    end method.
    
    method public void PutAll(input poMap as IInjectionModuleCollection):
        super:PutAll(input poMap).
    end method.    
    
    
end class.
