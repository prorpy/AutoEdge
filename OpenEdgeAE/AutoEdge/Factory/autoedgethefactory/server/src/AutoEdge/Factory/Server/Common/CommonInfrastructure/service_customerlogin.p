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
@openapi.openedge.export FILE(type="BPM", operationName="%FILENAME%", useReturnValue="false", writeDataSetBeforeImage="false", executionMode="external").
/** ----------------------------------------------------------------------
    File        : AutoEdge/Factory/Server/Common/CommonInfrastructure/service_customerlogin.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Thu Dec 16 09:17:18 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using AutoEdge.Factory.Common.CommonInfrastructure.UserTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.System.ApplicationError.

using OpenEdge.Lang.String.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.Assert.
using Progress.Lang.Class.
using Progress.Lang.AppError.
using Progress.Lang.Error.

/** -- params, defs -- **/
define input  parameter pcBrand as character no-undo.
define input  parameter pcUserName as character no-undo.
/* plain-text. ugh. */
define input  parameter pcPassword as character no-undo.

define output parameter pcUserContextId as longchar no-undo.
define output parameter pcCustNum as longchar no-undo.
define output parameter pcCustomerEmail as longchar no-undo.
define output parameter pdCreditLimit as decimal no-undo.
define output parameter pcCustomerName as character no-undo.

define variable oServiceMgr as IServiceManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.
define variable oContext as IUserContext no-undo.
define variable cUserDomain as character no-undo.
define variable cContextId as longchar no-undo.

/** Dummy return for modelling purposes (Savvion lets us make a test call to a WebService). */
if pcUserName eq 'Savvion::Test' then
do:
    assign pcUserContextId = 'pcUserContextId'
           pcCustNum = 'pcCustNum'
           pcCustomerEmail = 'pcCustomerEmail'
           pdCreditLimit = -1
           pcCustomerName = 'pcCustomerName'.
    return.
end.

/** -- validate defs -- **/
Assert:ArgumentNotNullOrEmpty(pcUserName, 'User Name').
Assert:ArgumentNotNullOrEmpty(pcBrand, 'Brand').
Assert:ArgumentNotNullOrEmpty(pcPassword, 'User Password').

/** -- main -- **/
oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).

oSecMgr = cast(oServiceMgr:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).

/* log in and establish tenancy, user context */
cUserDomain = substitute('&1.&2',
                    UserTypeEnum:Customer:ToString(),
                    pcBrand).
cContextId = oSecMgr:UserLogin(pcUserName,
                  cUserDomain,
                  pcPassword).

oContext = oSecMgr:GetUserContext(cContextId). 
Assert:ArgumentNotNull(oContext, 'User Context').

assign pcUserContextId = oContext:ContextId
       pcCustomerEmail = cast(oContext:UserProperties:Get(new String('Customer.PrimaryEmailAddress')), String):Value
       pcCustNum = cast(oContext:UserProperties:Get(new String('Customer.CustNum')), String):Value
       pdCreditLimit = decimal(cast(oContext:UserProperties:Get(new String('Customer.CreditLimit')), String):Value)
       pcCustomerName = cast(oContext:UserProperties:Get(new String('Customer.Name')), String):Value
       .
error-status:error = no.
return.

/** -- error handling -- **/
catch oApplError as ApplicationError:
    return error oApplError:ResolvedMessageText().
end catch.

catch oAppError as AppError:
    return error oAppError:ReturnValue. 
end catch.

catch oError as Error:
    return error oError:GetMessage(1).
end catch.
/** -- eof -- **/
