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
    File        : AutoEdge/Factory/Server/Order/BusinessComponent/service_captureorder.p
    Purpose     :

    Syntax      :

    Description :

    Author(s)   : pjudge
    Created     : Mon Aug 02 09:37:10 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using AutoEdge.Factory.Common.CommonInfrastructure.UserTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequestError.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.FetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SaveRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Service.

using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.IQueryDefinition.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.

using Progress.Json.ObjectModel.JsonConstruct.
using Progress.Json.ObjectModel.JsonArray.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.ObjectModelParser.
using Progress.Json.ObjectModel.JsonDataType.
using Progress.Json.JsonParserError.

using Progress.Lang.AppError.
using Progress.Lang.Error.

/** -- params, variables -- **/
define input parameter piOrderNumber as integer no-undo.
define input parameter pcBrand as character no-undo.

define input parameter pcDealerCode as longchar no-undo.
define input parameter pcCustomerId as longchar no-undo.
define input parameter plOrderApproved as logical no-undo.
define input parameter pcInstructions as longchar no-undo.
define input parameter pcModel as longchar no-undo.
define input parameter pcInteriorTrimMaterial as longchar no-undo.
define input parameter pcInteriorTrimColour as longchar no-undo.
define input parameter pcInteriorAccessories as longchar no-undo.
define input parameter pcExteriorColour as longchar no-undo.
define input parameter pcMoonroof as longchar no-undo.
define input parameter pcWheels as longchar no-undo.

define output parameter pcOrderId as character no-undo.
define output parameter pdOrderAmount as decimal no-undo.

define variable oServiceMessageManager as IServiceMessageManager no-undo.
define variable oServiceMgr as IServiceManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.
define variable mhOrderDataset as handle no-undo.
define variable mhOrderBuffer as handle no-undo.

/* ***************************  Functions  *************************** */
function GetSelectedOption returns character (input pcOptions as longchar):
    define variable oParsedConstruct as JsonConstruct     no-undo.
    define variable oArray           as JsonArray         no-undo.
    define variable oDetail          as JsonObject        no-undo.
    define variable oParser          as ObjectModelParser no-undo.
    define variable iMax             as integer           no-undo.
    define variable iLoop            as integer           no-undo.
    define variable cSelectedOption  as character         no-undo.
    define variable cDelimiter       as character         no-undo.
    
    oParser = new ObjectModelParser().
    oParsedConstruct = oParser:Parse(pcOptions).
    if type-of(oParsedConstruct, JsonArray) then
    do:
        oArray = cast(oParsedConstruct,JsonArray).
        iMax =  oArray:Length.
        cDelimiter = ''.
        do iLoop = 1 to iMax:        
            case oArray:GetType(iLoop).
                when JsonDataType:OBJECT then
                    do:
                        oDetail = oArray:GetJsonObject(iLoop).
                        if oDetail:GetLogical('selected') then
                            cSelectedOption = trim(oDetail:GetCharacter('value')). 
                    end.    /* object */
                otherwise
                assign 
                    cSelectedOption = cSelectedOption + cDelimiter + trim(oArray:GetJsonText(iLoop))
                    cDelimiter      = ','.
            end case.
        end.
    end.
        
    catch oParseError as JsonParserError:
        cSelectedOption = trim(pcOptions).
    end catch.
    finally:
        return cSelectedOption.
    end finally.
end function.


function FetchSchema returns logical (output dataset-handle phDataset):
    define variable oRequest as IServiceRequest extent 1 no-undo.
    define variable oResponse as IServiceResponse extent no-undo.

    oRequest[1] = new FetchRequest('Order', ServiceMessageActionEnum:FetchSchema).

    oResponse = oServiceMessageManager:ExecuteRequest(oRequest).
    cast(oResponse[1], IServiceMessage):GetMessageData(output phDataset).
end function.

function FetchData returns logical (output dataset-handle phDataset):
    define variable oRequest as IServiceRequest extent 1 no-undo.
    define variable oResponse as IServiceResponse extent no-undo.
    define variable cTableName as character no-undo.
    define variable oTableRequest as ITableRequest no-undo.

    oRequest[1] = new FetchRequest('Order', ServiceMessageActionEnum:FetchData).

    cTableName = 'eOrder'.
    oTableRequest = new TableRequest(cTableName).
    cast(oRequest[1], IFetchRequest):TableRequests:Put(cTableName, oTableRequest).
    cast(oTableRequest, IQueryDefinition):AddFilter(cTableName,
                                          'OrderNum',
                                          OperatorEnum:IsEqual,
                                          new String(string(piOrderNumber)),
                                          DataTypeEnum:Integer,
                                          JoinEnum:And).

    oResponse = oServiceMessageManager:ExecuteRequest(oRequest).
    cast(oResponse[1], IServiceMessage):GetMessageData(output phDataset).
end function.

