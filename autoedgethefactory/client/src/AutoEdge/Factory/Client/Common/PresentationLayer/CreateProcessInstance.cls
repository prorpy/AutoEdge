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
 /*------------------------------------------------------------------------
    File        : CreateProcessInstance
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri Jul 16 12:03:50 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.WorkFlowWebService.
using OpenEdge.Lang.BPM.ProcessTemplate.
using AutoEdge.Factory.Client.Common.PresentationLayer.CreateProcessInstance. 
using Progress.Windows.Form.

class AutoEdge.Factory.Client.Common.PresentationLayer.CreateProcessInstance inherits Form: 
    
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable lblInstanceName as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblPriority as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblName as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable uxCreate as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.
    define private variable uxInstanceName as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxPriority as Infragistics.Win.UltraWinEditors.UltraComboEditor no-undo.
    define private variable uxProcessName as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.

    define public property Process as ProcessTemplate no-undo get. private set.
    define public property WorkFlowWebService as IBizLogicAPI no-undo get. private set.
    define public property SessionId as longchar no-undo get. private set.
    
    constructor public CreateProcessInstance(pcSessionId as longchar,
                                             poWorkFlowWebService as IBizLogicAPI,
                                             poProcessTemplate as ProcessTemplate):        
        this-object().
        
        assign this-object:Process = poProcessTemplate
               SessionId = pcSessionId
               WorkFlowWebService = poWorkFlowWebService.
               
        InitUI().               
    end constructor.
    
    constructor public CreateProcessInstance(  ):
        super().
        InitializeComponent().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.

    end constructor.
    
    method protected void InitUI():
        
        message 
        'process:name=' process:name skip
        'process:priority=' process:priority skip
        process:Group skip
        process:Description skip
        process:AppName
        view-as alert-box.
        
        assign uxProcessName:Text = process:name
               uxInstanceName:Text = uxProcessName:Text
               uxPriority:Value = process:priority
               this-object:Text = this-object:Text + ' ' + uxProcessName:Text   
               .
    end method.
    
    method private void InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("AutoEdge.Factory.Client.Common.PresentationLayer.CreateProcessInstance").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance2 as Infragistics.Win.Appearance no-undo.
        appearance2 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem1 as Infragistics.Win.ValueListItem no-undo.
        valueListItem1 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem2 as Infragistics.Win.ValueListItem no-undo.
        valueListItem2 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem3 as Infragistics.Win.ValueListItem no-undo.
        valueListItem3 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem4 as Infragistics.Win.ValueListItem no-undo.
        valueListItem4 = new Infragistics.Win.ValueListItem().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:uxCreate = new Infragistics.Win.Misc.UltraButton().
        this-object:lblName = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxProcessName = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:uxPriority = new Infragistics.Win.UltraWinEditors.UltraComboEditor().
        this-object:lblPriority = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxInstanceName = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblInstanceName = new Infragistics.Win.Misc.UltraLabel().
        cast(this-object:uxProcessName, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxPriority, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxInstanceName, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* imageList1 */
        /*  */
        this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageList1:Images:SetKeyName(0, "cog_add_32x32.png").
        /*  */
        /* uxCreate */
        /*  */
        appearance2:FontData:BoldAsString = "True".
        appearance2:FontData:Name = "Segoe UI".
        appearance2:FontData:SizeInPoints = 12.
        appearance2:Image = "cog_add_32x32.png".
        this-object:uxCreate:Appearance = appearance2.
        this-object:uxCreate:DialogResult = System.Windows.Forms.DialogResult:OK.
        this-object:uxCreate:ImageList = this-object:imageList1.
        this-object:uxCreate:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxCreate:Location = new System.Drawing.Point(215, 94).
        this-object:uxCreate:Name = "uxCreate".
        this-object:uxCreate:Size = new System.Drawing.Size(167, 40).
        this-object:uxCreate:TabIndex = 41.
        this-object:uxCreate:Text = "Create Instance".
        this-object:uxCreate:Click:Subscribe(this-object:uxCreate_Click).
        /*  */
        /* lblName */
        /*  */
        this-object:lblName:AutoSize = true.
        this-object:lblName:Location = new System.Drawing.Point(60, 17).
        this-object:lblName:Name = "lblName".
        this-object:lblName:Size = new System.Drawing.Size(78, 14).
        this-object:lblName:TabIndex = 42.
        this-object:lblName:Text = "Process Name".
        /*  */
        /* uxProcessName */
        /*  */
        this-object:uxProcessName:Location = new System.Drawing.Point(144, 13).
        this-object:uxProcessName:Name = "uxProcessName".
        this-object:uxProcessName:ReadOnly = true.
        this-object:uxProcessName:ShowOverflowIndicator = true.
        this-object:uxProcessName:Size = new System.Drawing.Size(238, 21).
        this-object:uxProcessName:TabIndex = 43.
        /*  */
        /* uxPriority */
        /*  */
        valueListItem1:DataValue = "low".
        valueListItem1:DisplayText = "Low".
        valueListItem2:DataValue = "medium".
        valueListItem2:DisplayText = "Medium".
        valueListItem3:DataValue = "high".
        valueListItem3:DisplayText = "High".
        valueListItem4:DataValue = "critical".
        valueListItem4:DisplayText = "Critical".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as Infragistics.Win.ValueListItem extent 4 no-undo.
        arrayvar0[1] = valueListItem1.
        arrayvar0[2] = valueListItem2.
        arrayvar0[3] = valueListItem3.
        arrayvar0[4] = valueListItem4.
        this-object:uxPriority:Items:AddRange(arrayvar0).
        this-object:uxPriority:Location = new System.Drawing.Point(144, 40).
        this-object:uxPriority:Name = "uxPriority".
        this-object:uxPriority:Size = new System.Drawing.Size(238, 21).
        this-object:uxPriority:TabIndex = 44.
        /*  */
        /* lblPriority */
        /*  */
        this-object:lblPriority:AutoSize = true.
        this-object:lblPriority:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblPriority:Location = new System.Drawing.Point(98, 44).
        this-object:lblPriority:Name = "lblPriority".
        this-object:lblPriority:Size = new System.Drawing.Size(40, 14).
        this-object:lblPriority:TabIndex = 45.
        this-object:lblPriority:Text = "Priority".
        /*  */
        /* uxInstanceName */
        /*  */
        this-object:uxInstanceName:Location = new System.Drawing.Point(144, 67).
        this-object:uxInstanceName:Name = "uxInstanceName".
        this-object:uxInstanceName:Size = new System.Drawing.Size(238, 21).
        this-object:uxInstanceName:TabIndex = 47.
        /*  */
        /* lblInstanceName */
        /*  */
        this-object:lblInstanceName:AutoSize = true.
        this-object:lblInstanceName:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblInstanceName:Location = new System.Drawing.Point(14, 71).
        this-object:lblInstanceName:Name = "lblInstanceName".
        this-object:lblInstanceName:Size = new System.Drawing.Size(124, 14).
        this-object:lblInstanceName:TabIndex = 46.
        this-object:lblInstanceName:Text = "Process Instance Name".
        /*  */
        /* CreateProcessInstance */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(393, 145).
        this-object:Controls:Add(this-object:uxInstanceName).
        this-object:Controls:Add(this-object:lblInstanceName).
        this-object:Controls:Add(this-object:lblPriority).
        this-object:Controls:Add(this-object:uxPriority).
        this-object:Controls:Add(this-object:uxProcessName).
        this-object:Controls:Add(this-object:lblName).
        this-object:Controls:Add(this-object:uxCreate).
        this-object:Name = "CreateProcessInstance".
        this-object:Text = "Create Process Instance".
        cast(this-object:uxProcessName, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxPriority, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxInstanceName, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    method private void uxCreate_Click( input sender as System.Object, input e as System.EventArgs ):
    
    /*
            
        ' get the values from the wstestStartePage for the 
        Dim piName As String = Me.pinameValue.Text
        Dim priority As String = Me.pipriorityValue.SelectedItem


        pi = WorkFlow.LoginForm1.wf.createProcessInstance(WorkFlow.LoginForm1.sessionId, WorkFlow.MyHome1.currentPt.name, piName, priority, Nothing)

    */            
        return.

    end method.

    destructor public CreateProcessInstance ( ):

        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.

end class.
