/*------------------------------------------------------------------------
    File        : test_vehbranddata.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Mon Aug 09 08:10:45 EDT 2010
    Notes       :
  ----------------------------------------------------------------------*/

/*------------------------------------------------------------------------
    File        : test_appserver_si.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Wed Jan 19 09:25:39 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.

using OpenEdge.Lang.SessionClientTypeEnum.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.ObjectInputStream.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.ObjectOutputStream.
using Progress.Lang.Error.

/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
SessionClientTypeEnum:CurrentSession = SessionClientTypeEnum:AppServer.

run OpenEdge/CommonInfrastructure/Server/as_startup.p (SessionClientTypeEnum:AppServer).

run test_getbranddata ('fjord').

procedure test_getbranddata:
    define input  parameter pcBrand as character no-undo.
    
define variable pcDealerNameList as longchar no-undo.
define variable pcCompactModels as longchar no-undo.
define variable pcTruckModels as longchar no-undo.
define variable pcSuvModels as longchar no-undo.
define variable pcPremiumModels as longchar no-undo.
define variable pcSedanModels as longchar no-undo.
define variable pcInteriorTrimMaterial as longchar no-undo.
define variable pcInteriorTrimColour as longchar no-undo.
define variable pcInteriorAccessories as longchar no-undo.
define variable pcExteriorColour as longchar no-undo.
define variable pcMoonroof as longchar no-undo.
define variable pcWheels as longchar no-undo.
    def var iOrderNum as int.
    def var cUserContextId as longchar.
    
    run AutoEdge/Factory/Server/Order/BusinessComponent/service_branddata.p (
                input pcBrand,
                input iOrderNum,
                input cUserContextId,
                
                output pcDealerNameList ,
                output pcCompactModels ,
                output pcTruckModels ,
                output pcSuvModels ,
                output pcPremiumModels,
                output pcSedanModels,
                output pcInteriorTrimMaterial ,
                output pcInteriorTrimColour ,
                output pcInteriorAccessories ,
                output pcExteriorColour ,
                output pcMoonroof ,
                output pcWheels     ).
                
message 
error-status:error skip
error-status:get-message(1) skip(2)
'pcDealerNameList=' string(pcDealerNameList) skip(2)
'pcTruckModels=' string(pcTruckModels) skip(2)
'pcExteriorColour' string(pcExteriorColour) skip(2)
'pcWheels=' string(pcWheels) skip(2)
view-as alert-box error title '[PJ DEBUG]'.                
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
