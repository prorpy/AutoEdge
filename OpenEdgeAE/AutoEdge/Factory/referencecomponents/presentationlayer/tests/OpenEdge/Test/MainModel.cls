 
 /*------------------------------------------------------------------------
    File        : MainModel
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 07 14:28:05 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Test.*.
using Progress.Lang.*.

class OpenEdge.Test.MainModel 
/*        inherits OpenEdge.PresentationLayer.Model.DatasetModel*/
        implements OpenEdge.Test.IMainSecondaryModel, IMainPrimaryModel: 

end class.