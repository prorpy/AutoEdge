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
    File        : SecurityManagerServiceAdapter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Tue Jan 04 14:23:46 EST 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Client.AppServerServiceAdapter.
using OpenEdge.CommonInfrastructure.Client.ServiceAdapter.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerResponse.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.System.UnsupportedOperationError.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.UnhandledError.
using OpenEdge.Core.System.InvalidCallError.
using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Lang.WidgetHandle.
using OpenEdge.Lang.Assert.
using Progress.Lang.Error.
using Progress.Lang.Object.

class OpenEdge.CommonInfrastructure.Client.SecurityManagerServiceAdapter inherits AppServerServiceAdapter:

    constructor public SecurityManagerServiceAdapter():
        super().
    end constructor.
    
    /** Services a request. The service provider will call ExecuteResponse() in 
        the ServiceMessageManager once it's done with the request and ready with 
        a response (IServiceResponse); typically this will happen in a callback of
        some sort.
        
        @param IServiceRequest An array of requests to service. */
    method override public void ExecuteRequest(input poRequest as IServiceRequest extent):
        return error new InvalidCallError('asynchronous', 'OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceProvider:ExecuteRequest').
    end method.
    
    /** Services a request in a synchronous manner. The responses are returned from the
        ExecuteSyncRequest() call, rather than the service provider calling ExecuteResponse() in the
        ServiceMessageManager at a later time.
        
        @param IServiceRequest An array of requests to service.
        @return IServiceResponse An array of responses to the request.  */    
    method override public IServiceResponse extent ExecuteSyncRequest(input poRequest as IServiceRequest extent):
        define variable oResponse as IServiceResponse extent no-undo.
        
        Assert:ArgumentNotNull(poRequest, "Service request").
        
        /* Requests are bundled by service message type, so we can only check this once. */
        case cast(poRequest[1], IServiceMessage):ActionType:
            when ServiceMessageActionEnum:UserLogin then oResponse = UserLogin(cast(poRequest, SecurityManagerRequest)).
            when ServiceMessageActionEnum:UserLogout then oResponse = UserLogout(cast(poRequest, SecurityManagerRequest)).
            when ServiceMessageActionEnum:EstablishSession then oResponse = EstablishSession(cast(poRequest, SecurityManagerRequest)).
            otherwise 
                undo, throw new UnsupportedOperationError(
                                        cast(poRequest[1], IServiceMessage):ActionType:ToString(),
                                        this-object:GetClass():TypeName). 
        end case.
        
        return oResponse.
    end method.
    
    method protected SecurityManagerResponse extent UserLogin(input poRequest as SecurityManagerRequest extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cContextId as longchar no-undo.
        define variable oResponse as SecurityManagerResponse extent no-undo. 
        define variable mUserContext as memptr no-undo.
        
        assign iMax = extent(poRequest)
               extent(oResponse) = iMax.
        
        do iLoop = 1 to iMax on error undo, next:
            oResponse[iLoop] = new SecurityManagerResponse(poRequest[iLoop]).
            
            set-byte-order(mUserContext) = ByteOrderEnum:BigEndian:Value.
            
            run OpenEdge/CommonInfrastructure/Server/service_interface_userlogin.p on GetServiceLocation()
                    ( input poRequest[iLoop]:UserName,
                      input poRequest[iLoop]:UserDomain,
                      input poRequest[iLoop]:UserPassword,
                      output mUserContext).
            
            oResponse[iLoop]:UserContext = ServiceAdapter:DeserializeContext(mUserContext).
            
            catch oApplicationError as ApplicationError:
                /* Create response, since we've got an UNDO block */
                oResponse[iLoop] = new SecurityManagerResponse(poRequest[iLoop]).
                
                cast(oResponse[iLoop], IServiceResponse):HasError = true.
                cast(oResponse[iLoop], IServiceResponse):ErrorText = oApplicationError:ResolvedMessageText().
            end catch.
            catch oError as Error:
                define variable oUHError as UnhandledError no-undo.
                oUHError = new UnhandledError(oError).
                
                /* Create response, since we've got an UNDO block */
                oResponse[iLoop] = new SecurityManagerResponse(poRequest[iLoop]).
                cast(oResponse[iLoop], IServiceResponse):HasError = true.
                cast(oResponse[iLoop], IServiceResponse):ErrorText = oUHError:ResolvedMessageText().
            end catch.
        end.
        
        return oResponse.
    end method.
    
    method protected SecurityManagerResponse extent UserLogout(input poRequest as SecurityManagerRequest extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cContextId as longchar no-undo.
        define variable oResponse as SecurityManagerResponse extent no-undo. 
        define variable mUserContext as memptr no-undo.
        
        assign iMax = extent(poRequest)
               extent(oResponse) = iMax.
        
        do iLoop = 1 to iMax on error undo, next:
            oResponse[iLoop] = new SecurityManagerResponse(poRequest[iLoop]).
            
            set-byte-order(mUserContext) = ByteOrderEnum:BigEndian:Value.
            
            mUserContext = ServiceAdapter:SerializeContext(poRequest[iLoop]:UserContext).
            
            run OpenEdge/CommonInfrastructure/Server/service_interface_userlogout.p on GetServiceLocation()
                    (input-output mUserContext).
            
            oResponse[iLoop]:UserContext = ServiceAdapter:DeserializeContext(mUserContext).
            
            catch oApplicationError as ApplicationError:
                cast(oResponse[iLoop], IServiceResponse):HasError = true.
                cast(oResponse[iLoop], IServiceResponse):ErrorText = oApplicationError:ResolvedMessageText().
            end catch.
            catch oError as Error:
                define variable oUHError as UnhandledError no-undo.
                oUHError = new UnhandledError(oError).
                
                cast(oResponse[iLoop], IServiceResponse):HasError = true.
                cast(oResponse[iLoop], IServiceResponse):ErrorText = oUHError:ResolvedMessageText().
            end catch.
        end.
        
        return oResponse.
    end method.
    
    method protected SecurityManagerResponse extent EstablishSession(input poRequest as SecurityManagerRequest extent):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable cContextId as longchar no-undo.
        define variable oResponse as SecurityManagerResponse extent no-undo. 
        define variable mUserContext as memptr no-undo.
        
        assign iMax = extent(poRequest)
               extent(oResponse) = iMax.
        
        do iLoop = 1 to iMax on error undo, next:
            oResponse[iLoop] = new SecurityManagerResponse(poRequest[iLoop]).
            mUserContext = ServiceAdapter:SerializeContext(poRequest[iLoop]:UserContext).
            
            run OpenEdge/CommonInfrastructure/Server/service_interface_validatesession.p on GetServiceLocation()
                    (input-output mUserContext).
            
            oResponse[iLoop]:UserContext = ServiceAdapter:DeserializeContext(mUserContext).
                                            
            catch oApplicationError as ApplicationError:
                cast(oResponse[iLoop], IServiceResponse):HasError = true.
                cast(oResponse[iLoop], IServiceResponse):ErrorText = oApplicationError:ResolvedMessageText().
            end catch.
            catch oError as Error:
                define variable oUHError as UnhandledError no-undo.
                oUHError = new UnhandledError(oError).
                
                cast(oResponse[iLoop], IServiceResponse):HasError = true.
                cast(oResponse[iLoop], IServiceResponse):ErrorText = oUHError:ResolvedMessageText().
            end catch.
        end.
        
        return oResponse.
    end method.
    
end class.
