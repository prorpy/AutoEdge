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
    File        : SaxWriterDataTypeEnum
    Purpose     : Enumeration of the types that the SAX-WRITER can write as values
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Nov 23 09:02:49 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.XML.SaxWriterDataTypeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Core.XML.SaxWriterDataTypeEnum inherits EnumMember:
    
    define static public property CData as SaxWriterDataTypeEnum  no-undo get. private set.
    define static public property Characters as SaxWriterDataTypeEnum  no-undo get. private set.
    define static public property Comment as SaxWriterDataTypeEnum  no-undo get. private set.
    define static public property EntityReference as SaxWriterDataTypeEnum  no-undo get. private set.
    define static public property Fragment as SaxWriterDataTypeEnum  no-undo get. private set.
        
    constructor static SaxWriterDataTypeEnum():
        SaxWriterDataTypeEnum:CData = new SaxWriterDataTypeEnum(1).
        SaxWriterDataTypeEnum:Characters = new SaxWriterDataTypeEnum(2).
        SaxWriterDataTypeEnum:Comment = new SaxWriterDataTypeEnum(3).
        SaxWriterDataTypeEnum:EntityReference = new SaxWriterDataTypeEnum(4).
        SaxWriterDataTypeEnum:Fragment = new SaxWriterDataTypeEnum(5).
    end constructor.
    
    constructor public SaxWriterDataTypeEnum(input piValue as integer):
        super (input piValue).
    end constructor.
    
end class.
