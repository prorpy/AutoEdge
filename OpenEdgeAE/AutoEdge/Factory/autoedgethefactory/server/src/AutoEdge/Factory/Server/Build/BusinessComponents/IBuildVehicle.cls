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
    File        : IBuildVehicle
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Jul 19 11:35:31 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
interface AutoEdge.Factory.Server.Build.BusinessComponents.IBuildVehicle:
    
    /** (derived, readonly) The current status */
    define public property BuildStatus as character no-undo get.
    
    /** (mandatory) OrderId passed for this vehicle. */
    define public property OrderId as character no-undo get.
    
end interface.
