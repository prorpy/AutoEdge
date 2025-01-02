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
@deprecated(version="0.0"). 
/*------------------------------------------------------------------------
    File        : LoginData
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jun 12 13:44:10 EDT 2009
    Notes       : * This is a sample LoginData: ILoginData could have 
                    anything in it, really. 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.*.

class OpenEdge.Core.System.LoginData  implements ILoginData :
         
    define public property UserName as character no-undo get. set.
    define public property Password as character no-undo get. set. 
    
    constructor public LoginData (  ):
        super ().
        
    end constructor.

    constructor public LoginData (pcUserName as char, pcPassword as char):
        super ().
        
        UserName = pcUserName.
        Password = pcPassword.
    end constructor.
    
end class.
