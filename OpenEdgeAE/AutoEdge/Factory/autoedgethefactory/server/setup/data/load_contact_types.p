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
    File        : load_contact_types.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Tue Jan 25 15:16:45 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

run load_ContactTypes.

procedure load_ContactTypes:
    
    define variable cTypes as character no-undo.
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    
    cTypes = 'email-sales|email-info|email-home|email-admin|email-work|fax-work|phone-work|phone-home|phone-mobile|fax-home'.
    
    iMax = num-entries(ctypes, '|').
    do iLoop = 1 to iMax:
        if can-find(ContactType where ContactType.Name eq entry(iLoop, ctypes, '|')) then
            next.
        
        create ContactType.
        assign ContactType.Name = entry(iLoop, ctypes, '|').
    end.
        
end procedure.
