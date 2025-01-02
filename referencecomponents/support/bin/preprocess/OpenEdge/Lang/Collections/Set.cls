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
    File        : Set
    Purpose     : 
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Wed Jan 09 10:45:45 EST 2008
    Notes       : 
  ----------------------------------------------------------------------*/

routine-level on error undo, throw.
using Progress.Lang.*.
using OpenEdge.Lang.Collections.*. 
 
class OpenEdge.Lang.Collections.Set inherits AbstractTTCollection implements ISet : 
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    /* temp-table  */ 
    define private temp-table ttSet 
      field objectref as Object 
      index objidx as unique primary objectref.
        
    constructor public Set (  ):
        super (temp-table ttSet:handle,"objectref").        
    end constructor.
    
    constructor public Set (copyset as ISet):
        super (cast(copyset,ICollection),temp-table ttSet:handle,"objectref").        
    end constructor.    

    method public override logical Contains( checkObject as Object):
        define variable lContains as logical no-undo.
        
        if not valid-object(checkObject) then
            return false.
        
        /* try by-reference first */
        lContains = can-find(first ttSet where ttSet.ObjectRef = checkObject). 
        for each ttSet while lContains = false:
            lContains = ttSet.ObjectRef:Equals(checkObject).
        end.
        
        return lContains.
    end method.
       
    method protected override void FindBufferUseObject (obj as Object):
        find ttSet where ttSet.objectref = obj no-error.
    end.
   
    method public override logical Add(obj as Object):    
        find ttSet where ttSet.objectref = obj no-error.
        if not avail ttSet then     
            return super:add(obj).
        else
            return false.
    end method.
    
    method public override logical AddAll(collection as ICollection):
        define variable iterator as IIterator no-undo.
        define variable anyAdded as logical   no-undo.

        iterator = collection:Iterator().
        do while iterator:HasNext():
            if this-object:add(Iterator:Next()) then
               anyAdded = true.
        end.
        delete object iterator.
        return anyAdded.
    end method.
    
    method public logical ContainsAll(collection as ICollection):            
        define variable iterator as IIterator no-undo.
        define variable found    as logical   no-undo.
        iterator = collection:Iterator(). 
        do while iterator:HasNext():
            if not this-object:Contains(iterator:Next()) then 
                return false.
            found = true.      
        end.    
        return found.         
    end method.
    
    /* Equals if Set and every member of the specified set is contained in this set */
    method public override logical Equals(o as Object):
        define buffer btSet for ttSet.
        define variable oSet as ISet no-undo.
        if super:Equals(o) then 
            return true.
        if type-of(o,ISet) then
        do:
            oSet = cast(o,ISet).
            if oSet:Size = Size then
            do:
                for each btSet:
                    if not oSet:Contains(btSet.objectref) then
                        return false. 
                end.    
                return true.
            end.    
        end.
        return false.    
    end method.    
    
    method public override logical RemoveAll(collection as ICollection):
        define variable iterator   as IIterator no-undo.         
        define variable anyRemoved as logical no-undo.
        iterator = collection:Iterator().
        do while iterator:HasNext():
            if remove(iterator:Next()) then 
                anyRemoved = true. 
        end.
        return anyRemoved.
    end method.
     
end class.
