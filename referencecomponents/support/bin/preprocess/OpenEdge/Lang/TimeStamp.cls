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
    File        : TimeStamp
    Purpose     : Primitive class for date, TimeStamp and TimeStamp-tz values
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Nov 22 14:29:32 EST 2010
    Notes       : * Named 'TimeStamp' because of keyword/namespace conflicts with
                    ABL Primitive DATETIME. There's no built-in class for this.
                  * Initial requirement for collections; having a class for the
                    primitive value means that we don't have to distinguish between
                    primitives and types, which makes the code more readable.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.TimeStamp.
using OpenEdge.Lang.DateTimeAddIntervalEnum.
using OpenEdge.Lang.DataTypeEnum.
using Progress.Lang.Object.

class OpenEdge.Lang.TimeStamp:
    
    define public property Format as DataTypeEnum no-undo get. private set.
    
    define private variable mtDate as date no-undo.
    define private variable miTime as integer no-undo.
    define private variable miTZOffset as integer no-undo.
    
    constructor public TimeStamp(piTimeStamp as integer):
        super().
        
        assign miTime = piTimeStamp
               this-object:Format = DataTypeEnum:Integer.
    end constructor.

    constructor public TimeStamp(ptTimeStamp as date):
        super().
        
        assign mtDate = ptTimeStamp
               this-object:Format = DataTypeEnum:Date.
    end constructor.
    
    constructor public TimeStamp(ptTimeStamp as datetime):
        super().
        
        assign mtDate = date(ptTimeStamp)
               miTime = mtime(ptTimeStamp)
               this-object:Format = DataTypeEnum:DateTime.
    end constructor.

    constructor public TimeStamp(ptTimeStamp as datetime-tz):
        super().
        
        assign mtDate = date(ptTimeStamp)
               miTime = mtime(ptTimeStamp)
               miTZOffset = timezone(ptTimeStamp)
               this-object:Format = DataTypeEnum:DateTimeTZ.
    end constructor.

    constructor public TimeStamp(input pcTimeStamp as character):
        define variable tTimeStamp as datetime-tz no-undo.
        
        super().
        
        tTimeStamp = TimeStamp:ToABLDateTimeFromISO(pcTimeStamp).
        
        assign mtDate = date(tTimeStamp)
               miTime = mtime(tTimeStamp)
               miTZOffset = timezone(tTimeStamp)
               this-object:Format = DataTypeEnum:DateTimeTZ.
    end constructor.
    
    constructor public TimeStamp():
        this-object(now).
    end constructor.
    
    method override public logical Equals(input p0 as Object):
        if type-of(p0, TimeStamp) then
        case this-object:Format:
            when DataTypeEnum:Integer then return (ToTime() eq cast(p0, TimeStamp):ToTime()).
            when DataTypeEnum:Date then return (ToDate() eq cast(p0, TimeStamp):ToDate()).
            when DataTypeEnum:DateTime then return (ToDateTime() eq cast(p0, TimeStamp):ToDateTime()).
            when DataTypeEnum:DateTimeTZ then return (ToDateTimeTz() eq cast(p0, TimeStamp):ToDateTimeTz()).
        end case.
        else
            return super:Equals(p0).
    end method.

    /** Converts an ABL datetime into a correct ISO date. The ISO-DATE()
        function requires the session's date format to be YMD before
        performing the conversion; this method wraps that.
        
        @return character An ISO date.      */
    method public character ToISODate():
        define variable cDateFormat as character no-undo.
        
        cDateFormat = session:date-format.
        session:date-format = 'ymd'.
        
        return iso-date(ToDateTimeTz()).
        finally:
            session:date-format = cDateFormat.        
        end finally.
    end method.
    
    /** Converts an ABL datetime into a correct ISO date. The ISO-DATE()
        function requires the session's date format to be YMD before
        performing the conversion; this method wraps that.
        
        @param datetime-tz The date value to convert
        @return character An ISO date.      */
    method static public character ToISODateFromABL(input ptValue as datetime-tz):
        define variable cDateFormat as character no-undo.
        
        cDateFormat = session:date-format.
        session:date-format = 'ymd'.
        
        return iso-date(ptValue).
        finally:
            session:date-format = cDateFormat.        
        end finally.
    end method.
    
    /** Converts an ISO date into an ABL DATETIME-TZ. The ISO-DATE()
        requires the session's date format to be YMD before
        performing the conversion; this method wraps that.
        
        @param character An ISO date
        @return datetime-tz The date value to convert.      */
    method static public datetime-tz ToABLDateTimeFromISO(input pcValue as character):
        define variable cDateFormat as character no-undo.
        
        cDateFormat = session:date-format.
        session:date-format = 'ymd'.
        
        return datetime-tz(pcValue).
        finally:
            session:date-format = cDateFormat.        
        end finally.
    end method.
    
    method public datetime-tz ToDateTimeTz():
        return datetime-tz(mtDate, miTime, miTZOffset).
    end method.
        
    method public datetime ToDateTime():
        return datetime(mtDate, miTime).
    end method.

    method public date ToDate():
        return mtDate.
    end method.
    
    method public integer ToTime():
        return miTime.
    end method.
    
end class.
