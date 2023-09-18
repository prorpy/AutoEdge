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
    File        : TypedMap
    Purpose     : A Map collections that's typed: this means that only
                  objects of a specific type can be added as a Key or Value.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 21 11:51:17 EDT 2010
    Notes       : * This class basically allows pseudo-generic collections
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.Lang.Collections.TypedMap inherits Map: 
    define public property KeyType as class Class no-undo get. private set. 
    define public property ValueType as class Class no-undo get. private set. 
        
    constructor public TypedMap(poMap as TypedMap):
        super(poMap).

        assign KeyType = poMap:KeyType
               ValueType = poMap:ValueType.
    end constructor.

    constructor public TypedMap(pcKeyType as character, pcValueType as character):
        this-object(Class:GetClass(pcKeyType), Class:GetClass(pcValueType)).
    end constructor.
    
    constructor public TypedMap(poKeyType as class Class, poValueType as class Class):
        super().
        
        Assert:ArgumentNotNull(poKeyType, 'Key type').
        Assert:ArgumentNotNull(poValueType, 'Value type').
        
        assign KeyType = poKeyType
               ValueType = poValueType.
    end constructor.

    /* Associates the specified value with the specified key in this map (optional operation).*/
    method override public Object Put(poKey as Object, poValue as Object):
        Assert:ArgumentIsType(poKey, KeyType).
        Assert:ArgumentIsType(poValue, ValueType).
        return super:Put(poKey, poValue).
    end method.
    
    /* Removes the mapping for this key from this map if it is present (optional operation).*/
    method override public Object Remove(poKey as Object):
        Assert:ArgumentIsType(poKey, KeyType).
        return super:Remove(poKey).
    end method.
    
    /* Returns true if this map contains a mapping for the specified key. */
    method override public logical ContainsKey(poKey as Object):
        Assert:ArgumentIsType(poKey, KeyType).
        return super:ContainsKey(poKey).
    end method.
    
    /* Returns true if this map maps one or more keys to the specified value.*/
    method override public logical ContainsValue(poValue as Object):
        Assert:ArgumentIsType(poValue, ValueType).
        return super:ContainsValue(poValue).
    end method.
   
    /* Returns the value to which this map maps the specified key.*/
    method override public Object Get(poKey as Object):
        Assert:ArgumentIsType(poKey, KeyType).
        return super:Get(poKey).
    end method.
    
    method override public void PutAll( input poMap as IMap):
        Assert:ArgumentIsType(poMap, this-object:GetClass()).
        super:PutAll(poMap).
    end method.
    
end class.
