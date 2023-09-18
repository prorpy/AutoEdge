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
    File        : ServiceRequestError
    Purpose     : Error thrown on ServiceRequest error. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Dec 10 22:03:24 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using Progress.Lang.Error.

class OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequestError inherits ApplicationError: 

    define override protected property ErrorText as longchar no-undo get. private set. 
    define override protected property ErrorTitle as character no-undo get. private set. 
        
    constructor public ServiceRequestError(input poInnerError as Error):
        super(input poInnerError).
        
       assign ErrorTitle = 'Service Request Error'
              ErrorText = 'Error &1 on service request &2'.
    end constructor.

    constructor public ServiceRequestError(pcArgs1 as char, pcArgs2 as char):
        this-object(?, pcArgs1, pcArgs2).
    end constructor.
    
    constructor public ServiceRequestError(poInnerError as Error, pcArgs1 as char, pcArgs2 as char):
        this-object(poInnerError).
        
        AddMessage(pcArgs1, 1).
        AddMessage(pcArgs2, 2).
    end constructor.

end class.
