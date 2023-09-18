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
    File        : load_orders.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Wed Dec 15 10:08:54 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

routine-level on error undo, throw.

/* ********************  Preprocessor Definitions  ******************** */
function GetAddressId returns character 
    (input pcType as character,
     input pcCustomerId as character,
     input pcTenantId as character):
    
    find AddressType where AddressType.AddressType = pcType no-lock.
    
    find CustomerAddress where
         CustomerAddress.AddressType eq AddressType.AddressType  and
         CustomerAddress.CustomerId eq pcCustomerId and
         CustomerAddress.TenantId eq pcTenantId
         no-lock no-error.
    
    if available CustomerAddress then
        return CustomerAddress.AddressDetailId.
end function.        

/* ***************************  Main Block  *************************** */
define variable iLoop as integer no-undo.
define variable iMax as integer no-undo.
define variable dOrder as date no-undo.
define variable iNumCustomers as integer no-undo.
define variable iLastOrderNum as integer no-undo.
define variable iNumAddresses as integer no-undo.
define variable iNumSalesreps as integer no-undo.
    
define buffer carItem for Item.
define buffer carItemType for ItemType.
define query qryCar for carItemType, carItem scrolling. 
define query qryItemOption for ItemOption, Item scrolling.

define query qryCustomer for Tenant, Customer scrolling.
define query qryAddresses for AddressDetail scrolling.
define query qrySalesrep for Salesrep scrolling.

open query qryAddresses preselect each AddressDetail no-lock.
iNumAddresses = query qryAddresses:num-results - 1.

open query qryCustomer preselect each Tenant no-lock, each Customer where Customer.TenantId eq Tenant.TenantId no-lock.
iNumCustomers = query qryCustomer:num-results - 1.

iMax = 30.

do iLoop = 1 to iMax:
    reposition qryCustomer to row random(0, iNumCustomers).
    get next qryCustomer no-lock.
    
    /* figure out the ordernum */    
    for each Order where
             Order.TenantId eq Tenant.TenantId
             no-lock
             by Order.OrderNum descending:
        iLastOrderNum = Order.OrderNum.
        leave.
    end.
    
    /* status and date */
    if iLoop mod 3 eq 0 then 
    do:
        find StatusDetail where StatusDetail.Code = 'order-build-complete' no-lock.
        dorder = today - 3.
    end.
    else if iLoop mod 3 eq 1 then 
    do:
        find StatusDetail where StatusDetail.Code = 'order-build-start' no-lock.
        dOrder = (today - 2).
    end.
    else if iLoop mod 3 eq 2 then
    do:
        find StatusDetail where StatusDetail.Code = 'order-new' no-lock.
            dOrder = (today - 1).
    end.
    
    /* salesrep */
    open query qrySalesrep preselect each Salesrep where Salesrep.TenantId eq Tenant.TenantId no-lock.
    iNumSalesreps = query qrySalesrep:num-results - 1.
    reposition qrySalesrep to row random(0, iNumSalesreps).
    get next qrySalesrep no-lock.
    
    if can-find(Order where
                Order.TenantId eq Tenant.TenantId and
                Order.OrderNum eq (iLastOrderNum + iLoop)) then
    do:
        /* since we skipped one, add on onto the end */
        iMax = iMax + 1.                
        next.
    end.
    
    create Order.
    assign Order.OrderId = guid(generate-uuid)
           Order.OrderNum = iLastOrderNum + iLoop
           Order.TenantId = Tenant.TenantId
           Order.OrderDate = dOrder
           Order.StatusId = StatusDetail.StatusDetailId
           Order.CustomerId = Customer.CustomerId
           Order.BillingAddressId = GetAddressId('Billing', Customer.CustomerId, Tenant.TenantId)
           Order.ShippingAddressId = GetAddressId('Shipping', Customer.CustomerId, Tenant.TenantId)
           Order.InventoryTransId = ''
           Order.InvoiceId = ''
           Order.SalesrepId = Salesrep.SalesrepId
           .
    run create_orderline (Order.OrderId, Order.TenantId, Order.OrderDate, Order.StatusId).
end.

