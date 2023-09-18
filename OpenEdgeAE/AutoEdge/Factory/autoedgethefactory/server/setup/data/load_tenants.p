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
/** ------------------------------------------------------------------------
    File        : load_tenants.p
    Purpose     : 

    Syntax      :

    Description : Loads tenants from XML

    Author(s)   : pjudge
    Created     : Wed Dec 15 08:53:20 EST 2010
    Notes       : * Tenants are car manufacturers; structured
                  * The tenant structure is described in http://communities.progress.com/pcom/docs/DOC-106882/ 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
routine-level on error undo, throw.

define buffer lbParent for Tenant.

define variable cTenants as character no-undo.
define variable cParent as character no-undo.
define variable cBrand as character no-undo.
define variable iLoop as integer no-undo.
define variable iMax as integer no-undo.
define variable cDomainType as character no-undo.

cTenants = 'motorgroupeast:genericmotors|motorgroupeast:h2omotors|motorgroupeast:hinda|motorgroupeast:toyola|h2omotors:scubaroo|h2omotors:fjord|genericmotors:potomoc|genericmotors:chery'.

run CreateSecurityAuthenticationSystem(output cDomainType).

find first Locale no-lock.

iMax = num-entries(cTenants, '|').
do iLoop = 1 to iMax:
    if num-entries(entry(iLoop, cTenants, '|'), ':') eq 1 then
        assign cParent = ''
               cBrand = entry(iLoop, cTenants, '|').
    else
        assign cParent = entry(1, entry(iLoop, cTenants, '|'), ':')
               cBrand = entry(2, entry(iLoop, cTenants, '|'), ':').
    
    if can-find(Tenant where Tenant.Name eq cBrand) then next.
    
    create Tenant.
    assign Tenant.TenantId = guid(generate-uuid)
           Tenant.Name = cBrand
           Tenant.LocaleId = Locale.LocaleId.
    
    find lbParent where
         lbParent.Name = cParent
         no-lock no-error.
    if available lbParent then
        Tenant.ParentTenantId = lbParent.TenantId.
    else
        Tenant.ParentTenantId = ''.
    
    run AddContact('email-work',
                   Tenant.TenantId,
                   Tenant.TenantId,
                   substitute('&1@&2.aetf','admin', Tenant.Name)).
    run CreateSecurityAuthenticationDomain(cDomainType, Tenant.Name, Tenant.TenantId).                    
end.

procedure CreateSecurityAuthenticationSystem:
    define output parameter pcDomainType as character no-undo.
    
    pcDomainType = 'TABLE-ApplicationUser'.
    
    if can-find(_sec-authentication-system where
                _sec-authentication-system._Domain-type eq pcDomainType) then
        return.                
    
    create _sec-authentication-system.
    assign _sec-authentication-system._Domain-type = pcDomainType
           _sec-authentication-system._Domain-type-description = 'The AutoEdge|TheFactory ApplicationUser table serves as the authentication domain'
           .
end procedure.

procedure CreateSecurityAuthenticationDomain:
    define input  parameter pcDomainType as character no-undo.
    define input  parameter pcTenantName as character no-undo.
    define input  parameter pcTenantId as character no-undo.
    
    create _sec-authentication-domain.
    assign _sec-authentication-domain._Domain-name = lc(pcTenantName)
           _sec-authentication-domain._Domain-type = pcDomainType
           _sec-authentication-domain._Domain-description = substitute('Authentication Domain for the &1 tenant', pcTenantName)
           _sec-authentication-domain._Domain-access-code = audit-policy:encrypt-audit-mac-key(substitute('&1::&2', pcDomainType, pcTenantId))
           _sec-authentication-domain._Domain-enabled = true
           .
end procedure.
    
procedure AddContact:
    define input parameter pcContactType as character no-undo.
    define input parameter pcTenantId as character no-undo.
    define input parameter pcParentId as character no-undo.
    define input parameter pcContactDetail as character no-undo.
    
    define buffer ContactDetail for ContactDetail.
    define buffer ContactType for ContactType.
    define buffer ContactXref for ContactXref.
    
    find first ContactDetail where
               ContactDetail.Detail eq pcContactDetail
               no-lock no-error.
    if not available ContactDetail then
    do:
        create ContactDetail.
        assign ContactDetail.ContactDetailId = guid(generate-uuid)
               ContactDetail.Detail = pcContactDetail.
    end.
    
    find ContactType where ContactType.Name = pcContactType  no-lock.
    
    if can-find(ContactXref where
                ContactXref.ParentId eq pcParentId and
                ContactXref.TenantId eq pcTenantId and
                ContactXref.ContactType = ContactType.Name) then
        return.
    
    create ContactXref.
    assign ContactXref.ContactDetailId = ContactDetail.ContactDetailId
           ContactXref.ParentId = pcParentId
           ContactXref.TenantId = pcTenantId
           ContactXref.ContactType = ContactType.Name.
end procedure.
/* -- eof -- */
