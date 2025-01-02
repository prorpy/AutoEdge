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
    File        : UserTypeEnum
    Purpose     : Describes the user type of the currently-logged in user. 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Fri Feb 25 10:08:03 EST 2011
    Notes       : * Used for authorising actions
                  * The types correspond to the foreign keys off the ApplicationUser
                    table. In addition, we have a special kind of customer 'guest'
                    who has differnt permissions to a customer.
  ---------------------------------------------------------------------- */
using AutoEdge.Factory.Common.CommonInfrastructure.UserTypeEnum.
using OpenEdge.Lang.EnumMember.

class AutoEdge.Factory.Common.CommonInfrastructure.UserTypeEnum inherits EnumMember: 
    
    define static public property Employee as UserTypeEnum no-undo get. private set.
    define static public property Customer as UserTypeEnum no-undo get. private set.
    define static public property Guest as UserTypeEnum no-undo get. private set.
    define static public property Supplier as UserTypeEnum no-undo get. private set.
    define static public property System as UserTypeEnum no-undo get. private set.
    
    
    constructor static UserTypeEnum ():
        UserTypeEnum:Employee = new UserTypeEnum('Employee').
        UserTypeEnum:Customer = new UserTypeEnum('Customer').
        UserTypeEnum:Guest = new UserTypeEnum('Guest').
        UserTypeEnum:Supplier = new UserTypeEnum('Supplier').
        UserTypeEnum:System = new UserTypeEnum('System').
    end constructor.
    
	constructor public UserTypeEnum ( input pcName as character ):
		super (input pcName).
	end constructor.
	
	method static public UserTypeEnum EnumFromString (input pcName as character):
        define variable oEnum as UserTypeEnum no-undo.
        
        case pcName:
            when UserTypeEnum:Employee:ToString() then oEnum = UserTypeEnum:Employee.
            when UserTypeEnum:Customer:ToString() then oEnum = UserTypeEnum:Customer.
            when UserTypeEnum:Guest:ToString() then oEnum = UserTypeEnum:Guest.
            when UserTypeEnum:System:ToString() then oEnum = UserTypeEnum:System.
            when UserTypeEnum:Supplier:ToString() then oEnum = UserTypeEnum:Supplier.
        end case.
        
        return oEnum.
    end method.
    
end class.
