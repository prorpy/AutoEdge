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
    File        : StandardConditionResolver
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Dec 29 10:05:25 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.Binding.Conditions.IConditionResolver.
using OpenEdge.Core.InjectABL.Binding.Conditions.ICondition.
using OpenEdge.Core.InjectABL.Binding.Conditions.Condition.

using OpenEdge.Lang.Assert.

using Progress.Lang.Class.

class OpenEdge.Core.InjectABL.Binding.Conditions.StandardConditionResolver implements IConditionResolver: 

    constructor public StandardConditionResolver():
    end constructor. 

    /** Evaluates the provided conditions. 
        
        @param ICondition The left-hand side argument for the clause
        @param ICondition The clause operator
        @param ICondition The right-hand side argument for the clause
        @return logical Whether the clause resolves to true or false
         */
    method public logical EvaluateClause(input poLHS as ICondition,
                                         input poOperator as ICondition,
                                         input poRHS as ICondition):
        define variable lConditionsMet as logical no-undo.
        
        case poOperator:
            when Condition:Is  then lConditionsMet = poLHS:Equals(poRHS).
            when Condition:Not then lConditionsMet = not poLHS:Equals(poRHS).
        end case.
        
        return lConditionsMet.
    end method.
        
    /** Factory method for new IConditionResolver instances.
        
        @param Class The typename of the condition resolver.
        @return IConditionResolver The new resolver to use.      */
    method static public IConditionResolver GetResolver(input poConditionResolverType as class Class):
        define variable oConditionResolver as IConditionResolver no-undo.
        
        Assert:ArgumentNotNull(poConditionResolverType, 'Condition Resolver Type').
        Assert:ArgumentIsType(poConditionResolverType,
                              Class:GetClass('OpenEdge.Core.InjectABL.Binding.Conditions.IConditionResolver')).
        
        oConditionResolver = dynamic-new(poConditionResolverType:TypeName) ().
        
        return oConditionResolver.
    end method.
    
    
end class.
