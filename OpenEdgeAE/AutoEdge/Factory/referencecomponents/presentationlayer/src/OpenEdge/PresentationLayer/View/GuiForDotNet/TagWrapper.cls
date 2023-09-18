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
    File        : TagWrapper
    Purpose     : Simple wrapper for non-.NETGUI PABLO's so that they can be
                  used for Tags.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Jul 08 14:48:22 EDT 2010
    Notes       : * PABLO = Plain ABL Object
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.
  
/* No USING to make it clear which Object is which */

class OpenEdge.PresentationLayer.View.GuiForDotNet.TagWrapper final inherits System.Object:
    /** The ABL Object being stored in the .NET Object's Tag property. */
    define public property PABLO as Progress.Lang.Object no-undo get. private set.  
    
    constructor public TagWrapper(poPABLO as Progress.Lang.Object):
        this-object:PABLO = poPABLO.
    end constructor.
    
end class.
