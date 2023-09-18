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
    File        : LoginPresenter
    Purpose     : Presenter to handle login functionality
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Mon Dec 10 16:50:29 EST 2007
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.
  
using OpenEdge.PresentationLayer.Presenter.Presenter.
using OpenEdge.PresentationLayer.Presenter.IPresenter.
using OpenEdge.PresentationLayer.Presenter.ILoginPresenter.
using OpenEdge.PresentationLayer.Common.LoginError.

using OpenEdge.CommonInfrastructure.Common.IApplicationLogin.
using OpenEdge.CommonInfrastructure.Common.IServiceManager. 
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

using OpenEdge.Core.System.ILoginData.
using OpenEdge.Core.System.ApplicationError.

class OpenEdge.PresentationLayer.Presenter.LoginPresenter
        inherits Presenter
        implements ILoginPresenter, IApplicationLogin:
    
    constructor public LoginPresenter(poComponentInfo as IComponentInfo):
        super(poComponentInfo).
    end constructor.
    
    /* ILoginPresenter methods below */
    method public void ValidateLogin(poLoginData as ILoginData).
        /* authenticate & authorise
         
        define private variable moAuthenticationService as ISecurityManager no-undo.
        moAuthenticationService = cast(ServiceManager:StartService(SecurityManager:ISecurityManagerType)
                    , ISecurityManager).
        */
        
        /* If we get here, then login has succeeded and we can close the login window down. */
        CloseView().
        
        catch oAuthError as ApplicationError:
            oAuthError:ShowError().
            undo, throw new LoginError(oAuthError, 'failed').
        end catch.
    end method.

end class.
