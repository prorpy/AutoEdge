/*------------------------------------------------------------------------
    File        : test_appserver_start.p
    Purpose     : 

    Syntax      :

    Description : 	

    Author(s)   : pjudge
    Created     : Wed Jan 12 18:14:13 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

routine-level on error undo, throw.

using OpenEdge.Lang.SessionClientTypeEnum.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
SessionClientTypeEnum:CurrentSession = SessionClientTypeEnum:AppServer.

run OpenEdge/CommonInfrastructure/Server/as_startup.p (SessionClientTypeEnum:AppServer).

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