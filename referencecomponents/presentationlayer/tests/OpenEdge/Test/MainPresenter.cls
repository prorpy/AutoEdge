/*------------------------------------------------------------------------
    File        : MainPresenter
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 07 14:16:14 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Test.*.
using OpenEdge.PresentationLayer.Presenter.*. 
using Progress.Lang.*.

class OpenEdge.Test.MainPresenter 
    inherits DataboundPresenter
    implements IMainPresenter: 

    constructor public MainPresenter ( input poView as IView, input poModel as IModel extent, input poChildPresenter as IPresenter extent ):
        super (input poView, input poModel, input poChildPresenter).
    end constructor.


end class.