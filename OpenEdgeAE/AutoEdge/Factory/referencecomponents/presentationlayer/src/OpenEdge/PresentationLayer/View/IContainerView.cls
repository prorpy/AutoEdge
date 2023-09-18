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
    File        : IContainerView
    Purpose     : Interface for views that are containers and can be shown (viewed).
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Feb 06 14:12:26 EST 2009
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.PresentationLayer.View.IView.
using OpenEdge.PresentationLayer.View.EventLoopModeEnum.
using OpenEdge.Lang.EnumMember.
using Progress.Lang.Object.

interface OpenEdge.PresentationLayer.View.IContainerView /*inherits IView */ :

    method public void ShowModal().

    method public void BeginEventLoop(poShowMode as EventLoopModeEnum).
    method public void EndEventLoop().
    
end interface.
