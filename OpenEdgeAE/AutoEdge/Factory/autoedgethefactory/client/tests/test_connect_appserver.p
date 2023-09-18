/*------------------------------------------------------------------------
    File        : test_connect_appserver.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Thu Jan 13 12:59:34 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.IConnectionParameters.
using OpenEdge.CommonInfrastructure.AppServerConnectionParameters.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.Lang.ABLSession.

/** --  variables -- **/
def var oParams as IConnectionParameters.
def var oSvcMgr as IServiceManager.
def var oConMgr as IConnectionManager.
def var hAS as handle.

/** -------------- **/
run OpenEdge/CommonInfrastructure/Common/start_session.p ().

oParams = new AppServerConnectionParameters().
oParams:Options = '-AppService AutoEdgeTheFactory -sessionModel session-free '.

oSvcMgr = cast(ABLSession:Instance:SessionProperties:Get(OpenEdge.CommonInfrastructure.Common.ServiceManager:IServiceManagerType), IServiceManager).
oConMgr = cast(oSvcMgr:StartService(OpenEdge.CommonInfrastructure.Common.ConnectionManager:IConnectionManagerType), IConnectionManager).  
hAS = oConMgr:Connect(
    OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum:AppServer,
    'AutoEdgeTheFactory',
    oParams).

message 
    hAS
view-as alert-box error title '[PJ DEBUG]'.

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
    run OpenEdge/CommonInfrastructure/Common/stop_session.p.
end finally.