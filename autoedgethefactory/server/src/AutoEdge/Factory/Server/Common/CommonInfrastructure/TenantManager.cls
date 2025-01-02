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
    File        : TenantManager
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Dec 21 16:44:52 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Server.TenantManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.InvalidValueSpecifiedError.
using OpenEdge.Core.System.DoesNotExistError.
using OpenEdge.Lang.Collections.IMap.
using OpenEdge.Lang.Collections.TypedMap.
using OpenEdge.Lang.String.

class AutoEdge.Factory.Server.Common.CommonInfrastructure.TenantManager inherits TenantManager: 

    constructor public TenantManager(input poComponentInfo as IComponentInfo ):
        super(input poComponentInfo).
    end constructor.

    /** Returns the tenant name for a given security domain.
    
        @param character The domain name.
        @return character The tenant name. */
    method override public character GetDomainTenant(input pcDomain as character):
        define variable cTenantName as character no-undo.
        
        define buffer lbTenant for Tenant.
        
        /* In our world, domain names are structured as follows:
            DOMAIN.SUB-DOMAIN.TENANT-NAME or TENANT-NAME */
        if num-entries(pcDomain, '.') eq 1 then
            cTenantName = pcDomain.
        else
            cTenantName = entry(num-entries(pcDomain, '.'), pcDomain, '.').        
        
        if not can-find(lbTenant where lbTenant.Name eq cTenantName no-lock) then 
            undo, throw new DoesNotExistError(substitute('tenant (name: &1)', cTenantName)).
        
        if not IsValidTenant(pcDomain, cTenantName) then
            undo, throw new InvalidValueSpecifiedError(
                substitute('tenant (&1)', cTenantName),
                substitute('for domain (&1)', pcDomain)).
        
        return cTenantName.                                           
    end method.
    
    /** Returns the tenant Ids associated with a tenant by name.
        
        @param character The tenant name
        @return IMap A map of the logical DB names and tenant Id's for the
                given tenant.   */
    method override public IMap GetTenantId(input pcTenantName as character):
        define variable oTenantId as IMap no-undo.
        
        define buffer lbTenant for Tenant.
        
        find lbTenant where
             lbTenant.Name eq pcTenantName 
             no-lock no-error.
        if not available lbTenant then
            undo, throw new DoesNotExistError(substitute('tenant (name: &1)', pcTenantName)).
        
        oTenantId = new TypedMap(String:Type, String:Type).
        oTenantId:Put(new String('aetf'), new String(lbTenant.TenantId)).
        
        return oTenantId.
    end method.
    
    /** Determines whether the tenant is valid for the given domain
        
        @param character The domain name
        @param character The tenant name        
        @return logical Whether this is a valid tenant for the domain or not    */
    method override protected logical IsValidTenant(input pcDomain as character,
                                                    input pcTenantName as character):
        define variable lValid as logical no-undo.
        define buffer lbTenant for Tenant.
        define buffer lbChildTenant for Tenant.
        
        /* customers should not belong to a parent tenant (ie group). They should belong to a brand tenant. */
        if pcDomain begins 'customer.' then
        do:
            find lbTenant where lbTenant.Name = pcTenantName no-lock no-error.
            lValid = not can-find(first lbChildTenant where
                                    lbChildTenant.ParentTenantId = lbTenant.TenantId).
        end.
        else
            lValid = true.
                        
        return lValid.
    end method.

end class.
