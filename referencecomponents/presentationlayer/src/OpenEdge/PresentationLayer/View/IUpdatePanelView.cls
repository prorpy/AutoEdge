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
    File        : IUpdatePanelView
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon May 18 15:07:59 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.PresentationLayer.Common.ActionStateEnum.
using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.

interface OpenEdge.PresentationLayer.View.IUpdatePanelView:
      
    method public void UpdateStateChange (input poActions as UpdateActionEnum extent,
                                          input poStates as ActionStateEnum extent).
    
    method public void TableNameChange (input pcTableName as char).
    
end interface.
