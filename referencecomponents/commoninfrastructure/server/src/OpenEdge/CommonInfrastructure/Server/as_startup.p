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
    File        : OpenEdge/CommonInfrastructure/Server/as_startup.p
    Purpose     : AppServer startup procedure
     
    @param character A free-text string. This is assumed in our simple case
           to be the session code. If left blank, the session:client-type is
           used. 

    @author pjudge
    Created     : Fri Jun 04 13:54:27 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.

using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.String.
using Progress.Lang.Class.
using Progress.Lang.AppError.
using Progress.Lang.Error.

/** -- params, defs -- **/
define input parameter pcStartupData as character no-undo.

run OpenEdge/CommonInfrastructure/Common/start_session.p.

ABLSession:Instance:SessionProperties:Put(new String('startup-procedure-parameters'), new String(pcStartupData)).

error-status:error = no.
return.

/** -- error handling -- **/
catch oException as ApplicationError:
    oException:LogError().

    message '*** OpenEdge.Core.System.ApplicationError'.
    message '~t' oException:ResolvedMessageText().
    
    return error oException:ResolvedMessageText().
end catch.

catch oAppError as Progress.Lang.AppError:
    message '*** Progress.Lang.AppError'.
    message '~t' oAppError:ReturnValue.
    message '~t' oAppError:CallStack.
    
    return error oAppError:ReturnValue.
end catch.

catch oError as Progress.Lang.Error:
    message '*** Progress.Lang.Error ' oError:GetMessageNum(1).
    message '~t' oError:GetMessage(1).
    message '~t' oError:CallStack.
    
    return error oError:GetMessage(1).
end catch.
/** -- eof -- **/
