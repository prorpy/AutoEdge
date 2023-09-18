/*------------------------------------------------------------------------
    File        : start.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Thu Jul 15 16:27:18 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using Progress.Lang.Error.

def var oDR as UI.DealerReview.

session:system-alert-boxes = true.
session:appl-alert-boxes = true.

oDR = new UI.DealerReview().

wait-for System.Windows.Forms.Application:Run(oDR).

quit.

/** ----------------- **/

catch oException as ApplicationError:
    oException:ShowError().
    oException:LogError().
end catch.

catch oAppError as Progress.Lang.AppError:
    message
        oAppError:GetMessage(1)      skip
        oAppError:ReturnValue skip(2)
        oAppError:CallStack
        view-as alert-box error title 'Unhandled Progress.Lang.AppError'.
end catch.

catch oError as Progress.Lang.Error:
    message
        oError:GetMessage(1)      skip
        '(' oError:GetMessageNum(1) ')'  skip(2)        
        oError:CallStack
        view-as alert-box error title 'Unhandled Progress.Lang.Error'.
end catch.

/* ~E~O~F~ */


/** --  -- **/
/** --  -- **/
/** --  -- **/
