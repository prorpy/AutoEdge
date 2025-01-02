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
    File        : UndoDeleteOnSubmitErrorEnum
    Purpose     : Decides whether to immediately undo deleted records after a failed submit 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 19 14:36:29 EDT 2009
    Notes       : * These values taken from ADM2 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Model.UndoDeleteOnSubmitErrorEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.PresentationLayer.Model.UndoDeleteOnSubmitErrorEnum final inherits EnumMember:
    
    define public static property Default as UndoDeleteOnSubmitErrorEnum get. private set.
    
    /** Only undo deletions that causes an error and keep deletions that was 
       rejected just because the transaction failed. Allows immediate resubmit. */
    define public static property Error as UndoDeleteOnSubmitErrorEnum get. private set.
     
    /** Undo all deleted records. */
    define public static property All as UndoDeleteOnSubmitErrorEnum get. private set.

    /** Keep all deletions. Fix the problem and resave */
    define public static property None as UndoDeleteOnSubmitErrorEnum get. private set.
    
    constructor static UndoDeleteOnSubmitErrorEnum ():
        UndoDeleteOnSubmitErrorEnum:Error = new UndoDeleteOnSubmitErrorEnum('Error').
        UndoDeleteOnSubmitErrorEnum:All = new UndoDeleteOnSubmitErrorEnum('All').
        UndoDeleteOnSubmitErrorEnum:None = new UndoDeleteOnSubmitErrorEnum('None').
        
        UndoDeleteOnSubmitErrorEnum:Default = UndoDeleteOnSubmitErrorEnum:Error.
    end constructor.

    constructor public UndoDeleteOnSubmitErrorEnum ( input pcName as character ):
        super (input pcName).
    end constructor.
    
end class.
