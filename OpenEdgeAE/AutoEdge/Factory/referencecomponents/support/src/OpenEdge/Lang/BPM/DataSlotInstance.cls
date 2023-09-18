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
    File        : DataSlotInstance
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jul 06 12:13:31 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.BPM.DataSlotTemplate.

using OpenEdge.Lang.BPM.DataSlotTemplate.
using OpenEdge.Lang.BPM.SavvionType.

using OpenEdge.Core.XML.SaxReader.
using OpenEdge.Core.XML.SaxWriter.

using Progress.Lang.Object.

class OpenEdge.Lang.BPM.DataSlotInstance inherits SavvionType:
    
    define public property Choices as character no-undo get. set.
    define public property ReadOnly as logical no-undo get. set.
    define public property WriteOnly as logical no-undo get. set.
    define public property Name as character no-undo get. set.
    define public property ProcessInstanceId as int64 no-undo get. set.
    define public property ProcessTemplateId as int64 no-undo get. set.
    /* This is an XML schema type, not an ABL type. */
    define public property Type as character no-undo get. set.
    define public property Value as longchar no-undo get. set.
        
    define static private temp-table DataSlotInstance no-undo
        field Choices as character
        field ReadOnly as logical
        field WriteOnly as logical
        field Name as character
        field ProcessInstanceId as int64
        field ProcessTemplateId as int64
        field Type as character
        field DataSlotValue as character label 'Value'
        field DataSlotInstance as Object
        index idx1 as primary Name
        index idx2 DataSlotInstance.
    
    constructor public DataSlotInstance():
        super().
    end constructor.
    
    /** Returns a table handle for the type; typically this is an empty
        table and is used in for serializing the SavvionType objects
        
        @param table-handle The output table handle for the type. */
    method static public void GetTable(output table-handle phTable):
        phTable = temp-table DataSlotInstance:handle.
    end method.
    
    /** Serializes the SavvionType object to the input buffer handle. 
        
        @param handle The buffer handle into which the object is serialised. */
    method override public void ObjectToBuffer(input phBuffer as handle):
        assign phBuffer::Choices = this-object:Choices
               phBuffer::ReadOnly = this-object:ReadOnly
               phBuffer::WriteOnly = this-object:WriteOnly
               phBuffer::Name = this-object:Name
               phBuffer::ProcessInstanceId = this-object:ProcessInstanceId
               phBuffer::ProcessTemplateId = this-object:ProcessTemplateId
               phBuffer::Type = this-object:Type
               phBuffer::DataSlotValue = this-object:Value
               phBuffer::DataSlotInstance = this-object.
    end method.
    
    /** Serializes this instance of the type to XML, using a SAXWriter object.
        
        @param SaxWriter The SAX writer used to serialize the object.
        @param longchar The namespace used. */
    method override public void ObjectToXML(input poSaxWriter as SaxWriter,
                                            input pcNamespace as longchar):
        SavvionType:WriteElement(poSaxWriter,
                                 'choices', this-object:Choices,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'isReadOnly', this-object:ReadOnly,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'isWriteOnly', this-object:WriteOnly,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'name', this-object:Name,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'piid', this-object:ProcessInstanceId,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'ptid', this-object:ProcessTemplateId,
                                 pcNamespace).       
        SavvionType:WriteElement(poSaxWriter,
                                 'type', this-object:Type,
                                 pcNamespace).                                 
        SavvionType:WriteElement(poSaxWriter,
                                 'value', this-object:Value,
                                 pcNamespace,
                                 this-object:Type).
    end method.
    
    method override public void ReadElement(input pcElementName as longchar,
                                            input pcValue as longchar ):
        case string(pcElementName):
            when 'choices' then this-object:Choices = pcValue.
            when 'isReadOnly' then this-object:ReadOnly = logical(pcValue).
            when 'isWriteOnly' then this-object:WriteOnly = logical(pcValue).
            when 'name' then this-object:Name = pcValue.
            when 'piid' then this-object:ProcessInstanceId = int64(pcValue).
            when 'ptid' then this-object:ProcessTemplateId = int64(pcValue).
            when 'type' then this-object:Type = pcValue.
            when 'value' then this-object:Value = pcValue.
        end case.
    end method.
    
end class.
