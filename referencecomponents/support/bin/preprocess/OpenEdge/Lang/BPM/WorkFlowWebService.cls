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
    File        : WorkFlowWebService
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri Jul 02 15:16:37 EDT 2010
    Notes       : * Some of the operations herein - particularly those that have
                    primitive and/or void arguments (in and out) use the RUN syntax
                    and let the ABL perform the datatype transformations.
                    The other operations - those that use the complex types descended
                    from the SavvionType - construct SOAP messages coming and going. 
                    There are currently no mixed-mode calls (where the inputs are primitives and
                    the outputs SOAP) although that's probably a candidate for refactoring.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.WorkFlowWebService.
using OpenEdge.Lang.BPM.SavvionType.
using OpenEdge.Lang.BPM.ProcessTemplate.
using OpenEdge.Lang.BPM.ProcessInstance.
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.WorkStepTemplate.
using OpenEdge.Lang.BPM.WorkStepInstance.
using OpenEdge.Lang.BPM.DataSlotTemplate.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.BPM.Task.

using OpenEdge.Core.XML.WebServiceProtocol.
using OpenEdge.Core.XML.SaxWriter.

using OpenEdge.Lang.Assert.
using Progress.Lang.Object.
using Progress.Lang.Class.

class OpenEdge.Lang.BPM.WorkFlowWebService inherits WebServiceProtocol
        implements IBizLogicAPI:
    
    define private variable mcPortType as character initial 'WorkFlowWS' no-undo.
    define private variable moSaxWriter as SaxWriter no-undo.
    define private variable mhSoapMessage as memptr no-undo.
    
    /* The Savvion Session ID */
    define public property SessionId as longchar no-undo get. protected set.
    
    constructor public WorkFlowWebService(input pcHost as character):
        super('WorkFlowService',
              substitute('&1/sbm/services/BizLogic1?wsdl', pcHost),
              '').
        
        InitializeSaxWriter().
    end constructor.
    
    destructor public WorkFlowWebService():
        set-size(mhSoapMessage) = 0.
    end destructor.
    
