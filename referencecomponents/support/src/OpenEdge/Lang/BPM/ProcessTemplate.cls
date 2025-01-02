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
    File        : ProcessTemplate
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Jul 06 11:57:08 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.ProcessTemplateStateEnum.
using OpenEdge.Lang.BPM.ProcessTemplate.
using OpenEdge.Lang.BPM.SavvionType.

using OpenEdge.Core.XML.SaxWriter.
using OpenEdge.Lang.TimeStamp.
using Progress.Lang.Object.

class OpenEdge.Lang.BPM.ProcessTemplate inherits SavvionType:
     
    define public property AppName as character no-undo get. set.
    define public property Category as character no-undo get. set.
    define public property Description as character no-undo get. set.
    define public property Group as character no-undo get. set.
    define public property Id as int64 no-undo get. set.
    define public property Manager as character no-undo get. set.
    define public property Name as character no-undo get. set.
    define public property Priority as character no-undo get. set.
    define public property StartTime as datetime-tz no-undo get. set.
    define public property State as ProcessTemplateStateEnum no-undo get. set.
    
    define static private temp-table ProcessTemplate no-undo
        field AppName as character 
        field Category as character 
        field Description as character 
        field ProcessTemplateGroup as character label 'Group' 
        field Id as int64 
        field Manager as character 
        field Name as character 
        field Priority as character 
        field StartTime as datetime-tz
        field State as Object /*ProcessTemplateStateEnum*/
        field ProcessTemplate as Object /* ProcessTemplate */    
        index idx1 as primary Id
        index idx2 ProcessTemplate.

    constructor public ProcessTemplate():
        super().
    end constructor.
    
    /** Returns a table handle for the type; typically this is an empty
        table and is used in for serializing the SavvionType objects
        
        @param table-handle The output table handle for the type. */
    method static public void GetTable(output table-handle phTable):
        phTable = temp-table ProcessTemplate:handle.
    end method.

    /** Serializes the SavvionType object to the input buffer handle. 
        
        @param handle The buffer handle into which the object is serialised. */
    method override public void ObjectToBuffer(input phBuffer as handle):
        assign phBuffer::AppName = this-object:AppName
               phBuffer::Category = this-object:Category
               phBuffer::Description = this-object:Description
               phBuffer::ProcessTemplateGrou = this-object:Group
               phBuffer::Id = this-object:Id
               phBuffer::Manager = this-object:Manager
               phBuffer::Name = this-object:Name
               phBuffer::Priority = this-object:Priority
               phBuffer::StartTime = this-object:StartTime
               phBuffer::State = this-object:State
               phBuffer::ProcessTemplate = this-object.
    end method.

    method override public void ObjectToXML(input poSaxWriter as SaxWriter,
                                            input pcNamespace as longchar ):
        SavvionType:WriteElement(poSaxWriter,
                                 'appName', this-object:AppName,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'category', this-object:Category,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'description', this-object:Description,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'group', this-object:Group,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'id', this-object:Id,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'manager', this-object:Manager,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'name', this-object:Name,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'priority', this-object:Priority, 
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'startTime', this-object:StartTime,
                                 pcNamespace).
        SavvionType:WriteElement(poSaxWriter,
                                 'state', this-object:State:ToString(),
                                 pcNamespace).
    end method.

    method override public void ReadElement(input pcElementName as longchar,
                                            input pcValue as longchar ):
        case string(pcElementName):
            when 'appName' then this-object:AppName = pcValue.
            when 'category' then this-object:Category = pcValue.
            when 'description' then this-object:Description = pcValue.
            when 'group' then this-object:Group = pcValue.
            when 'id' then this-object:Id = int64(pcValue).
            when 'manager' then this-object:Manager = pcValue.
            when 'name' then this-object:Name = pcValue.
            when 'priority' then this-object:Priority = pcValue.
            when 'startTime' then this-object:StartTime = TimeStamp:ToABLDateTimeFromISO(string(pcValue)).
            when 'state' then this-object:State = ProcessTemplateStateEnum:EnumFromString(string(pcValue)).
        end case.
    end method.
    
end class.
