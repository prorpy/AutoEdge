/*------------------------------------------------------------------------
    File        : WarriorModule
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Mar 02 11:07:55 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.InjectABL.*.
using OpenEdge.Core.InjectABL.Binding.*.
using OpenEdge.Core.InjectABL.Binding.Parameters.*.
using OpenEdge.Core.InjectABL.Binding.Conditions.*.
using OpenEdge.Core.InjectABL.Lifecycle.*.
using OpenEdge.Core.InjectABL.Binding.Modules.*.
using OpenEdge.Lang.*.
using Progress.Lang.*.

class OpenEdge.Test.WarriorModule inherits InjectionModule:
    
    constructor public WarriorModule():
        super().
    end constructor.

    method override public void Load():
        def var oParam as IParameter extent no-undo.
        
        /* use oBS as bug workaround */
        def var obs as IBindingSyntax.
        
        /* Samurai! */
        obs = Bind('OpenEdge.Test.IWeapon').
        obs = obs:To('OpenEdge.Test.Sword').
        
        obs = Bind('OpenEdge.Test.IWeapon').
        obs = obs:To('OpenEdge.Test.Shuriken'):Named('alternateweapon').
        
        obs = Bind('OpenEdge.Test.Samurai').
        obs = obs
            :ToSelf()
            :Using('OpenEdge.Test.SamuraiProvider')
            :WithPropertyValue('Dojo', 'Ninja Gym East')
        .
        
        extent(oParam) = ?.
        extent(oParam) = 1.
        oParam[1] = new Parameter('brian', DataTypeEnum:Integer).

        obs
            :WithPropertyValue('NumberOfAssistants', oParam).
        
        
        extent(oParam) = ?.
        extent(oParam) = 2.
        oParam[1] = new Parameter('Mike').
        oParam[2] = new Parameter('Dwight').
        
        obs    
            :WithMethodValue('SetNinjaMasters', oParam)
            :WithMethodValue('SetAlternateWeapon',
                              Class:GetClass('OpenEdge.Test.IWeapon'))
            /*:OnServerSession()*/
            .
        
        /*
        obs = Bind('OpenEdge.Test.Samurai').
        obs = obs
            :To('OpenEdge.Test.ClientSamurai')
            :Using('OpenEdge.Test.SamuraiProvider')
            /*:OnClientSession()*/
            .
        */            
    end method.

end class.