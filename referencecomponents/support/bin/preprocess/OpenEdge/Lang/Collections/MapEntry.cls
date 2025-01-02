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
    File        : MapEntry
    Purpose     : 
    Syntax      : 
    Description : 
    @author hdaniels
    Created     : Mon Apr 12 00:24:25 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.Object.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.IMapEntry.

routine-level on error undo, throw.
 
class OpenEdge.Lang.Collections.MapEntry implements IMapEntry: 
    define protected property OwningMap as IMap no-undo get. set.
    
       define public property Key as  Object no-undo 
    get.
    set. 

    define public property Value as  Object no-undo 
    get.
    set(poValue as  Object): 
        if valid-object(OwningMap) then 
           OwningMap:Put(Key,poValue).

        this-object:Value = poValue.    
    end.
    
    constructor public MapEntry (poMap as IMap, poKey as Object):
        super ().
        assign
            this-object:Key = poKey
            /* Set value before OwningMap! see Set override */
            this-object:Value = poMap:Get(poKey)
            OwningMap = poMap .
    end constructor.
   
    method public override logical Equals(o as Object):
         define variable oMapEntry as IMapEntry no-undo.
         if o:Equals(this-object) then
             return true.
         if type-of(o,IMapEntry) then
         do: 
             oMapEntry = cast(o,IMapEntry).
             return this-object:Key:Equals(oMapEntry:Key) 
                    and 
                    this-object:Value:Equals(oMapEntry:Value).
         end.
         return false.
    end method.
    

end class.
