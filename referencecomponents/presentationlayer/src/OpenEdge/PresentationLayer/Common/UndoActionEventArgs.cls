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
    File        : UndoActionEventArgs
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Mar 31 11:44:27 EDT 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.Core.System.EventArgs.
using Progress.Lang.Class.

class OpenEdge.PresentationLayer.Common.UndoActionEventArgs inherits EventArgs   : 
    
    define public property RecordKey as character extent no-undo get. set. /* where strings */
    define public property ModelService as IComponentInfo no-undo get. set.
    define public property QueryName as character no-undo get. set.
    define public property BufferName as character no-undo get. set.
    define public property UndoActionType as UpdateActionEnum no-undo get. set. 
    define public property Order as integer no-undo get. set.

    constructor UndoActionEventArgs():
        super().
    end constructor.
                
    constructor UndoActionEventArgs(poModelService as IComponentInfo,
                                    pcQueryName as char,
                                    pcBufferName as char,
                                    pcRecordKey as char extent,
                                    poUndoActionType as UpdateActionEnum):
        this-object().
        
        assign BufferName = pcBufferName
               RecordKey = pcRecordKey
               QueryName = pcQueryName
               ModelService = poModelService
               UndoActionType = poUndoActionType.                        
    end constructor.

end class.
