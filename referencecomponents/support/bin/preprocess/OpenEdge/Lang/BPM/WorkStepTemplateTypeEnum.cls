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
    File        : WorkStepTemplateTypeEnum
    Purpose     : Enumeration of WorkStepTemplate types
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Nov 24 13:34:42 EST 2010
    Notes       : * As per Savvion documentation
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.WorkStepTemplateTypeEnum.
using OpenEdge.Lang.EnumMember.


class OpenEdge.Lang.BPM.WorkStepTemplateTypeEnum inherits EnumMember:
    
    define static public property Start as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property End as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property OrJoin as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property AndJoin as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property ParallelSplit as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property DecisionSplit as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property Atomic as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property External as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property WebService as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property MessageDriven as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property Notification as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property Nested as WorkStepTemplateTypeEnum no-undo get. private set.
    define static public property Delay as WorkStepTemplateTypeEnum no-undo get. private set.
        
    constructor static WorkStepTemplateTypeEnum():
        WorkStepTemplateTypeEnum:Start = new WorkStepTemplateTypeEnum('START').
        WorkStepTemplateTypeEnum:End = new WorkStepTemplateTypeEnum('END').
        WorkStepTemplateTypeEnum:OrJoin = new WorkStepTemplateTypeEnum('OR-JOIN').
        WorkStepTemplateTypeEnum:AndJoin = new WorkStepTemplateTypeEnum('AND-JOIN').
        WorkStepTemplateTypeEnum:ParallelSplit = new WorkStepTemplateTypeEnum('PARALLEL-SPLIT').
        WorkStepTemplateTypeEnum:DecisionSplit = new WorkStepTemplateTypeEnum('DECISION-SPLIT').
        WorkStepTemplateTypeEnum:Atomic = new WorkStepTemplateTypeEnum('ATOMIC').
        WorkStepTemplateTypeEnum:External = new WorkStepTemplateTypeEnum('EXTERNAL').
        WorkStepTemplateTypeEnum:WebService = new WorkStepTemplateTypeEnum('WEBSERVICE').
        WorkStepTemplateTypeEnum:MessageDriven = new WorkStepTemplateTypeEnum('MESSAGEDRIVEN').
        WorkStepTemplateTypeEnum:Notification = new WorkStepTemplateTypeEnum('NOTIFICATION').
        WorkStepTemplateTypeEnum:Nested = new WorkStepTemplateTypeEnum('NESTED').
        WorkStepTemplateTypeEnum:Delay = new WorkStepTemplateTypeEnum('DELAY').
    end constructor.        
        
    constructor public WorkStepTemplateTypeEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
    method static public WorkStepTemplateTypeEnum EnumFromString(input pcName as character):
        define variable oEnum as WorkStepTemplateTypeEnum no-undo.
        
        case pcName:
            when WorkStepTemplateTypeEnum:Start:ToString() then oEnum = WorkStepTemplateTypeEnum:Start.
            when WorkStepTemplateTypeEnum:End:ToString() then oEnum = WorkStepTemplateTypeEnum:End.
            when WorkStepTemplateTypeEnum:OrJoin:ToString() then oEnum = WorkStepTemplateTypeEnum:OrJoin.
            when WorkStepTemplateTypeEnum:AndJoin:ToString() then oEnum = WorkStepTemplateTypeEnum:AndJoin.
            when WorkStepTemplateTypeEnum:ParallelSplit:ToString() then oEnum = WorkStepTemplateTypeEnum:ParallelSplit.
            when WorkStepTemplateTypeEnum:DecisionSplit:ToString() then oEnum = WorkStepTemplateTypeEnum:DecisionSplit.
            when WorkStepTemplateTypeEnum:Atomic:ToString() then oEnum = WorkStepTemplateTypeEnum:Atomic.
            when WorkStepTemplateTypeEnum:External:ToString() then oEnum = WorkStepTemplateTypeEnum:External.
            when WorkStepTemplateTypeEnum:WebService:ToString() then oEnum = WorkStepTemplateTypeEnum:WebService.
            when WorkStepTemplateTypeEnum:MessageDriven:ToString() then oEnum = WorkStepTemplateTypeEnum:MessageDriven.
            when WorkStepTemplateTypeEnum:Notification:ToString() then oEnum = WorkStepTemplateTypeEnum:Notification.
            when WorkStepTemplateTypeEnum:Nested:ToString() then oEnum = WorkStepTemplateTypeEnum:Nested.
            when WorkStepTemplateTypeEnum:Delay:ToString() then oEnum = WorkStepTemplateTypeEnum:Delay.
        end case.
        return oEnum.
    end method.
    
end class.
