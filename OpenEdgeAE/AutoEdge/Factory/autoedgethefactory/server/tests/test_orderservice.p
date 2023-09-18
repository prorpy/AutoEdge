/*------------------------------------------------------------------------
    File        : test_orderservice.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon Feb 21 09:07:17 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequestTypeEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceRequestError.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.  
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
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
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ITableRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.TableRequest.

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
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.ObjectInputStream.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.ObjectOutputStream.

using OpenEdge.Lang.OperatorEnum.
using OpenEdge.Lang.JoinEnum.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.SessionClientTypeEnum.
using OpenEdge.Lang.ByteOrderEnum.

using Progress.Lang.AppError.
using Progress.Lang.Error.

/** -- params, variables -- **/
define variable iOrderNumber as integer no-undo.
define variable cTenant as character no-undo.
define variable cDealerCode as character no-undo.
def var crepcode as char.
define variable cOrderId as character no-undo.
define variable dOrderAmount as decimal no-undo.
define variable iCustNum  as int no-undo.

define variable oServiceMessageManager as IServiceMessageManager no-undo.
define variable oServiceMgr as IServiceManager no-undo.
define variable oSecMgr as ISecurityManager no-undo.
define variable mhOrderDataset as handle no-undo.

/** -- -- **/

/** Deserialises a MEMPTR into a UserContext object. This helper function is in this
        super class since this is a frequently-undertaken action.
        
        @param memptr The serialised user-context
        @return IUserContext The reconstituted object.  */
function DeserializeContext returns IUserContext  (input pmUserContext as memptr):
        define variable oContext as IUserContext no-undo.
        define variable oInput as IObjectInput no-undo.
        
        oInput = new ObjectInputStream().
        oInput:Read(pmUserContext).
        oContext = cast(oInput:ReadObject(), IUserContext).
        
        return oContext.
        finally:
            set-size(pmUserContext) = 0.
        end finally. 
end function.

    /** Serialises a UserContext object to MEMPTR. This helper function is in this
        super class since this is a frequently-undertaken action.
        
        @return IUserContext The context being serialised.
        @param memptr The serialised user-context   */
function  SerializeContext returns memptr  (input poUserContext as IUserContext):
        define variable mContext as memptr no-undo.
        define variable oOutput as IObjectOutput no-undo.
        
        oOutput = new ObjectOutputStream().
        oOutput:WriteObject(poUserContext).
        oOutput:Write(output mContext).
        
        return mContext.
        finally:
            set-size(mContext) = 0.
        end finally. 
end function.

function FetchDataForOrderNum returns logical (input piOrderNum as integer,
                                    output dataset-handle phDataset):
    
    define variable oTableRequest as ITableRequest no-undo.
    define variable oFetchRequest as IFetchRequest extent 1 no-undo.
    define variable cTableName as character no-undo.
    define variable oResponse as IServiceResponse extent no-undo.
    
    oFetchRequest[1] = new FetchRequest('Order', ServiceMessageActionEnum:FetchData).
    
    cTableName = 'eOrder'.
    oTableRequest = new TableRequest(cTableName).
/*    oTableRequest:TableRequestType = TableRequestTypeEnum:NoChildren.*/
    oFetchRequest[1]:TableRequests:Put(cTableName, oTableRequest).

    cast(oTableRequest, IQueryDefinition):AddFilter(cTableName,
                                          'OrderNum',
                                          OperatorEnum:IsEqual,
                                          new String(string(piOrderNum)),
                                          DataTypeEnum:Integer,
                                          JoinEnum:And).
    
    oResponse = oServiceMessageManager:ExecuteRequest(cast(oFetchRequest, IServiceRequest)).
    
    cast(oResponse[1], IServiceMessage):GetMessageData(output phDataset).
    
    phDataset:write-json('file', session:temp-dir + 'fetchordernum.json', true).
end function.

function FetchDataForDealer returns logical (input pcDealerCode as character,
                                             output dataset-handle phDataset):
    
    define variable oTableRequest as ITableRequest no-undo.
    define variable oFetchRequest as IFetchRequest extent 1 no-undo.
    define variable cTableName as character no-undo.
    define variable oResponse as IServiceResponse extent no-undo.
    
    oFetchRequest[1] = new FetchRequest('Order', ServiceMessageActionEnum:FetchData).
    
    cTableName = 'eOrder'.
    oTableRequest = new TableRequest(cTableName).
