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
    File        : CompleteVehicleBuild
    Purpose     : The AutoEdge|TheFactory CompleteVehicleBuild workstep. This operates only on the
                  ABL part of the application; there's a decorator which allows us to add BPM 
                  functionality onto it. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Nov 30 16:39:34 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using AutoEdge.Factory.Server.Build.BusinessComponents.CompleteVehicleBuild.
using AutoEdge.Factory.Server.Build.BusinessComponents.VehicleBuildStep.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

class AutoEdge.Factory.Server.Build.BusinessComponents.CompleteVehicleBuild inherits VehicleBuildStep:
		
	constructor public CompleteVehicleBuild(input poComponentInfo as IComponentInfo ):
		super (input poComponentInfo).
	end constructor.
	
    method override public void PerformStep():
        QualityControlCheckEngine().
        QualityControlCheckBody().
        QualityControlAnalyzeRepair().
    end method.
    
    method protected void QualityControlCheckEngine():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'QualityControlCheckEngine').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'QualityControlCheckEngine').
    end method.
    
    method protected void QualityControlCheckBody():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'QualityControlCheckBody').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'QualityControlCheckBody').
    end method.
    
    method protected void QualityControlAnalyzeRepair():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'QualityControlAnalyzeRepair').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'QualityControlAnalyzeRepair').
    end method.
    

end class.
