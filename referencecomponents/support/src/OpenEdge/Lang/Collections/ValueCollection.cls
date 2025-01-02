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
/*------------------------------------------------------------------------------
    File        : ValueCollection
    Purpose     : ICollection implementation over values in an IMap (also TT based) 
                  object that needs collection capabilities.. 
                  used to return Values IMap 
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : 2010
    Notes       : no empty constructor, specialized for IMap 
                 - Changes to the map are reflected here, and vice-versa. 
                 - Supports removal and removes the corresponding map entry from the map
                   (Iterator.remove, Collection.remove, removeAll, retainAll and clear) .
                 - Do not support add and addAll.   
                 - no empty constructor, specialised for IMap 
----------------------------------------------------------------------------------------------*/

routine-level on error undo, throw.
using Progress.Lang.Object.

using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.Iterator.
using OpenEdge.Lang.Collections.IMap.

class OpenEdge.Lang.Collections.ValueCollection implements ICollection: 
    define protected property OwningMap as IMap no-undo get. set.
    
    define public property Size as integer no-undo 
    get():
        return OwningMap:Size.
    end. 
    
    define private variable mhTempTable     as handle no-undo. 
    define private variable mhField         as handle no-undo. 
 
    constructor public ValueCollection(poMap as IMap,phTT as handle, pcValuefield as char):
        super ().
        assign
            mhTempTable = phTT
            mhField = mhTempTable:default-buffer-handle:buffer-field (pcValuefield)
            OwningMap = poMap.
    end constructor.
    
    method public logical Add(newObject as Object ):
        return false.
        /* undo, throw new AppError("Cannot add, use Map:AddAll instead"). */
    end method.

    method public logical AddAll( newCollection as ICollection ):
        return false.
        /* undo, throw new AppError("Cannot addAll, use Map:AddAll instead"). */
    end method.
    
    method public logical AddArray( o as Object extent ):
        return false.
        /* undo, throw new AppError("Cannot addAll, use Map:AddAll instead"). */
    end method.

    method public void Clear(  ):
        OwningMap:Clear().
    end method.
   
    method public logical IsEmpty(  ):
        return OwningMap:IsEmpty().
    end method.

    method public logical Contains( checkObject as Object):
        return OwningMap:ContainsValue(checkObject).
    end method.
    
    /* Returns a new IIterator over the collection. */
    method public IIterator Iterator( ):    
        return new Iterator(this-object,mhTempTable,mhField:name).
    end method.
      
    /* slow... use Remove on Map or Map:KeySet() instead  */
    method public logical Remove( poOld as Object ):
        define variable oIter as IIterator no-undo.
        define variable oKey  as Object    no-undo.
        define variable oVal  as Object    no-undo.
        oIter = OwningMap:KeySet:Iterator().
        do while oIter:HasNext():
            oKey = oIter:Next().
            oVal  = OwningMap:Get(oKey).
            if oVal:Equals(poOld) then
            do:
                OwningMap:Remove(oKey).
                return true.
            end.    
        end.     
        return false.
    end method.
    
    method public logical RemoveAll(poRemoveCol as ICollection):
        define variable oIter as IIterator no-undo.
        define variable oKey  as Object    no-undo.
        define variable oVal  as Object    no-undo.
        define variable lany as logical no-undo.
        oIter = OwningMap:KeySet:Iterator().
        do while oIter:HasNext():
            oKey = oIter:Next().
            oVal  = OwningMap:Get(oKey).
            if poRemoveCol:Contains(oVal) then
            do:  
                OwningMap:Remove(oKey).
                lAny = true.
            end.    
        end.
        return lAny.
    end method.
    
    method public logical RetainAll(poCol as ICollection):
        define variable oIter as IIterator no-undo.
        define variable oKey  as Object    no-undo.
        define variable oVal  as Object    no-undo.
        define variable lany as logical no-undo.
        oIter = OwningMap:KeySet:Iterator().
        do while oIter:HasNext():
            oKey = oIter:Next().
            oVal  = OwningMap:Get(oKey).
            if not poCol:Contains(oVal) then
            do:  
                OwningMap:Remove(oKey).
                lAny = true.
            end.    
        end.
        return lAny.
    end method.
    
    /* ToArray should not be used with large collections
       If there is too much data the ABL will throw:  
       Attempt to update data exceeding 32000. (12371) */
    method public Object extent ToArray():
        define variable i as integer no-undo.
        define variable oObjArray as Object extent no-undo.
        define variable iterator as IIterator no-undo.
        
        if Size eq 0 then
            return oObjArray.
            
        extent(oObjarray) = Size.
        iterator = Iterator(). 
        do while iterator:hasNext():
           i = i + 1.
           oObjArray[i] = iterator:Next().  
        end.                                     
        return oObjArray.
    end method.
    
    method public void ToTable( output table-handle tt ):
        tt = mhTempTable.
    end method. 
end class.
