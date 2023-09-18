 
 /*------------------------------------------------------------------------
    File        : test_form
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Tue Apr 21 16:28:30 EDT 2009
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Windows.Form.



CLASS test_form INHERITS Form   : 
    
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
    def var hq as handle.
    def var hb as handle.
    
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.

    define private variable bindingSource1 as Progress.Data.BindingSource no-undo.

    define private variable textBox1 as System.Windows.Forms.TextBox no-undo.
    define private variable textBox2 as System.Windows.Forms.TextBox no-undo.

    define private variable button1 as System.Windows.Forms.Button no-undo.


        
    CONSTRUCTOR PUBLIC test_form (  ):
        
        
        SUPER().
        InitializeComponent().

        fetchdata().
        mhMasterDataset = dataset dsDepartment:handle.
        
        
        hb = mhMasterDataset:get-buffer-handle(1).
        
        create query hq.
        hq:set-buffers(hb).
        hq:query-prepare('preselect each ' + hb:name).
        
/* CHANGE TO SEE DATA
        hq = mhMasterDataset:top-nav-query.
        */
        
        bindingSource1:handle = hq.        
        
        hq:query-open().
        
        hq:get-first(). 
        
        MESSAGE '[DEBUG]' this-object program-name(1) program-name(2) skip(2)
        hb::deptcode
        view-as alert-box error.
        
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.

    END CONSTRUCTOR.

    
    /*------------------------------------------------------------------------------
            Purpose:                                                                        
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    METHOD PRIVATE VOID getnextclick( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
        def var i as int.
        i = hq:current-result-row.
        
        hq:reposition-to-row(i + 1).
        hq:get-next().
        
        MESSAGE '[DEBUG]' this-object program-name(1) program-name(2) skip(2)
        'i=' i skip
        'hq:current-result-row=' hq:current-result-row skip
        "after next" hb::deptcode skip
        'bindingSource1:Position=' bindingSource1:Position skip
        view-as alert-box error.
        
        
        
        RETURN.

    END METHOD.


     METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("eDepartment").
        this-object:bindingSource1 = new Progress.Data.BindingSource().
        this-object:textBox1 = new System.Windows.Forms.TextBox().
        this-object:textBox2 = new System.Windows.Forms.TextBox().
        this-object:button1 = new System.Windows.Forms.Button().
        cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* bindingSource1 */
        /*  */
        this-object:bindingSource1:MaxDataGuess = 0.
        this-object:bindingSource1:NoLOBs = false.
        this-object:bindingSource1:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 2 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("DeptCode", "Code", Progress.Data.DataType:CHARACTER).
        arrayvar1[2] = new Progress.Data.ColumnPropDesc("DeptName", "Name", Progress.Data.DataType:CHARACTER).
        tableDesc1:Columns = arrayvar1.
        this-object:bindingSource1:TableSchema = tableDesc1.
        /*  */
        /* textBox1 */
        /*  */
        this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "DeptCode")).
        this-object:textBox1:Location = new System.Drawing.Point(99, 30).
        this-object:textBox1:Name = "textBox1".
        this-object:textBox1:Size = new System.Drawing.Size(100, 20).
        this-object:textBox1:TabIndex = 0.
        /*  */
        /* textBox2 */
        /*  */
        this-object:textBox2:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "DeptName")).
        this-object:textBox2:Location = new System.Drawing.Point(96, 123).
        this-object:textBox2:Name = "textBox2".
        this-object:textBox2:Size = new System.Drawing.Size(100, 20).
        this-object:textBox2:TabIndex = 1.
        /*  */
        /* button1 */
        /*  */
        this-object:button1:Location = new System.Drawing.Point(112, 192).
        this-object:button1:Name = "button1".
        this-object:button1:Size = new System.Drawing.Size(75, 23).
        this-object:button1:TabIndex = 2.
        this-object:button1:Text = "Get Next".
        this-object:button1:UseCompatibleTextRendering = true.
        this-object:button1:UseVisualStyleBackColor = true.
        this-object:button1:Click:subscribe(this-object:getnextclick).
        /*  */
        /* test_form */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(292, 266).
        this-object:Controls:Add(this-object:button1).
        this-object:Controls:Add(this-object:textBox2).
        this-object:Controls:Add(this-object:textBox1).
        this-object:Name = "test_form".
        this-object:Text = "test_form".
        cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    END METHOD.


 

    DESTRUCTOR PUBLIC test_form ( ):

        IF VALID-OBJECT(components) THEN DO:
            CAST(components, System.IDisposable):Dispose().
        END.

    END DESTRUCTOR.

    method public void FetchData():
        buffer edepartment:attach-data-source(data-source dsdept:handle).
        buffer eemployee:attach-data-source(data-source dsemp:handle).
        buffer efamily:attach-data-source(data-source dsfam:handle).

        dataset dsDepartment:fill().
        
        buffer edepartment:detach-data-source().
        buffer eemployee:detach-data-source().
        buffer efamily:detach-data-source().
    end method.
    
END CLASS.