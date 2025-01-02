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
    File        : WorkStepTemplate
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jul 06 12:03:30 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.WorkStepTemplateTypeEnum.
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.SavvionType.

using OpenEdge.Core.XML.SaxWriter.
using OpenEdge.Lang.TimeStamp.
using Progress.Lang.Object.

class OpenEdge.Lang.BPM.WorkStepTemplate inherits SavvionType:
    
    define public property Duration as int64 no-undo get. set.
    define public property Name as character no-undo get. set.
    define public property Performer as character no-undo get. set.
    define public property Priority as character no-undo get. set.
    define public property ProcessTemplateId as int64 no-undo get. set.
    define public property Type as WorkStepTemplateTypeEnum no-undo get. set.
    
    define static private temp-table WorkStepTemplate no-undo
        field Duration as int64
        field Name as character
        field Performer as character 
        field Priority as character 
        field ProcessTemplateId as int64 
        field Type as Object /* WorkStepTemplateTypeEnum */ 
        field WorkStepTemplate as Object /* WorkStepTemplate */
        index idx1 as primary name
        index idx2 WorkStepTemplate.

    constructor public WorkStepTemplate():
        super().
    end constructor.
    
    /** Returns a table handle for the type; typically this is an empty
        table and is used in for serializing the SavvionType objects
        
        @param table-handle The output table handle for the type. */
    method static public void GetTable(output table-handle phTable):
        phTable = temp-table WorkStepTemplate:handle.
    end method.

    /** Serializes the SavvionType object to the input buffer handle. 
        
        @param handle The buffer handle into which the object is serialised. */
    method override public void ObjectToBuffer(input phBuffer as handle):
        assign phBuffer::Duration = this-object:Duration
               phBuffer::Name = this-object:Name
               phBuffer::Performer = this-object:Performer
               phBuffer::Priority = this-object:Priority
               phBuffer::ProcessTemplateId = this-object:ProcessTemplateId
               phBuffer::Type = this-object:Type
               phBuffer::WorkStepTemplate = this-object.
    end method.
    
    method override public void ObjectToXML(input poSaxWriter as SaxWriter,
                                            input pcNamespace as longchar ):
        SavvionType:WriteElement(poSaxWriter,
                                 'duration', this-object:Duration,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'name', this-object:Name,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter, 
                                 'performer', this-object:Performer,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'priority', this-object:Priority, 
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'ptid', this-object:ProcessTemplateId,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'type', this-object:Type:ToString(),
                                 pcNamespace).
    end method.

    method override public void ReadElement(input pcElementName as longchar,
                                            input pcValue as longchar ):
        case string(pcElementName):
            when 'duration' then this-object:Duration = int(pcValue).
            when 'name' then this-object:Name = pcValue.
            when 'performer' then this-object:Performer = pcValue.
            when 'priority' then this-object:Priority = pcValue.
            when 'ptid' then this-object:ProcessTemplateId = int64(pcValue).
            when 'type' then this-object:Type = WorkStepTemplateTypeEnum:EnumFromString(string(pcValue)).
        end case.
    end method.
    
end class.
