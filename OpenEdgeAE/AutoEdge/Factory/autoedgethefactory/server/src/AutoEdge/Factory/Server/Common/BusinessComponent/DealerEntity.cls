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
    File        : DealerEntity
    Purpose     :
    Syntax      :
    Description :
    @author pjudge
    Created     : Tue Jan 25 14:26:45 EST 2011
    Notes       :
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.BusinessComponent.Entity.StandardBusinessEntity.
using OpenEdge.DataAccess.IDataAccess.

using OpenEdge.CommonInfrastructure.Common.IComponentInfo.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.

class AutoEdge.Factory.Server.Common.BusinessComponent.DealerEntity inherits StandardBusinessEntity:

    define private temp-table eDealer no-undo
        field DealerId as character
        field Code as character
        field Name as character
        field SalesEmail as character
        field InfoEmail as character
        field StreetAddress as character
        field PhoneNumber as character
        index idx1 as primary unique DealerId
        index idx2 as unique Code.

    define private temp-table eSalesrep no-undo
        field DealerId as character
        field Code as character
        field Quota as decimal
        field Region as character
        index idx1 as primary unique DealerId Code.
        .

	define dataset dsDealer for eDealer, eSalesrep
	   /*data-relation for eDealer, eSalesrep relation-fields(DealerId, DealerId)*/ .

	constructor public DealerEntity(input poComponentInfo as IComponentInfo,
	                                input poDAO as IDataAccess ):
		super(input poComponentInfo, input poDAO).
	end constructor.

	constructor public DealerEntity(input poComponentInfo as IComponentInfo):

 		super(input poComponentInfo).

	end constructor.

    method override protected handle CopyStaticDataset (output dataset-handle phDataset):
        phDataset = dataset dsDealer:handle.
    end method.

end class.
