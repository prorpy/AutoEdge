    define temp-table eAction no-undo before-table eActionBefore
        field RecordKey as character extent 18
        field QueryName as character
        field BufferName as character 
        field ModelName as character
        field UndoActionType as integer /* MVP.Presenter.UpdateActionEnum */
        field Order as integer
        index idx1 as primary unique ModelName QueryName BufferName Order
        .
    
    define dataset dsAction for eAction.
                

    def var h as handle.
    h = dataset dsAction:handle.
    
/*    h:set-callback(Base.System.CallbackNameEnum:RowUpdate, "RowUpdate").*/
    h:get-buffer-handle(1):set-callback-procedure('Row-Update', 'RowUpdate').
                        