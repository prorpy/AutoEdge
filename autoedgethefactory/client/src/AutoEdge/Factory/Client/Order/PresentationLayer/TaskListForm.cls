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
/* ------------------------------------------------------------------------
    File        : TaskListForm
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Nov 24 08:29:13 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.

routine-level on error undo, throw.

class AutoEdge.Factory.Client.Order.PresentationLayer.TaskListForm inherits Form: 
    
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable ultraPanel2 as Infragistics.Win.Misc.UltraPanel no-undo.
    define private variable uxDisconnect as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxConnect as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxPW as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxHost as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable ultraPanel1 as Infragistics.Win.Misc.UltraPanel no-undo.
    define private variable lbluser as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblhost as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblPW as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable uxUser as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxStatus as Infragistics.Win.UltraWinStatusBar.UltraStatusBar no-undo. 
        
    constructor public TaskListForm (  ):
        
        
        super().
        InitializeComponent().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.

    end constructor.

    method private void InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraStatusPanel1 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel no-undo.
        ultraStatusPanel1 = new Infragistics.Win.UltraWinStatusBar.UltraStatusPanel().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraStatusPanel2 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel no-undo.
        ultraStatusPanel2 = new Infragistics.Win.UltraWinStatusBar.UltraStatusPanel().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraStatusPanel3 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel no-undo.
        ultraStatusPanel3 = new Infragistics.Win.UltraWinStatusBar.UltraStatusPanel().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraStatusPanel4 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel no-undo.
        ultraStatusPanel4 = new Infragistics.Win.UltraWinStatusBar.UltraStatusPanel().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraStatusPanel5 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel no-undo.
        ultraStatusPanel5 = new Infragistics.Win.UltraWinStatusBar.UltraStatusPanel().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraStatusPanel6 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel no-undo.
        ultraStatusPanel6 = new Infragistics.Win.UltraWinStatusBar.UltraStatusPanel().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraStatusPanel7 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel no-undo.
        ultraStatusPanel7 = new Infragistics.Win.UltraWinStatusBar.UltraStatusPanel().
        this-object:ultraPanel1 = new Infragistics.Win.Misc.UltraPanel().
        this-object:uxDisconnect = new Infragistics.Win.Misc.UltraButton().
        this-object:uxConnect = new Infragistics.Win.Misc.UltraButton().
        this-object:lblPW = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxPW = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lbluser = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxUser = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblhost = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxHost = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:ultraPanel2 = new Infragistics.Win.Misc.UltraPanel().
        this-object:uxStatus = new Infragistics.Win.UltraWinStatusBar.UltraStatusBar().
        this-object:ultraPanel1:ClientArea:SuspendLayout().
        this-object:ultraPanel1:SuspendLayout().
        cast(this-object:uxPW, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxUser, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxHost, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:ultraPanel2:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* ultraPanel1 */
        /*  */
        /*  */
        /* ultraPanel1.ClientArea */
        /*  */
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:uxDisconnect).
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:uxConnect).
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:lblPW).
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:uxPW).
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:lbluser).
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:uxUser).
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:lblhost).
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:uxHost).
        this-object:ultraPanel1:Dock = System.Windows.Forms.DockStyle:Top.
        this-object:ultraPanel1:Location = new System.Drawing.Point(0, 0).
        this-object:ultraPanel1:Name = "ultraPanel1".
        this-object:ultraPanel1:Size = new System.Drawing.Size(591, 69).
        this-object:ultraPanel1:TabIndex = 1.
        /*  */
        /* uxDisconnect */
        /*  */
        this-object:uxDisconnect:Location = new System.Drawing.Point(432, 35).
        this-object:uxDisconnect:Name = "uxDisconnect".
        this-object:uxDisconnect:Size = new System.Drawing.Size(75, 23).
        this-object:uxDisconnect:TabIndex = 7.
        this-object:uxDisconnect:Text = "Disconnect".
        /*  */
        /* uxConnect */
        /*  */
        this-object:uxConnect:Location = new System.Drawing.Point(351, 35).
        this-object:uxConnect:Name = "uxConnect".
        this-object:uxConnect:Size = new System.Drawing.Size(75, 23).
        this-object:uxConnect:TabIndex = 6.
        this-object:uxConnect:Text = "Connect".
        /*  */
        /* lblPW */
        /*  */
        this-object:lblPW:AutoSize = true.
        this-object:lblPW:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblPW:Location = new System.Drawing.Point(16, 38).
        this-object:lblPW:Name = "lblPW".
        this-object:lblPW:Size = new System.Drawing.Size(54, 14).
        this-object:lblPW:TabIndex = 5.
        this-object:lblPW:Text = "Password".
        /*  */
        /* uxPW */
        /*  */
        this-object:uxPW:Location = new System.Drawing.Point(75, 34).
        this-object:uxPW:Name = "uxPW".
        this-object:uxPW:Size = new System.Drawing.Size(203, 21).
        this-object:uxPW:TabIndex = 4.
        this-object:uxPW:Text = "ebms".
        /*  */
        /* lbluser */
        /*  */
        this-object:lbluser:AutoSize = true.
        this-object:lbluser:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lbluser:Location = new System.Drawing.Point(42, 11).
        this-object:lbluser:Name = "lbluser".
        this-object:lbluser:Size = new System.Drawing.Size(28, 14).
        this-object:lbluser:TabIndex = 3.
        this-object:lbluser:Text = "User".
        /*  */
        /* uxUser */
        /*  */
        this-object:uxUser:Location = new System.Drawing.Point(75, 7).
        this-object:uxUser:Name = "uxUser".
        this-object:uxUser:Size = new System.Drawing.Size(203, 21).
        this-object:uxUser:TabIndex = 2.
        this-object:uxUser:Text = "ebms".
        /*  */
        /* lblhost */
        /*  */
        this-object:lblhost:AutoSize = true.
        this-object:lblhost:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblhost:Location = new System.Drawing.Point(318, 11).
        this-object:lblhost:Name = "lblhost".
        this-object:lblhost:Size = new System.Drawing.Size(27, 14).
        this-object:lblhost:TabIndex = 1.
        this-object:lblhost:Text = "Host".
        /*  */
        /* uxHost */
        /*  */
        this-object:uxHost:Location = new System.Drawing.Point(351, 7).
        this-object:uxHost:Name = "uxHost".
        this-object:uxHost:Size = new System.Drawing.Size(203, 21).
        this-object:uxHost:TabIndex = 0.
        this-object:uxHost:Text = "http://172.16.114.240:18793".
        /*  */
        /* ultraPanel2 */
        /*  */
        this-object:ultraPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:ultraPanel2:Location = new System.Drawing.Point(0, 69).
        this-object:ultraPanel2:Name = "ultraPanel2".
        this-object:ultraPanel2:Size = new System.Drawing.Size(591, 371).
        this-object:ultraPanel2:TabIndex = 2.
        /*  */
        /* uxStatus */
        /*  */
        this-object:uxStatus:Location = new System.Drawing.Point(0, 440).
        this-object:uxStatus:Name = "uxStatus".
        ultraStatusPanel1:Enabled = false.
        ultraStatusPanel1:SizingMode = Infragistics.Win.UltraWinStatusBar.PanelSizingMode:Automatic.
        ultraStatusPanel1:Text = "Portal User:".
        ultraStatusPanel2:SizingMode = Infragistics.Win.UltraWinStatusBar.PanelSizingMode:Automatic.
        ultraStatusPanel2:Text = "<user name>".
        ultraStatusPanel3:Enabled = false.
        ultraStatusPanel3:SizingMode = Infragistics.Win.UltraWinStatusBar.PanelSizingMode:Automatic.
        ultraStatusPanel3:Text = "Session Id:".
        ultraStatusPanel4:SizingMode = Infragistics.Win.UltraWinStatusBar.PanelSizingMode:Spring.
        ultraStatusPanel4:Text = "<id>".
        ultraStatusPanel5:Enabled = false.
        ultraStatusPanel5:MinWidth = 5.
        ultraStatusPanel5:Style = Infragistics.Win.UltraWinStatusBar.PanelStyle:ControlContainer.
        ultraStatusPanel5:Width = 19.
        ultraStatusPanel6:Style = Infragistics.Win.UltraWinStatusBar.PanelStyle:Date.
        ultraStatusPanel7:SizingMode = Infragistics.Win.UltraWinStatusBar.PanelSizingMode:Automatic.
        ultraStatusPanel7:Style = Infragistics.Win.UltraWinStatusBar.PanelStyle:Time.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel extent 7 no-undo.
        arrayvar0[1] = ultraStatusPanel1.
        arrayvar0[2] = ultraStatusPanel2.
        arrayvar0[3] = ultraStatusPanel3.
        arrayvar0[4] = ultraStatusPanel4.
        arrayvar0[5] = ultraStatusPanel5.
        arrayvar0[6] = ultraStatusPanel6.
        arrayvar0[7] = ultraStatusPanel7.
        this-object:uxStatus:Panels:AddRange(arrayvar0).
        this-object:uxStatus:Size = new System.Drawing.Size(591, 23).
        this-object:uxStatus:TabIndex = 0.
        this-object:uxStatus:Text = "ultraStatusBar1".
        /*  */
        /* TaskListForm */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(591, 463).
        this-object:Controls:Add(this-object:ultraPanel2).
        this-object:Controls:Add(this-object:ultraPanel1).
        this-object:Controls:Add(this-object:uxStatus).
        this-object:Name = "TaskListForm".
        this-object:Text = "TaskListForm".
        this-object:ultraPanel1:ClientArea:ResumeLayout(false).
        this-object:ultraPanel1:ClientArea:PerformLayout().
        this-object:ultraPanel1:ResumeLayout(false).
        cast(this-object:uxPW, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxUser, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxHost, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ultraPanel2:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    destructor public TaskListForm ( ):

        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.

end class.
