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
    File        : ArrayIterator
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Jun 14 12:13:12 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.Collections.ICollection.
using OpenEdge.Lang.Collections.Array.
using OpenEdge.Lang.Assert.

using Progress.Lang.Object.

class OpenEdge.Lang.Collections.ArrayIterator implements IIterator:
    define protected property CurrentExtent as integer no-undo get. set.
    define protected property IteratedArray as Array no-undo  get. set .
    
    constructor public ArrayIterator(input poIteratedArray as Array):
        Assert:ArgumentNotNull(poIteratedArray, 'Iterated Array').
        
        CurrentExtent = 0.
        IteratedArray = poIteratedArray.
    end method.
    
	method public logical HasNext():
		define variable lHasNext as logical no-undo.
		
		lHasNext = (CurrentExtent + 1) le IteratedArray:Size.
		
		return lHasNext.
	end method.

	method public Object Next():
	    define variable iGetExtent as integer no-undo.
	    
	    assign iGetExtent = CurrentExtent
	           CurrentExtent = CurrentExtent + 1.        
		return IteratedArray:GetValue(iGetExtent).
	end method.
	
	method public logical Remove():
        return IteratedArray:Remove(IteratedArray:GetValue(CurrentExtent)).
	end method.

end class.