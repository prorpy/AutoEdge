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
    File        : EventLoopModeEnum
    Purpose     : Enumeration of event loop modes (modal etc) 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 14 16:55:02 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.View.EventLoopModeEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.PresentationLayer.View.EventLoopModeEnum final inherits EnumMember:
    /** Form/view/page not currently shown  */
    define public static property None     as EventLoopModeEnum no-undo get. private set.     
    /** Show a form/view/page as modal  */
    define public static property Modal        as EventLoopModeEnum no-undo get. private set.
    /** Show a form/view/page as non-modal, with event blocking for a particular form/view/page  */
    define public static property NonModalView as EventLoopModeEnum no-undo get. private set.
    /** Show a form/view/page as non-modal, with event blocking for no particular form/view/page  */
    define public static property NonModalNone as EventLoopModeEnum no-undo get. private set.
    /** Show a form/view/page as embedded in another */
    define public static property Embedded     as EventLoopModeEnum no-undo get. private set.
    
    constructor static EventLoopModeEnum():
        EventLoopModeEnum:None = new EventLoopModeEnum('None').
        EventLoopModeEnum:Modal = new EventLoopModeEnum('Modal').
        EventLoopModeEnum:NonModalView = new EventLoopModeEnum('NonModalView').
        EventLoopModeEnum:NonModalNone = new EventLoopModeEnum('NonModalNone').
        EventLoopModeEnum:Embedded = new EventLoopModeEnum('Embedded').
    end constructor.

    constructor public EventLoopModeEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
end class.
