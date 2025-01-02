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
    File        : OpenEdge/CommonInfrastructure/Client/service_managed_async_response.p
    Purpose     : (Async) response procedure for ServiceAdapter calls.
    Syntax      :

    Description : 

    @author pjudge
    Created     : Fri Oct 29 15:15:39 EDT 2010
    Notes       :
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.CommonInfrastructure.Client.ServiceAdapter.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceMessage.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IFetchResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.ISaveResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.IServiceResponse.
using OpenEdge.CommonInfrastructure.Common.ServiceMessage.DataFormatEnum.
using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.Util.IObjectInput.
using OpenEdge.Core.Util.ObjectInputStream.
using OpenEdge.Lang.ABLSession.
using Progress.Lang.Class.
 
/* ***************************  Main Block  *************************** */
define variable moServiceManager as IServiceManager no-undo.
define variable moSMM as IServiceMessageManager no-undo.
define variable moSecMgr as ISecurityManager no-undo.

assign moServiceManager = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager)
       moSMM = cast(moServiceManager:GetService(ServiceMessageManager:IServiceMessageManagerType), IServiceMessageManager)
       moSecMgr = cast(moServiceManager:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).

/* ***************************  Procedures *************************** */
procedure EventProcedure_FetchData:
    define input parameter phResponseDataset as handle extent no-undo.
    define input parameter pmResponse as memptr extent no-undo.
    define input parameter pmUserContext as memptr no-undo.
    
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable mTemp as memptr no-undo.
    define variable oInput as IObjectInput no-undo.    
    define variable oResponse as IFetchResponse extent no-undo.
        
    assign iMax = extent(pmResponse)
           extent(oResponse) = iMax.
    
    do iLoop = 1 to iMax:
        oInput = new ObjectInputStream().
        oInput:Read(pmResponse[iLoop]).
        oResponse[iLoop] = cast(oInput:ReadObject(), IFetchResponse).
        
        cast(oResponse[iLoop], IServiceMessage):SetMessageData(
                phResponseDataset[iLoop],
                DataFormatEnum:ProDataSet).
    end.
    
    /* Set context in to ContextManager from the data received from the server call. */
    moSecMgr:SetUserContext(ServiceAdapter:DeserializeContext(pmUserContext)).
    
    moSMM:ExecuteResponse(cast(oResponse, IServiceResponse)).
    
    /* nothing more for this procedure to do, so we get rid of it. */
    if this-procedure:async-request-count eq 0 then
        delete object this-procedure.
end procedure.

procedure EventProcedure_SaveData:
    define input parameter phRequestDataset as handle extent no-undo.
    define input parameter pmResponse as memptr extent no-undo.
    define input parameter pmUserContext as memptr no-undo.
    
    define variable oResponse as ISaveResponse  extent no-undo.
    define variable iLoop as integer no-undo.
    define variable iMax as integer no-undo.
    define variable mTemp as memptr no-undo.
    define variable mRequest as memptr extent no-undo.
    define variable oInput as IObjectInput no-undo.
    define variable hDataset as handle no-undo.
    
    assign iMax = extent(pmResponse)
           extent(oResponse) = iMax.
    
    oInput = new ObjectInputStream().
    do iLoop = 1 to iMax:
        oInput:Reset().
        oInput:Read(pmResponse[iLoop]).
        oResponse[iLoop] = cast(oInput:ReadObjectArray(), ISaveResponse).
        
        cast(oResponse[iLoop], IServiceMessage):SetMessageData(
                phRequestDataset[iLoop],
                DataFormatEnum:ProDataSet).
    end.
    
    /* Set context in to ContextManager from the data received from the server call. */
    moSecMgr:SetUserContext(ServiceAdapter:DeserializeContext(pmUserContext)).
    
    moSMM:ExecuteResponse(cast(oResponse, IServiceResponse)).
    
    /* nothing more for this procedure to do, so we get rid of it. */
    if this-procedure:async-request-count eq 0 then
        delete object this-procedure.
end procedure.

/* *** EOF *** */
