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
    File        : WorkItem
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jul 06 11:59:56 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.PriorityEnum.
using OpenEdge.Lang.BPM.WorkItemStatusEnum.  
using OpenEdge.Lang.BPM.SavvionType.

using OpenEdge.Core.XML.SaxWriter.
using OpenEdge.Lang.TimeStamp.
using Progress.Lang.Object.

class OpenEdge.Lang.BPM.WorkItem inherits SavvionType:
    
    define public property DueDate as datetime-tz no-undo get. set.
    define public property Id as int64 no-undo get. set.
    define public property Name as character no-undo get. set.
    define public property Performer as character no-undo get. set.
    define public property ProcessInstanceCreator as character no-undo get. set.
    define public property ProcessInstanceName as character no-undo get. set.
    define public property ProcessInstanceId as int64 no-undo get. set.
    define public property Priority as PriorityEnum no-undo get. set.
    define public property ProcessTemplateId as int64 no-undo get. set.
    define public property Status as WorkItemStatusEnum no-undo get. set.
    define public property TimeStarted as datetime-tz no-undo get. set.
    define public property WorkStepName as character no-undo get. set.
    
    define static private temp-table WorkItem no-undo
        field DueDate as datetime-tz
        field Id as int64
        field Name as character
        field Performer as character
        field ProcessInstanceCreator as character
        field ProcessInstanceName as character
        field ProcessInstanceId as int64
        field Priority as Object /*PriorityEnum*/ 
        field ProcessTemplateId as int64
        field WorkStepStatus as Object /*WorkItemStatusEnum*/ label 'Status'
        field TimeStarted as datetime-tz
        field WorkStepName as character
        field WorkItem as Object    /* WorkItem */
        index idx1 as primary Id
        index idx2 WorkItem.

    constructor public WorkItem():
        super().
    end constructor.

    /** Returns a table handle for the type; typically this is an empty
        table and is used in for serializing the SavvionType objects
        
        @param table-handle The output table handle for the type. */
    method static public void GetTable(output table-handle phTable):
        phTable = temp-table WorkItem:handle.
    end method.
    
    /** Serializes the SavvionType object to the input buffer handle. 
        
        @param handle The buffer handle into which the object is serialised. */
    method override public void ObjectToBuffer(input phBuffer as handle):
        assign phBuffer::DueDate = this-object:DueDate
               phBuffer::Id = this-object:Id
               phBuffer::Name = this-object:Name
               phBuffer::Performer = this-object:Performer
               phBuffer::ProcessInstanceCreator = this-object:ProcessInstanceCreator
               phBuffer::ProcessInstanceName = this-object:ProcessInstanceName
               phBuffer::ProcessInstanceId = this-object:ProcessInstanceId
               phBuffer::Priority = this-object:Priority
               phBuffer::ProcessTemplateId = this-object:ProcessTemplateId
               phBuffer::WorkItemStatus = this-object:Status
               phBuffer::TimeStarted = this-object:TimeStarted
               phBuffer::WorkStepName = this-object:WorkStepName
               phBuffer::WorkItem = this-object.
    end method.
    
    method override public void ObjectToXML(input poSaxWriter as SaxWriter,
                                            input pcNamespace as longchar ):
        SavvionType:WriteElement(poSaxWriter,
                                 'duedate', this-object:DueDate,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'id', this-object:Id,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'name', this-object:Name,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'performer', this-object:Performer,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'piCreator', this-object:ProcessInstanceCreator,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'piName', this-object:ProcessInstanceName,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'piid', this-object:ProcessInstanceId,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'priority', this-object:Priority:ToString(), 
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'ptid', this-object:ProcessTemplateId,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'status', this-object:Status:ToString(),
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'timeStarted', this-object:TimeStarted,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'wsName', this-object:WorkStepName,
                                 pcNamespace).
    end method.
    
    method override public void ReadElement(input pcElementName as longchar,
                                            input pcValue as longchar ):
        case string(pcElementName):
            when 'duedate' then this-object:DueDate = TimeStamp:ToABLDateTimeFromISO(string(pcValue)).
            when 'id' then this-object:Id = int64(pcValue).
            when 'name' then this-object:Name = pcValue.
            when 'performer' then this-object:Performer = pcValue.
            when 'piCreator' then this-object:ProcessInstanceCreator = pcValue.
            when 'piName' then this-object:ProcessInstanceName = pcValue.
            when 'piid' then this-object:ProcessInstanceId = int64(pcValue).
            when 'priority' then this-object:Priority = PriorityEnum:EnumFromString(string(pcValue)).
            when 'ptid' then this-object:ProcessTemplateId = int64(pcValue).
            when 'status' then this-object:Status = WorkItemStatusEnum:EnumFromString(string(pcValue)).
            when 'timeStarted' then this-object:TimeStarted = TimeStamp:ToABLDateTimeFromISO(string(pcValue)).
            when 'wsName' then this-object:WorkStepName = pcValue.
        end case.
    end method.
    
    method override public logical Equals( input p0 as Object ):
        define variable lEquals as logical no-undo.
        
        lEquals = super:Equals(input p0).
        if not lEquals then
            lEquals = type-of(p0, WorkItem).
        if lEquals then
            lEquals = this-object:Id eq cast(p0, WorkItem):Id.
        
        return lEquals.

	end method.

end class.
