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
    File        : start_ui.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Thu Dec 16 10:42:00 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Windows.Form.

using OpenEdge.CommonInfrastructure.Common.InjectABL.ComponentKernel.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.

using OpenEdge.Core.InjectABL.IKernel.
using OpenEdge.Core.System.UnhandledError.
using OpenEdge.Core.System.ApplicationError.

using OpenEdge.Lang.ABLSession.
using Progress.Lang.Error.
using Progress.Lang.AppError.
using Progress.Lang.Object.
using Progress.Lang.Class.

/** -- defs  -- **/
define variable oTasks as Object no-undo.
define variable oServiceManager as IServiceManager no-undo.

session:debug-alert = true.
session:error-stack-trace = true.
session:system-alert-boxes = true.
session:appl-alert-boxes = true.
/** -- main -- **/
run OpenEdge/CommonInfrastructure/Common/start_session.p.

oServiceManager = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).
oTasks = cast(oServiceManager:Kernel:Get('OpenEdge.CommonInfrastructure.Common.IApplicationStart'), Form).

wait-for System.Windows.Forms.Application:Run(cast(oTasks, Form)). 

quit.

/** ----------------- **/
catch oException as ApplicationError:
    oException:LogError().
    oException:ShowError().
end catch.

catch oError as Error:
    define variable oUnhandled as UnhandledError no-undo.
    
    oUnhandled = new UnhandledError(oError).
    
    oUnhandled:LogError().
    oUnhandled:ShowError().
end catch.

finally:
    run OpenEdge/CommonInfrastructure/Common/stop_session.p.
end finally.