/*    oTableRequest:TableRequestType = TableRequestTypeEnum:NoChildren.*/
    oFetchRequest[1]:TableRequests:Put(cTableName, oTableRequest).

    cast(oTableRequest, IQueryDefinition):AddFilter(cTableName,
                                          'DealerCode',
                                          OperatorEnum:IsEqual,
                                          new String(pcDealerCode),
                                          DataTypeEnum:Character,
                                          JoinEnum:And).
    
    oResponse = oServiceMessageManager:ExecuteRequest(cast(oFetchRequest, IServiceRequest)).
    
    cast(oResponse[1], IServiceMessage):GetMessageData(output phDataset).
    
    phDataset:write-json('file', session:temp-dir + 'fetchorderdealer.json', true).
end function.


function FetchSchema returns logical (output dataset-handle phDataset):
    define variable oRequest as IServiceRequest extent 1 no-undo.
    define variable oResponse as IServiceResponse extent no-undo.
    
    oRequest[1] = new FetchRequest('Order', ServiceMessageActionEnum:FetchSchema).
    
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


function SaveData returns logical (input poRequest as ISaveRequest):
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable oRequest as IServiceRequest extent 1 no-undo.
    define variable oResponse as IServiceResponse extent 1 no-undo.
    define variable cTableName as character no-undo.
    define variable oTableResponse as ITableResponse no-undo.   
    define variable cKeys as longchar no-undo.
    define variable cTexts as longchar no-undo.
               
    oRequest[1] = cast(BuildSaveRequest(), IServiceRequest).
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
                                substitute('[ OrderNum: &1 ]', iOrderNumber)).
        end.
    end.    
end function.

function CreateOrder returns logical(input phDataset as handle,
            input piOrderNum as int,
            input pcDealerCode as char,
            input pcRepCode as char,
            input piCustNum as int):
    define variable hOrder as handle no-undo.
    define variable hItem as handle no-undo.
    define variable hOrderLine as handle no-undo.
    define variable hFinishedItem as handle no-undo.
    define variable hComponent as handle no-undo.
    define variable cOrderId as character no-undo.
    define variable cInstructions as character no-undo.
    
    def var hTransport as handle.
    def var i as int.
    def var i2 as int.
    def var oKeys as String extent.
    def var oTexts as String extent.
    def var cStrVal1 as character.
    def var cStrVal2 as character.
    
    hOrder = phDataset:get-buffer-handle('eOrder').
    hOrderLine = phDataset:get-buffer-handle('eOrderLine').
    hFinishedItem = phDataset:get-buffer-handle('eFinishedItem').
    hComponent = phDataset:get-buffer-handle('eComponentItem').
    
    EnableDatasetForUpdate(phDataset).
    
    do transaction:
        /** -- add an order  -- **/
        hOrder:buffer-create().
            hOrder::OrderId = guid(generate-uuid).
            hOrder::OrderNum = piOrderNum.
            hOrder::EnteredDate = now.
            hOrder::OrderDate = today.
            hOrder::OrderStatus = 'ORDER-NEW'.
            hOrder::CustomerNum = piCustNum.
            hOrder::SalesrepCode = pcRepCode.
            hOrder::DealerCode = pcDealerCode.
            hOrder::Instructions = cInstructions.
        hOrder:buffer-release().
        
        /* finished item */
        hFinishedItem:buffer-create().
            hFinishedItem::FinishedItemId = guid(generate-uuid).
            /*hFinishedItem::ItemId =*/  
            hFinishedItem::StatusDate = now.
            hFinishedItem::FinishedItemStatus = 'ORDER-BUILD-START'.
        hFinishedItem:buffer-release().
        
        /* orderline */
        hOrderLine:buffer-create().
            hOrderLine::OrderId = hOrder::OrderId.
            hOrderLine::LineNum = 1.
            hOrderLine::Price = 0.
            hOrderLine::Quantity = 1.
            hOrderLine::FinishedItemId = hFinishedItem::FinishedItemId.
            /*
            hOrderLine::ItemId =
            */
            hOrderLine::OrderLineStatus = 'ORDER-NEW'. 
        hOrderLine:buffer-release().

/***        
        /*  item */
        
        
***/        
    end. /*transaction*/    
end function.

