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
    File        : ComponentKernelSettings
    Purpose     : Flags/settings for the InjectABL ComponentKernel 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Jun 01 16:20:42 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.KernelSettings.

class OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentKernelSettings inherits KernelSettings:
    
    define public property AutoStartComponents as logical no-undo get. set.
    define public property AutoStartServices   as logical no-undo get. set.
    define public property AutoStartManagers   as logical no-undo get. set.
    
    constructor public ComponentKernelSettings():
		super ().
		
		AutoStartComponents = true.
		AutoStartServices = true.
		AutoStartManagers = true.
	end constructor.

end class.
