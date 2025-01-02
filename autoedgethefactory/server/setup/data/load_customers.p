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
    File        : load_customers.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Wed Dec 15 09:19:48 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
routine-level on error undo, throw.


/* ********************  Preprocessor Definitions  ******************** */
function getRandom returns character (input cValueList as character):
    define variable iEntries as integer    no-undo.
    iEntries = num-entries (cValueList, '|') .
    if iEntries > 1 
        then return entry ((random (1, iEntries)), cValueList, '|') .
        else return cValueList.
end function.

/* ***************************  Main Block  *************************** */
define variable iCustNum as integer no-undo.
define variable iMax as integer no-undo.
define variable iNumCreated as integer no-undo.
define variable cLastNames as character no-undo.
define variable cMiddleNames as character no-undo.
define variable cFirstNamesMale as character no-undo.
define variable cFirstNamesFemale as character no-undo.
define variable cSalutationsMale as character no-undo.
define variable cSalutationsFemale as character no-undo.
define variable cNotes as character no-undo.
define variable cEmailAddress as character no-undo.
define variable cFullName as character no-undo.

define variable iNumAddresses as integer no-undo.
define buffer childTenant for Tenant.

define query qryAddresses for AddressDetail scrolling.

iMax = 10.

cLastNames = "Miller|Anderson|Higgins|Gant|Jones|Smith|Johnson|Moore|Taylor|Jackson|Harris|Martin|Garcia|Martinez|Robinson|Lewis|Lee|Walker|Baker|Nelson|Carter|Roberts|Tuner|Parker|Evans|Collins|Stewart|Murphy|Cooper|Richardson|Cox|Howard|Geller|Bing|Ward|Torres|Peterson|Gray|Ramirez|James|Watson|Brooks|Kelly|Sanders|Price|Bennet|Wood|Barnes|Ross|Henderson|Coleman|Jenkins|Perry|Powell|Long|Patterson|Hughes|Flores|Washington|Butler|Simmons|Foster|Gonzales|Alexander|Hayes|Myers|Ford|Hamilton|Graham|Sullivan|Wallace|Woods|West|Jordan|Reynolds|Marshall|Freeman|Wells|Webbs|Simpson|Stevens|Tucker|Porter|Hunter|Hicks|Crawford|Kennedy|Burns|Shaw|Holmes|Robertson|Hunt|Black|Palmer|Rose|Spencer|Pierce|Wagner".
cMiddleNames = "A.|B.|M.|N.|L.||".
cFirstNamesMale = "John|Robert|Mike|David|Richard|Thomas|Chris|Paul|Mark|Donald|Steve|Anthony|Larry|Frank|Scott|Eric|Greg|Patrick|Peter|Carl|Arthur|Joe|Jack|Justin|Keith".
cFirstNamesFemale = "Mary|Linda|Barbara|Susan|Margaret|Lisa|Nancy|Betty|Helen|Donna|Carol|Laura|Sarah|Jessica|Melissa|Brenda|Amy|Rebecca|Martha|Amanda|Janet|Ann|Joyce|Diane|Alice|Julie|Heather|Evelyn|Kelly".
cSalutationsMale = "Mr.|Mr.|Mr.|Mr.|Mr.|Mr.|Dr.".
cSalutationsFemale = "Ms.|Miss|Ms.|Miss|Ms.|Miss|Dr.".
cNotes = "Some note|Another note|No note|||||".
cEmailAddress = "@customer.aetf".

open query qryAddresses preselect each AddressDetail.
iNumAddresses = query qryAddresses:num-results - 1.

for each Tenant:
    /* only want customers of brands */
    if Tenant.ParentTenantId eq '' then next.    
    if can-find(first childTenant where childTenant.ParentTenantId = Tenant.TenantId) then next.
    
    /* get the last custnum per tenant */
    for each Customer where
             Customer.TenantId eq Tenant.TenantId
             no-lock
             by Customer.CustNum desc:
        iCustNum = Customer.CustNum.
        leave.
    end.
    
    do while iNumCreated le iMax: 
        iCustNum = iCustNum + 1.
        
        if can-find(Customer where
                    Customer.CustNum eq iCustNum and
                    Customer.TenantId eq Tenant.TenantId) then
            next.
            
        iNumCreated = iNumCreated + 1.
        
        if iCustNum mod 2 eq 0 then
            cFullName = getRandom(cFirstNamesFemale) + ' ' + getRandom(cMiddleNames) + ' ' + getRandom(cLastNames).
        else
            cFullName = getRandom(cFirstNamesMale) + ' ' + getRandom(cMiddleNames) + ' ' + getRandom(cLastNames).
        
        run AddCustomer(iCustNum, Tenant.TenantId, Tenant.LocaleId, cFullName).             
    end.
    
    /* Create a similarly-named customer & user for all brands, for easy memorisation. Also add
       'bad' user with no email address. */
    if not can-find(first Customer where
                          Customer.TenantId eq Tenant.TenantId and
                          Customer.Name begins 'Amy') then
    do:
        iNumCreated = 0.
        do while iNumCreated le 1: 
            iCustNum = iCustNum + 1.
            
            if can-find(Customer where
                        Customer.CustNum eq iCustNum and
                        Customer.TenantId eq Tenant.TenantId) then
                next.
            
            iNumCreated = iNumCreated + 1.
            cFullName = 'Amy ' + getRandom(cMiddleNames) + ' ' + getRandom(cLastNames).
            run AddCustomer(iCustNum, Tenant.TenantId, Tenant.LocaleId, cFullName).             
        end.
    end.    /* create amy */