function ModifyOrder returns logical (input phDataset as handle, input piOrderNum as int):
    define variable hOrder as handle no-undo.
    define variable hItem as handle no-undo.
    define variable hOrderLine as handle no-undo.
    define variable hFinishedItem as handle no-undo.
    define variable hItemOption as handle no-undo.
    
    def var hTransport as handle.
    def var i as int.
    def var i2 as int.
    def var oKeys as String extent.
    def var oTexts as String extent.
    def var cStrVal1 as character.
    def var cStrVal2 as character.
    
    hOrder = phDataset:get-buffer-handle('eOrder').
    hOrderLine = phDataset:get-buffer-handle('eOrderLine').
    hFinishedItem = phDataset:get-buffer-handle('eFinishedItem').
    hItemOption = phDataset:get-buffer-handle('eItemOption').
    
end function.

function DeleteOrder returns logical (input phDataset as handle, input piOrderNum as int):
    define variable hOrder as handle no-undo.
    define variable hItem as handle no-undo.
    define variable hOrderLine as handle no-undo.
    define variable hFinishedItem as handle no-undo.
    define variable hItemOption as handle no-undo.
    
    def var hTransport as handle.
    def var i as int.
    def var i2 as int.
    def var oKeys as String extent.
    def var oTexts as String extent.
    def var cStrVal1 as character.
    def var cStrVal2 as character.
    
    hOrder = phDataset:get-buffer-handle('eOrder').
    hOrderLine = phDataset:get-buffer-handle('eOrderLine').
    hFinishedItem = phDataset:get-buffer-handle('eFinishedItem').
    hItemOption = phDataset:get-buffer-handle('eItemOption').
    
end function.

/* ***************************  Main Block  *************************** */
&global-define USE-ROUTINE-LEVEL false

SessionClientTypeEnum:CurrentSession = SessionClientTypeEnum:AppServer.

run OpenEdge/CommonInfrastructure/Server/as_startup.p (SessionClientTypeEnum:AppServer).

/** -- main -- **/
oServiceMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType)
               , IServiceManager).

/* Are we who we say we are? Note that this should really happen on activate. activate doesn't run for state-free AppServers */
oSecMgr = cast(oServiceMgr:StartService(SecurityManager:ISecurityManagerType), ISecurityManager).

cTenant =  'FJORD'.
iOrderNumber =  12.
cDealerCode = 'dealer03'.
crepcode = 'fc'.
iCustNum = 4.

oSecMgr:UserLogin('frank.coleman', 'sales.employee.' + cTenant, ('letmein')).

oSecMgr:AuthoriseServiceAction('CaptureOrder', ServiceMessageActionEnum:SaveData).

oServiceMessageManager = cast(oServiceMgr:StartService(ServiceMessageManager:IServiceMessageManagerType), IServiceMessageManager).

/*
FetchSchema(output dataset-handle mhOrderDataset).
CreateOrder(mhOrderDataset,
    iOrderNumber,
    cDealerCode,
    cRepCode,
    iCustNum ).
    
SaveData(BuildSaveRequest()).
*/

mhOrderDataset = ?.

FetchDataForDealer(cDealerCode, output dataset-handle mhOrderDataset).

/*
FetchDataForOrderNum(iOrderNumber, output dataset-handle mhOrderDataset).
*/

/*
ModifyOrder(mhOrderDataset, iOrderNumber).
DeleteOrder(mhOrderDataset, iOrderNumber).

SaveData(BuildSaveRequest()).
*/

/** ----------------- **/
catch oException as OpenEdge.Core.System.ApplicationError:
    oException:LogError().
    oException:ShowError().
end catch.

catch oAppError as Progress.Lang.AppError:
    message
        oAppError:ReturnValue skip(2)
        oAppError:CallStack
        view-as alert-box error title 'Unhandled Progress.Lang.AppError'.
end catch.

catch oError as Progress.Lang.Error:
    message
        oError:GetMessage(1)      skip
        '(' oError:GetMessageNum(1) ')' skip(2)        
        oError:CallStack
        view-as alert-box error title 'Unhandled Progress.Lang.Error'.
end catch.

finally:
    message skip(2)
    'just about done'
    view-as alert-box error title '[PJ DEBUG]'.
    run OpenEdge/CommonInfrastructure/Common/stop_session.p.
end finally.

/** -- eof -- **/