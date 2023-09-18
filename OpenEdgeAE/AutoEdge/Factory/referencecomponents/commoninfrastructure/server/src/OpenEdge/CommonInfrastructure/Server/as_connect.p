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
    File        : OpenEdge/CommonInfrastructure/Server/as_connect.p
    Purpose     : 

    Syntax      :

    Description : AppServer connect procedure

    @author pjudge
    Created     : Fri Jun 04 16:01:48 EDT 2010
    Notes       : * Not run for statefree appservers.
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.AgentConnection.
using OpenEdge.Lang.String.

define input parameter user-id          as character no-undo.
define input parameter password         as character no-undo.
define input parameter app-server-info  as character no-undo.

/* ***************************  Main Block  *************************** */
define variable oProps as IMap no-undo.

/* This starts the connection object and sets its ID */
oProps = AgentConnection:Instance:ConnectionProperties.

oProps:Put(new String('user-id'), new String(user-id)).
oProps:Put(new String('password'), new String(password)).
oProps:Put(new String('app-server-info'), new String(app-server-info)).

/* eof */
