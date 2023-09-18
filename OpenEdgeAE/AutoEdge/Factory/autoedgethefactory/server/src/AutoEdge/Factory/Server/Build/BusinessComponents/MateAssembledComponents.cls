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
    File        : IMateAssembledComponents
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Nov 30 16:38:54 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using AutoEdge.Factory.Server.Build.BusinessComponents.MateAssembledComponents.
using AutoEdge.Factory.Server.Build.BusinessComponents.VehicleBuildStep.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

class AutoEdge.Factory.Server.Build.BusinessComponents.MateAssembledComponents inherits VehicleBuildStep:
    
    constructor public MateAssembledComponents(input poComponentInfo as IComponentInfo  ):
        super (input poComponentInfo).
    end constructor.
    
    method override public void PerformStep():
        MateChassisAndBody().
        InstallFinalTrim().
        InstallWheels().
        FillFluids().
        EngineStartAndDriveoff().
    end method.
      
    method public void MateChassisAndBody():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'MateChassisAndBody').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'MateChassisAndBody').
    end method.
        
    method public void InstallFinalTrim():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'InstallFinalTrim').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'InstallFinalTrim').
    end method.
    
    method public void InstallWheels():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'InstallWheels').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'InstallWheels').
    end method.
    
    method public void FillFluids():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'FillFluids').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'FillFluids').
    end method.
    
    method public void EngineStartAndDriveoff():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'EngineStartAndDriveoff').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'EngineStartAndDriveoff').
    end method.
      
end class.
