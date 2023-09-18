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
    File        : load_geography.p
    Purpose     : 

    Syntax      :

    Description : Loads country data from ISO3166 data

    Author(s)   : pjudge
    Created     : Tue Dec 14 14:14:30 EST 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

/* ***************************  Definitions  ************************** */
define stream strLoad.


/* ********************  Preprocessor Definitions  ******************** */

function getRandom returns character (input cValueList as character):
    define variable iEntries as integer    no-undo.
    iEntries = num-entries (cValueList, '|') .
    if iEntries > 1 
        then return entry ((random (1, iEntries)), cValueList, '|') .
        else return cValueList.
end function.

run loadCountries.
run loadLocales ('Standard USA', 'us').
run loadStates.

procedure loadCountries:
    define variable cName as character no-undo.
    define variable cCode as character no-undo.

    input stream strLoad from value(search('setup/data/iso3166_en_code_lists.txt')).
    
    repeat:
        import stream strLoad delimiter ';'
            cName cCode.
        
        /* hash marks indicate comments */
        if not cName begins '#' then
        do:
            if can-find(Country where Country.Code = cCode) then
                next.
            
            create Country.
            Country.Code = cCode.
            Country.Name = cName.
        end.
    end.
    
    input stream strLoad close.
end procedure.

procedure loadLocales:
    define input  parameter pcName as character no-undo.
    define input  parameter pcCountry as character no-undo.
    
    if can-find(Locale where Locale.Name eq pcName) then
        return.
    
    create Locale.
    assign Locale.LocaleId = guid(generate-uuid)
           Locale.Country = pcCountry 
           Locale.CurrencySymbol = '$'
           Locale.DateFormat = 'MDY'
           Locale.Name = pcName
           Locale.PhoneFormat = '(NNN) NNN-NNNN' 
           Locale.PostCodeFormat = 'NNNNN-NNNN'
           Locale.StateLabel = 'State'.
end procedure.

procedure loadStates:
    define variable cFile as character no-undo.
    define variable cName as character no-undo.
    define variable cCode as character no-undo.
    define variable cCategory as character no-undo.
    
    for each Country no-lock:
        cFile  = search(substitute('setup/data/iso3166-2_en_&1_lists.txt', lc(Country.Code))).
        if cFile eq ? then
            next.
        
        input stream strLoad from value(cFile).
        
        repeat:
            import stream strLoad delimiter ','
                cCode
                cName
                cCategory
                .
            
            /* hash marks indicate comments 
                #Code,Subdivision name,Subdivision category */
            if not cCode begins '#' then
            do:
                cCode = trim(entry(2, cCode, '-')).
                if can-find(State where
                            State.Country eq Country.Code and
                            State.State eq cCode) then
                    next.
                
                create State.
                assign State.Country = Country.Code
                       State.State = cCode
                       State.StateName = trim(cName).
            end.
        end.
        input stream strLoad close.
    end.
end procedure.
