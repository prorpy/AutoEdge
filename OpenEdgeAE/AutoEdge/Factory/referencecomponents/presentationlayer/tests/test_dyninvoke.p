/*------------------------------------------------------------------------
    File        : test_dyninvoke.p
    Purpose     : 

    Syntax      :

    Description : 

    @author pjudge
    Created     : Fri Jun 19 13:05:13 EDT 2009
    Notes       :
  ----------------------------------------------------------------------*/

using OpenEdge.Base.System.*.

def var o as Progress.Lang.Object.

/*o = TypeFactory:GetType('SampleApp.OERA.Infrastructure.AuthenticationManager').*/
o = TypeFactory:GetType('OpenEdge.MVP.Presenter.SessionPresenter').

MESSAGE '[DEBUG]' program-name(1) program-name(2) skip(2)
o
view-as alert-box error.



/*
METHOD PUBLIC Runtype Invoke( 
    INPUT myDynObject AS Progress.Lang.Object, 
    INPUT SomeDynMethodName AS CHARACTER, 
    INPUT paramList AS Progress.Lang.ParameterList).
*/
/*
def var oclass as class Progress.Lang.Class.


oClass = Progress.Lang.Class
oClass:GetClass('test.testInvoke').
MESSAGE '[DEBUG]' 
    'oClass:TypeName=' oClass:TypeName skip 
    "oClass:Invoke('Statm')=" oClass:Invoke('Statm') skip
    "oClass:Invoke('Statp')=" oClass:Invoke('Statp') skip
view-as alert-box error.
*/    