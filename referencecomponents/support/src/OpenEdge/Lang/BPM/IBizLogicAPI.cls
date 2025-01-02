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
    File        : IBizLogicAPI
    Purpose     : ABL interface into the Savvion BizLogic API
    Syntax      :
    Description :
    @author pjudge
    Created     : Mon Nov 22 12:18:05 EST 2010
    Notes       :
  ---------------------------------------------------------------------- */
using OpenEdge.Lang.BPM.IBizLogicAPI.

using OpenEdge.Lang.BPM.ProcessTemplate.
using OpenEdge.Lang.BPM.ProcessInstance.
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.WorkStepTemplate.
using OpenEdge.Lang.BPM.WorkStepInstance.
using OpenEdge.Lang.BPM.DataSlotTemplate.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.BPM.Task.

interface OpenEdge.Lang.BPM.IBizLogicAPI:

    /* The Savvion Session ID */
    define public property SessionId as longchar no-undo get.

    /** Connects to a Savvion server, and establishes a session.

        @param character Username
        @param character Password  */
    method public void Login(input pcUser as character,
                             input pcPassword as character).

    /** Re-estaablishes an existing session without requiring a new login.

        @param longchar An existing session id. */
    method public void EstablishSession(input pcSessionId as longchar).

    /** Ends an existing session without performing a logout from the server. */
    method public void EndSession().

    /** Disconnects the specified session

        @param character A unique session id for the session. */
    method public void Logout().

    method public character GetStatus().

    method public ProcessTemplate GetProcessTemplate(input pcProcessTemplateName as character).

    method public ProcessTemplate GetProcessTemplate(input piProcessTemplateId as int64).

    method public logical IsSessionValid().

    method public ProcessTemplate extent GetUserAuthorizedProcessTemplateList().

    method public void CompleteWorkItem(input pcWorkItemName as character,
                                        input poDataSlotInstance as DataSlotInstance extent).

    method public void CompleteWorkItem(input piWorkItemInstanceId as int64,
                                        input poDataSlotInstance as DataSlotInstance extent).

    method public ProcessInstance extent GetProcessInstanceList().

    method public void AssignWorkItem(input pcWorkItemName as character,
                                      input pcPerformer as character).
    method public void AssignWorkItem(input piWorkItemInstanceId as int64,
                                      input pcPerformer as character).

    /* @param character A unique session id for the session. */
    method public int64 GetProcessTemplateID(input pcProcessTemplateName as character).

    /* @param character A unique session id for the session. */
    method public ProcessInstance CreateProcessInstance(input pcProcessTemplateName as character,
                                                        input pcProcessInstanceNamePrefix as character,
                                                        input pcPriority as character,
                                                        input poDataSlotTemplate as DataSlotTemplate extent).

    method public WorkStepInstance GetWorkStepInstance(input pcProcessInstanceName as character,
                                                       input pcWorkStepName as character).

    method public WorkStepInstance GetWorkStepInstance(input piProcessInstanceId as int64,
                                                       input pcWorkStepName as character).

    method public WorkStepTemplate GetWorkStepTemplate(input pcProcessTemplateName as character,
                                                       input pcWorkStepName as character).

    method public WorkItem extent GetAvailableWorkItemList().
    method public WorkItem extent GetAssignedWorkItemList().

    /** Tasks are not a complex type in Savvion, but are a logical type (workitems + their dataslots) */
    method public Task extent GetAvailableTasks().
    method public Task extent GetAssignedTasks().

    @todo(task="implement", action="").
    /* returns the tasks for a particular process (template, not instance)
    method public Task extent GetAvailableTasks(input piProcessTemplateId as int64).
    method public Task extent GetAssignedTasks(input piProcessTemplateId as int64).
    */

    /** Allows for lazy-loading of dataslots */
    method public Task extent CreateTasks(input poWorkItem as WorkItem extent).
    method public void CompleteTask(input poTask as Task).

    method public ProcessInstance GetProcessInstance(input pcProcessInstanceName as character).
    method public ProcessInstance GetProcessInstance(input piProcessInstanceId as int64).

    method public WorkItem GetWorkItem(input pcWorkItemName as character).
    method public WorkItem GetWorkItem(input piWorkItemInstanceId as int64).

    method public character extent GetProcessTemplateVersions(input pcApplicationName as character).

    method public void SetProcessInstancePriority(input pcProcessInstanceName as character,
                                                  input pcPriority as character).

    method public longchar GetProcessTemplateXML(input pcProcessTemplateName as character).

    method public void RemoveProcessTemplate(input pcProcessTemplateName as character).

    method public void ResumeProcessInstance(input pcProcessInstanceName as character).

    method public void SuspendProcessInstance(input pcProcessInstanceName as character).

    method public logical IsProcessTemplateExist(input pcProcessTemplateName as character).

    method public WorkItem extent GetProxyAssignedWorkItemList().

    method public WorkItem extent GetProxyAvailableWorkItemList().

    method public WorkItem extent GetSuspendedWorkItemList().

    method public character extent GetUserAuthorizedProcessTemplateNames().

    method public character GetProcessTemplateAppName(input pcProcessTemplateName as character).

    method public character GetProcessTemplateName(input pcProcessInstanceName as character).
    method public character GetProcessTemplateName(input piProcessTemplateId as int64).

    method public WorkSteptemplate extent GetProcessTemplateWorkSteps(input pcProcessTemplateName as character).

    method public DataSlotTemplate extent GetProcessTemplateDataSlots(input pcProcessTemplateName as character).

    method public DataSlotTemplate extent GetProcessTemplateDataSlot(input pcProcessTemplateName as character,
                                                                     input pcDataslotName as character extent).

    method public DataSlotInstance extent GetProcessInstanceDataSlots(input pcProcessInstanceName as character).

    method public DataSlotInstance extent GetProcessInstanceDataSlot(input pcProcessInstanceName as character,
                                                                     input pcDataslotName as character extent).

    method public DataSlotInstance extent GetProcessInstanceDataSlot(input piProcessInstanceId as int64,
                                                                     input pcDataslotName as character extent).

    method public DataSlotInstance extent GetWorkStepInstanceDataSlots(input pcProcessInstanceName as character,
                                                                       input pcWorkstepInstanceName as character).
    method public DataSlotInstance extent GetWorkStepInstanceDataSlots(input piProcessInstanceId as int64,
                                                                       input pcWorkstepInstanceName as character).

    method public DataSlotInstance extent GetWorkItemDataSlots(input pcWorkItemName as character).
    method public DataSlotInstance extent GetWorkItemDataSlots(input piWorkstepInstanceId as int64).

    method public DataSlotTemplate extent GetWorkStepTemplateDataSlots(input pcProcessTemplateName as character,
                                                                       input pcWorkStepName as character).
    method public DataSlotTemplate extent GetWorkStepTemplateDataSlots(input piProcessTemplateId as int64,
                                                                       input pcWorkStepName as character).

    method public void SetProcessTemplateDataSlotValue(input pcProcessTemplateName as character,
                                                       input poDataSlotTemplate as DataSlotTemplate).

    method public void SetProcessTemplateDataSlotsValue(input pcProcessTemplateName as character,
                                                        input poDataSlotTemplate as DataSlotTemplate extent).

    method public void SetProcessInstanceDataSlotValue(input pcProcessInstanceName as character,
                                                       input poDataSlotInstance as DataSlotInstance).

    method public void SetProcessInstanceDataSlotsValue(input pcProcessInstanceName as character,
                                                        input poDataSlotInstance as DataSlotInstance extent).

    method public void SetWorkItemDataSlotsValue(input pcWorkItemName as character,
                                                 input poDataSlotInstance as DataSlotInstance extent).

    method public void SetWorkItemDataSlotValue(input pcWorkItemName as character,
                                                input poDataSlotInstance as DataSlotInstance).

    method public void SetProcessInstanceDueDate(input pcProcessInstanceName as character,
                                                 input ptDueDate as datetime-tz).

    method public void SuspendWorkItem(input pcWorkItemName as character).

    method public void ResumeWorkItem(input pcWorkItemName as character).

    method public void ReassignWorkItem(input pcWorkItemName as character,
                                        input pcPerformer as character).
    method public void ReassignWorkItem(input piWorkItemInstanceId as int64,
                                        input pcPerformer as character).

    method public void MakeAvailableWorkItem(input pcWorkItemName as character,
                                             input pcPerformers as character extent).
    method public void MakeAvailableWorkItem(input piWorkItemInstanceId as int64,
                                             input pcPerformers as character extent).

    method public WorkStepInstance extent GetProcessInstanceWorkSteps(input pcProcessInstanceName as character).

    method public void SuspendWorkStepInstance(input pcProcessInstanceName as character,
                                               input pcWorkStepName as character).

    method public void ResumeWorkStepInstance(input pcProcessInstanceName as character,
                                              input pcWorkStepName as character).

    method public WorkSteptemplate extent GetStartWorkStepTemplate(input pcProcessTemplateName as character).

end interface.
