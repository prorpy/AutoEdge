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
    File        : UserLoginEntity
    Purpose     :
    Syntax      :
    Description :
    @author pjudge
    Created     : Wed Dec 22 10:06:26 EST 2010
    Notes       :
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.Entity.StandardBusinessEntity.
using OpenEdge.DataAccess.IDataAccess.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.IComponentInfo.

class AutoEdge.Factory.Server.Common.BusinessComponent.UserLoginEntity inherits StandardBusinessEntity:
    define private temp-table eUserLogin no-undo
        field ApplicationUserId as character
        field UserCategory      as character    /* supplier/customer/employee */
        field LastLoginDate     as datetime-tz
        field LastLoginLocation as character
        field LocaleName        as character
        field LoginName         as character
        field LoginDomain       as character
        field Password          as character
        index idx1 as primary LoginDomain LoginName
        .

    define private dataset dsUser for eUserLogin.

    constructor public UserLoginEntity(input poComponentInfo as IComponentInfo ):
        super(input poComponentInfo).
    end constructor.

    constructor public UserLoginEntity(input poComponentInfo as IComponentInfo, input poDAO as IDataAccess ):
        super(input poComponentInfo, input poDAO).

        // Sigrid
        output to logging.txt.
        put program-name(1).
        
    end constructor.

    method override protected handle CopyStaticDataset (output dataset-handle phDataset):
        phDataset = dataset dsUser:handle.
    end method.

end class.
