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
    File        : IObjectOutput
    Purpose     : Object serialization/externalisation interface
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jan 25 10:10:35 EST 2011
    Notes       : * The Write*() and Write*Array() methods write the argument to the stream etc. 
                    They could have been simply named Write() and been overloaded by input
                    parameter; however, since the IObjectInput interface's analog Read*() and Read*Array()
                    methods return the data value (and don't use an OUTPUT parameter) since this
                    makes the Read a little easier to work with, the Write() methods follow
                    the same naming convention for consistency.
  ---------------------------------------------------------------------- */
using OpenEdge.Lang.EnumMember.
using Progress.Lang.Object.

interface OpenEdge.Core.Util.IObjectOutput:
    
    /** Resets/reinitialises the output */
    method public void Reset().
    
    /**  Writes the serialized output to the specified file 
         
         @param character The name of a file to write the output into. */
    method public void Write(input pcFileName as character).

    /**  Writes the serialized output to a memptr
         
         @param memptr The memprt into which to write the output. */    
    method public void Write(output pmStream as memptr).

    /**  Writes the serialized output to a CLOB
         
         @param longchar The CLOB into which to write the output. */        
    method public void Write(output pcStream as longchar).
    
    /** Write*() and Write*Array() methods to write individual members into the output.
        (see note above). */
    method public void WriteObject(input poValue as Object).
    method public void WriteObjectArray(input poValue as Object extent).
    
    method public void WriteEnum(input poMember as EnumMember).

    method public void WriteChar(input pcValue as character).
    method public void WriteCharArray(input pcValue as character extent).
    
    method public void WriteLongchar(input pcValue as longchar).
    method public void WriteLongcharArray(input pcValue as longchar extent).
    
    method public void WriteInt(input piValue as integer).
    method public void WriteIntArray(input piValue as integer extent).
    
    method public void WriteInt64(input piValue as int64).
    method public void WriteInt64Array(input piValue as int64 extent).
    
    method public void WriteDecimal(input pdValue as decimal).
    method public void WriteDecimalArray(input pdValue as decimal extent).
    
    method public void WriteDate(input ptValue as date).
    method public void WriteDateArray(input ptValue as date extent).

    method public void WriteDateTime(input ptValue as datetime).
    method public void WriteDateTimeArray(input ptValue as datetime extent).

    method public void WriteDateTimeTz(input ptValue as datetime-tz).
    method public void WriteDateTimeTzArray(input ptValue as datetime-tz extent).
    
    method public void WriteLogical(input plValue as logical).
    method public void WriteLogicalArray(input plValue as logical extent).
    
    method public void WriteRowid(input prValue as rowid).
    method public void WriteRowidArray(input prValue as rowid extent).
    
    method public void WriteRecid(input prValue as recid).
    method public void WriteRecidArray(input prValue as recid extent).
    
    method public void WriteDataset(input phValue as handle).
    method public void WriteTable(input phValue as handle).
    
    method public void WriteHandle(input phValue as handle).
    method public void WriteHandleArray(input phValue as handle extent).

end interface.
