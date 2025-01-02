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
    File        : IComponent
    Purpose     : Interface definition for base OERA component.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 18 14:25:00 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

interface OpenEdge.CommonInfrastructure.Common.IComponent:
    
    /** (mandatory) Stores information about the component, such as a developer-defined instance name
        so as to be able to uniquely identify the component.   */
    define public property ComponentInfo as IComponentInfo no-undo get.
    
    /** General creation code; constructors should only be used for property setting, not
        for any more complex wiring.  */
    method public void CreateComponent().
    
    /** Not InitializeComponent, since the Gui for .NET uses that name already, 
       as a PRIVATE member, and we want to have only 1 IComponent interface. */
    method public void Initialize().

    /** General destruction code that can be called outside of the destructor
        if needed (but will also be called from within the dtor). */
    method public void DestroyComponent().
        
end interface.
