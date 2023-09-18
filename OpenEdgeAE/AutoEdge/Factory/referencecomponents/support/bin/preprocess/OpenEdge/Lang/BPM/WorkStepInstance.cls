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
   File        : WorkStepInstance
   Purpose     : 
   Syntax      : 
   Description : 
   @author pjudge
   Created     : Tue Jul 06 12:05:15 EDT 2010
   Notes       : 
 ---------------------------------------------------------------------- */
routine-level on error undo, throw.
  
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.SavvionType.

using OpenEdge.Core.XML.SaxWriter.
using OpenEdge.Lang.TimeStamp.
using Progress.Lang.Object.
 
class OpenEdge.Lang.BPM.WorkStepInstance inherits SavvionType:
     
    define public property DueDate as datetime-tz no-undo get. set.
    define public property LoopCounter as integer no-undo get. set.
    define public property Name as character no-undo get. set.
    define public property Performer as character no-undo get. set.
    define public property ProcessInstanceName as character no-undo get. set.
    define public property ProcessInstanceId as int64 no-undo get. set.
    define public property Priority as character no-undo get. set.
    define public property ProcessTemplateId as int64 no-undo get. set.
    define public property StartTime as datetime-tz no-undo get. set.
    define public property Status as character no-undo get. set.
    define public property Type as character no-undo get. set.
    
    define static private temp-table WorkStepInstance no-undo
        field DueDate as datetime-tz 
        field LoopCounter as integer 
        field Name as character 
        field Performer as character 
        field ProcessInstanceName as character 
        field ProcessInstanceId as int64 
        field Priority as character 
        field ProcessTemplateId as int64 
        field StartTime as datetime-tz 
        field WorkStepInstanceStatus as character label 'Status' 
        field Type as character
        field WorkStepInstance as Object /* WorkStepInstance */
        index idx1 as primary Name
        index idx2 WorkStepInstance.
    
    constructor public WorkStepInstance():
        super().
    end constructor.
    
    /** Returns a table handle for the type; typically this is an empty
        table and is used in for serializing the SavvionType objects
        
        @param table-handle The output table handle for the type. */
    method static public void GetTable(output table-handle phTable):
        phTable = temp-table WorkStepInstance:handle.
    end method.

    /** Serializes the SavvionType object to the input buffer handle. 
        
        @param handle The buffer handle into which the object is serialised. */
    method override public void ObjectToBuffer(input phBuffer as handle):
        assign phBuffer::DueDate = this-object:DueDate
               phBuffer::LoopCounter = this-object:LoopCounter
               phBuffer::Name = this-object:Name
               phBuffer::Performer = this-object:Performer
               phBuffer::ProcessInstanceName = this-object:ProcessInstanceName
               phBuffer::ProcessInstanceId = this-object:ProcessInstanceId
               phBuffer::Priority = this-object:Priority
               phBuffer::ProcessTemplateId = this-object:ProcessTemplateId
               phBuffer::StartTime = this-object:StartTime
               phBuffer::WorkStepInstanceStatus = this-object:Status
               phBuffer::Type = this-object:Type
               phBuffer::WorkStepInstance = this-object.
    end method.    
    
    method override public void ObjectToXML(input poSaxWriter as SaxWriter,
                                            input pcNamespace as longchar ):
        SavvionType:WriteElement(poSaxWriter,
                                 'duedate', this-object:DueDate,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'loopCounter', this-object:LoopCounter,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'name', this-object:Name,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'performer', this-object:Performer,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'piName', this-object:ProcessInstanceName,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'piid', this-object:ProcessInstanceId,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'priority', this-object:Priority, 
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'ptid', this-object:ProcessTemplateId,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'startTime', this-object:StartTime,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'status', this-object:Status,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'type', this-object:Type,
                                 pcNamespace).
    end method.

    method override public void ReadElement(input pcElementName as longchar,
                                            input pcValue as longchar ):
        case string(pcElementName):
            when 'duedate' then this-object:DueDate = TimeStamp:ToABLDateTimeFromISO(string(pcValue)).
            when 'loopCounter' then this-object:LoopCounter = int(pcValue).
            when 'name' then this-object:Name = pcValue.
            when 'performer' then this-object:Performer = pcValue.
            when 'piName' then this-object:ProcessInstanceName = pcValue.
            when 'piid' then this-object:ProcessInstanceId = int64(pcValue).
            when 'priority' then this-object:Priority = pcValue.
            when 'ptid' then this-object:ProcessTemplateId = int64(pcValue).
            when 'startTime' then this-object:StartTime = TimeStamp:ToABLDateTimeFromISO(string(pcValue)).
            when 'status' then this-object:Status = pcValue.
            when 'type' then this-object:Type = pcValue.
        end case.
    end method.
    
end class.
