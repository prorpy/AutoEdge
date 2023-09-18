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
    File        : load_items.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon Dec 20 15:23:50 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

/* ***************************  Definitions  ************************** */
define temp-table ttItemOption no-undo serialize-name 'option'
    field TenantName as character serialize-name 'brand' xml-node-type 'hidden'
    field ItemTypeName as character serialize-name 'type'  xml-node-type 'attribute'
    field ParentItemNum as integer xml-node-type 'attribute' serialize-name 'parentitemnum'
    field ItemName as character serialize-name  'name' xml-node-type 'attribute'
    field StandardOption as logical serialize-name  'isstandard' xml-node-type 'attribute' initial false
    index idx1 as primary unique TenantName ParentItemNum ItemTypeName ItemName.
    
define temp-table ttItem no-undo serialize-name 'item'
    field TenantName as character serialize-name 'brand' 
    field ItemNum as integer xml-node-type 'attribute' serialize-name 'num'
    field ItemName as character serialize-name  'name'
    field Description as character serialize-name 'description' /* lowercase*/
    field ItemTypeName as character serialize-name 'type'  xml-node-type 'attribute'
    field Price as decimal serialize-name 'price' /* lowercase */
    field Quantity as decimal serialize-name 'qty'
    field StandardOption as logical serialize-name  'isstandard' xml-node-type 'attribute' initial false
    index idx1 as primary unique TenantName ItemNum
    .

define temp-table ttBrand no-undo serialize-name 'brand'
    field TenantName as character serialize-name 'name' xml-node-type 'attribute'
    index idx1 as primary unique TenantName.     
    
define dataset dsVehicles serialize-name 'vehicles' for ttBrand, ttItem, ttItemOption
    data-relation for ttBrand, ttItem relation-fields (TenantName, TenantName) nested
    data-relation for ttItem, ttItemOption relation-fields (TenantName, TenantName, ItemNum, ParentItemNum) nested
    .
        

/* ********************  Preprocessor Definitions  ******************** */

function getRandom returns character (input cValueList as character):
    define variable iEntries as integer    no-undo.
    iEntries = num-entries (cValueList, '|') .
    if iEntries > 1 
        then return entry ((random (1, iEntries)), cValueList, '|') .
        else return cValueList .
end function .

/* ***************************  Main Block  *************************** */
define variable cFile as character no-undo.

cFile = search('setup/data/vehicles.xml').

dataset dsVehicles:read-xml('file', cFile, 'Empty', ?, ?).
/*dataset dsVehicles:write-json('file', './cars.json', true).*/

run load_ItemType.
run load_vehicle_items.

