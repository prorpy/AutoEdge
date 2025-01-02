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
    File        : WebServiceProtocol
    Purpose     : Simple OOABL wrapper around ABL WebServices Out 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Jul 02 12:01:04 EDT 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.XML.WebServiceProtocol.
using OpenEdge.Core.XML.WebServiceInvocationError.

using OpenEdge.Lang.DataTypeEnum.
using OpenEdge.Lang.Assert.

using Progress.Lang.SoapFaultError.
using Progress.Lang.Error.

class OpenEdge.Core.XML.WebServiceProtocol abstract:
    /** (mandatory) The name of the service to which we are connecting */
    define public property Service as character no-undo get. private set.
    
    /** (mandatory) The WSDL document descibing the service */
    define protected property WSDL as character no-undo get. private set.
    
    /** (optional) Any additional connection parameters */
    define protected property ConnectionParams as character no-undo get. set.
    
    /** The handle to the running webservice */
    define protected property WebServiceHandle as handle no-undo get. private set.
    
    /** The handle to the port on the running webservice */
    define protected property PortHandle as handle no-undo get. private set.
    
    /** (derived) Returns whether the service is currently connected. */
    define public property Connected as logical no-undo 
        get():
            return (valid-handle(WebServiceHandle) and WebServiceHandle:connected()).
        end get.
    
    constructor public WebServiceProtocol(pcService as character,
                                          pcWSDL as character,
                                          pcConnectionParams as character):
        Assert:ArgumentNotNullOrEmpty(pcService, 'Service').
        Assert:ArgumentNotNullOrEmpty(pcWSDL, 'WSDL').
                                                      
        assign Service = pcService
               WSDL = pcWSDL
               ConnectionParams = pcConnectionParams.
    end constructor.
    
    destructor public WebServiceProtocol():
        DisconnectService().
    end destructor.
    
    /** Executes an operation in a port on the WebService. This is a generalised method;
        concrete implementors can execute their operations using this method or using 
        a more specialised call.
        
        @param character The port type
        @param character The operation name
        @param longchar The request SOAP message
        @return longchar The return SOAP message.       */
    method public longchar ExecuteOperation(input pcPortTypeName as character,
                                            input pcOperationName as character,
                                            input pcInputParam as longchar):
        
        define variable cOutputParam as longchar no-undo.
        
        ConnectService().
        
        run value(pcOperationName) in ConnectPortType(pcPortTypeName) (input pcInputParam, output cOutputParam).
        
        return cOutputParam.
        
        catch eError as Error:
            undo, throw new WebServiceInvocationError(eError, pcOperationName, this-object:Service, '').
        end catch.
        finally:
            DisconnectPortType().
            DisconnectService().
        end finally.
    end method.
    
    /** Connects to the service. */
    method public void ConnectService():
        define variable cConnectString as character no-undo.
        
        if not this-object:Connected then
        do:
            cConnectString = substitute('-S &1 -WSDL &2 &3',
                                this-object:Service,
                                this-object:WSDL,
                                this-object:ConnectionParams).
            create server WebServiceHandle.
            WebServiceHandle:connect(cConnectString).
        end.
        catch eError as Error:
            delete object WebServiceHandle no-error.
            undo, throw new WebServiceInvocationError(eError, 'ConnectService', this-object:Service, '').
        end catch.        
    end method.
    
    /** Disconnects from the service, if connected. */
    method public void DisconnectService():
        if this-object:Connected then
            WebServiceHandle:disconnect().
        delete object WebServiceHandle no-error.
    end method.
    
    /** Connects to the specified port type.
        
        @param character The port type 
        @return handle The port on which to run the operation.  */
    method protected handle ConnectPortType(input pcPortType as character):
        if not this-object:Connected then
            undo, throw new WebServiceInvocationError(
                    pcPortType,
                    this-object:Service,
                    '  - service not connected').
        
        run value(pcPortType) set PortHandle on server WebServiceHandle.
        
        return PortHandle.
    end method.
    
    /**  Disconnects the currently-connected port type */
    method protected handle DisconnectPortType():
        delete object PortHandle no-error.
    end method.
    
    method static public character XmlTypeFromABL(input pcABLType as longchar):
        define variable cXmlType as character no-undo.
        
        case string(pcABLType):
            when 'datetime' then cXmlType = 'dateTime'.
            when 'logical' then  cXmlType = 'boolean'.
            when 'character' then  cXmlType = 'string'.
            otherwise cXmlType = lc(pcABLType).
        end case.
        
        return cXmlType.
    end method.
    
end class.
