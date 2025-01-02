/*------------------------------------------------------------------------
    File        : test_appserver_si.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : pjudge
    Created     : Wed Jan 19 09:25:39 EST 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

/* ***************************  Definitions  ************************** */

using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.SecurityManagerRequest.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ServiceMessageActionEnum.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.UnhandledError.
using OpenEdge.Lang.SessionClientTypeEnum.
using OpenEdge.Lang.ByteOrderEnum.
using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.ObjectInputStream.
using OpenEdge.Core.Util.IObjectOutput.
using OpenEdge.Core.Util.ObjectOutputStream.
using Progress.Lang.Error.

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
define variable moUC as IUserContext extent no-undo.

SessionClientTypeEnum:CurrentSession = SessionClientTypeEnum:AppServer.

run OpenEdge/CommonInfrastructure/Server/as_startup.p (SessionClientTypeEnum:AppServer).

/*run test_userlogin (output moUC).*/
/*run test_userlogout (input moUC).*/

/*run test_customerlogin.*/

/*run test_getbranddata ('fjord').*/
run test_captureorder.
/*run test_dealerdetail.*/

procedure test_captureorder:
    define VARIABLE piOrderNumber as integer no-undo.
    define VARIABLE pcBrand as character no-undo.
    define VARIABLE pcDealerId as longchar no-undo.
    define VARIABLE pcCustomerId as longchar no-undo.
    define VARIABLE plOrderApproved as logical no-undo.
    define variable pcInstructions as longchar no-undo.
    define VARIABLE pcModel as longchar no-undo.
    define VARIABLE pcInteriorTrimMaterial as longchar no-undo.
    define VARIABLE pcInteriorTrimColour as longchar no-undo.
    define VARIABLE pcInteriorAccessories as longchar no-undo.
    define VARIABLE pcExteriorColour as longchar no-undo.
    define VARIABLE pcMoonroof as longchar no-undo.
    define VARIABLE pcWheels as longchar no-undo.
    
    
    define variable pcOrderId as character no-undo.
    define variable pdOrderAmount as decimal no-undo.    
    
    piOrderNumber = 74.
    pcBrand = 'fjord'.
    pcDealerId = 'dealer03'.
    pcCustomerId = '8e1f00c4-ec87-119b-e011-c50e4ed40b4c'.
    pcCustomerId = '10'.
    plOrderApproved = true.
    pcInstructions = 'extra instructions'.
    pcmodel = '[~{"label":"FJ-200","value":"fd16dc03-8bcb-9bb8-e011-b02411c531fa","selected":false~},~{"label":"FJ-100","value":"fd16dc03-8bcb-9bb8-e011-b024cd2831fa","selected":true~}]'.    
    pcInteriorTrimMaterial = 'fd16dc03-8bcb-9bb8-e011-b024aeda30fa'.
    pcInteriorTrimColour = 'fd16dc03-8bcb-9bb8-e011-b024bc0131fa'.
    pcInteriorAccessories = '["fd16dc03-8bcb-9bb8-e011-b024be0131fa", "fd16dc03-8bcb-9bb8-e011-b024c00131fa"]'.
    pcMoonroof = 'fd16dc03-8bcb-9bb8-e011-b0249eb330fa'.
    pcWheels = 'fd16dc03-8bcb-9bb8-e011-b0249db330fa'.
    
    run AutoEdge/Factory/Server/Order/BusinessComponent/service_captureorder.p (
                input piOrderNumber,
                input pcBrand,
/*                input pcUserContextId,*/
                
                input pcDealerId ,
                input pcCustomerId, 
                input plOrderApproved ,
                input pcInstructions, 
                input pcModel,
                input pcInteriorTrimMaterial, 
                input pcInteriorTrimColour, 
                input pcInteriorAccessories, 
                input pcExteriorColour, 
                input pcMoonroof,
                input pcWheels, 
                output pcOrderId ,
                output pdOrderAmount). 
                
    message
    pcOrderId skip
    pdOrderAmount
    view-as alert-box error title '[PJ DEBUG]'.                
    
end procedure.

procedure test_customerlogin:
    /** -- params, defs -- **/
    def var cBrand as character no-undo.
    def var cUserName as character no-undo.
    /* plain-text. ugh. */
    def var cPassword as character no-undo.
    
    def var cUserContextId as longchar no-undo.
    def var cCustomerId as longchar no-undo.
    def var cCustomerEmail as longchar no-undo.
    def var dCreditLimit as decimal no-undo.
    
    cbrand = 'fjord'.
    cPassword = 'letmein'.
    cusername = 'amy'.

        run AutoEdge/Factory/Server/Common/CommonInfrastructure/service_customerlogin.p 
                (  input cBrand,
                   input cUserName,
                  input cPassword,
                  output cUserContextId,
                  output cCustomerId,
                  output cCustomerEmail,
                  output dCreditLimit).
                  
end procedure.     

