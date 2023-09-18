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
    File        : TypedCollection
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Mar 10 10:43:01 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.TypedCollection.
using OpenEdge.Lang.Collections.Collection.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Assert.
using Progress.Lang.Object.

class OpenEdge.Lang.Collections.TypedCollection inherits Collection:
    define public property CollectionType as Progress.Lang.Class no-undo get. private set. 
    
    constructor public TypedCollection (poType as Progress.Lang.Class):
        super().
        CollectionType = poType.
    end constructor.
    
    constructor public TypedCollection(c as TypedCollection):
        super(input c).
        
        CollectionType = c:CollectionType.
    end constructor.
    
    method override public logical Add(newObject as Object):
        Assert:ArgumentIsType(newObject, CollectionType).
        return super:Add(newObject).
    end method.
    
    method override public logical Remove(oldObject as Object):
        Assert:ArgumentIsType(oldObject, CollectionType).
        return super:Remove(oldObject).
    end method.
    
    method override public logical Contains(checkObject as Object):
        Assert:ArgumentIsType(checkObject, CollectionType).
        return super:Contains(checkObject).
    end method.
    
    /* Deep clone. or rather deep enough since we don't know what the elements' Clone()
       operations do, so this may end up being a memberwise clone */
    method override public Object Clone():
        define variable oClone as ICollection no-undo.
        
        oClone = new TypedCollection(this-object:CollectionType). 
        CloneElements(oClone).
        
        return oClone.      
    end method.

end class.
