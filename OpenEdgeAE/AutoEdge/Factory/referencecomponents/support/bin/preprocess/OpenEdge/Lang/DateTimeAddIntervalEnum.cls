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
    File        : DateTimeAddIntervalEnum
    Purpose     : Enumeration of intervals for DATETIME and -TZ operations
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Mar 11 11:35:55 EST 2010
    Notes       : * Taken fromA BL documentation
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.DateTimeAddIntervalEnum.
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.DateTimeAddIntervalEnum final inherits EnumMember: 

    define static public property Default as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Years as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Months as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Weeks as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Days as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Hours as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Minutes as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Seconds as DateTimeAddIntervalEnum no-undo get. private set.
    define static public property Milliseconds as DateTimeAddIntervalEnum no-undo get. private set.
    
    constructor static DateTimeAddIntervalEnum():        
        assign DateTimeAddIntervalEnum:Years = new DateTimeAddIntervalEnum('Years')
               DateTimeAddIntervalEnum:Months = new DateTimeAddIntervalEnum('Months')
               DateTimeAddIntervalEnum:Weeks = new DateTimeAddIntervalEnum('Weeks')
               DateTimeAddIntervalEnum:Days = new DateTimeAddIntervalEnum('Days')
               DateTimeAddIntervalEnum:Hours = new DateTimeAddIntervalEnum('Hours')
               DateTimeAddIntervalEnum:Minutes = new DateTimeAddIntervalEnum('Minutes')
               DateTimeAddIntervalEnum:Seconds = new DateTimeAddIntervalEnum('Seconds')
               DateTimeAddIntervalEnum:Milliseconds = new DateTimeAddIntervalEnum('Milliseconds')
               
               DateTimeAddIntervalEnum:Default = DateTimeAddIntervalEnum:Milliseconds
               .
    end constructor.
    
    constructor public DateTimeAddIntervalEnum(pcName as character):
        super(pcName).
    end constructor.
    
end class.
