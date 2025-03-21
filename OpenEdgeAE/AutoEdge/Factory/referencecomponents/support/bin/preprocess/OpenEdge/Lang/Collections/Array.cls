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
    File        : Array
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Jun 14 11:35:49 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.Array.

using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ArrayIterator.
using OpenEdge.Lang.Collections.ResizeError.
using OpenEdge.Lang.Assert.

using Progress.Lang.Class.
using Progress.Lang.Object.

class OpenEdge.Lang.Collections.Array
    implements IExternalizable, ICollection:
    
    /* only ever used for ToTable() */
    define static private temp-table ttArray
        field ObjIndex as integer
        field ObjRef as Object
        index idx1 as primary unique ObjIndex.
    
    define static public property Type as class Class no-undo
        get():
            if not valid-object(OpenEdge.Lang.String:Type) then
                Array:Type = Class:GetClass('OpenEdge.Lang.Array').
            
            return Array:Type.
        end.
        private set.
    
    define public static variable DEFAULT_ARRAY_SIZE as integer no-undo.
    
    /* Keep incrementally growing array Size as new elements are added. AutoExpanded
       ararys will grow by 50% of the current size each time. 
       
       This will negatively impact performance. */
    define public property AutoExpand as logical no-undo get. set.
    
    /* If true, we'll discard stuff off the bottom of the stack if
       we resize the stack smaller than its contents. */
    define public property DiscardOnShrink as logical no-undo get. set.
    
    define protected property Value as Object extent no-undo get. private set.
    
    define public property Size as integer no-undo
        get():
            return extent(this-object:Value).
        end.
        set(input piSize as integer):
            SetArraySize(piSize).
        end.
    
    constructor static Array():
        Array:DEFAULT_ARRAY_SIZE = 10.
    end constructor.
    
    constructor public Array(input piSize as integer):
        assign Size = piSize
               AutoExpand = false
               DiscardOnShrink = false.
    end constructor.

    constructor public Array(input poArray as Object extent):
        this-object(extent(poArray)).
        this-object:AddArray(poArray).
    end constructor.
    
    constructor public Array():
        this-object(Array:DEFAULT_ARRAY_SIZE).
    end constructor.
    
    method private void SetArraySize(input piNewSize as integer):
        define variable oTempObject as Object extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        /* do nothing if there's nothing to do */
        if piNewSize eq ? then
        do:
            if not DiscardOnShrink then
                undo, throw new ResizeError('Array', 'smaller'). 
            extent(this-object:Value) = piNewSize.            
        end.
        else
        if piNewSize ne this-object:Size then
        do:
            if piNewSize lt this-object:Size and not DiscardOnShrink then
                undo, throw new ResizeError('Array', 'smaller'). 
            
            /* if this is an indeterminate array, then do nothing */
            if this-object:Size eq ? then
                assign iMax = 0.
            else
                assign extent(oTempObject) = this-object:Size
                       oTempObject = this-object:Value
                       extent(this-object:Value) = ?
                       iMax = this-object:Size.
            extent(this-object:Value) = piNewSize.
            
            /* On init this loop won't execute */
            do iLoop = 1 to iMax:
                SetValue(oTempObject[iLoop], iLoop).
            end.
        end.
    end method.
    
    method public void SetValue(input poValue as Object):
        SetValue(poValue, (this-object:Size + 1)).
    end method.

    method public Object GetValue(input piExtent as integer):
        Assert:ArgumentNotNullOrZero(piExtent, 'Extent').
        return this-object:Value[piExtent].
    end method.
    
    method public void SetValue(input poValue as Object,
                                input piExtent as integer):
        
        /* Expand array, if allowed and needed */
        if piExtent ge this-object:Size then
        do:
            if AutoExpand then            
                SetArraySize(integer(piExtent + round(0.5 * this-object:Size, 0))).
            else
                undo, throw new ResizeError('Array','smaller').
        end.
        
        this-object:Value[piExtent] = poValue.
    end method.
    
    /* ICollection */
        method public logical Add(input o as Object):
            SetValue(o).
                return true.
        end method.

        method public logical AddAll(input c as ICollection):
            return AddArray(c:ToArray()).
        end method.

        method public logical AddArray(input c as Object extent):
            define variable iLoop as integer no-undo.
            define variable iMax as integer no-undo.
            define variable iStartSize as integer no-undo.
            
            iMax = extent(c).
            /* manually resize the array, don't auto-increment */
            iStartSize = this-object:Size.
            SetArraySize(iStartSize + iMax).
            do iLoop = 1 to iMax:
                SetValue(c[iLoop], iStartSize + iLoop).
        end.
        
        return true.
        end method.

        method public void Clear():
            SetArraySize(?).
        end method.
        
        method public logical Contains( input o as Object):
            define variable lContainsArgument as logical no-undo.
            define variable iMax as integer no-undo.
            define variable iLoop as integer no-undo.
            
            iMax = this-object:Size.
            do iLoop = 1 to iMax while not lContainsArgument:
                lContainsArgument = this-object:Value[iLoop]:Equals(o).
        end.
            
            return lContainsArgument.
        end method.

        method public IIterator Iterator( ):
                define variable oArrayIterator as IIterator no-undo.
        return new ArrayIterator(this-object).
        end method.

        method public logical IsEmpty(  ):
                return (this-object:Size eq ?).
        end method.

        method public logical Remove( input o as Object ):
                define variable lRemoved as logical no-undo.
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        iMax = this-object:Size.
        do iLoop = 1 to iMax while not lRemoved:
            if this-object:Value[iLoop]:Equals(o) then
                assign this-object:Value[iLoop] = ?
                       lRemoved = true.
        end.
        
                return lRemoved.
        end method.
        
        method public logical RemoveAll( input c as ICollection):
        define variable oIterator as IIterator.
        define variable oRemove  as Object. 
        define variable lAny as logical no-undo.
        
        oIterator = c:Iterator().
        do while oIterator:HasNext():
            oRemove = oIterator:Next().
            do while this-object:Remove(oRemove):
                lAny = true.
            end.
        end.
        
        return lAny.
        end method.

        method public logical RetainAll( input oCollection as ICollection ):
        define variable oIterator as IIterator no-undo.
        define variable oChild as Object no-undo.  
        define variable lAny as logical no-undo.
        
        oIterator = Iterator().
        do while oIterator:HasNext():
            oChild = oIterator:Next().
            if not oCollection:Contains(oChild) then 
            do:
                do while Remove(oChild):
                    lAny = true.
                end.
            end.     
        end.                                     
        return lAny.     
        end method.

        method public void ToTable( output table-handle tt):
        define variable iMax as integer no-undo.
        define variable iLoop as integer no-undo.
        
        empty temp-table ttArray.
        iMax = this-object:Size.
        do iLoop = 1 to iMax:
            create ttArray.
            assign ttArray.ObjIndex = iLoop
                   ttArray.ObjRef = this-object:Value[iLoop]. 
        end.
        
        tt = temp-table ttArray:handle.
        end method.
        
        method public Object extent ToArray():
                return this-object:Value.
        end method.
        
    /* Deep clone. or rather deep enough since we don't know what the elements' Clone()
       operations do, so this may end up being a memberwise clone */
    method override public Object Clone():
        define variable oClone as ICollection no-undo.
        
        oClone = cast(this-object:GetClass():New(), ICollection).
        CloneElements(oClone).
        
        return oClone.        
    end method.
    
    method protected void CloneElements(input poClone as ICollection):
        define variable oIterator as IIterator no-undo. 

        oIterator = this-object:Iterator().
        do while oIterator:HasNext():
           poClone:Add(oIterator:Next():Clone()).
        end.
    end method.
        
    /* IExternalizable */
        method public void WriteObject(input poStream as IObjectOutput):
            poStream:WriteObjectArray(this-object:Value).
        end method.
        
        method public void ReadObject(input poStream as IObjectInput):
            this-object:Value = poStream:ReadObjectArray().
        end method.
        
end class.
