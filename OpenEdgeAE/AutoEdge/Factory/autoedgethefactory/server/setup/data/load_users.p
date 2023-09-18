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
    File        : load_users.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Wed Dec 15 09:19:48 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

define variable cLoginName as character no-undo.
define variable cDomain as character no-undo.
define variable iLoop as integer no-undo.
define variable iMax as integer no-undo.
define variable cTenantUsers as character no-undo.
define variable cPassword as character no-undo.

define buffer lbUser for ApplicationUser.
define buffer childTenant for Tenant.

cPassword = 'letmein'.

/* Customer users : UserTypeEnum:Customer */
for each Customer no-lock,
    first Tenant where Tenant.TenantId = Customer.TenantId no-lock:
        
    /* allow for reloads */
    if can-find(ApplicationUser where
                ApplicationUser.CustomerId eq Customer.CustomerId and
                ApplicationUser.TenantId eq Tenant.TenantId) then next. 
    
    cDomain  = 'customer.' + Tenant.Name.
    cLoginName = entry(1, Customer.Name, ' ').
    
    if can-find(lbUser where lbUser.LoginDomain = cDomain and lbUser.LoginName = cLoginName) then
        assign cLoginName = replace(lc(Customer.Name), ' ', '_')
               cLoginName = replace(cLoginName, '__', '_')
               cLoginName = replace(cLoginName, '.', '').
    
    create ApplicationUser.
    assign ApplicationUser.ApplicationUserId = guid(generate-uuid)
           ApplicationUser.CustomerId = Customer.CustomerId
           ApplicationUser.EmployeeId = ''
           ApplicationUser.LocaleId = Customer.PrimaryLocaleId
           ApplicationUser.LoginDomain = lc(cDomain)
           ApplicationUser.LoginName = lc(cLoginName)
           ApplicationUser.Password = encode(cPassword) 
           ApplicationUser.SupplierId = ''
           ApplicationUser.TenantId = Customer.TenantId
           .
end.

/* Employee users : UserTypeEnum:Employee */
for each Employee no-lock,
    first Department where Employee.DepartmentId = Department.DepartmentId no-lock,
    first Tenant where Tenant.TenantId = Employee.TenantId no-lock:
    
    /* allow for reloads */
    if can-find(ApplicationUser where
                ApplicationUser.EmployeeId eq Employee.EmployeeId and
                ApplicationUser.TenantId eq Tenant.TenantId) then next. 
    
    cDomain  = substitute('&1.employee.&2',
                      Department.Name,
                      Tenant.Name).
    cLoginName = Employee.FirstName + '_' + Employee.LastName.
    
    if can-find(lbUser where lbUser.LoginDomain = cDomain and lbUser.LoginName = cLoginName) then
        cLoginName = cLoginName + substitute('-&1-&2', Employee.EmpNum, Tenant.Name).    
    
    create ApplicationUser.
    assign ApplicationUser.ApplicationUserId = guid(generate-uuid)
           ApplicationUser.CustomerId = ''
           ApplicationUser.EmployeeId = Employee.EmployeeId
           ApplicationUser.LocaleId = Tenant.LocaleId 
           ApplicationUser.LoginDomain = lc(cDomain)
           ApplicationUser.LoginName = lc(cLoginName)
           ApplicationUser.Password = encode(cPassword) 
           ApplicationUser.SupplierId = ''
           ApplicationUser.TenantId = Employee.TenantId
           .
end.

/* system and brand users : UserTypeEnum:System */
cTenantUsers = 'admin:system|guest:customer|factory:system|lob_manager:system'.
iMax = num-entries(cTenantUsers, '|').

for each Tenant no-lock:    
    do iLoop = 1 to iMax:                
        cLoginName = entry(iLoop, cTenantUsers, '|').
        cDomain = entry(2, cLoginName, ':') + '.' + Tenant.Name.
        cLoginName = entry(1, cLoginName, ':').
        
        if cDomain begins 'customer' then
        do:
            /* only want customers of brands */
            if Tenant.ParentTenantId eq '' then next.
            if can-find(first childTenant where childTenant.ParentTenantId = Tenant.TenantId) then next.
        end.            
        
        if num-entries(cLoginName, ':') gt 1 then
            cLoginName = entry(1, cLoginName, ':').
        
        /* allow for reloads */
        if can-find(ApplicationUser where
                    ApplicationUser.LoginDomain eq lc(cDomain) and
                    ApplicationUser.LoginName eq lc(cLoginName) ) then next. 
        
        create ApplicationUser.
        assign ApplicationUser.ApplicationUserId = guid(generate-uuid)
               ApplicationUser.CustomerId = ''
               ApplicationUser.EmployeeId = ''
               ApplicationUser.LocaleId = Tenant.LocaleId
               ApplicationUser.LoginDomain = lc(cDomain)
               ApplicationUser.LoginName = lc(cLoginName)
               ApplicationUser.Password = encode(cPassword) 
               ApplicationUser.SupplierId = ''
               ApplicationUser.TenantId = Tenant.TenantId
               .
    end.
end.

/** -- eof -- **/
