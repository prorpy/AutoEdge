/*------------------------------------------------------------------------
    File        : MainView
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Wed Apr 07 14:25:43 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.*.
using OpenEdge.PresentationLayer.View.*.
using OpenEdge.Lang.EnumMember.
using OpenEdge.Test.IMainView.
using OpenEdge.PresentationLayer.Presenter.IPresenter.

class OpenEdge.Test.MainView implements IMainView, IView: 
    define public property Presenter as IPresenter no-undo get. set.

    method public void DataRefreshed( input pcModel as character, input pcQuery as character, input poModelAction as EnumMember ):
    
    end method.

    method public void DataFetched( input pcModel as character, input plNewData as logical ):
    
    end method.

    method public void SaveData( input pcModel as character, input pcBuffer as character ):
        
    end method.

    method public void ShowView(  ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void HideView(  ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void CloseView(  ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void DataRefreshed( input poModelService as Progress.Lang.Class, input pcQuery as character, input poModelAction as OpenEdge.Lang.EnumMember ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void DataFetched( input poModelService as Progress.Lang.Class, input plNewData as logical ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.

    method public void SaveData( input poModelService as Progress.Lang.Class, input pcBuffer as character ):
        
        undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

    end method.
    
end class.