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
    File        : ITenantManager
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 06 11:40:31 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.IManager.
using OpenEdge.Lang.Collections.IMap.

interface OpenEdge.CommonInfrastructure.Common.ITenantManager   /* inherits IManager*/:  
    
    /** Returns the tenant name for a given security domain.
    
        @param character The domain name.
        @return character The tenant name. */
    method public character GetDomainTenant(input pcDomain as character).
    
    /** Returns the tenant Ids associated with a tenant by name.
        
        @param character The tenant name
        @return IMap A map of the logical DB names and tenant Id's for the
                given tenant.   */
    method public IMap GetTenantId (input pcTenantName as character).

end interface.
