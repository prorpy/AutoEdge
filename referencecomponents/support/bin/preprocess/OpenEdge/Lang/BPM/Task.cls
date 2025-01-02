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
    File        : Task
    Purpose     : An OEBPM Task - composed of a WorkItem and its associated
                  DataSlotInstances
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Jul 14 10:34:40 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.BPM.Task.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap. 
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.String.
using Progress.Lang.Class.
using Progress.Lang.Object.


class OpenEdge.Lang.BPM.Task:
    define public property WorkItem as WorkItem no-undo get. private set.
    
    define public property DataSlots as IMap no-undo
        get():
            if not valid-object(DataSlots) then
                DataSlots = new TypedMap(
                                    String:Type,
                                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).
            return DataSlots.
        end get.
        private set.
    
    constructor public Task(input poWorkItem as WorkItem,
                            input poDataSlots as DataSlotInstance extent):
        super().
        
        this-object:WorkItem = poWorkItem.
        AddDataSlots(poDataSlots).
    end constructor.

    constructor public Task(poWorkItem as WorkItem):
        define variable oDummy as DataSlotInstance extent no-undo.
        
        this-object(poWorkItem, oDummy).
    end constructor.
    
    method public void AddDataSlots(input poDataSlots as DataSlotInstance extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = extent(poDataSlots).
        do iLoop = 1 to iMax:
            DataSlots:Put(new String(poDataSlots[iLoop]:Name), poDataSlots[iLoop]). 
        end.
    end method.

    method public longchar GetDataSlotValue(input pcDataSlotName as character):
        define variable oDSI as DataSlotInstance no-undo.
        define variable cValue as longchar no-undo.
        
        oDSI = cast(DataSlots:Get(new String(pcDataSlotName)), DataSlotInstance).
        Assert:ArgumentNotNull(oDSI, substitute('Dataslot &1', pcDataSlotName)).
        
        return oDSI:Value. 
    end method.
        
    method public void SetDataSlotValue(input pcDataSlotName as character,
                                        input pcDataSlotValue as longchar):
        cast(DataSlots:Get(new String(pcDataSlotName)), DataSlotInstance):value = pcDataSlotValue.
    end method.
    
    method override public logical Equals(input p0 as Object):
        define variable lEquals as logical no-undo.
        
                lEquals = super:Equals(input p0).
        if not lEquals then
            lEquals = type-of(p0, Task).

        if lEquals then
            lEquals = this-object:WorkItem:Equals(cast(p0, Task):WorkItem).
        
        return lEquals.            
        end method.
    
end class.
