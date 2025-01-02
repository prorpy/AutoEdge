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
    File        : Map
    Purpose     : Unique Key-Value mapping collection 
    Syntax      :  
    Description : 
    @author hdaniels
    Created     : Sun Apr 11 01:35:13 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ISet.
using OpenEdge.Lang.Collections.EntrySet.
using OpenEdge.Lang.Collections.KeySet.
using OpenEdge.Lang.Collections.Map.
using OpenEdge.Lang.Collections.ValueCollection.

using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.ISerializable.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IObjectInput.

using Progress.Lang.AppError.
using Progress.Lang.Object.

class OpenEdge.Lang.Collections.Map
    implements IMap, IExternalizable, ISerializable: 
    
    define temp-table ttMap 
      field KeyRef as Object 
      field ValueRef as Object 
      index validx ValueRef
      index keyidx as unique primary KeyRef.
     
    define public property Size as integer no-undo 
    get.
    private set. 
    
    define public property Values as ICollection no-undo 
    get():
        if not valid-object(this-object:Values) then 
            this-object:Values = new ValueCollection(this-object,temp-table ttMap:handle,"ValueRef"). 
        return this-object:Values.   
    end.   
    private set. 
   
    define public property KeySet as ISet no-undo 
    get():
        if not valid-object(this-object:KeySet) then 
            this-object:KeySet = new KeySet(this-object,temp-table ttMap:handle,"KeyRef"). 
        return this-object:KeySet.   
    end.   
    private set. 
    define public property EntrySet as ISet no-undo 
    get():
        if not valid-object(this-object:EntrySet) then
            this-object:EntrySet = new EntrySet(this-object,temp-table ttMap:handle,"KeyRef").
        return this-object:EntrySet.
    end.   
    private set.    
            
    constructor public Map (poMap as IMap ):
        super ().    
        if type-of(poMap,Map) then
        do:
            poMap:Values:ToTable(output table ttMap).
            Size = poMap:Size.
        end. 
        else PutAll(poMap).  
    end constructor.
    
    constructor public Map (  ):
        super ().   
    end constructor.

    method public void Clear(  ):
        empty temp-table ttMap.
    end method.

    method public logical ContainsKey(poKey as Object):
        define variable lContainsKey as logical no-undo.
        define buffer lbMap for ttMap.
        
        if not valid-object(poKey) then
            return false.
        
        /* try by-reference first */
        lContainsKey = can-find(lbMap where lbMap.KeyRef = poKey). 
        for each lbMap while lContainsKey = false:
            lContainsKey = lbMap.KeyRef:Equals(poKey).
        end.
               
        return lContainsKey.
    end method.

    method public logical ContainsValue(poValue as Object):
        define variable lContainsValue as logical no-undo.
        define buffer lbMap for ttMap.
        
        if not valid-object(poValue) then
            return false.
        
        /* try by-reference first */
        lContainsValue = can-find(lbMap where lbMap.ValueRef = poValue). 
        for each lbMap while lContainsValue = false:
            lContainsValue = lbMap.ValueRef:Equals(poValue).
        end.
                       
        return lContainsValue.
    end method.
    
    /* Returns true if the given object is also a map and the two Maps represent the same mappings.  */
    method public override logical Equals(o as Object):
        define buffer btMap for ttMap.
        define variable oMap as IMap no-undo.
        define variable oValue as Object no-undo.
        
        if super:Equals(o) then 
            return true.
        if type-of(o,IMap) then
        do:
            oMap = cast(o,IMap).
            if oMap:Size = Size then
            do:
                for each btMap:
                    oValue = oMap:Get(btMap.KeyRef).
                    if oValue <> ? and oValue <> btMap.ValueRef then
                        return false.
                    
                    if oValue = ? then
                    do:
                       if not oMap:ContainsKey(btMap.KeyRef) then
                           return false. 
                       if btMap.ValueRef <> ? then
                           return false.
                    end.       
                    
                end.    
                return true.
            end.    
        end.
        return false.    
    end method.    
    
    /* This must be the buffer handle passed to the constructor of the 2 sets of this Map 
       (they all call back here for find of BufferHandle) */ 
    method public Object Get(poKey as Object):
        define variable oValue as Object no-undo.
        define buffer lbMap for ttMap.
       
        if not valid-object(poKey) then
            return oValue.
        
        find lbMap where lbMap.KeyRef = poKey no-error.
        if avail lbMap then
            oValue = lbMap.ValueRef.
        
        for each lbMap while not valid-object(oValue):
            if lbMap.KeyRef:Equals(poKey) then
                oValue = lbMap.ValueRef.
        end.
        
        return oValue.
    end method.

    method public logical IsEmpty(  ):
        return not can-find(first ttMap).
    end method.

    /* add entry to the map, return old value of any. Note that return of unknown could 
       also mean that the old mapped value was unknown... (check Size before and after) */   
    method public Object Put(poKey as Object, poValue as Object):
        define variable oOld as Object no-undo.
        define buffer lbMap for ttMap.

        if poKey:Equals(this-object) then 
             undo, throw new AppError("A Map cannot have itself as key.").
        /* not a real transaction, but scoping of updates 
          (not tested without, so not sure if it is really needed... )  */
        do transaction:
            /* try by-reference first */
            find ttMap where ttMap.KeyRef = poKey no-error.
            if not available ttMap then        
            for each lbMap while not available ttMap:
                if lbMap.KeyRef:Equals(poKey) then
                    find ttMap where rowid(ttMap) = rowid(lbMap) no-error.
            end.
                        
            if not avail ttMap then
            do:
                create ttMap.
                assign ttMap.KeyRef = poKey
                       Size = Size + 1.
            end.
            else 
                oOld = ttMap.ValueRef.
            
            ttMap.ValueRef = poValue.
        end.
        return oOld.
    end method.

    method public void PutAll(poMap as IMap):
        define variable oKey as Object no-undo.
        define variable oIter as IIterator no-undo.    
 
        oIter = poMap:KeySet:Iterator(). 
        do while oIter:hasNext():
            oKey = oIter:Next().
            this-object:Put(oKey,poMap:Get(oKey)).
        end.
    end method.
    
    /* return old value of any. Note that return of unknown could 
       also mean that the old mapped value was unknown. */ 
    method public Object Remove(poKey as Object):
        define variable oOld as Object no-undo.
        define buffer lbMap for ttMap.
        
        /* try by-reference first */
        find ttMap where ttMap.KeyRef = poKey no-error.
        if not available ttMap and valid-object(poKey) then
        for each lbMap while not available ttMap:
            if lbMap.KeyRef:Equals(poKey) then
                find ttMap where rowid(ttMap) = rowid(lbMap) no-error.
        end.
        
        if avail ttMap then
        do:
            oOld = ttMap.ValueRef.
            delete ttMap.
            Size = Size - 1.
        end.
        
        return oOld.
    end method.

    method public void WriteObject(input poStream as IObjectOutput):
        poStream:WriteObjectArray(KeySet:ToArray()).
        poStream:WriteObjectArray(Values:ToArray()).
	end method.
	
	method public void ReadObject(input poStream as IObjectInput):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oKeys as Object extent no-undo.
        define variable oValues as Object extent no-undo.
        
        assign oKeys = poStream:ReadObjectArray()
               oValues = poStream:ReadObjectArray()
               iMax = extent(oKeys).
        do iloop = 1 to iMax:
            this-object:Put(oKeys[iLoop], oValues[iLoop]).
        end.
    end method.
    
    destructor public Map ( ):
        this-object:Values = ?.
        this-object:KeySet = ?.
    end destructor.
      
      
end class.
