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
    File        : IProcessComponents
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Nov 30 16:14:50 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using AutoEdge.Factory.Server.Build.BusinessComponents.VehicleBuildStep.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

class AutoEdge.Factory.Server.Build.BusinessComponents.ProcessComponents inherits VehicleBuildStep:

    constructor public ProcessComponents(input poComponentInfo as IComponentInfo):
        super (input poComponentInfo).
    end constructor.
    
    /* step */
    method override public void PerformStep():
        AssembleSubcomponents().
    end method.
    
    /* substeps */
    method public void AssembleSubcomponents():
        BuildStatus = substitute('Substep &1 [ STARTING ]', 'AssembleSubcomponents').
        
        BuildStatus = substitute('Substep &1 [ OK ]', 'AssembleSubcomponents').
    end method.
    
end class.
