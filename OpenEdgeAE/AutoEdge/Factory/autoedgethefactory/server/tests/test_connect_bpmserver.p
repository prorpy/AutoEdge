
/*------------------------------------------------------------------------
    File        : test_connect_bpmserver.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Wed Apr 20 08:43:39 EDT 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
/* ***************************  Definitions  ************************** */
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.SessionClientTypeEnum.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.ObjectInputStream.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.ObjectOutputStream.
using OpenEdge.Lang.String.
using Progress.Lang.Error.
using OpenEdge.Lang.ABLSession.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnection.

/* ********************  Preprocessor Definitions  ******************** */

    /** Deserialises a MEMPTR into a UserContext object. This helper function is in this
        super class since this is a frequently-undertaken action.
        
        @param memptr The serialised user-context
        @return IUserContext The reconstituted object.  */
function DeserializeContext returns IUserContext  (input pmUserContext as memptr):
        define variable oContext as IUserContext no-undo.
        define variable oInput as IObjectInput no-undo.
        
        oInput = new ObjectInputStream().
        oInput:Read(pmUserContext).
        oContext = cast(oInput:ReadObject(), IUserContext).
        
        return oContext.
        finally:
            set-size(pmUserContext) = 0.
        end finally. 
end function.

    /** Serialises a UserContext object to MEMPTR. This helper function is in this
        super class since this is a frequently-undertaken action.
        
        @return IUserContext The context being serialised.
        @param memptr The serialised user-context   */
function  SerializeContext returns memptr  (input poUserContext as IUserContext):
        define variable mContext as memptr no-undo.
        define variable oOutput as IObjectOutput no-undo.
        
        oOutput = new ObjectOutputStream().
        oOutput:WriteObject(poUserContext).
        oOutput:Write(output mContext).
        
        return mContext.
        finally:
            set-size(mContext) = 0.
        end finally. 
end function.

/* ***************************  Main Block  *************************** */
def var oConnMgr as IConnectionManager.
def var oSvcMgr as IServiceManager.
define variable oSC as IServerConnection no-undo.
def var oUC as IUserContext.

SessionClientTypeEnum:CurrentSession = SessionClientTypeEnum:AppServer.

run OpenEdge/CommonInfrastructure/Server/as_startup.p (SessionClientTypeEnum:AppServer).

oSvcMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).
oConnMgr = cast(oSvcMgr:StartService(ConnectionManager:IConnectionManagerType), IConnectionManager). 
    
run connect (output oSC).

/*
run bpm_login (input OSC).
run bpm_logout (input OSC).
*/

run user_login('john.webbs', 'sales.employee.fjord', 'letmein', output oUC).
run user_logout(input-output oUC).

run disconnect (input oSC).

    
/** -- procedures -- **/
procedure connect:
    define output parameter poSC as IServerConnection no-undo.
    
    poSC = oConnMgr:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
    
    message 
        'poSC:IsConnected=' poSC:IsConnected
    view-as alert-box error title '[PJ DEBUG]'.
end procedure.

procedure bpm_login:
    define input param poSC as IServerConnection no-undo.
    
    def var oBpmServer as IBizLogicAPI.
    def var cSessionId as longchar.
    
    oBpmServer = cast(poSC:Server, IBizLogicAPI).
    oBpmServer:Login('ebms', 'ebms').
    cSessionId = oBpmServer:SessionId.
    
    message 
    'cSessionId=' string(cSessionId)
    view-as alert-box error title '[PJ DEBUG]'. 
    
end procedure.

procedure bpm_logout:
    define input param poSC as IServerConnection no-undo.
    
    def var oBpmServer as IBizLogicAPI.
    def var cSessionId as longchar.
    
    oBpmServer = cast(poSC:Server, IBizLogicAPI).
    oBpmServer:Logout().
    
    message 
    'oBpmServer:IsSessionValid()=' oBpmServer:IsSessionValid()
    view-as alert-box error title '[PJ DEBUG]'.
    
end procedure.

procedure disconnect:
    define input param poSC as IServerConnection no-undo.
    
    poSC:Disconnect().

    message 
    'poSC:IsConnected=' poSC:IsConnected
    view-as alert-box error title '[PJ DEBUG]'.
    