function BuildSaveRequest returns ISaveRequest ():
    define variable oSaveRequest as ISaveRequest no-undo.
    define variable cChangedTables as character extent no-undo.
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable iExtent as integer no-undo.
    define variable hTransportDataset as handle no-undo.
    define variable hBuffer as handle no-undo.

    oSaveRequest = new SaveRequest('Order').

    /* Get the change data */
    create dataset hTransportDataset.
    hTransportDataset:create-like(mhOrderDataset).
    hTransportDataset:get-changes(mhOrderDataset).

    /* Put the PDS into the message */
    cast(oSaveRequest, IServiceMessage):SetMessageData(
            hTransportDataset,
            DataFormatEnum:ProDataSet).

    /* We set the ISaveRequest:TableNames property, but we
       can probably also derive that from the dataset. */
    assign iMax = hTransportDataset:num-buffers
           extent(cChangedTables) = iMax.

    do iLoop = 1 to iMax:
        hBuffer = hTransportDataset:get-buffer-handle(iLoop).

        /* There will always be records in the before buffer, regardless of the operation.
           The 'after' buffer won't contain deletes. */
        if hBuffer:before-buffer:table-handle:has-records then
            assign iExtent = iExtent + 1
                   cChangedTables[iExtent] = hBuffer:name.
    end.

    if iExtent gt 0 then
    do:
        /* Fill the array backwards, since a stack is always LIFO. Order is
           probably not important anyway, but ... */
        extent(oSaveRequest:TableNames) = iExtent.
        do iLoop = 1 to iMax while cChangedTables[iLoop] ne '':
            oSaveRequest:TableNames[iLoop] = cChangedTables[iloop].
        end.
    end.

    return oSaveRequest.
end function.

function EnableDatasetForUpdate returns logical (phDataset as handle):
    define variable iLoop   as integer no-undo.
    define variable hBuffer as handle  no-undo.

    do iLoop = 1 to phDataset:num-buffers:
        hBuffer = phDataset:get-buffer-handle(iLoop).
        hBuffer:table-handle:tracking-changes = true.
    end.
end function.

function DisableDatasetForUpdate returns logical (phDataset as handle):
    define variable iLoop   as integer no-undo.
    define variable hBuffer as handle  no-undo.

    do iLoop = 1 to phDataset:num-buffers:
        hBuffer = phDataset:get-buffer-handle(iLoop).
        hBuffer:table-handle:tracking-changes = no.
    end.
end function.

function CreateComponentItem returns logical (input phBuffer as handle,
                                              input pcFinishedItemId as character,
                                              input pcItemId as character,
                                              input pdQuantity as decimal):
    if pcItemId eq '' or pcItemId eq ? or pcItemId eq '<NULL>' then
        return false.

    phBuffer:find-first(substitute(' where &1.ItemId eq &2 and &1.FinishedItemId eq &3',
                               phBuffer:name,
                               quoter(pcItemId),
                               quoter(pcFinishedItemId))) no-error.
    if not phBuffer:available then
    do:
        phBuffer:buffer-create().
        assign phBuffer::ItemId = pcItemId
               phBuffer::FinishedItemId = pcFinishedItemId.
    end.
    phBuffer::Quantity = phBuffer::Quantity + pdQuantity.
    phBuffer:buffer-release().

    return true.
end function.

