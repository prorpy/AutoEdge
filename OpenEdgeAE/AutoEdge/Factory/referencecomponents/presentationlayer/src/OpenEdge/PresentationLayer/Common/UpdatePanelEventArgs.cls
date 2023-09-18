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
@todo(task="This is identical to ModelEventArgs").
/*------------------------------------------------------------------------
    File        : UpdatePanelEventArgs
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Mar 09 10:05:46 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Common.ModelActionEnum .
using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using Progress.Lang.Class.


class OpenEdge.PresentationLayer.Common.UpdatePanelEventArgs inherits ModelActionEventArgs: 

    constructor public UpdatePanelEventArgs ( input poModelService as IComponentInfo, input poModelAction as ModelActionEnum ):
        super (input poModelService, input poModelAction).
        
    end constructor.

        
    constructor public UpdatePanelEventArgs ( input poModelService as IComponentInfo, input poModelAction as ModelActionEnum, input pcTable as character extent, input pcKey as character extent ):
        super (input poModelService, input poModelAction, input pcTable, input pcKey).
        
    end constructor.

        
    constructor public UpdatePanelEventArgs ( input poModelService as IComponentInfo, input poModelAction as ModelActionEnum, input pcTable as character, input pcKey as character ):
        super (input poModelService, input poModelAction, input pcTable, input pcKey).
        
    end constructor.

        
    constructor public UpdatePanelEventArgs ( input poModelService as IComponentInfo, input poModelAction as ModelActionEnum, input pcTables as character extent, input pcMessageId as character ):
        super (input poModelService, input poModelAction, input pcTables, input pcMessageId).
        
    end constructor.


end class.
