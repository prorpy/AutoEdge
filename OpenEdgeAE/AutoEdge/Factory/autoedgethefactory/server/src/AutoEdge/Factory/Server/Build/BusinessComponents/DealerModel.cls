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
    File        : DealerModel
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Thu Aug 05 08:51:18 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

class AutoEdge.Factory.Server.Build.BusinessComponents.DealerModel: 
    
    define static private temp-table ttDealer no-undo
        field DealerId as character
        field DealerName as character
        field DealerEmail as character
        index idx1 as primary unique DealerId.
        
    define static private temp-table ttDealerBrand no-undo
        field DealerId as character
        field Brand as character
        index idx1 Brand
        index idx2 DealerId
        .        
    
    constructor static DealerModel():
        InitData().
    end constructor.
    
    method public character GetDealerEmail (pcDealerId as character):
        find ttDealer where ttDealer.DealerId = pcDealerId no-error.
        if available ttDealer then
            return ttDealer.DealerEmail.
        else
            return ''.
    end method.
    
    method public longchar GetBrandDealer(pcBrand as character):
        define variable cBrandDealer as longchar no-undo.
        
        cBrandDealer = '[ ~{ '
                     + '~"selected~":true,'
                     + '~"value~": ~" none  ~",'
                     + '~"label~": ~" Please select a dealer ~"'
                     + '~},'.
        
        for each ttDealerBrand where
                 ttDealerBrand.Brand = pcBrand,
            first ttDealer where 
                  ttDealer.DealerId = ttDealerBrand.DealerId:
            
            cBrandDealer = cBrandDealer + '~{'
                                 + '~"selected~":false,'
                                 + '~"value~": ~"' + ttDealer.DealerId + '~",'
                                 + '~"label~": ~"' + ttDealer.DealerName + '~"'
                                 + '~},'.
        end.
        cBrandDealer = right-trim(cBrandDealer, ',') + ']'.
        
        return cBrandDealer.
    end method.
    
    method static protected void InitData():
        /* Dealer 1 */
        create ttDealer.        
        assign ttDealer.DealerId = 'dealer01'
               ttDealer.DealerName = 'Stiller Motors Inc. (Dealer #1)'
               ttDealer.DealerEmail = 'info@stillerinc.com'.
               ttDealer.DealerEmail = 'dealer01@judge.co.za'.
        
        create ttDealerBrand.
        assign ttDealerBrand.DealerId = ttDealer.DealerId
               ttDealerBrand.Brand  = 'Chery'.               
        create ttDealerBrand.
        assign ttDealerBrand.DealerId = ttDealer.DealerId
               ttDealerBrand.Brand  = 'Hinda'.

        /* Dealer 2 */
        create ttDealer.        
        assign ttDealer.DealerId = 'dealer02'
               ttDealer.DealerName = 'Roth Brothers Corp. (Dealer #2)'
               ttDealer.DealerEmail = 'info@rothcars.com'.
               ttDealer.DealerEmail = 'dealer02@judge.co.za'.
        
        create ttDealerBrand.
        assign ttDealerBrand.DealerId = ttDealer.DealerId
               ttDealerBrand.Brand  = 'Toyola'.               
        create ttDealerBrand.
        assign ttDealerBrand.DealerId = ttDealer.DealerId
               ttDealerBrand.Brand  = 'Potomoc'.
    end method.
    
end class.