/*  BizLogicAPI implementations */
    /** Re-estaablishes an existing session without requiring a new login.
        
        @param longchar An existing session id. */
    method public void EstablishSession(input pcSessionId as longchar):
        SessionId = pcSessionId.
    end method.
    
    /** Ends an existing session without performing a logout from the server. */
    method public void EndSession():
        SessionId = ''.
    end method.
    
    method public void Login(input pcUser as character,
                             input pcPassword as character):
        define variable cSessionId as longchar no-undo.
        
        ConnectService().
        
        run connect in ConnectPortType(mcPortType) (
                input pcUser,
                input pcPassword,
                output cSessionId).
        
        EstablishSession(cSessionId).
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public void Logout():
        Assert:ArgumentNotNullOrEmpty(this-object:SessionId, 'Session Id').
        
        ConnectService().
        
        run disconnect in ConnectPortType(mcPortType) (input this-object:SessionId).
        
        EndSession().
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.
    end method.
            
    method public character GetStatus().
        define variable cStatus as character no-undo.
        
        ConnectService().
        
        run getStatus in ConnectPortType(mcPortType) (output cStatus).
        
        return cStatus.        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public ProcessTemplate GetProcessTemplate(input pcProcessTemplateName as character):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oPT as SavvionType extent no-undo.
        define variable cOutputParam as longchar no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessTemplate'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        
        oPT = SavvionType:XMLToArray(cOutputParam,
                                     cOperation,
                                     Class:GetClass('OpenEdge.Lang.BPM.ProcessTemplate')).
        
        return cast(oPT[1] , ProcessTemplate).                                                             
    end method.
    
    method public logical IsSessionValid().
        define variable lValidSession as logical no-undo.
        
        ConnectService().
        
        run isSessionValid in ConnectPortType(mcPortType) (input this-object:SessionId, output lValidSession).
        
        return lValidSession.
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public ProcessTemplate extent GetUserAuthorizedProcessTemplateList():
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oPT as ProcessTemplate extent no-undo.
        define variable cOutputParam as longchar no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getUserAuthorizedProcessTemplateList'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).

        return cast(SavvionType:XMLToArray(
                        cOutputParam,
                        cOperation,
                        Class:GetClass('OpenEdge.Lang.BPM.ProcessTemplate'))
                , ProcessTemplate).    
    end method.
    
    method public void CompleteTask(input poTask as Task):
        CompleteWorkItem(
            poTask:WorkItem:Id,
            cast(poTask:DataSlots:Values:ToArray(), DataSlotInstance)).
    end method.
            
    method public void CompleteWorkItem(input pcWorkItemName as character,
                                        input poDataSlotInstance as DataSlotInstance extent):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'completeWorkItem'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiName', pcWorkItemName, cNamespace).
            if extent(poDataSlotInstance) ne ? then
                SavvionType:ArrayToXML(moSaxWriter,
                                       'dsi',
                                       cNamespace,
                                       poDataSlotInstance).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
    
    method public ProcessInstance extent GetProcessInstanceList():
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oPI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessInstanceList'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oPI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.ProcessInstance')).                         
        
        return cast(oPI, ProcessInstance).
    end method.
            
    method public void AssignWorkItem(input pcWorkItemName as character,
                                      input pcPerformer as character):
        ConnectService().
        
        run assignWorkItem in ConnectPortType(mcPortType) (
                    input this-object:SessionId,
                    input pcWorkItemName,
                    input pcPerformer).
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public int64 GetProcessTemplateID(input pcProcessTemplateName as character):
        define variable cPTId as int64 no-undo.
        
        ConnectService().
        
        run getProcessTemplateID in ConnectPortType(mcPortType) (
                    input this-object:SessionId,
                    input pcProcessTemplateName,
                    output cPTId).
                    
        return cPTId.
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public ProcessInstance CreateProcessInstance(input pcProcessTemplateName as character,
                                                        input pcProcessInstanceNamePrefix as character,
                                                        input pcPriority as character,
                                                        input poDataSlotTemplate as DataSlotTemplate extent):
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oPI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'createProcessInstance'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
            WriteElement('piNamePrefix', pcProcessInstanceNamePrefix, cNamespace).
            WriteElement('priority', pcPriority, cNamespace).
            if extent(poDataSlotTemplate) ne ? then
                SavvionType:ArrayToXML(moSaxWriter,
                                       'dst',
                                       cNamespace,
                                       poDataSlotTemplate).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oPI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.ProcessInstance')).                         
        
        return cast(oPI[1], ProcessInstance).
    end method.
            
    method public WorkStepInstance GetWorkStepInstance(input pcProcessInstanceName as character,
                                                       input pcWorkStepName as character):
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWSI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkStepInstance'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
            WriteElement('wsName', pcWorkStepName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWSI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkStepInstance')).
        
        return cast(oWSI[1], WorkStepInstance).
    end method.
            
    method public WorkStepTemplate GetWorkStepTemplate(input pcProcessTemplateName as character,
                                                       input pcWorkStepName as character):
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkStepTemplate'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
            WriteElement('wsName', pcWorkStepName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkStepTemplate')).
        
        return cast(oWST[1], WorkStepTemplate).
    end method.
    
    method public WorkItem extent GetAvailableWorkItemList():
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getAvailableWorkItemList'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkItem')).
        
        return cast(oWI, WorkItem).
    end method.
    
    
    method public Task extent GetAvailableTasks():
        return CreateTasks(GetAvailableWorkItemList()).
    end method.
    
    method public Task extent GetAssignedTasks():
        return CreateTasks(GetAssignedWorkItemList()).
    end method.
    
    /** Allows for lazy-loading of dataslots */
    method public Task extent CreateTasks(input poWorkItem as WorkItem extent).
        define variable oTask as Task extent no-undo.
        define variable oDSI as DataSlotInstance extent no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        iMax = extent(poWorkItem).
        extent(oTask) = iMax.
                
        do iLoop = 1 to iMax:
            oDSI = GetWorkItemDataSlots(poWorkItem[iLoop]:Id).
            oTask[iLoop] = new Task(poWorkItem[iLoop], oDSI).
        end.
        
        return oTask.
    end method.
            
    method public WorkItem extent GetAssignedWorkItemList().
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getAssignedWorkItemList'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkItem')).
        
        return cast(oWI, WorkItem).
    end method.
            
    method public ProcessInstance GetProcessInstance(input pcProcessInstanceName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oPI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessInstance'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oPI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.ProcessInstance')).                         
        
        return cast(oPI[1], ProcessInstance).
    end method.
            
    method public WorkItem GetWorkItem(input pcWorkItemName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkItem'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiName', pcWorkItemName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkItem')).
        
        return cast(oWI[1], WorkItem).
    end method.
            
    method public character extent GetProcessTemplateVersions(input pcApplicationName as character).
        
        define variable cPTVersion as character extent no-undo. 
         
        ConnectService().
        
        run getProcessTemplateVersions in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcApplicationName,
                 output cPTVersion).
        
        return cPTVersion.
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public void SetProcessInstancePriority(input pcProcessInstanceName as character,
                                                  input pcPriority as character).
        ConnectService().
        
        run setProcessInstancePriority in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessInstanceName,
                 input pcPriority).
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public longchar GetProcessTemplateXML(input pcProcessTemplateName as character).
        define variable cOutputParam as longchar no-undo.
        
        ConnectService().
        
        run getProcessTemplateXML in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessTemplateName,
                 output cOutputParam).
        
        return cOutputParam.
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public void RemoveProcessTemplate(input pcProcessTemplateName as character).
        ConnectService().
        
        run removeProcessTemplate in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessTemplateName).
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public void ResumeProcessInstance(input pcProcessInstanceName as character).
        ConnectService().
        
        run resumeProcessInstance in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessInstanceName).

        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public void SuspendProcessInstance(input pcProcessInstanceName as character).
        ConnectService().
        
        run suspendProcessInstance in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessInstanceName).

        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public logical IsProcessTemplateExist(input pcProcessTemplateName as character).
        define variable lPTExists as logical no-undo.
        
        ConnectService().
        
        run isProcessTemplateExist in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessTemplateName,
                 output lPTExists).

        return lPTExists.
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public WorkItem extent GetProxyAssignedWorkItemList().
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProxyAssignedWorkItemList'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkItem')).
        
        return cast(oWI, WorkItem).
    end method.
            
    method public WorkItem extent GetProxyAvailableWorkItemList().
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProxyAvailableWorkItemList'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkItem')).
        
        return cast(oWI, WorkItem).
    end method.
            
    method public WorkItem extent GetSuspendedWorkItemList().
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getSuspendedWorkItemList'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkItem')).
        
        return cast(oWI, WorkItem).
    end method.
            
    method public character extent GetUserAuthorizedProcessTemplateNames().
        define variable cTemplateName as character extent no-undo.
        
        ConnectService().
        
        run getUserAuthorizedProcessTemplateNames in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 output cTemplateName).

        return cTemplateName.                 
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public character GetProcessTemplateAppName(input pcProcessTemplateName as character).
        define variable cAppName as character no-undo.
        
        ConnectService().
        
        run getProcessTemplateAppName in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessTemplateName,
                 output cAppName).

        return cAppName.
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
            
    method public character GetProcessTemplateName(input pcProcessInstanceName as character).
        define variable cTemplateName as character no-undo.
        
        ConnectService().
        
        run getProcessTemplateNameFromProcessInstance in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessInstanceName,
                 output cTemplateName).

        return cTemplateName.                 
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public character GetProcessTemplateName(input piProcessTemplateId as int64).
        define variable cTemplateName as character no-undo.
        
        ConnectService().
        
        run getProcessTemplateNameFromProcessInstance in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input piProcessTemplateId,
                 output cTemplateName).

        return cTemplateName.                 
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public WorkStepTemplate extent GetProcessTemplateWorkSteps(input pcProcessTemplateName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessTemplateWorkSteps'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkStepTemplate')).
        
        return cast(oWST, WorkStepTemplate).
    end method.
            
    method public ProcessTemplate GetProcessTemplate(input piProcessTemplateId as int64).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oPT as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessTemplateFromID'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptid', string(piProcessTemplateId), cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oPT = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.ProcessTemplate')).
        
        return cast(oPT[1], ProcessTemplate).
    end method.
            
    method public DataSlotTemplate extent GetProcessTemplateDataSlots(input pcProcessTemplateName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oDST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessTemplateDataSlots'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oDST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotTemplate')).
        
        return cast(oDST, DataSlotTemplate).
    end method.
            
    method public DataSlotTemplate extent GetProcessTemplateDataSlot(input pcProcessTemplateName as character,
                                                                     input pcDataslotName as character extent).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oDST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessTemplateDataSlot'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
            if extent(pcDataslotName) ne ? then
                SavvionType:ArrayToXML(moSaxWriter,
                                       'dsName',
                                       cNamespace,
                                       pcDataslotName).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oDST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotTemplate')).
        
        return cast(oDST, DataSlotTemplate).
    end method.
            
    method public DataSlotInstance extent GetProcessInstanceDataSlots(input pcProcessInstanceName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oDST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessInstanceDataSlots'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oDST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).
        
        return cast(oDST, DataSlotInstance).
    end method.
            
    method public DataSlotInstance extent GetProcessInstanceDataSlot(input pcProcessInstanceName as character,
                                                                     input pcDataslotName as character extent).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oDST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessInstanceDataSlot'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
            if extent(pcDataslotName) ne ? then
                SavvionType:ArrayToXML(moSaxWriter,
                                       'dsName',
                                       cNamespace,
                                       pcDataslotName).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oDST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).
        
        return cast(oDST, DataSlotInstance).
    end method.
            
    method public DataSlotInstance extent GetProcessInstanceDataSlot(input piProcessInstanceId as int64,
                                                                             input pcDataslotName as character extent).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oDST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessInstanceDataSlotFromPiid'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piid', string(piProcessInstanceId), cNamespace).
            if extent(pcDataslotName) ne ? then
                SavvionType:ArrayToXML(moSaxWriter,
                                       'dsName',
                                       cNamespace,
                                       pcDataslotName).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oDST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).
        
        return cast(oDST, DataSlotInstance).
    end method.
            
    method public DataSlotInstance extent GetWorkStepInstanceDataSlots(input pcProcessInstanceName as character,
                                                                       input pcWorkstepInstanceName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oDST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkStepInstanceDataSlots'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
            WriteElement('wsName', pcWorkstepInstanceName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oDST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).
        
        return cast(oDST, DataSlotInstance).
    end method.
            
    method public DataSlotInstance extent GetWorkStepInstanceDataSlots(input piProcessInstanceId as int64,
                                                                               input pcWorkstepInstanceName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oDST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkStepInstanceDataSlotsFromPiid'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piid', string(piProcessInstanceId), cNamespace).
            WriteElement('wsiName', pcWorkstepInstanceName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oDST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).
        
        return cast(oDST, DataSlotInstance).
    end method.
            
    method public DataSlotInstance extent GetWorkItemDataSlots(input pcWorkItemName as character):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable cOutputParam as longchar no-undo.
        define variable oDataSlotInstance as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkItemDataSlots'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiName', pcWorkItemName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam =  ExecuteOperation(mcPortType,
                                         cOperation,
                                         SoapMessageToLongchar()).
        
        oDataSlotInstance = SavvionType:XMLToArray(
                                cOutputParam,
                                cOperation,
                                Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).
        
        return cast(oDataSlotInstance, DataSlotInstance). 
    end method.
            
    method public DataSlotInstance extent GetWorkItemDataSlots(input piWorkstepInstanceId as int64):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable cOutputParam as longchar no-undo.
        define variable oDataSlotInstance as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkItemDataSlotsFromWIID'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiid', string(piWorkstepInstanceId), cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam =  ExecuteOperation(mcPortType,
                                         cOperation,
                                         SoapMessageToLongchar()).
        
        oDataSlotInstance = SavvionType:XMLToArray(
                                cOutputParam,
                                cOperation,
                                Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance')).

        
        return cast(oDataSlotInstance, DataSlotInstance). 
    end method.
            
    method public DataSlotTemplate extent GetWorkStepTemplateDataSlots(input pcProcessTemplateName as character,
                                                                       input pcWorkStepName as character):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable cOutputParam as longchar no-undo.
        define variable oDataSlotTemplate as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkStepTemplateDataSlots'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
            WriteElement('wsName', pcWorkStepName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam =  ExecuteOperation(mcPortType,
                                         cOperation,
                                         SoapMessageToLongchar()).
        
        oDataSlotTemplate = SavvionType:XMLToArray(
                                cOutputParam,
                                cOperation,
                                Class:GetClass('OpenEdge.Lang.BPM.DataSlotTemplate')).
        
        return cast(oDataSlotTemplate, DataSlotTemplate). 
    end method.
    
    method public DataSlotTemplate extent GetWorkStepTemplateDataSlots(input piProcessTemplateId as int64,
                                                                               input pcWorkStepName as character):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable cOutputParam as longchar no-undo.
        define variable oDataSlotTemplate as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkStepTemplateDataSlotsFromPtid'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptid', string(piProcessTemplateId), cNamespace).
            WriteElement('wsName', pcWorkStepName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam =  ExecuteOperation(mcPortType,
                                         cOperation,
                                         SoapMessageToLongchar()).
        
        oDataSlotTemplate = SavvionType:XMLToArray(
                                cOutputParam,
                                cOperation,
                                Class:GetClass('OpenEdge.Lang.BPM.DataSlotTemplate')).
        
        return cast(oDataSlotTemplate, DataSlotTemplate).    
    end method.
            
    method public void SetProcessTemplateDataSlotValue(input pcProcessTemplateName as character,
                                                       input poDataSlotTemplate as DataSlotTemplate):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'setProcessTemplateDataSlotValue'.
        extent(oST) = 1.
        oST[1] = poDataSlotTemplate.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
            SavvionType:ArrayToXML(moSaxWriter,
                                   'dst',
                                   cNamespace,
                                   oST).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
            
    method public void SetProcessTemplateDataSlotsValue(input pcProcessTemplateName as character,
                                                        input poDataSlotTemplate as DataSlotTemplate extent).
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'setProcessTemplateDataSlotsValue'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
            SavvionType:ArrayToXML(moSaxWriter,
                                   'dst',
                                   cNamespace,
                                   poDataSlotTemplate).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
    
    method public void SetProcessInstanceDataSlotValue(input pcProcessInstanceName as character,
                                                       input poDataSlotInstance as DataSlotInstance):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'setProcessTemplateDataSlotValue'.
        extent(oST) = 1.
        oST[1] = poDataSlotInstance.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
            SavvionType:ArrayToXML(moSaxWriter,
                                   'dsi',
                                   cNamespace,
                                   oST).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
            
    method public void SetProcessInstanceDataSlotsValue(input pcProcessInstanceName as character,
                                                        input poDataSlotInstance as DataSlotInstance extent):
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'setProcessInstanceDataSlotsValue'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
            SavvionType:ArrayToXML(moSaxWriter,
                                   'dsi',
                                   cNamespace,
                                   poDataSlotInstance).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
            
    method public void SetWorkItemDataSlotsValue(input pcWorkItemName as character,
                                                 input poDataSlotInstance as DataSlotInstance extent).
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'setWorkItemDataSlotsValue'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiName', pcWorkItemName, cNamespace).
            SavvionType:ArrayToXML(moSaxWriter,
                                   'dsi',
                                   cNamespace,
                                   poDataSlotInstance).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
            
    method public void SetWorkItemDataSlotValue(input pcWorkItemName as character,
                                                input poDataSlotInstance as DataSlotInstance).
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'setWorkItemDataSlotValue'.
        extent(oST) = 1.
        oST[1] = poDataSlotInstance.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiName', pcWorkItemName, cNamespace).
            SavvionType:ArrayToXML(moSaxWriter,
                                   'dsi',
                                   cNamespace,
                                   oST).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
            
    method public ProcessInstance GetProcessInstance(input piProcessInstanceId as int64):
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oPI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessInstanceFromID'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piid', string(piProcessInstanceId), cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oPI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.ProcessInstance')).
        
        return cast(oPI[1], ProcessInstance).
    end method.
            
    method public void SetProcessInstanceDueDate(input pcProcessInstanceName as character,
                                                 input ptDueDate as datetime-tz):
        ConnectService().
        
        run setProcessInstanceDueDate in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessInstanceName,
                 input ptDueDate).
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public WorkItem GetWorkItem(input piWorkItemInstanceId as int64):
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkItemFromID'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiid', string(piWorkItemInstanceId), cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkItem')).
        
        return cast(oWI[1], WorkItem).
    end method.
            
    method public void SuspendWorkItem(input pcWorkItemName as character).

        ConnectService().
        
        run suspendWorkItem in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcWorkItemName).        
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
                
    method public void ResumeWorkItem(input pcWorkItemName as character).
        ConnectService().
        
        run resumeWorkItem in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcWorkItemName).        
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public void AssignWorkItem(input piWorkItemInstanceId as int64,
                                              input pcPerformer as character).
        ConnectService().
        
        run assignWorkItemFromWiid in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input piWorkItemInstanceId,
                 input pcPerformer).        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public void ReassignWorkItem(input pcWorkItemName as character,
                                        input pcPerformer as character).
        ConnectService().
        
        run reassignWorkItem in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcWorkItemName,
                 input pcPerformer).        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
          
    method public void ReassignWorkItem(input piWorkItemInstanceId as int64,
                                                input pcPerformer as character).
        ConnectService().
        
        run reassignWorkItemFromWiid in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input piWorkItemInstanceId,
                 input pcPerformer).        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public void MakeAvailableWorkItem(input pcWorkItemName as character,
                                             input pcPerformers as character extent).
        ConnectService().
        
        run makeAvailableWorkItem in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcWorkItemName,
                 input pcPerformers).        
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public void MakeAvailableWorkItem(input piWorkItemInstanceId as int64,
                                                     input pcPerformers as character extent).
        ConnectService().
        
        run makeAvailableWorkItemFromWiid in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input piWorkItemInstanceId,
                 input pcPerformers).
                   
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public void CompleteWorkItem(input piWorkItemInstanceId as int64,
                                                input poDataSlotInstance as DataSlotInstance extent).
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'completeWorkItemFromWIID'.
        
        StartSoapMessage(cOperation, cNamespace).        
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('wiid', string(piWorkItemInstanceId), cNamespace).        
            if extent(poDataSlotInstance) ne ? then
                SavvionType:ArrayToXML(moSaxWriter,
                                       'dsi',
                                       cNamespace,
                                       poDataSlotInstance).
        EndSoapMessage(cOperation, cNamespace).
        
        ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
    end method.
    
    method public WorkStepInstance GetWorkStepInstance(input piProcessInstanceId as int64,
                                                               input pcWorkStepName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWSI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getWorkStepInstanceFromPiid'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piid', string(piProcessInstanceId), cNamespace).
            WriteElement('wsName', pcWorkStepName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWSI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkStepInstance')).
        
        return cast(oWSI[1], WorkStepInstance).
    end method.
    
    method public WorkStepInstance extent GetProcessInstanceWorkSteps(input pcProcessInstanceName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWSI as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getProcessInstanceWorkSteps'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('piName', pcProcessInstanceName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWSI = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkStepInstance')).
        
        return cast(oWSI, WorkStepInstance).
    end method.
    
    method public void SuspendWorkStepInstance(input pcProcessInstanceName as character,
                                               input pcWorkStepName as character).
        ConnectService().
        
        run suspendWorkStepInstance in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessInstanceName,
                 input pcWorkStepName).
        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public void ResumeWorkStepInstance(input pcProcessInstanceName as character,
                                              input pcWorkStepName as character).
        ConnectService().
        
        run resumeWorkStepInstance in ConnectPortType(mcPortType)
                (input this-object:SessionId,
                 input pcProcessInstanceName,
                 input pcWorkStepName).        
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.        
    end method.
    
    method public WorkStepTemplate extent GetStartWorkStepTemplate(input pcProcessTemplateName as character).
        define variable cOutputParam as longchar no-undo.
        define variable cNamespace as character no-undo.
        define variable cOperation as character no-undo.
        define variable oWST as SavvionType extent no-undo.
        
        cNamespace = 'ns0'.
        cOperation = 'getStartWorkStepTemplate'.
        
        StartSoapMessage(cOperation, cNamespace).
            WriteElement('session', this-object:SessionId, cNamespace).
            WriteElement('ptName', pcProcessTemplateName, cNamespace).
        EndSoapMessage(cOperation, cNamespace).
        
        cOutputParam = ExecuteOperation(mcPortType,
                         cOperation,
                         SoapMessageToLongchar()).
        oWST = SavvionType:XMLToArray(cOutputParam,
                    cOperation,
                    Class:GetClass('OpenEdge.Lang.BPM.WorkStepTemplate')).
        
        return cast(oWST, WorkStepTemplate).
    end method.
    