procedure test_userlogin:
    define output parameter poUserContext as IUserContext extent no-undo.
    
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable cContextId as longchar no-undo.
    define variable oResponse as SecurityManagerResponse extent no-undo. 
    define variable mUserContext as memptr no-undo.
    define variable oRequest as SecurityManagerRequest extent 1 no-undo.
    

        oRequest[1] = new SecurityManagerRequest('SecurityManager.UserLogin', ServiceMessageActionEnum:UserLogin).
        assign oRequest[1]:UserName = 'john_webbs'
               oRequest[1]:UserDomain = 'sales.employee.fjord'
               oRequest[1]:UserPassword = 'letmein'.
    
    assign iMax = extent(oRequest)
           extent(oResponse) = iMax
           extent(poUserContext) = iMax.
    
    do iLoop = 1 to iMax on error undo, next:
        oResponse[iLoop] = new SecurityManagerResponse(oRequest[iLoop]).
        
        set-byte-order(mUserContext) = ByteOrderEnum:BigEndian:Value.
        
        run OpenEdge/CommonInfrastructure/Server/service_interface_userlogin.p 
                ( input oRequest[iLoop]:UserName,
                  input oRequest[iLoop]:UserDomain,
                  input oRequest[iLoop]:UserPassword,
                  output mUserContext).
        
        oResponse[iLoop]:UserContext = DeserializeContext(mUserContext).
        poUserContext[iLoop] = oResponse[iLoop]:UserContext.
         
        catch oError as Error:
            cast(oResponse[iLoop], IServiceResponse):HasError = true.
            cast(oResponse[iLoop], IServiceResponse):ErrorText = oError:GetMessage(1).
        end catch.
    end.
    
end procedure.

procedure test_userlogout:
    define input parameter poUserContext as IUserContext extent no-undo.
    
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable oResponse as SecurityManagerResponse extent no-undo. 
    define variable mUserContext as memptr no-undo.
    define variable oRequest as SecurityManagerRequest extent no-undo.
    
    assign iMax = extent(poUserContext)
           extent(oRequest) = iMax
           extent(oResponse) = iMax.
    
    do iLoop = 1 to iMax on error undo, next:
        oRequest[iLoop] = new SecurityManagerRequest(OpenEdge.CommonInfrastructure.Common.SecurityManager:ISecurityManagerType:TypeName,
                                                     ServiceMessageActionEnum:UserLogout).
        oRequest[iLoop]:ContextId = poUserContext[iLoop]:ContextId.
        oRequest[iLoop]:UserContext = poUserContext[iLoop].
    
        oResponse[iLoop] = new SecurityManagerResponse(oRequest[iLoop]).
        
        set-byte-order(mUserContext) = ByteOrderEnum:BigEndian:Value.
        
        mUserContext = SerializeContext(poUserContext[iLoop]).
        run OpenEdge/CommonInfrastructure/Server/service_interface_userlogout.p 
                ( input-output mUserContext).
        
        oResponse[iLoop]:UserContext = DeserializeContext(mUserContext).
        catch oApplicationError as ApplicationError:
            cast(oResponse[iLoop], IServiceResponse):HasError = true.
            cast(oResponse[iLoop], IServiceResponse):ErrorText = oApplicationError:ResolvedMessageText().
            
            oApplicationError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).

            cast(oResponse[iLoop], IServiceResponse):HasError = true.
            cast(oResponse[iLoop], IServiceResponse):ErrorText = oUHError:ResolvedMessageText().
            
            oUHError:ShowError().
        end catch.
    end.
end procedure.


procedure test_dealerdetail:
    define variable pcBrand as character no-undo.
    define variable pcDealerCode as character no-undo.
    define variable pcUserContextId as longchar no-undo.

    define variable pcDealerId as longchar no-undo.
    define variable pcName as character no-undo.
    define variable pcSalesEmail as character no-undo.
    define variable pcInfoEmail as character no-undo.
    define variable pcStreetAddress as character no-undo.
    define variable pcPhoneNumber as character no-undo.
    define variable pcSalesReps as longchar no-undo.
    
    pcBrand =  'fjord'.
    pcDealerCode = 'dealer03'.
    pcUserContextId = ''.
    
    run AutoEdge/Factory/Server/Order/BusinessComponent/service_dealer_detail.p
        (pcBrand, pcDealerCode, pcUserContextId,
        output pcDealerId,
        output pcName,
        output pcSalesEmail,
        output pcInfoEmail,
        output pcStreetAddress,
        output pcPhoneNumber,
        output pcSalesEmail).
        
end procedure.     

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
    def var cUserContextId as longchar.

    run AutoEdge/Factory/Server/Order/BusinessComponent/service_branddata.p (
                input pcBrand,
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
catch oApplicationError as ApplicationError:
    oApplicationError:LogError().
    oApplicationError:ShowError().
end catch.
catch oError as Error:
    define variable oUHError as UnhandledError no-undo.
    oUHError = new UnhandledError(oError).
    oUHError:LogError().
    oUHError:ShowError().
end catch.

finally:
    run OpenEdge/CommonInfrastructure/Common/stop_session.p.
end finally.
