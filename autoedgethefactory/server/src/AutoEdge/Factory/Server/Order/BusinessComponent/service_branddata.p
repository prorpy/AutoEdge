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
    File        : AutoEdge/Factory/Server/Order/BusinessComponent/service_branddata.p
    Purpose     :

    Syntax      :

    Description : Vehicle and dealer info for a give brand

    Author(s)   : pjudge
    Created     : Wed Jul 28 16:50:34 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using AutoEdge.Factory.Common.CommonInfrastructure.UserTypeEnum.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableContext.
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
define input  parameter pcBrand as character no-undo.
define input  parameter pcUserContextId as longchar no-undo.

define output parameter pcDealerNameList as longchar no-undo.
define output parameter pcCompactModels as longchar no-undo.
define output parameter pcTruckModels as longchar no-undo.
define output parameter pcSuvModels as longchar no-undo.
define output parameter pcConvertibleModels as longchar no-undo.
define output parameter pcSedanModels as longchar no-undo.
define output parameter pcInteriorTrimMaterial as longchar no-undo.
define output parameter pcInteriorTrimColour as longchar no-undo.
define output parameter pcInteriorAccessories as longchar no-undo.
define output parameter pcExteriorColour as longchar no-undo.
define output parameter pcMoonroof as longchar no-undo.
define output parameter pcWheels as longchar no-undo.

/** local variables **/
define variable oServiceMgr as IServiceManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.
define variable oServiceMessageManager as IServiceMessageManager no-undo.
define variable iLoop as integer no-undo.
define variable iMax as integer no-undo.
define variable mTemp as memptr no-undo.
define variable oRequest as IFetchRequest extent 2 no-undo.
define variable oResponse as IServiceResponse extent no-undo.
define variable cUserName as character no-undo.
define variable cUserDomain as character no-undo.
define variable cUserPassword as character no-undo.

/** -- functions -- **/
function BuildVehicleRequest returns IFetchRequest ():
    define variable oFetchRequest as IFetchRequest no-undo.
    define variable oTableContext as ITableContext no-undo.
    define variable oTableRequest as ITableRequest no-undo.
    define variable iMax as integer no-undo.
    define variable iLoop as integer no-undo.
    define variable cTableName as character no-undo.

    oFetchRequest = new FetchRequest('VehicleOptions').

    /* Fetch defaults / all */
    return oFetchRequest.
end function.

function BuildDealerRequest returns IFetchRequest ():
    define variable oFetchRequest as IFetchRequest no-undo.
    define variable cTableName as character no-undo.
    define variable oTableRequest as ITableRequest no-undo.

    oFetchRequest = new FetchRequest('Dealer').

    cTableName = 'eDealer'.
    oTableRequest = new TableRequest(cTableName).
    oTableRequest:TableRequestType = TableRequestTypeEnum:NoChildren.
    oFetchRequest:TableRequests:Put(cTableName, oTableRequest).

    return oFetchRequest.
end function.

/** Escapes certain characters for JSON strings */
function SanitiseString returns character (input pcString as character):
    define variable cString as character no-undo.
    define variable c as character no-undo.

    cString = pcString.

    if index(cString, '~"') gt 0 then
        cString = replace(cString, '~"', '\~"').

    if index(cString, '~{') gt 0 then
        cString = replace(cString, '~{', '\~{').

    if index(cString, '~[') gt 0 then
        cString = replace(cString, '~[', '\~[').

    return cString.
end function.

function GetOptions returns longchar (input pcGroup as character, input phDataset as handle):
    define variable cOptions as longchar no-undo.
    define variable hQuery as handle no-undo.
    define variable hItemBuffer as handle no-undo.
    define variable hOptionBuffer as handle no-undo.

    hItemBuffer = phDataset:get-buffer-handle('eItem').
    hOptionBuffer = phDataset:get-buffer-handle('eItemOption').

    create query hQuery.
    hQuery:set-buffers(hItemBuffer, hOptionBuffer).
    hQuery:query-prepare(' for each eItem where eItem.ItemType eq ' + quoter(pcGroup)
                        + ', first eItemOption where eItemOption.ChildItemId eq eItem.ItemId ').
    hQuery:query-open().

    cOptions = ''.
    hQuery:get-first().
    do while not hQuery:query-off-end:
            cOptions = cOptions + ', ~{ '
                     + '~"selected~" : ' + string(hOptionBuffer::StandardOption, 'true/false') + ', '
                     + '~"value~" : ~"' + SanitiseString(hItemBuffer::ItemId) + '~", '
                     + '~"label~" : ~"' + SanitiseString(hItemBuffer::Description) + '~"'
                     + ' ~}'.
        hQuery:get-next().
    end.

    if cOptions eq '' then
       cOptions = cOptions + ' ~{ ~"selected~" : false, '
                     + '~"value~" : ~"none~", '
                     + '~"label~" : ~"None~" ~} '.

    cOptions = '[' + trim(cOptions, ',')  + ' ]'.
    return cOptions.
    finally:
        hQuery:query-close().
        delete object hQuery no-error.
    end finally.
end function.

