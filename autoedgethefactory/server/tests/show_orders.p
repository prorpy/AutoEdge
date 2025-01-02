/*------------------------------------------------------------------------
    File        : show_orders.p
    Purpose     :

    Syntax      :

    Description :

    Author(s)   : pjudge
    Created     : Mon Apr 04 15:33:24 EDT 2011
    Notes       :
  ----------------------------------------------------------------------*/

current-window:width-c = 180.

/* ***************************  Definitions  ************************** */
define buffer itemItem for Item.
define buffer finishedItemItem for Item.

define buffer itemItemType  for ItemType.
define buffer finishedItemItemType for ItemType.

/* ***************************  Main Block  *************************** */

for each Tenant no-lock:
    
    /* not all tenant have orders */
    if not can-find(first order where order.tenantid eq tenant.tenantid) then
        next.

    for each Order where
             Order.TenantId eq Tenant.TenantId
             no-lock,
        first Customer where
              Customer.CustomerId eq Order.CustomerId
              no-lock,
        first StatusDetail where
              StatusDetail.StatusDetailId eq Order.StatusId
              no-lock
              by Order.OrderNum descending:
        displ
            Tenant.Name label 'Brand'
            StatusDetail.Code form 'x(30)' label 'Status' skip
            Order.OrderNum
            Customer.Name label 'Customer'
            Order.OrderDate
            with width 150 title 'Orders' side-labels.

        for each OrderLine where
                 OrderLine.OrderId eq Order.OrderId and
                 OrderLine.TenantId eq Order.TenantId
                 no-lock,
            first FinishedItem where
                  FinishedItem.FinishedItemId eq OrderLine.FinishedItemId and
                  FinishedItem.TenantId eq OrderLine.TenantId
                  no-lock,
            first finishedItemItem where
                  finishedItemItem.TenantId eq FinishedItem.TenantId and
                  finishedItemItem.ItemId eq FinishedItem.ItemId
                  no-lock,
            first finishedItemItemType where
                  finishedItemItemType.ItemTypeId eq FinishedItemItem.ItemTypeId
                  no-lock:

            displ
                OrderLine.LineNum
                OrderLine.Price
                OrderLine.Qty
                finishedItemItem.ItemNum
                finishedItemItem.ItemName
                finishedItemItem.Price
                finishedItemItemType.Name
                with width 150 title 'Order Lines' no-labels.

            for each ComponentItem where
                     ComponentItem.FinishedItemId eq FinishedItem.FinishedItemId and
                     ComponentItem.TenantId eq FinishedItem.TenantId
                     no-lock,
                first itemItem where
                      itemItem.TenantId eq ComponentItem.TenantId and
                      itemItem.ItemId eq ComponentItem.ItemId
                      no-lock,
                first itemItemType where
                      itemItemType.ItemTypeId eq itemItem.ItemTypeId
                      no-lock:

                displ
                    itemItem.ItemNum
                    itemItem.ItemName
                    ComponentItem.Qty
                    itemItem.Price (sum)
                    itemItemType.Name
                    with width 150 title 'Component Items'.

            end.
        end.
    end.
end.

