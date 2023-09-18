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
    File        : ConnectionManagerActionEventArgs
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 05 13:48:17 EDT 2011
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Connection.IConnectionParameters.
using OpenEdge.Core.System.EventArgs.
using OpenEdge.Lang.Assert.

class OpenEdge.CommonInfrastructure.Common.ConnectionManagerActionEventArgs inherits EventArgs:
    
    define public property ConnectionType as ConnectionTypeEnum no-undo get. set.
    define public property ConnectionName as character no-undo get. set.
    define public property Parameters as IConnectionParameters no-undo get. set.
    define public property ActionFailed as logical no-undo get. set.
    
	constructor public ConnectionManagerActionEventArgs(  ):
		super ().
	end constructor.
	
    constructor public ConnectionManagerActionEventArgs(input poConnectionType as ConnectionTypeEnum,
                                                        input pcConnectionName as character,
                                                        input poParameters as IConnectionParameters,
                                                        input plActionFailed as logical):
        super().
        
        Assert:ArgumentNotNull(poConnectionType, 'Connection Type').
        Assert:ArgumentNotNullOrEmpty(pcConnectionName, 'Connection Name').
        
        assign ConnectionType = poConnectionType
               ConnectionName = pcConnectionName
               Parameters = poParameters
               ActionFailed = plActionFailed.
    end constructor.
    
end class.
