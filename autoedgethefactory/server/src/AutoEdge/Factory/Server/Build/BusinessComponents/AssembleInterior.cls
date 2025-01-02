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
    File        : IAssembleInterior
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Nov 30 16:38:15 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using AutoEdge.Factory.Server.Build.BusinessComponents.AssembleInterior.
using AutoEdge.Factory.Server.Build.BusinessComponents.VehicleBuildStep.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

class AutoEdge.Factory.Server.Build.BusinessComponents.AssembleInterior inherits VehicleBuildStep:  
    
    constructor public AssembleInterior(input poComponentInfo as IComponentInfo  ):
        super (input poComponentInfo).
    end constructor.

    /* step */
    method override public void PerformStep():
        InstallUpholstery().
        InstallElectronics().
        InstallInteriorTrim().
        FitWindshield().
    end method.
    
    method protected void InstallUpholstery():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'InstallUpholstery').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'InstallUpholstery').
    end method.
    
    method protected void InstallElectronics():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'InstallElectronics').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'InstallElectronics').
    end method.
    
    method protected void InstallInteriorTrim():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'InstallInteriorTrim').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'InstallInteriorTrim').
    end method.
    
    method protected void FitWindshield():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'FitWindshield').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'FitWindshield').
    end method.
  
end class.