/* SOAP Message Helper methods */
    method protected void InitializeSaxWriter():   
        moSaxWriter = new SaxWriter().
        moSaxWriter:IsFragment = true.
        moSaxWriter:IsStrict = false.
        /* for debugging 
        moSaxWriter:IsFormatted = true.
        */
        
        moSaxWriter:WriteTo(mhSoapMessage).
    end method.
    
    method protected void ResetSaxWriter():
        if not moSaxWriter:Reset() then
            InitializeSaxWriter().
        
        /* no leaks, please */
        set-size(mhSoapMessage) = 0.        
    end method.
    
    method protected void StartSoapMessage(input pcElementName as character,
                                           input pcNamespace as character):
        ResetSaxWriter().
        
        moSaxWriter:StartDocument().
        moSaxWriter:StartElement(substitute('&1:&2', pcNamespace, pcElementName)).
        
        /* standard namespaces */
        moSaxWriter:DeclareNamespace("http://workflow.webservice.savvion.com", pcNamespace).
        moSaxWriter:DeclareNamespace("http://www.w3.org/2001/XMLSchema-instance", 'xsi').        
        moSaxWriter:DeclareNamespace("http://www.w3.org/2001/XMLSchema", 'xsd').
    end method.

    method protected void WriteElement(input pcElementName as character,
                                       input pcValue as longchar,
                                       input pcNamespace as character):
        moSaxWriter:StartElement(substitute('&1:&2', pcNamespace, pcElementName)).
        moSaxWriter:WriteValue(pcValue).
        moSaxWriter:EndElement(substitute('&1:&2', pcNamespace, pcElementName)).
    end method.
    
    method protected void EndSoapMessage(input pcElementName as character,
                                         input pcNamespace as character):
        moSaxWriter:EndElement(substitute('&1:&2', pcNamespace, pcElementName)).
        moSaxWriter:EndDocument().
    end method.
    
    /** Converts the current soap message to LONGCHAR for use as an operation.
        
        @return longchar The current SOAP message.  */
    method protected longchar SoapMessageToLongchar():        
        define variable cMessage as longchar no-undo.
        
        copy-lob mhSoapMessage to cMessage.
        set-size(mhSoapMessage) = 0.
        
        return cMessage.
    end method.
        
end class.
