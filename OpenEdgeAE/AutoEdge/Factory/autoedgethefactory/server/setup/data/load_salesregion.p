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
    File        : load_salesregion.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Thu Dec 23 13:17:19 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

routine-level on error undo, throw.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
run loadSalesRegions.

procedure loadSalesRegions:
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    
    define variable cRegions as character no-undo.
    
    cRegions = 'NorthAmerica|EMEA|APAC|SouthCentralAmerica'.
    iMax = num-entries(cRegions, '|').
    
    for each Tenant:
        do iLoop = 1 to iMax:
            if can-find(SalesRegion where
                        SalesRegion.Name eq entry(iLoop, cRegions, '|') and
                        SalesRegion.TenantId eq Tenant.TenantId) then
                next.
            
            create SalesRegion.
            assign SalesRegion.Name = entry(iLoop, cRegions, '|')
                   SalesRegion.TenantId = Tenant.TenantId.
        end.
    end.
end procedure.
