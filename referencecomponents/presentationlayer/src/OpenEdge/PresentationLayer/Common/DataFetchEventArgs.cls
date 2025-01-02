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
@deprecated.
/*------------------------------------------------------------------------
    File        : DataFetchEventArgs
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Sep 01 17:11:58 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.Common.ModelActionEventArgs.
using OpenEdge.PresentationLayer.Common.ModelActionEnum.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using Progress.Lang.Class.

class OpenEdge.PresentationLayer.Common.DataFetchEventArgs inherits ModelActionEventArgs:
    define public property NewData as logical no-undo get. set.
        
    constructor public DataFetchEventArgs (poModelService as IComponentInfo, plNewData as log):
        super(poModelService, ModelActionEnum:Fetch).
        
        this-object:NewData = plNewData.
    end constructor.

        
    constructor public DataFetchEventArgs ( input poModelService as IComponentInfo):
        super (input poModelService, ModelActionEnum:Fetch).
    end constructor.

        
    constructor public DataFetchEventArgs ( input poModelService as IComponentInfo, input pcTable as character extent, input pcKey as character extent ):
        super (input poModelService, ModelActionEnum:Fetch, input pcTable, input pcKey).
        
    end constructor.

        
    constructor public DataFetchEventArgs ( input poModelService as IComponentInfo, input pcTable as character, input pcKey as character ):
        super (input poModelService, ModelActionEnum:Fetch, input pcTable, input pcKey).
        
    end constructor.

        
    constructor public DataFetchEventArgs ( input poModelService as IComponentInfo, input pcTables as character extent, input pcMessageId as character ):
        super (input poModelService, ModelActionEnum:Fetch, input pcTables, input pcMessageId).
    end constructor.
    
end class.
