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
    File        : OpenEdge/CommonInfrastructure/Server/as_disconnect.p
    Purpose     : AppServer Disconnect procedure. 

    Syntax      :

    Description : 

    @author pjudge
    Created     : Fri Jun 04 16:04:42 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

/* ***************************  Main Block  *************************** */
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.AgentConnection.

using Progress.Lang.Class.
using Progress.Lang.Object.

define variable oServiceMgr as IServiceManager no-undo.

/** -- main -- **/
oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).
               
cast(oServiceMgr:GetService(SecurityManager:ISecurityManagerType), ISecurityManager):EndSession().
               
oServiceMgr:Kernel:Clear(AgentConnection:Instance).

delete object AgentConnection:Instance.

/* eof */
