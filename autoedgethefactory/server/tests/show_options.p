/*------------------------------------------------------------------------
    File        : show_options.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon Apr 04 16:25:50 EDT 2011
    Notes       :
  ----------------------------------------------------------------------*/
current-window:width-c = 150.

/* ***************************  Definitions  ************************** */
define buffer childItemItem for Item.
define buffer childItemItemType  for ItemType.
define buffer childTenant for Tenant.

/* ***************************  Main Block  *************************** */

for each Tenant no-lock by Tenant.Name:
    
    /* only want customers of brands */
    if Tenant.ParentTenantId eq '' then next.
    
    if can-find(first childTenant where childTenant.ParentTenantId = Tenant.TenantId) then next.    
    
    displ Tenant.Name
        with width 120 title 'Brands'.
    
    for each ItemType where
             ItemType.Name begins 'Vehicle-'
             no-lock,
        each Item where
             Item.ItemTypeId eq ItemType.ItemTypeId and 
             Item.TenantId eq Tenant.TenantId
             no-lock
             by Item.ItemNum:
        
        displ
            Item.ItemNum 
            Item.ItemName
            ItemType.Name
            with width 120 title 'Vehicles' down.
            
        for each ItemOption where
                 ItemOption.TenantId eq Item.TenantId and
                 ItemOption.ItemId eq Item.ItemId
                 no-lock,
            each childItemItem where
                 childItemItem.TenantId eq ItemOption.TenantId and
                 childItemItem.ItemId eq ItemOption.ChildItemId
                 no-lock,
            first childItemItemType where
                  childItemItemType.ItemTypeId eq childItemItem.ItemTypeId
                  no-lock
                  break by childItemItemType.Name:
            
                displ
                    childItemItemType.Name when first-of(childItemItemType.Name)
                    childItemItem.ItemNum
                    childItemItem.ItemName
                    ItemOption.StandardOption
                    with width 120 title 'Item Options'.
        end.                          
    end.
end.