function GetModels returns longchar (input pcStyle as character, input phDataset as handle):
    define variable cModels as longchar no-undo.
    define variable hQuery as handle no-undo.
    define variable hBuffer as handle no-undo.
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.

    assign iMax = num-entries(pcStyle)
           cModels = ''
           hBuffer = phDataset:get-buffer-handle('eVehicle').

    create query hQuery.
    hQuery:set-buffers(hBuffer).

    do iLoop = 1 to iMax:
        hQuery:query-prepare(' for each eVehicle where eVehicle.VehicleType = ' + quoter(entry(iloop, pcStyle))).
        hQuery:query-open().
        hQuery:get-first().
        do while hBuffer:available:
                cModels  = cModels + ', ~{ '
                         + '~"selected~" : false, '
                         + '~"value~" : ~"' + SanitiseString(hBuffer::ItemId) + '~", '
                         + '~"label~" : ~"' + SanitiseString(hBuffer::VehicleName) + '~"'
                         + ' ~}'.
            hQuery:get-next().
        end.
        hQuery:query-close().
    end.

    if cModels eq '' then
       cModels = cModels + ' ~{ ~"selected~" : false, '
                     + '~"value~" : ~"none~", '
                     + '~"label~" : ~"None~" ~}'.

    cModels = ' [ ' + trim(cModels, ',')  + ' ]'.

    return cmodels.
    finally:
        hQuery:query-close().
        delete object hQuery no-error.
    end finally.
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

    create query hQuery.
    hQuery:set-buffers(hBuffer).
    hQuery:query-prepare(' for each eDealer ').
    hQuery:query-open().

    pcDealerNameList = ''.

    hQuery:get-first().
    do while hBuffer:available:
        pcDealerNameList = pcDealerNameList
                         + substitute(', ~{ ~"selected~":'
                                      + string(logical(pcDealerNameList eq ''), 'true/false')
                                      + ', ~"value~": ~"&1~", ~"label~": ~"&2~" ~}',
                                      SanitiseString(hBuffer::Code),
                                      SanitiseString(hBuffer::Name)).
        hQuery:get-next().
    end.

    if pcDealerNameList eq '' then
       pcDealerNameList = pcDealerNameList + ' ~{ ~"selected~" : true, '
                     + '~"value~" : ~"none~", '
                     + '~"label~" : ~"No dealers available~" ~}'.

    pcDealerNameList= ' [ ' + trim(pcDealerNameList, ',')  + ' ]'.
    finally:
        hQuery:query-close().
        delete object hQuery no-error.
        delete object hDataSet no-error.
    end finally.
end procedure.

procedure BuildVehicleOutputParameters:
    define input  parameter poResponse as IServiceResponse no-undo.

    define variable hDataSet as handle no-undo.
    define variable hQuery as handle no-undo.
    define variable hBuffer as handle no-undo.

    cast(poResponse, IServiceMessage):GetMessageData(output hDataSet).

    assign pcCompactModels = GetModels('Vehicle-Compact', hDataSet)
           pcTruckModels = GetModels('Vehicle-Truck,Vehicle-Commercial', hDataSet)
           pcSedanModels = GetModels('Vehicle-Sedan', hDataSet)
           pcSuvModels = GetModels('Vehicle-SUV,Vehicle-Crossover', hDataSet)
           pcConvertibleModels = GetModels('Vehicle-Convertible,Vehicle-Coupe', hDataSet)

           pcInteriorTrimMaterial = GetOptions('Trim-Material', hDataSet)
           pcInteriorTrimColour = GetOptions('Trim-Colour', hDataSet)
           pcInteriorAccessories = GetOptions('Accessories', hDataSet)
           pcExteriorColour = GetOptions('Ext-Colour', hDataSet)
           pcMoonroof = GetOptions('Moonroof', hDataSet)
           pcWheels = GetOptions('Wheels', hDataSet).

    finally:
        delete object hDataSet no-error.
    end finally.
end procedure.

/** Dummy return for modelling purposes (Savvion lets us make a test call to a WebService). */
if pcUserContextId eq 'Savvion::Test' then
do:
    assign pcDealerNameList = 'pcDealerNameList'
           pcCompactModels = 'pcCompactModels '
           pcTruckModels = 'pcTruckModels '
           pcSedanModels = 'pcSedanModels'
           pcSuvModels = 'pcSuvModels'
           pcConvertibleModels = 'pcConvertibleModels'
           pcInteriorTrimMaterial = 'pcInteriorTrimMaterial'
           pcInteriorTrimColour = 'pcInteriorTrimColour'
           pcInteriorAccessories = 'pcInteriorAccessories'
           pcExteriorColour = 'pcExteriorColour'
           pcMoonroof = 'pcMoonroof'
           pcWheels = 'pcWheels'.
    return.
end.

/** -- validate defs -- **/
Assert:ArgumentNotNullOrEmpty(pcBrand, 'Brand').

oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).
oSecMgr = cast(oServiceMgr:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).

/* log in and establish tenancy, user context */
assign cUserName = 'guest'
       cUserDomain = substitute('&1.&2',
                            UserTypeEnum:Customer:ToString(),
                            pcBrand)
       cUserPassword = 'letmein'.

       
oSecMgr:UserLogin(cUserName, cUserDomain, cUserPassword).

oSecMgr:AuthoriseServiceAction('VehicleOptions', ServiceMessageActionEnum:FetchData).

oServiceMessageManager = cast(oServiceMgr:GetService(ServiceMessageManager:IServiceMessageManagerType)
                        , IServiceMessageManager).

/* Perform request. This is where the actual work happens. */
oRequest[1] = BuildVehicleRequest().
oRequest[2] = BuildDealerRequest().
oResponse = oServiceMessageManager:ExecuteRequest(cast(oRequest, IServiceRequest)).

/* Serialize requests, context. Output values written ('serializes') straight to the procedure's output aprameters. */
iMax = extent(oResponse).

do iLoop = 1 to iMax:
    case cast(oResponse[iLoop], IServiceMessage):Service:
        when 'Dealer'           then run BuildDealerOutputParameters(input oResponse[iLoop]).
        when 'VehicleOptions'   then run BuildVehicleOutputParameters(input oResponse[iLoop]).
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

