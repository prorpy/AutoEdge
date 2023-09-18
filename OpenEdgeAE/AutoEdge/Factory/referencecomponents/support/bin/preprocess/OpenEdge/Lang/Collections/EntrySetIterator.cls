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
    File        : EntrySetIterator
    Purpose     : Iterator for entrysets
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Mon Apr 12 00:18:04 EDT 2010
    Notes       : The IMappedEntry Key Value are created in next().      
  ----------------------------------------------------------------------*/

using Progress.Lang.Object.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.Iterator.
using OpenEdge.Lang.Collections.MapEntry.
 
routine-level on error undo, throw.

class OpenEdge.Lang.Collections.EntrySetIterator inherits Iterator: 
    define protected property OwningMap as IMap no-undo get. set. 
    constructor public EntrySetIterator (poMap as IMap, poCol as ICollection, tt as handle,ofield as char):
        super(poCol,tt,ofield).  
        OwningMap = poMap.          
    end constructor.    
    
    method public override Object Next():
        define variable oKey as Object no-undo.
        oKey = super:Next().
        return new MapEntry(OwningMap,oKey). 
    end method.    
     
end class.
