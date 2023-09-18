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
    File        : ILoginPresenter
    Purpose     : Window-specific events. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 17 15:17:01 EST 2008
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.PresentationLayer.Presenter.ILoginPresenter.
using OpenEdge.Core.System.ILoginData.

interface OpenEdge.PresentationLayer.Presenter.ILoginPresenter /* inherits IPResenter */:
    
    method public void ValidateLogin(poLoginData as ILoginData).
    
end interface.
