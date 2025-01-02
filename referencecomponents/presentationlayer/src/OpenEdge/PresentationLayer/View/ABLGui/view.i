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
    File        : view.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon Feb 23 11:03:27 EST 2009
    Notes       :
  ----------------------------------------------------------------------*/
define variable gcViewName as character no-undo.
define variable goView as OpenEdge.PresentationLayer.View.IView no-undo.
define variable goPresenter as OpenEdge.PresentationLayer.Presenter.IPresenter no-undo.

/* ***************************  Main Block  *************************** */
function GetPresenter returns OpenEdge.PresentationLayer.Presenter.IPresenter 
	(  ):
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    return goPresenter.	    
end function.
	
function SetPresenter returns logical
        ( poPresenter as OpenEdge.PresentationLayer.Presenter.IPresenter ):
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    goPresenter = poPresenter.

    return true.
end function.

function SetView returns logical ( poView as OpenEdge.PresentationLayer.View.IView ):
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    goView = poView.
    	    
    return true.
end function.

function GetView returns OpenEdge.PresentationLayer.View.IView ( ):
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    return goView.
end function.

function SetViewName returns logical ( pcViewName as character ):
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    gcViewName = pcViewName.
            
    return true.
end function.

function GetViewName returns character ( ):
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    return gcViewName.
end function.

procedure InitializeChildViews :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable iLoop as integer no-undo.
    define variable cChildren as character no-undo.
    define variable hView as handle no-undo.    
    define variable cViewName as character no-undo.
    define variable oView as OpenEdge.PresentationLayer.View.IView no-undo.
    define variable oPresenter as OpenEdge.PresentationLayer.Presenter.IPresenter no-undo.
    
    {get ContainerTarget cChildren} no-error.
    
    do iLoop = 1 to num-entries(cChildren):
        hView = widget-handle(entry(iLoop, cChildren)).
        
        cViewName = dynamic-function('GetViewName' in hView) no-error.
        if cViewName gt '' then
        do:
            /** We don't know if we have a IView object available for use. We first need to get that 
                object, and then hoow it up to it's Presenter.    
              */
            @todo(task="implement", action="need to do this in  MVPWINDOW/ContainedObject ").
/**            
            oView = OpenEdge.PresentationLayer.View.ViewFactory:GetView(cViewName, ?).
                                       
            if valid-object(oView) and
               type-of(oView, OpenEdge.PresentationLayer.View.IContainedView) then
            do:
                oPresenter = GetPresenter():AssociateContainedView(cast(oView, OpenEdge.PresentationLayer.View.IContainedView)). 
                cast(oView, OpenEdge.PresentationLayer.View.IView):Presenter = oPresenter.
                            
                /* Initialize will recurse */
                cast(oView, OpenEdge.PresentationLayer.Common.IComponent):Initialize().
            end.
**/            
        end.
    end.
    
end procedure.

