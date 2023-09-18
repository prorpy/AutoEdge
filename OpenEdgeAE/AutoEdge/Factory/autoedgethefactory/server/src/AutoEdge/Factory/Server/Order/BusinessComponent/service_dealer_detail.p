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
/*------------------------------------------------------------------------
    File        : AutoEdge/Factory/Server/Order/BusinessComponent/service_dealer_detail.p
    Purpose     : Returns details about a single dealer.

    Syntax      :

    Description :

    Author(s)   : pjudge
    Created     : Wed Feb 16 14:40:50 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using AutoEdge.Factory.Common.CommonInfrastructure.UserTypeEnum.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Server.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.IQueryDefinition.

using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.
using Progress.Lang.AppError.
using Progress.Lang.Error.

/** -- params -- **/
define input parameter pcBrand as character no-undo.
define input parameter pcDealerCode as character no-undo.
define input parameter pcUserContextId as longchar no-undo.

define output parameter pcDealerId as longchar no-undo.
define output parameter pcName as character no-undo.
define output parameter pcSalesEmail as character no-undo.
define output parameter pcInfoEmail as character no-undo.
define output parameter pcStreetAddress as character no-undo.
define output parameter pcPhoneNumber as character no-undo.
define output parameter pcSalesReps as longchar no-undo.

/** local variables **/
define variable oServiceMgr as IServiceManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.
define variable oServiceMessageManager as IServiceMessageManager no-undo.
define variable iLoop as integer no-undo.
define variable iMax as integer no-undo.
define variable mTemp as memptr no-undo.
define variable oRequest as IFetchRequest extent 1 no-undo.
define variable oResponse as IServiceResponse extent no-undo.
define variable cUserName as character no-undo.
define variable cUserDomain as character no-undo.
define variable cUserPassword as character no-undo.

/** -- functions -- **/
function BuildDealerRequest returns IFetchRequest ():
    define variable oFetchRequest as IFetchRequest no-undo.
    define variable cTableName as character no-undo.
    define variable oTableRequest as ITableRequest no-undo.

    oFetchRequest = new FetchRequest('Dealer').

    cTableName = 'eDealer'.
    oTableRequest = new TableRequest(cTableName).
    oTableRequest:TableRequestType = TableRequestTypeEnum:NoChildren.
    oFetchRequest:TableRequests:Put(cTableName, oTableRequest).

    cast(oTableRequest, IQueryDefinition):AddFilter(cTableName,
                                          'Code',
                                          OperatorEnum:IsEqual,
                                          new String(pcDealerCode),
                                          DataTypeEnum:Character,
                                          JoinEnum:And).

    /* we also want the salesreps
    cTableName = 'eSalesrep'.
    oTableRequest = new TableRequest(cTableName).
    oFetchRequest:TableRequests:Put(cTableName, oTableRequest).
    */

    return oFetchRequest.
end function.

/** -- procedures -- **/
procedure BuildDealerOutputParameters:
    define input parameter poResponse as IServiceResponse no-undo.
    @todo(task="refactor", action="add JSON serialiser as IObjectOutput implementation").

    define variable hDataSet as handle no-undo.
    define variable hQuery as handle no-undo.
    define variable hBuffer as handle no-undo.

    cast(poResponse, IServiceMessage):GetMessageData(output hDataSet).

    hBuffer = hDataSet:get-buffer-handle('eDealer').
    hBuffer:find-first(' where eDealer.Code = ' + quoter(pcDealerCode) ) no-error.
    if hBuffer:available then
        assign pcDealerId = hBuffer::DealerId
               pcName = hBuffer::Name
               pcSalesEmail = hBuffer::SalesEmail
               pcInfoEmail = hBuffer::InfoEmail
               pcStreetAddress = hBuffer::StreetAddress
               pcPhoneNumber = hBuffer::PhoneNumber.

    finally:
        delete object hDataSet no-error.
    end finally.
end procedure.

/** Dummy return for modelling purposes (Savvion lets us make a test call to a WebService). */
if pcUserContextId eq 'Savvion::Test' then
do:
    assign pcDealerId = 'pcDealerId'
           pcName = 'pcName'
           pcSalesEmail = 'pcSalesEmail'
           pcInfoEmail = 'pcInfoEmail'
           pcStreetAddress = 'pcStreetAddress'
           pcPhoneNumber = 'pcPhoneNumber'.
    return.
end.

/** -- validate defs -- **/
Assert:ArgumentNotNullOrEmpty(pcBrand, 'Brand').
Assert:ArgumentNotNullOrEmpty(pcDealerCode, 'Dealer Code').

oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).
oSecMgr = cast(oServiceMgr:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).

if pcUserContextId eq '' or pcUserContextId eq ? or pcUserContextId eq '<NULL>' then
do:
    /* log in and establish tenancy, user context */
    assign cUserName = 'guest'
           cUserDomain = substitute('&1.&2',
                            UserTypeEnum:Customer:ToString(),
                            pcBrand)
           cUserPassword = 'letmein'.
    cast(oSecMgr, OpenEdge.CommonInfrastructure.Common.ISecurityManager):UserLogin(cUserName, cUserDomain, cUserPassword).
end.
else
    oSecMgr:EstablishSession(pcUserContextId).

cast(oSecMgr, OpenEdge.CommonInfrastructure.Common.ISecurityManager):AuthoriseServiceAction('DealerDetail', ServiceMessageActionEnum:FetchData).

oServiceMessageManager = cast(oServiceMgr:GetService(ServiceMessageManager:IServiceMessageManagerType)
                        , IServiceMessageManager).

/* Perform request. This is where the actual work happens. */
oRequest[1] = BuildDealerRequest().
oResponse = oServiceMessageManager:ExecuteRequest(cast(oRequest, IServiceRequest)).

/* Serialize requests, context. Output values written ('serializes') straight to the procedure's output aprameters. */
iMax = extent(oResponse).

do iLoop = 1 to iMax:
    case cast(oResponse[iLoop], IServiceMessage):Service:
        when 'Dealer' then run BuildDealerOutputParameters(input oResponse[iLoop]).
    end case.
end.

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
