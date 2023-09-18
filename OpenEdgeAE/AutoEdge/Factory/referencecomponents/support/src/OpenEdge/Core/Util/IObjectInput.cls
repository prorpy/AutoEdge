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
    File        : IObjectInput
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jan 25 10:11:57 EST 2011
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.Lang.EnumMember.
using Progress.Lang.Object.

interface OpenEdge.Core.Util.IObjectInput:  

    /** Resets/reinitialises the input */
    method public void Reset().
    
    method public void Read(input pcStream as longchar).
    method public void Read(input pcFile as character).
    method public void Read(input pmStream as memptr).
    
    method public Object ReadObject().
    method public Object extent ReadObjectArray().
    
    method public EnumMember ReadEnum().
    
    method public character ReadChar().
    method public character extent ReadCharArray().

    method public longchar ReadLongChar().
    method public longchar extent ReadLongCharArray().
    
    method public integer ReadInt().
    method public integer extent ReadIntArray().
    
    method public int64 ReadInt64().
    method public int64 extent ReadInt64Array().
    
    method public decimal ReadDecimal().
    method public decimal extent ReadDecimalArray().
    
    method public date ReadDate().
    method public date extent ReadDateArray().

    method public datetime ReadDateTime().
    method public datetime extent ReadDateTimeArray().
    
    method public datetime-tz ReadDateTimeTz().
    method public datetime-tz extent ReadDateTimeTzArray().

    method public logical ReadLogical().
    method public logical extent ReadLogicalArray().
    
    method public rowid ReadRowid().
    method public rowid extent ReadRowidArray().
    
    method public recid ReadRecid().
    method public recid extent ReadRecidArray().
    
    /** @param dataset-handle Can be called by-reference */
    method public void ReadDataset(input-output dataset-handle phValue).

    /** @param table-handle Can be called by-reference */    
    method public void ReadTable(input-output table-handle phValue).
    
    method public handle ReadHandle().
    method public handle extent ReadHandleArray().
        
end interface.
