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
    File        : service_returnerror.i
    Purpose     : Server-side include for common error handling.                   
    Author(s)   : pjudge
    Created     : Fri Jan 20 09:43:17 EST 2012
    Arguments   : RETURN-PARAM   : Caught errors are returned in string form in a variable/parameter 
                  RETURN-ERROR   : Caught errors are returned in string form via RETURN ERROR
                  RETURN-NOERROR : Caught errors are returned in string form via RETURN without raising the error status.
                  THROW-ERROR    : Caught errors are re-thrown. This will fail on an AppServer, with ABL error 14438.
                  
                  LOG-ERROR      : Errors logged to system log via LOG-MANAGER (indep. of above)
                  
    Notes       : * All arguments are optional
                  * All arguments default to false or empty
                  * The order of precedence is RETURN-ERROR, THROW-ERROR, RETURN-NOERROR, RETURN-PARAM 
  ----------------------------------------------------------------------*/
&if defined(RETURN-PARAM) eq 0 &then
    &global-define RETURN-PARAM  
&endif

&if "{&RETURN-PARAM}" ne "" &then
    &undefine THROW-ERROR
    &global-define THROW-ERROR false
    
    &undefine RETURN-ERROR
    &global-define RETURN-ERROR false
    
    &undefine RETURN-NOERROR
    &global-define RETURN-NOERROR false
&endif
  
&if defined(THROW-ERROR) eq 0 &then
    &global-define THROW-ERROR false
&endif 

&if "{&THROW-ERROR}" eq "true" &then
    &undefine RETURN-ERROR
    &global-define RETURN-ERROR false
    
    &undefine RETURN-NO-ERROR
    &global-define RETURN-NOERROR false
    
    &undefine RETURN-PARAM
    &global-define RETURN-PARAM 
&endif

&if defined(RETURN-NOERROR) eq 0 &then
    &global-define RETURN-NOERROR false
&endif


&if "{&RETURN-NOERROR}" eq "true" &then
    &undefine THROW-ERROR 
    &global-define THROW-ERROR false
    
    &undefine RETURN-ERROR
    &global-define RETURN-ERROR false
    
    &undefine RETURN-PARAM
    &global-define RETURN-PARAM 
&endif

&if defined(RETURN-ERROR) eq 0 &then
    &global-define RETURN-ERROR false
&endif

&if "{&RETURN-ERROR}" eq "true" &then
    &undefine THROW-ERROR
    &global-define THROW-ERROR false
    
    &undefine RETURN-NOERROR
    &global-define RETURN-NOERROR false
    
    &undefine RETURN-PARAM
    &global-define RETURN-PARAM 
&endif

&if defined(LOG-ERROR) eq 0 &then
    &global-define LOG-ERROR false
&endif 

/* if nothing is specified, automatically log errors. */
&if "{&THROW-ERROR}" eq "false" and
    "{&RETURN-ERROR}" eq "false" and 
    "{&RETURN-NOERROR}" eq "false" and
    "{&RETURN-PARAM}" eq "" &then
    &undefine LOG-ERROR 
    &global-define LOG-ERROR true
&endif

/** -- error handling -- **/
catch oApplicationError as OpenEdge.Core.System.ApplicationError:
    &if "{&LOG-ERROR}" eq "true" &then 
/*    oApplicationError:LogError().*/
    log-manager:write-message(oApplicationError:ReturnValue).
    &endif
     
    &if "{&RETURN-PARAM}" ne "" &then
    assign error-status:error = false
           {&RETURN-PARAM} = oApplicationError:ReturnValue. 
    &elseif "{&RETURN-ERROR}" eq "true" &then
    return error oApplicationError:ReturnValue.
    &elseif "{&RETURN-NOERROR}" eq "true" &then
    return oApplicationError:ReturnValue.
    &elseif "{&THROW-ERROR}" eq "true" &then
    undo, throw oApplicationError.    
    &endif
end catch.

catch oError as Progress.Lang.Error:
    define variable oUHError as OpenEdge.Core.System.UnhandledError no-undo.
    oUHError = new OpenEdge.Core.System.UnhandledError(oError).
    
    &if "{&LOG-ERROR}" eq "true" &then      
    log-manager:write-message (oUHError:ReturnValue).
/*    oUHError:LogError().*/
    &endif
    
    &if "{&RETURN-PARAM}" ne "" &then 
    assign error-status:error = false
           {&RETURN-PARAM} = oApplicationError:ReturnValue.  
    &elseif "{&RETURN-ERROR}" eq "true" &then 
    return error oUHError:ReturnValue. 
    &elseif "{&RETURN-NOERROR}" eq "true" &then
    return oApplicationError:ReturnValue.
    &elseif "{&THROW-ERROR}" eq "true" &then
    undo, throw oUHError.    
    &endif
end catch.
/** eof **/
