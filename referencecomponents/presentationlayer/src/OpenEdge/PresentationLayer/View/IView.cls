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
/*------------------------------------------------------------------------
    File        : IView
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Oct 31 14:04:42 EDT 2008
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.PresentationLayer.Presenter.IPresenter.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.                                

using Progress.Lang.Class.

interface OpenEdge.PresentationLayer.View.IView     /* inherits IComponent */ :
    define public property Presenter as IPresenter no-undo get. set.
    
    method public void ShowView().
    method public void HideView().
    method public void CloseView().
    
    method public void DataRefreshed(poModelService as IComponentInfo,
                                     pcQuery as char,
                                     poModelAction as ModelActionEnum).
    
    method public void DataFetched(poModelService as IComponentInfo, plNewData as logical).
    
    method public void SaveData(poModelService as IComponentInfo, pcBuffer as char).
    
end interface.
