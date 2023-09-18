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
    File        : IUserContext
    Purpose     : Applicaiton User context
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Jun 07 14:26:49 EDT 2010
    Notes       : * Some of the properties on this object will move into the CLIENT-PRINCIPAL in
                    11.0+ 
  --------------------------------------------------------------------- */
using OpenEdge.CommonInfrastructure.Common.ITenantManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.Lang.Collections.IMap.

interface OpenEdge.CommonInfrastructure.Common.IUserContext:
    
    /** ABL CLIENT-PRINCIPAL object for pertaining to this context */
    define public property ClientPrincipal as handle no-undo get.
    
    /** name of the user to whom this context applies */
    define public property UserName as character no-undo get.
    
    /** domain of the user to whom this context applies */
    define public property UserDomain as character no-undo get.
    
    /** Unique identifier for the client session */
    define public property ContextId as longchar no-undo get.
    
    /** The tenant to whom this user belongs */
    define public property TenantName as character no-undo get.
    
    /** A collection of tenant Ids for this User. 
        
        key   = Logical DB Name
        value = TenantId        */
    define public property TenantId as IMap no-undo get.
    
    /** A collection of properties associated with this context. These
        can be any key/value set of objects (key and value types should 
        be serialisable). */
    define public property UserProperties as IMap no-undo get.
    
    /** Sets up the user's tenancy (including the tenant name and id map).
        
        @param ITenantManager The session's tenant manager. */
    method public void EstablishTenancy(input poTenantManager as ITenantManager).
    
end interface.