procedure load_vehicle_items:
    define buffer lbItem for Item.
    define buffer childTenant for Tenant.
    define buffer lbttItem for ttItem.
    
    /* create options for the items */
    for each Tenant no-lock:
        
        /* only want items of brands */
        if Tenant.ParentTenantId eq '' then next.    
        if can-find(first childTenant where childTenant.ParentTenantId = Tenant.TenantId) then next.
        
        /* create the generic options */
        for each ttBrand where ttBrand.TenantName = 'all',
            each ttItem where
                 ttItem.TenantName = ttBrand.TenantName,
            first ItemType where
                  ItemType.Name = ttItem.ItemTypeName
                  no-lock:
                      
            /* allow reruns */
            if can-find(Item where
                        Item.ItemNum eq ttItem.ItemNum and
                        Item.TenantId eq Tenant.TenantId) then next.
            create Item.
            assign Item.TenantId    = Tenant.TenantId
                   Item.ItemId      = guid(generate-uuid)
                   Item.ItemTypeId  = ItemType.ItemTypeId
                   Item.ItemNum     = ttItem.ItemNum
                   Item.ItemName    = ttItem.ItemName
                   Item.Price       = ttItem.Price
                   Item.OnHand      = random(1, 50)
                   Item.Allocated   = 0
                   Item.Description = ttItem.Description
                   Item.Weight      = 0
                   Item.MinQty      = 0.
        end.    /* 'all' items */
        
        for each ttBrand where
             ttBrand.TenantName = Tenant.Name, 
            each ttItem where
                 ttItem.TenantName = ttBrand.TenantName,
            first ItemType where
                  ItemType.Name = ttItem.ItemTypeName
                  no-lock.
              
            /* allow reruns */
            find Item where
                 Item.ItemNum eq ttItem.ItemNum and
                 Item.TenantId eq Tenant.TenantId
                 no-lock no-error.
            
            if not available Item then
            do:
                /* create the vehicles */
                create Item.
                assign Item.TenantId    = Tenant.TenantId
                       Item.ItemId      = guid(generate-uuid)
                       Item.ItemTypeId  = ItemType.ItemTypeId
                       Item.ItemNum     = ttItem.ItemNum
                       Item.ItemName    = ttItem.ItemName
                       Item.Price       = ttItem.Price
                       Item.OnHand      = random(1, 50)
                       Item.Allocated   = 0
                       Item.Description = ttItem.Description
                       Item.Weight      = 0
                       Item.MinQty      = 0.
            end.
                        
            run associate_generic(Item.TenantId, Item.ItemId).
            
            for each ttItemOption where
                     ttItemOption.TenantName eq ttItem.TenantName and
                     ttItemOption.ParentItemNum eq ttItem.ItemNum:
                
                find first lbItem where
                      lbItem.ItemName eq ttItemOption.ItemName and
                      lbItem.TenantId eq Tenant.TenantId
                      no-lock.

                find first lbttItem where
                      lbttItem.TenantName eq ttBrand.TenantName and
                      lbItem.ItemName eq ttItemOption.ItemName
                      no-lock.
                
                find ItemOption where
                     ItemOption.ItemId eq Item.ItemId and
                     ItemOption.ChildItemId eq lbItem.ItemId and
                     ItemOption.TenantId eq Item.TenantId
                     exclusive-lock no-error.
                if not available ItemOption then
                do:
                    create ItemOption.
                    assign ItemOption.ItemId = Item.ItemId
                           ItemOption.ChildItemId = lbItem.ItemId
                           ItemOption.TenantId = Item.TenantId.
                end.
                
                assign ItemOption.Quantity = ttItem.Quantity
                       ItemOption.StandardOption = ttItemOption.StandardOption.                 
            end.    /* item options */
        end.    /* each brand */
    end.    /* each tenant */
end.    /* procedure */

procedure associate_generic:
    define input parameter pcTenantId as character no-undo.
    define input parameter pcVehicleItemId as character no-undo.
    
    define buffer lbttOption for ttItemOption.
    define buffer lbItem for Item.
    define buffer lbttItem for ttItem.
    define buffer lbttBrand for ttBrand.

    /* create the generic options */
    for each lbttBrand where lbttBrand.TenantName = 'all' no-lock,
        each lbttItem where
             lbttItem.TenantName eq lbttBrand.TenantName
             no-lock,
        first lbItem where
              lbItem.ItemName eq lbttItem.ItemName and 
              lbItem.TenantId eq pcTenantId
              no-lock:
        /* xml should contain engine and fuel combos */
        if lookup(lbttItem.ItemTypeName, 'engine,fuel') gt 0 then
            next.
        find ItemOption where
             ItemOption.ItemId eq pcVehicleItemId and
             ItemOption.ChildItemId eq lbItem.ItemId and
             ItemOption.TenantId eq pcTenantId
             exclusive-lock no-error.
        if not available ItemOption then
        do:             
            create ItemOption.
            assign ItemOption.ItemId = pcVehicleItemId
                   ItemOption.ChildItemId = lbItem.ItemId
                   ItemOption.TenantId = pcTenantId.
        end.
        
        assign ItemOption.Quantity = lbttItem.Quantity
               ItemOption.StandardOption = lbttItem.StandardOption. 
    end.
end procedure.

procedure load_ItemType:
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable cTypes as character no-undo.
    
    cTypes = 'Engine|Fuel|Wheels|Trim-Material|Trim-Colour|Ext-Colour|Moonroof|Accessories|'
           + 'Vehicle-Convertible|Vehicle-Coupe|Vehicle-Sedan|Vehicle-SUV|Vehicle-Crossover|Vehicle-Truck|Vehicle-Commercial|Vehicle-Compact'. 
    
    iMax = num-entries(cTypes, '|').    
    do iLoop = 1 to iMax:
        if can-find(ItemType where ItemType.Name eq entry(iLoop, cTypes, '|')) then
            next.
            
        create ItemType.
        assign ItemType.ItemTypeId = guid(generate-uuid)
               ItemType.Name = entry(iLoop, cTypes, '|')
               ItemType.Description = 'Items of type ' + ItemType.Name.
    end.
    
end procedure.
