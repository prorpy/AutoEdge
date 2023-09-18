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
/** -----------------------------------------------------------------------
    File        : OpenEdge/CommonInfrastructure/Server/as_activate.p
    Purpose     : 

    Syntax      :

    Description : AppServer Activation routine

    @author     : pjudge 
    Created     : Fri Jun 04 16:21:40 EDT 2010
    Notes       :
  --------------------------------------------------------------------- */
routine-level on error undo, throw.

/* ***************************  Main Block  *************************** */

/* This starts the request object and sets its ID */
OpenEdge.Lang.AgentRequest:Instance.

/* eof */
