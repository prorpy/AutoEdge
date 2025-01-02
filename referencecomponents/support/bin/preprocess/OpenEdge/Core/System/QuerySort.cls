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
    File        : QuerySort
    Purpose     : Parameter object for query buffers, used in IQueryDefinition 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Dec 10 10:16:46 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.System.QuerySort.
using OpenEdge.Core.Util.IExternalizable.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Lang.SortDirectionEnum .
using OpenEdge.Lang.Assert.
using Progress.Lang.Object.

class OpenEdge.Core.System.QuerySort
        implements IExternalizable:
    
    define public property BufferName as character no-undo get. set.
    define public property FieldName as character no-undo get. set.
    define public property Direction as SortDirectionEnum no-undo get. set.
    
    constructor public QuerySort(input pcBufferName as character,
                                 input pcFieldName as character,
                                 input poDirection as SortDirectionEnum):
        Assert:ArgumentNotNullOrEmpty(pcBufferName, 'Buffer Name').
        Assert:ArgumentNotNullOrEmpty(pcFieldName, 'Field Name').
        Assert:ArgumentNotNull(poDirection, 'Direction').
        
        assign BufferName = pcBufferName
               FieldName = pcFieldName
               Direction = poDirection. 
    end constructor.

    constructor public QuerySort(input pcBufferName as character,
                                 input pcFieldName as character):
        this-object(pcBufferName, pcFieldName, SortDirectionEnum:Default).                                     
    end constructor.
    
    method override public logical Equals(input p0 as Object):
        define variable lEquals as logical no-undo.
        define variable oQB as QuerySort no-undo.
                
        lEquals = super:Equals(input p0).
        
        if not lEquals and type-of(p0, QuerySort) then
            assign oQB = cast(p0, QuerySort)
                   lEquals = oQB:BufferName eq this-object:BufferName
                         and oQB:FieldName eq this-object:FieldName
                         and oQB:Direction:Equals(this-object:Direction).
        
        return lEquals.
    end method.
    
    method public void WriteObject( input poStream as IObjectOutput):
        poStream:WriteChar(BufferName).
        poStream:WriteChar(FieldName).
        poStream:WriteEnum(Direction).
    end method.

    method public void ReadObject( input poStream as IObjectInput ):
        assign BufferName= poStream:ReadChar()
               FieldName = poStream:ReadChar()
               Direction =  cast(poStream:ReadEnum(), SortDirectionEnum).
    end method.
    
end class.
