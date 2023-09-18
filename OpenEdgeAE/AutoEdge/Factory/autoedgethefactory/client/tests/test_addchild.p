using Infragistics.Win.UltraWinGrid.*.
using Progress.Data.*.
using Progress.Lang.*.
using Progress.Windows.*.

    
    define temp-table eDepartment no-undo before-table eDepartmentBefore
        field DeptCode as char  label 'Department Code'
        field DeptName as char  label 'Department Name'
        index idx1 as primary unique DeptCode.
        
    define temp-table eEmployee no-undo before-table eEmployeeBefore
        field Address          as character format "x(35)" label "Address"
        field Address2         as character format "x(35)" label "Address2"
        field Birthdate        as date      format "99/99/9999" label "Birthdate"
        field City             as character format "x(25)" label "City"
        field DeptCode         as character format "x(3)" label "Dept Code"
        field EmpNum           as integer   format "zzzzzzzzz9" label "Emp No"
        field FirstName        as character format "x(15)" label "First Name"
        field HomePhone        as character format "x(20)" label "Home Phone"
        field LastName         as character format "x(25)" label "Last Name"
        field Position         as character format "x(20)" label "Position"
        field PostalCode       as character format "x(10)" label "Postal Code"
        field SickDaysLeft     as integer   format ">>9" label "Sick Days Left"
        field StartDate        as date      format "99/99/9999" label "Start Date"
        field State            as character format "x(20)" label "State"
        field VacationDaysLeft as integer   format ">>9" label "Vacation Days Left"
        field WorkPhone        as character format "x(20)" label "Work Phone"
        index idx1 /*as unique */ EmpNum
        index idx2 as primary unique DeptCode EmpNum
        index idx3 LastName FirstName.
        
    define temp-table eFamily no-undo before-table eFamilyBefore
        field BenefitDate       as date      format "99/99/9999" label "Benefit Date"
        field Birthdate         as date      format "99/99/9999" label "Birthdate"
        field CoveredOnBenefits as logical   label "Covered On Benefits"
        field EmpNum            as integer   format "zzzzzzzzz9" label "Emp No"
        field Relation          as character format "x(15)" label "Relation"
        field RelativeName      as character format "x(15)" label "Relative Name"
        index idx1 as primary unique EmpNum RelativeName.
    
    define dataset dsDepartment for eDepartment, eEmployee, eFamily
        data-relation for eDepartment, eEmployee relation-fields (DeptCode, DeptCode)
        data-relation for eEmployee, eFamily relation-fields (EmpNum, EmpNum).
    
    define data-source dsdept for Department.         
    define data-source dsemp for EMployee.
    define data-source dsfam for Family.

    def var mhMasterDataset as handle.

    run fetchdata.
    mhMasterDataset = dataset dsDepartment:handle.
    
    def var oform as Form.
    define var ogrid as UltraGrid no-undo.
    def var bs1 as BindingSource.
    define var obtn as Infragistics.Win.Misc.UltraButton no-undo.
    
    
    oform = new Form().
    
    obtn = new Infragistics.Win.Misc.UltraButton ().
    obtn:text = 'add'.
    obtn:Dock = System.Windows.Forms.DockStyle:Top.
    obtn:Click:Subscribe('AddButtonClick').
    
    bs1 = new BindingSource().
    bs1:handle = mhmasterdataset.
    
    ogrid = new Infragistics.Win.UltraWinGrid.UltraGrid().
    ogrid:DataSource = bs1.
    ogrid:Dock = System.Windows.Forms.DockStyle:Fill.
    
    oform:Controls:Add(ogrid).    
    oform:Controls:Add(obtn).
    
    
    wait-for System.Windows.Forms.Application:Run(oform). 
        
    procedure addrow:
        def input param hqry as handle.        
        def input param hbuffer as handle.
        def output param rr as rowid.
        
        message
            hqry:prepare-string skip
            ' num rows before add' hqry:num-results
        view-as alert-box.
    
        DO transaction:
            hbuffer:buffer-create().
            
            /* not strictly necessary since we're reopening */
            hqry:create-result-list-entry().
            
            run AssignKeyValues(hbuffer:name,hbuffer).

            rr = hbuffer:rowid.                        
            hbuffer:buffer-release().
        END.

        hqry:query-close().
        hqry:query-open().
        
        message
        ' num rows after query reopen' hqry:num-results
        view-as alert-box.
        
        hqry:reposition-to-rowid(rr).
    end procedure.
    

    procedure AddButtonClick:
        def input param sender as System.Object.
        def input param e as System.EventArgs.
        
        def var hqry as handle.
        def var hbuf as handle.
        def var cTable as char.
        
        if valid-object(ogrid:ActiveRow) then
            cTable = ogrid:ActiveRow:Band:Key.
        else
            cTable = ogrid:DisplayLayout:Bands[0]:Key.
        
        hbuf = bs1:Handle:get-buffer-handle(cTable).
        
        if valid-handle(hbuf:parent-relation) then
            /* Alternate query; works w.r.t num records after open, but not
               related to UI, so no screen update */
/*            hqry = bs1:Handle:get-buffer-handle(cTable):parent-relation:query.*/
            hqry = hbuf:parent-relation:current-query.
        else
            hqry = bs1:Handle:top-nav-query.
        
        MESSAGE 
            'ctable=' ctable skip
            'current-query=' hbuf:parent-relation:current-query
        VIEW-AS ALERT-BOX.
        
/* comment out for ASSERT failure   */     bs1:handle = ?. 
        def var rr as rowid.
        
        run addrow (hqry, hbuf, output rr).
        
/* comment out for ASSERT failure  */      bs1:handle = mhMasterDataset.

/*
        MESSAGE '[DEBUG]' skip program-name(1)  program-name(2)  skip(2)
            string(rr)        skip
            bs1:Handle:get-buffer-handle(cTable):parent-relation:current-query
        VIEW-AS ALERT-BOX.
        
        /*// Get the first child row of the first row in the UltraGrid.*/
        def var childrow as UltraGridRow .
        childRow = ogrid:Rows[6]:GetChild(Infragistics.Win.UltraWinGrid.ChildRow:First ).
           
        /*          // Expand all of its ancestors if the aren't already expanded.*/
        childRow:ExpandAncestors().
        ogrid:ActiveRow = childRow.
**/        
        
        bs1:Handle:get-buffer-handle(cTable):parent-relation:current-query:reposition-to-rowid(rr).
        bs1:RefreshAll().
    end.    
    
    procedure AssignKeyValues:
        def input param pcTable as char.
        def input param phBuffer as handle.
        
        define variable hRelation as handle no-undo.
        define variable iNumFields as integer no-undo.
        
        hRelation = phBuffer:parent-relation.
        
        if valid-handle(hRelation) then
        /* relationfields = parent-field1, child-field1 [, parent-fieldn, child-fieldn ] ...) */
        do iNumFields = 1 to num-entries(hRelation:relation-fields) by 2:
            phBuffer:buffer-field(entry(iNumFields + 1, hRelation:relation-fields)):buffer-value =
                    hRelation:parent-buffer:buffer-field(entry(iNumFields, hRelation:relation-fields)):buffer-value.
        end.                        
    end .
    
    PROCEDURE fetchdata:
        buffer edepartment:attach-data-source(data-source dsdept:handle).
        buffer eemployee:attach-data-source(data-source dsemp:handle).
        buffer efamily:attach-data-source(data-source dsfam:handle).

        dataset dsDepartment:fill().
        
        buffer edepartment:detach-data-source().
        buffer eemployee:detach-data-source().
        buffer efamily:detach-data-source().

    END procedure.