end procedure.
    
procedure user_login:
    define input  parameter pcName as character no-undo.
    define input  parameter pcDomain as character no-undo.
    define input  parameter pcPassword as character no-undo.
    define output parameter poContext as IUSerContext no-undo.
    
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable cContextId as longchar no-undo.
    define variable oResponse as SecurityManagerResponse extent no-undo. 
    define variable mUserContext as memptr no-undo.
    define variable oRequest as SecurityManagerRequest extent 1 no-undo.

    oRequest[1] = new SecurityManagerRequest('SecurityManager.UserLogin', ServiceMessageActionEnum:UserLogin).
    assign oRequest[1]:UserName = pcName
           oRequest[1]:UserDomain = pcDomain                
           oRequest[1]:UserPassword = pcPassword.
    
    assign iMax = extent(oRequest)
           extent(oResponse) = iMax.
    
    do iLoop = 1 to iMax on error undo, next:
        oResponse[iLoop] = new SecurityManagerResponse(oRequest[iLoop]).
        
        set-byte-order(mUserContext) = ByteOrderEnum:BigEndian:Value.
        
        run OpenEdge/CommonInfrastructure/Server/service_interface_userlogin.p         
                ( input oRequest[iLoop]:UserName,
                  input oRequest[iLoop]:UserDomain,
                  input oRequest[iLoop]:UserPassword,
                  output mUserContext).
        
        oResponse[iLoop]:UserContext = DeserializeContext(mUserContext).
        poContext = oResponse[iLoop]:UserContext.
         
        catch oError as Error:
            cast(oResponse[iLoop], IServiceResponse):HasError = true.
            cast(oResponse[iLoop], IServiceResponse):ErrorText = oError:GetMessage(1).
        end catch.
    end.    
    
end procedure.

procedure user_logout:
    define input-output parameter poContext as IUSerContext no-undo.
    
    define variable oRequest as SecurityManagerRequest extent 1 no-undo.
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable cContextId as longchar no-undo.
    define variable oResponse as SecurityManagerResponse extent no-undo. 
    define variable mUserContext as memptr no-undo.
    
    oRequest[1] = new SecurityManagerRequest(SecurityManager:ISecurityManagerType:TypeName,
                                             ServiceMessageActionEnum:UserLogout).
    oRequest[1]:ContextId = poContext:ContextId.
    oRequest[1]:UserContext = poContext.
    
    assign iMax = extent(oRequest)
           extent(oResponse) = iMax.
    
    do iLoop = 1 to iMax on error undo, next:
        oResponse[iLoop] = new SecurityManagerResponse(oRequest[iLoop]).
        set-byte-order(mUserContext) = ByteOrderEnum:BigEndian:Value.
        mUserContext = SerializeContext(oRequest[iLoop]:UserContext).
        
        run OpenEdge/CommonInfrastructure/Server/service_interface_userlogout.p
                (input-output mUserContext).
        
        oResponse[iLoop]:UserContext = DeserializeContext(mUserContext).
        catch oError as Error:
            cast(oResponse[iLoop], IServiceResponse):HasError = true.
            cast(oResponse[iLoop], IServiceResponse):ErrorText = oError:GetMessage(1).
        end catch.
    end.
end procedure.
    
/** ----------------- **/
catch oException as OpenEdge.Core.System.ApplicationError:
    oException:LogError().
    oException:ShowError().
end catch.

catch oAppError as Progress.Lang.AppError:
    message
        oAppError:ReturnValue skip(2)
        oAppError:CallStack
        view-as alert-box error title 'Unhandled Progress.Lang.AppError'.
end catch.

catch oError as Progress.Lang.Error:
    message
        oError:GetMessage(1)      skip
        '(' oError:GetMessageNum(1) ')' skip(2)        
        oError:CallStack
        view-as alert-box error title 'Unhandled Progress.Lang.Error'.
end catch.

finally:
    message skip(2)
    'just about done'
    view-as alert-box error title '[PJ DEBUG]'.
    run OpenEdge/CommonInfrastructure/Common/stop_session.p.
end finally.