function CreateEntityData returns logical (input phDataset as handle):
    define variable hOrder as handle no-undo.
    define variable hItem as handle no-undo.
    define variable hOrderLine as handle no-undo.
    define variable hFinishedItem as handle no-undo.
    define variable hComponentItem as handle no-undo.
    define variable cItemId as character no-undo.
    define variable cFinishedItemId as character no-undo.
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable cSalesrepCode as character no-undo.
    define variable oPropertyValue as String no-undo.
    define variable cSelectedAccessories as character no-undo.

    assign hOrder = phDataset:get-buffer-handle('eOrder')
           hOrderLine = phDataset:get-buffer-handle('eOrderLine')
           hFinishedItem = phDataset:get-buffer-handle('eFinishedItem')
           hComponentItem = phDataset:get-buffer-handle('eComponentItem').

    oPropertyValue = cast(oSecMgr:CurrentUserContext:UserProperties:Get(new String('Salesrep.Code')), String).
    if valid-object(oPropertyValue) then
        cSalesrepCode = oPropertyValue:Value.

    EnableDatasetForUpdate(phDataset).

    do transaction:
        /** -- add an order  -- **/
        hOrder:buffer-create().
        assign
            pcOrderId = guid(generate-uuid)
            hOrder::OrderNum = piOrderNumber
            hOrder::OrderId = pcOrderId
            hOrder::EnteredDate = now
            hOrder::OrderDate = today
            hOrder::DealerCode = pcDealerCode
            hOrder::Salesrepcode = cSalesrepCode
            hOrder::OrderStatus = 'ORDER-NEW'
            hOrder::CustomerNum = int(pcCustomerId)
            hOrder::Instructions = pcInstructions.
        hOrder:buffer-release().

        /* finished item */
        cItemId = GetSelectedOption(pcModel).
        hFinishedItem:buffer-create().
        assign
            cFinishedItemId = guid(generate-uuid)
            hFinishedItem::FinishedItemId = cFinishedItemId
            hFinishedItem::ItemId = cItemId
            hFinishedItem::StatusDate = now
            hFinishedItem::FinishedItemStatus = 'ORDER-NEW'.
        hFinishedItem:buffer-release().

        /* orderline */
        hOrderLine:buffer-create().
        assign
            hOrderLine::OrderId = pcOrderId
            hOrderLine::LineNum = 1
            hOrderLine::Quantity = 1
            hOrderLine::ItemId = cItemId
            hOrderLine::FinishedItemId = cFinishedItemId
            hOrderLine::OrderLineStatus = 'ORDER-NEW'.
        hOrderLine:buffer-release().

        /* components */
        CreateComponentItem(hComponentItem, cFinishedItemId, string(pcInteriorTrimColour), 1).
        CreateComponentItem(hComponentItem, cFinishedItemId, string(pcInteriorTrimMaterial), 1).
        CreateComponentItem(hComponentItem, cFinishedItemId, string(pcExteriorColour), 1).
        CreateComponentItem(hComponentItem, cFinishedItemId, string(pcWheels), 1).
        CreateComponentItem(hComponentItem, cFinishedItemId, string(pcMoonroof), 1).

        cSelectedAccessories = GetSelectedOption(pcInteriorAccessories).
        iMax = num-entries(cSelectedAccessories).
        do iLoop = 1 to iMax:
            CreateComponentItem(hComponentItem, cFinishedItemId, entry(iLoop, cSelectedAccessories), 1).
        end.
    end. /*transaction*/
end function.

function SaveData returns logical (input poRequest as ISaveRequest):
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable oRequest as IServiceRequest extent 1 no-undo.
    define variable oResponse as IServiceResponse extent 1 no-undo.
    define variable cTableName as character no-undo.
    define variable oTableResponse as ITableResponse no-undo.
    define variable cKeys as longchar no-undo.
    define variable cTexts as longchar no-undo.

    oRequest[1] = cast(poRequest, IServiceRequest).
    oResponse = oServiceMessageManager:ExecuteRequest(oRequest).

    if cast(oResponse[1], IServiceResponse):HasError then
    do:
        iMax  = num-entries(oResponse[1]:ErrorText, '|').
        do iLoop = 1 to iMax:
            cTableName = entry(iLoop, oResponse[1]:ErrorText, '|').

            oTableResponse = cast(cast(oResponse[1], ISaveResponse):TableResponses:Get(new String(cTableName)) , ITableResponse).

            cKeys = String:Join(cast(oTableResponse:ErrorText:KeySet:ToArray(), String), '|').
            cTexts = String:Join(cast(oTableResponse:ErrorText:Values:ToArray(), String), '|').
            undo, throw new ServiceRequestError(
                                'creating orders',
                                substitute('[ OrderNum: &1 ]', piOrderNumber)).
        end.
    end.
end function.

/** -- main block -- **/
/** Dummy return for modelling purposes (Savvion lets us make a test call to a WebService). */
if pcCustomerId eq 'Savvion::Test' then
do:
    assign pcOrderId = 'pcOrderId'
           pdOrderAmount = -1.
    return.
end.

/** -- validate defs -- **/
Assert:ArgumentNotNullOrEmpty(pcBrand, 'Brand').
Assert:ArgumentNonZero(piOrderNumber, 'Order Number').

/** -- main -- **/
oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType)
               , IServiceManager).

/* Are we who we say we are? Note that this should really happen on activate. activate doesn't run for state-free AppServers */
oSecMgr = cast(oServiceMgr:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).

oSecMgr:UserLogin('admin',
                  substitute('&1.&2', UserTypeEnum:System:ToString(), pcBrand),
                  'letmein').

oSecMgr:AuthoriseServiceAction('CaptureOrder', ServiceMessageActionEnum:SaveData).

oServiceMessageManager = cast(oServiceMgr:GetService(ServiceMessageManager:IServiceMessageManagerType), IServiceMessageManager).

FetchSchema(output dataset-handle mhOrderDataset).

CreateEntityData(mhOrderDataset).

SaveData(BuildSaveRequest()).

/* Now get the amount of the newly-created order */
FetchData(output dataset-handle mhOrderDataset).

mhOrderBuffer = mhOrderDataset:get-buffer-handle('eOrder').

mhOrderBuffer:find-first().
pdOrderAmount = mhOrderBuffer::OrderAmount.

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

finally:
    delete object mhOrderDataset no-error.
end finally.
/** -- eof -- **/
