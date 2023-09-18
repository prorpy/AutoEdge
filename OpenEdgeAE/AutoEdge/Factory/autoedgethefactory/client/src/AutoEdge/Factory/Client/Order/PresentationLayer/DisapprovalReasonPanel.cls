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
    File        : DisapprovalReasonPanel
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Jul 12 11:31:18 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.UnhandledError.

using Progress.Windows.Form.
using Progress.Windows.UserControl.
using Progress.Lang.Error.

class AutoEdge.Factory.Client.Order.PresentationLayer.DisapprovalReasonPanel inherits UserControl: 
	
	define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable lblReason as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.
    define private variable uxDetail as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxOK as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxInputPanel as Infragistics.Win.Misc.UltraPanel no-undo.
    define private variable uxCancel as Infragistics.Win.Misc.UltraButton no-undo.

    define private variable moParentForm as AutoEdge.Factory.Client.Order.PresentationLayer.CustomerOrderDetail no-undo.
    
    constructor public DisapprovalReasonPanel(poParent as AutoEdge.Factory.Client.Order.PresentationLayer.CustomerOrderDetail):
        this-object().
        moParentForm = poParent.
    end constructor.
    
	constructor public DisapprovalReasonPanel (  ):
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
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance1 as Infragistics.Win.Appearance no-undo.
        appearance1 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance2 as Infragistics.Win.Appearance no-undo.
        appearance2 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("AutoEdge.Factory.Client.Order.PresentationLayer.DisapprovalReasonPanel").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance3 as Infragistics.Win.Appearance no-undo.
        appearance3 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance7 as Infragistics.Win.Appearance no-undo.
        appearance7 = new Infragistics.Win.Appearance().
        this-object:uxInputPanel = new Infragistics.Win.Misc.UltraPanel().
        this-object:uxOK = new Infragistics.Win.Misc.UltraButton().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:uxCancel = new Infragistics.Win.Misc.UltraButton().
        this-object:lblReason = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxDetail = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:uxInputPanel:ClientArea:SuspendLayout().
        this-object:uxInputPanel:SuspendLayout().
        cast(this-object:uxDetail, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* uxInputPanel */
        /*  */
        appearance1:BackColor = System.Drawing.Color:NavajoWhite.
        this-object:uxInputPanel:Appearance = appearance1.
        this-object:uxInputPanel:BorderStyle = Infragistics.Win.UIElementBorderStyle:Rounded3.
        /*  */
        /* uxInputPanel.ClientArea */
        /*  */
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxOK).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxCancel).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:lblReason).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxDetail).
        this-object:uxInputPanel:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uxInputPanel:Location = new System.Drawing.Point(0, 0).
        this-object:uxInputPanel:Name = "uxInputPanel".
        this-object:uxInputPanel:Size = new System.Drawing.Size(427, 228).
        this-object:uxInputPanel:TabIndex = 0.
        /*  */
        /* uxOK */
        /*  */
        appearance2:FontData:BoldAsString = "True".
        appearance2:FontData:Name = "Segoe UI".
        appearance2:FontData:SizeInPoints = 12.
        appearance2:Image = "Knob Valid Green.png".
        this-object:uxOK:Appearance = appearance2.
        this-object:uxOK:DialogResult = System.Windows.Forms.DialogResult:OK.
        this-object:uxOK:ImageList = this-object:imageList1.
        this-object:uxOK:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxOK:Location = new System.Drawing.Point(166, 178).
        this-object:uxOK:Name = "uxOK".
        this-object:uxOK:Size = new System.Drawing.Size(120, 40).
        this-object:uxOK:TabIndex = 51.
        this-object:uxOK:Text = "OK".
        this-object:uxOK:Click:Subscribe(this-object:uxOK_Click).
        /*  */
        /* imageList1 */
        /*  */
        this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageList1:Images:SetKeyName(0, "Knob Valid Green.png").
        this-object:imageList1:Images:SetKeyName(1, "Knob Snapback.png").
        this-object:imageList1:Images:SetKeyName(2, "portal_silver_icon.png").
        this-object:imageList1:Images:SetKeyName(3, "portal_silver.png").
        this-object:imageList1:Images:SetKeyName(4, "").
        /*  */
        /* uxCancel */
        /*  */
        appearance3:FontData:BoldAsString = "True".
        appearance3:FontData:Name = "Segoe UI".
        appearance3:FontData:SizeInPoints = 12.
        appearance3:Image = "Knob Snapback.png".
        this-object:uxCancel:Appearance = appearance3.
        this-object:uxCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        this-object:uxCancel:ImageList = this-object:imageList1.
        this-object:uxCancel:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxCancel:Location = new System.Drawing.Point(292, 178).
        this-object:uxCancel:Name = "uxCancel".
        this-object:uxCancel:Size = new System.Drawing.Size(120, 40).
        this-object:uxCancel:TabIndex = 52.
        this-object:uxCancel:Text = "Cancel".
        this-object:uxCancel:Click:Subscribe(this-object:uxCancel_Click).
        /*  */
        /* lblReason */
        /*  */
        appearance7:FontData:BoldAsString = "True".
        appearance7:FontData:Name = "Segoe UI".
        appearance7:FontData:SizeInPoints = 12.
        this-object:lblReason:Appearance = appearance7.
        this-object:lblReason:AutoSize = true.
        this-object:lblReason:Enabled = false.
        this-object:lblReason:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblReason:Location = new System.Drawing.Point(22, 19).
        this-object:lblReason:Name = "lblReason".
        this-object:lblReason:Size = new System.Drawing.Size(159, 24).
        this-object:lblReason:TabIndex = 18.
        this-object:lblReason:Text = "Disapproval Reason".
        /*  */
        /* uxDetail */
        /*  */
        this-object:uxDetail:Location = new System.Drawing.Point(14, 49).
        this-object:uxDetail:Multiline = true.
        this-object:uxDetail:Name = "uxDetail".
        this-object:uxDetail:Scrollbars = System.Windows.Forms.ScrollBars:Both.
        this-object:uxDetail:ShowOverflowIndicator = true.
        this-object:uxDetail:Size = new System.Drawing.Size(398, 121).
        this-object:uxDetail:TabIndex = 0.
        /*  */
        /* DisapprovalReasonPanel */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(6, 13).
        this-object:Controls:Add(this-object:uxInputPanel).
        this-object:Name = "DisapprovalReasonPanel".
        this-object:Size = new System.Drawing.Size(427, 228).
        this-object:uxInputPanel:ClientArea:ResumeLayout(false).
        this-object:uxInputPanel:ClientArea:PerformLayout().
        this-object:uxInputPanel:ResumeLayout(false).
        cast(this-object:uxDetail, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
	end method.

	method private void uxCancel_Click( input sender as System.Object, input e as System.EventArgs ):
        cast(this-object:Parent, Form):Close().

        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
	end method.
	
	method private void uxOK_Click(input sender as System.Object, input e as System.EventArgs ):
	    if uxDetail:TextLength eq 0 then
            message
                'Please specify a rejection reason.'
            view-as alert-box error title 'AutoEdge|TheFactory Error'.
        else
            moParentForm:DisapproveOrder(uxDetail:Text).
            
        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
	end method.
	
	destructor public DisapprovalReasonPanel ( ):
		if valid-object(components) then do:
			cast(components, System.IDisposable):Dispose().
		end.
	end destructor.

end class.