end.

procedure AddCustomer:
    define input  parameter piCustNum as integer no-undo.
    define input  parameter pcTenantId as character no-undo.
    define input  parameter pcLocaleId as character no-undo.
    define input  parameter pcName as character no-undo.
    
    create Customer.
    assign Customer.CustNum = iCustNum
           Customer.Name = pcName
           Customer.Balance = random(0, 25000)
           Customer.Comments = getRandom(cNotes)
           Customer.CreditLimit = random(0, 25000)
           Customer.CustomerId = guid(generate-uuid)
           Customer.Discount = random(0, 11)
           Customer.Language = 'EN-US'
           Customer.PrimaryLocaleId = Tenant.LocaleId
           Customer.SalesrepId = ''
           Customer.TenantId = Tenant.TenantId
           Customer.Terms = ''.
    
    reposition qryAddresses to row random(0, iNumAddresses).
    get next qryAddresses no-lock.

    /* default billing and shipping to same address */
    run AddCustomerAddress(
            'billing',
            Customer.TenantId,
            Customer.CustomerId,
            AddressDetail.AddressDetailId).
    run AddCustomerAddress(
            'shipping',
            Customer.TenantId,
            Customer.CustomerId,
            AddressDetail.AddressDetailId).
    
    run AddCustomerContact(
            'email-home',
            Customer.TenantId, 
            Customer.CustomerId,
            trim(entry(1, Customer.Name, ' ')) + getRandom(cEmailAddress)).
    
    run AddCustomerContact(
            'phone-mobile',
            Customer.TenantId, 
            Customer.CustomerId,
            substitute('&1-555-&2',
                       random(201, 979),
                       random(1000, 9999))).    
end procedure.
    
procedure AddCustomerContact:
    define input parameter pcContactType as character no-undo.
    define input parameter pcTenantId as character no-undo.
    define input parameter pcCustomerId as character no-undo.
    define input parameter pcContactDetail as character no-undo.

    find first ContactDetail where ContactDetail.Detail eq pcContactDetail no-lock no-error.
    if not available ContactDetail then
    do:
        create ContactDetail.
        assign ContactDetail.ContactDetailId = guid(generate-uuid)
               ContactDetail.Detail = pcContactDetail.
    end.

    find ContactType where ContactType.Name eq pcContactType no-lock.
    
    if can-find(CustomerContact where
                CustomerContact.CustomerId eq pcCustomerId and
                CustomerContact.TenantId eq pcTenantId and
                CustomerContact.ContactType eq ContactType.Name) then
        return.
    
    create CustomerContact.
    assign CustomerContact.ContactDetailId = ContactDetail.ContactDetailId
           CustomerContact.CustomerId = pcCustomerId
           CustomerContact.TenantId = pcTenantId
           CustomerContact.ContactType = ContactType.Name.
end procedure.

procedure AddCustomerAddress:
    define input parameter pcAddressType as character no-undo.
    define input parameter pcTenantId as character no-undo.
    define input parameter pcCustomerId as character no-undo.
    define input parameter pcAddressDetailId as character no-undo.
    
    find AddressType where AddressType.AddressType eq pcAddressType no-lock.
    
    if can-find(CustomerAddress where
                CustomerAddress.AddressType eq AddressType.AddressType and
                CustomerAddress.CustomerId eq pcCustomerId and
                CustomerAddress.TenantId eq pcTenantId) then
        return.
    
    create CustomerAddress.
    assign CustomerAddress.AddressDetailId = pcAddressDetailId
           CustomerAddress.AddressType = AddressType.AddressType
           CustomerAddress.CustomerId = pcCustomerId
           CustomerAddress.TenantId = pcTenantId.
end procedure.

/* eof */
