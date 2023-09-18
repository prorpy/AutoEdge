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
    File        : IContainedView
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jan 09 11:55:24 EST 2009
    Notes       : 
  ----------------------------------------------------------------------*/
using Progress.Lang.Class.
using Progress.Lang.Object.

interface OpenEdge.PresentationLayer.View.IContainedView /*inherits IView */ :
    /** Stores the Presenter service for a contained view, so that we can  
        associate this View with its Presenter
        
        We use a Set method, since we cannot reflect on properties yet 
        (as of 10.2B) and we want to be able to set this value via InjectABL */
    define public property PresenterService as class Class no-undo get. set.
    method public void SetPresenterService(poService as class Class).
    
    /* Show as MDI child */
    method public void ShowEmbedded(poParentView as Object).
    
end interface.
