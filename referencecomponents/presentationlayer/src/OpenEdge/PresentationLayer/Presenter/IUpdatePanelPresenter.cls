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
    File        : IUpdatePanelPresenter
    Purpose     : Standard interface for (data) update functionality. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri May 15 11:18:40 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
  
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.

interface OpenEdge.PresentationLayer.Presenter.IUpdatePanelPresenter:  
    define public property ModelService as IComponentInfo no-undo get. set.
    define public property QueryName as char no-undo get. set.
    define public property TableName as char no-undo get. set.
    define public property CommitAction as UpdateActionEnum no-undo get. set.
    define public property DeleteAction as UpdateActionEnum no-undo get. set.  
end interface.
