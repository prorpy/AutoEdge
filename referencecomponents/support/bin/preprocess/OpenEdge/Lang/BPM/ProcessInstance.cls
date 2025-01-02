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
    File        : ProcessInstance
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jul 06 12:11:46 EDT 2010
    Notes       : 
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.ProcessInstanceStateEnum.
using OpenEdge.Lang.BPM.ProcessInstance.
using OpenEdge.Lang.BPM.SavvionType.

using OpenEdge.Core.XML.SaxWriter.
using OpenEdge.Lang.TimeStamp.
using Progress.Lang.Object.

class OpenEdge.Lang.BPM.ProcessInstance inherits SavvionType:
    
    define public property Creator as character no-undo get. set.
    define public property DueDate as datetime-tz no-undo get. set.
    define public property Id as int64 no-undo get. set.
    define public property IsSubProcess as logical no-undo get. set.
    define public property IsSyncSubProcess as logical no-undo get. set.
    define public property Name as character no-undo get. set.
    define public property Priority as character no-undo get. set.
    define public property ProcessTemplateId as int64 no-undo get. set.
    define public property StartTime as datetime-tz no-undo get. set.
    define public property Status as ProcessInstanceStateEnum no-undo get. set.
    define public property SubProcess as logical no-undo get. set.
    define public property SyncSubProcess as logical no-undo get. set.
    
    define static private temp-table ProcessInstance no-undo
        field Creator as character
        field DueDate as datetime-tz
        field Id as int64 
        field IsSubProcess as logical 
        field IsSyncSubProcess as logical 
        field Name as character 
        field Priority as character 
        field ProcessTemplateId as int64 
        field StartTime as datetime-tz 
        field ProcessInstanceStatus as Object /* ProcessInstanceStateEnum */ label 'Status' 
        field SubProcess as logical
        field SyncSubProcess as logical 
        field ProcessInstance as Object /* ProcessInstance */
        index idx1 as primary Id
        index idx2 ProcessInstance.
    
    constructor public ProcessInstance():
        super().
    end constructor.

    /** Returns a table handle for the type; typically this is an empty
        table and is used in for serializing the SavvionType objects
        
        @param table-handle The output table handle for the type. */
    method static public void GetTable(output table-handle phTable):
        phTable = temp-table ProcessInstance:handle.
    end method.

    /** Serializes the SavvionType object to the input buffer handle. 
        
        @param handle The buffer handle into which the object is serialised. */
    method override public void ObjectToBuffer(input phBuffer as handle):
        assign phBuffer::Creator = this-object:Creator
               phBuffer::DueDate = this-object:DueDate
               phBuffer::Id = this-object:Id
               phBuffer::IsSubProcess = this-object:IsSubProcess
               phBuffer::IsSyncSubProcess = this-object:IsSyncSubProcess
               phBuffer::Name = this-object:Name
               phBuffer::Priority = this-object:Priority
               phBuffer::ProcessTemplateId = this-object:ProcessTemplateId
               phBuffer::StartTime = this-object:StartTime
               phBuffer::ProccessInstanceStatus = this-object:Status
               phBuffer::SubProcess = this-object:SubProcess
               phBuffer::SyncSubProcess = this-object:SyncSubProcess
               phBuffer::ProcessInstance = this-object.
    end method.

    method override public void ObjectToXML(input poSaxWriter as SaxWriter,
                                            input pcNamespace as longchar ):
        SavvionType:WriteElement(poSaxWriter,
                                 'creator', this-object:Creator,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'duedate', this-object:DueDate,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'id', this-object:Id,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'isSubProcess', this-object:IsSubProcess,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'isSyncSubProcess', this-object:IsSyncSubProcess,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'name', this-object:Name,
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
                                 'status', this-object:Status:ToString(),
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'subProcess', this-object:SubProcess,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'syncSubProcess', this-object:SyncSubProcess,
                                 pcNamespace).
    end method.

    method override public void ReadElement(input pcElementName as longchar,
                                            input pcValue as longchar ):
        case string(pcElementName):
            when 'creator' then this-object:Creator= pcValue.
            when 'dueDate' then this-object:DueDate = TimeStamp:ToABLDateTimeFromISO(string(pcValue)).
            when 'id' then this-object:Id = int64(pcValue).
            when 'isSubProcess' then this-object:IsSubProcess = logical(pcValue).
            when 'isSyncSubProcess' then this-object:IsSyncSubProcess = logical(pcValue).
            when 'name' then this-object:Name = pcValue.
            when 'priority' then this-object:Priority = pcValue.
            when 'ptid' then this-object:ProcessTemplateId = int64(pcValue).
            when 'startTime' then this-object:StartTime = TimeStamp:ToABLDateTimeFromISO(string(pcValue)).
            when 'status' then this-object:Status = ProcessInstanceStateEnum:EnumFromString(string(pcValue)).
            when 'subProcess' then this-object:SubProcess = logical(pcValue).
            when 'syncSubProcess' then this-object:SyncSubProcess = logical(pcValue).
        end case.
    end method.
    
end class.
