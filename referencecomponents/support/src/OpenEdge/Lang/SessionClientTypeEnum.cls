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
    File        : SessionClientTypeEnum
    Purpose     : Enumeration of ABL client types, as per the SESSION:CLIENT-TYPE 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 18 15:08:28 EST 2010
    Notes       : * Descriptions appear in the ABL documentation.
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Lang.SessionClientTypeEnum. 
using OpenEdge.Lang.EnumMember.

class OpenEdge.Lang.SessionClientTypeEnum final inherits EnumMember:
    
    define static public property ABLClient as SessionClientTypeEnum no-undo get. private set.
    define static public property WebClient as SessionClientTypeEnum no-undo get. private set.
    define static public property AppServer as SessionClientTypeEnum no-undo get. private set.
    define static public property WebSpeed  as SessionClientTypeEnum no-undo get. private set.
    define static public property Other     as SessionClientTypeEnum no-undo get. private set.
    
    /** The CurrentSession is settable for debug purposes: for instance, it allows you to debug server-side
        code without having to run it on the server. */    
    define static public property CurrentSession as SessionClientTypeEnum no-undo get. set.
    
    constructor static SessionClientTypeEnum():
        SessionClientTypeEnum:ABLClient = new SessionClientTypeEnum('4GLCLIENT').
        SessionClientTypeEnum:WebClient = new SessionClientTypeEnum('WEBCLIENT').
        SessionClientTypeEnum:AppServer = new SessionClientTypeEnum('APPSERVER').
        SessionClientTypeEnum:WebSpeed  = new SessionClientTypeEnum('WEBSPEED').
        SessionClientTypeEnum:Other     = new SessionClientTypeEnum(?).
        
        SessionClientTypeEnum:CurrentSession = SessionClientTypeEnum:EnumFromString(session:client-type).
    end constructor.
    
    constructor public SessionClientTypeEnum(input pcName as character):
        super(pcName).
    end constructor.
    
    method public static SessionClientTypeEnum EnumFromString(input pcSessionClientType as character):
        define variable oMember as SessionClientTypeEnum no-undo.
        
        case pcSessionClientType:
            when SessionClientTypeEnum:ABLClient:Name then oMember = SessionClientTypeEnum:ABLClient.
            when SessionClientTypeEnum:WebClient:Name then oMember = SessionClientTypeEnum:WebClient.
            when SessionClientTypeEnum:AppServer:Name then oMember = SessionClientTypeEnum:AppServer.
            when SessionClientTypeEnum:WebSpeed:Name then oMember = SessionClientTypeEnum:WebSpeed.
            otherwise SessionClientTypeEnum:Other.
        end.
        
        return oMember.
    end method.
    
end class.
