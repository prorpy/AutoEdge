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
    File        : ServiceTypeEnum
    Purpose     : Server-side service types
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Feb 22 11:31:42 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Client.ServiceTypeEnum.

class OpenEdge.CommonInfrastructure.Client.ServiceTypeEnum inherits OpenEdge.CommonInfrastructure.Common.ServiceTypeEnum:
    
    /* Presentation Layer services */
    define public static property Model as ServiceTypeEnum no-undo get. private set.
    define public static property Presenter as ServiceTypeEnum no-undo get. private set.
    
    constructor static ServiceTypeEnum():
        ServiceTypeEnum:Model = new ServiceTypeEnum('Model').
        ServiceTypeEnum:Presenter = new ServiceTypeEnum('Presenter').
    end constructor.

    constructor public ServiceTypeEnum(pcName as character):
        super(pcName).
    end constructor.
    
end class.