procedure create_orderline:
    define input  parameter pcOrderId as character no-undo.
    define input  parameter pcTenantId as character no-undo.
    define input  parameter pdOrderDate as date no-undo.
    define input  parameter pcStatusId as character no-undo.
    
    define variable iNumCars as integer no-undo.
    define variable dTotalPrice as decimal no-undo.
    define variable dPrice as decimal no-undo.
    
    open query qryCar preselect 
        each carItemType where carItemType.Name begins 'vehicle-' no-lock,             
        each carItem where
             carItem.ItemTypeId eq carItemType.ItemTypeId and
             carItem.TenantId eq pcTenantId no-lock.
    iNumCars = query qryCar:num-results - 1.
    reposition qryCar to row random(0, iNumCars).
    get next qryCar no-lock.
        
    dTotalPrice = carItem.Price.
    
    create FinishedItem.
    assign FinishedItem.TenantId = pcTenantId
           FinishedItem.FinishedItemId = guid(generate-uuid)
           FinishedItem.ItemId = carItem.ItemId
           FinishedItem.StatusDate = pdOrderDate
           FinishedItem.ExternalId = ''
           FinishedItem.StatusId = pcStatusId
           .
    
    /* components */
    run create_component_item('Trim-Colour', FinishedItem.FinishedItemId, carItem.ItemId, pcTenantId, output dPrice).
    dTotalPrice = dTotalPrice + dPrice.
    
    run create_component_item('Trim-Material', FinishedItem.FinishedItemId, carItem.ItemId, pcTenantId, output dPrice).
    dTotalPrice = dTotalPrice + dPrice.
    
    run create_component_item('Wheels', FinishedItem.FinishedItemId, carItem.ItemId, pcTenantId, output dPrice).
    dTotalPrice = dTotalPrice + dPrice.

    run create_component_item('Accessories', FinishedItem.FinishedItemId, carItem.ItemId, pcTenantId, output dPrice).
    dTotalPrice = dTotalPrice + dPrice.
    
    run create_component_item('Fuel', FinishedItem.FinishedItemId, carItem.ItemId, pcTenantId, output dPrice).
    dTotalPrice = dTotalPrice + dPrice.
    
    run create_component_item('Engine', FinishedItem.FinishedItemId, carItem.ItemId, pcTenantId, output dPrice).
    dTotalPrice = dTotalPrice + dPrice.
    
    run create_component_item('Moonroof', FinishedItem.FinishedItemId, carItem.ItemId, pcTenantId, output dPrice).
    dTotalPrice = dTotalPrice + dPrice.
    
    create OrderLine.
    assign OrderLine.OrderId = pcOrderId
           OrderLine.TenantId = pcTenantId
           OrderLine.Discount = 0
           OrderLine.FinishedItemId = FinishedItem.FinishedItemId
           OrderLine.ItemId = FinishedItem.ItemId
           OrderLine.LineNum = 1
           OrderLine.Price = dTotalPrice
           OrderLine.Qty = 1 
           OrderLine.StatusId = pcStatusId
           .
end procedure.    
    
procedure create_component_item:
    define input  parameter pcType as character no-undo.
    define input  parameter pcFinishedItemId as character no-undo.
    define input  parameter pcBaseItemId as character no-undo.
    define input  parameter pcTenantId as character no-undo.
    define output parameter pdPrice as decimal no-undo.
    
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable cItemId as character no-undo.
    define variable iNumOptions as integer no-undo.
    
    find ItemType where ItemType.Name eq pcType no-lock.
    
    open query qryItemOption preselect 
        each ItemOption where
             ItemOption.TenantId eq pcTenantId and
             ItemOption.ItemId eq pcBaseItemId
             no-lock,
        first Item where
              Item.ItemId eq ItemOption.ChildItemId and 
              Item.TenantId eq ItemOption.TenantId and
              Item.ItemTypeId eq ItemType.ItemTypeId
              no-lock.
    case query qryItemOption:num-results:
        when 0 then
            return.
        when 1 then
            get first qryItemOption no-lock.
        otherwise
        do:
            iNumOptions = query qryItemOption:num-results - 1.
            reposition qryItemOption to row random(0, iNumOptions).
            get next qryItemOption no-lock.
        end.
    end case.
    
    iMax = max(ItemOption.Quantity, 1).
    do iLoop = 1 to iMax:
        pdPrice = pdPrice + Item.Price. 
    end.
    
    create ComponentItem.
    assign ComponentItem.FinishedItemId = pcFinishedItemId
           ComponentItem.ItemId = Item.ItemId
           ComponentItem.Qty = ItemOption.Quantity
           ComponentItem.TenantId = pcTenantId.
end procedure.

/* eof */
