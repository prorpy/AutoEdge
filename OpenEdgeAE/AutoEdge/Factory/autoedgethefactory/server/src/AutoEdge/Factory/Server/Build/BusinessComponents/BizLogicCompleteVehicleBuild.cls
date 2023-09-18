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
    File        : BizLogicCompleteVehicleBuild
    Purpose     : The OEBPM CompleteVehicleBuild workstep. This decorates the ABL-only step.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 20 16:48:52 EDT 2011
    Notes       : 
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.WorkFlow.BizLogicWorkStep.
using OpenEdge.BusinessComponent.WorkFlow.IWorkStep.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IWorkstepRequest.

using OpenEdge.Lang.BPM.DataSlotInstance.

class AutoEdge.Factory.Server.Build.BusinessComponents.BizLogicCompleteVehicleBuild inherits BizLogicWorkStep: 
    
	constructor public BizLogicCompleteVehicleBuild (input poWorkStep as IWorkStep, input pcBpmServerName as character ):
		super (input poWorkStep, input pcBpmServerName).
	end constructor.

    method override public void PerformStep():
        define variable cDSName as character extent 1 no-undo.
        define variable cDSValue as character extent 1 no-undo.
        define variable oDSI as DataSlotInstance extent no-undo.
        
        super:PerformStep().
        
        CompleteWorkItem(oDSI).
        
        cDSName[1] = 'VehicleBuildComplete'.
        cDSValue[1] = 'true'.
        
        UpdateDataSlotValue(cDSName, cDSValue).
    end method.
    
end class.
