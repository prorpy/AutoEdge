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
    File        : DealerLoginPanel
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Fri Jul 09 08:10:42 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw. 

using Progress.Windows.Form.
using Progress.Windows.UserControl.

using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.Core.System.UnhandledError.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Lang.ABLSession.
using Progress.Lang.Error.

class AutoEdge.Factory.Client.Common.PresentationLayer.DealerLoginPanel inherits UserControl: 
    
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable lblBrand as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblDepartment as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable ultraToolTipManager1 as Infragistics.Win.UltraWinToolTip.UltraToolTipManager no-undo.
    define private variable uxBrand as Infragistics.Win.UltraWinEditors.UltraComboEditor no-undo.
    define private variable uxDepartment as Infragistics.Win.UltraWinEditors.UltraComboEditor no-undo.
    define private variable uxInputPanel as Infragistics.Win.Misc.UltraPanel no-undo.
    define private variable uxUser as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxPassword as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxLogin as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxCancel as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable lblUser as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblPassword as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.

    define public property ServiceManager as IServiceManager no-undo
        get():
            if not valid-object(ServiceManager) then
                ServiceManager = cast(ABLSession:Instance:SessionProperties:Get(OpenEdge.CommonInfrastructure.Common.ServiceManager:IServiceManagerType), IServiceManager).
            return ServiceManager.
        end get.
        private set.
    
    constructor public DealerLoginPanel (  ):
        super().
        
        InitializeComponent().
        
        /* Sales */
        uxDepartment:SelectedIndex = 5.
        uxPassword:Text = 'letmein'.
        
        /* throws to wait-for */
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
        define variable appearance11 as Infragistics.Win.Appearance no-undo.
        appearance11 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance5 as Infragistics.Win.Appearance no-undo.
        appearance5 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance4 as Infragistics.Win.Appearance no-undo.
        appearance4 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem20 as Infragistics.Win.ValueListItem no-undo.
        valueListItem20 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem18 as Infragistics.Win.ValueListItem no-undo.
        valueListItem18 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem15 as Infragistics.Win.ValueListItem no-undo.
        valueListItem15 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem19 as Infragistics.Win.ValueListItem no-undo.
        valueListItem19 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem17 as Infragistics.Win.ValueListItem no-undo.
        valueListItem17 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem16 as Infragistics.Win.ValueListItem no-undo.
        valueListItem16 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance12 as Infragistics.Win.Appearance no-undo.
        appearance12 = new Infragistics.Win.Appearance().
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
        define variable valueListItem11 as Infragistics.Win.ValueListItem no-undo.
        valueListItem11 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem12 as Infragistics.Win.ValueListItem no-undo.
        valueListItem12 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem13 as Infragistics.Win.ValueListItem no-undo.
        valueListItem13 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable valueListItem14 as Infragistics.Win.ValueListItem no-undo.
        valueListItem14 = new Infragistics.Win.ValueListItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance1 as Infragistics.Win.Appearance no-undo.
        appearance1 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance6 as Infragistics.Win.Appearance no-undo.
        appearance6 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance2 as Infragistics.Win.Appearance no-undo.
        appearance2 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("AutoEdge.Factory.Client.Common.PresentationLayer.DealerLoginPanel").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance3 as Infragistics.Win.Appearance no-undo.
        appearance3 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance10 as Infragistics.Win.Appearance no-undo.
        appearance10 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraToolTipInfo1 as Infragistics.Win.UltraWinToolTip.UltraToolTipInfo no-undo.
        ultraToolTipInfo1 = new Infragistics.Win.UltraWinToolTip.UltraToolTipInfo("", Infragistics.Win.ToolTipImage:Info, "User Login Information", Infragistics.Win.DefaultableBoolean:Default).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance8 as Infragistics.Win.Appearance no-undo.
        appearance8 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraToolTipInfo2 as Infragistics.Win.UltraWinToolTip.UltraToolTipInfo no-undo.
        ultraToolTipInfo2 = new Infragistics.Win.UltraWinToolTip.UltraToolTipInfo("", Infragistics.Win.ToolTipImage:Info, "Password Hints", Infragistics.Win.DefaultableBoolean:Default).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance7 as Infragistics.Win.Appearance no-undo.
        appearance7 = new Infragistics.Win.Appearance().
        this-object:lblUser = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxInputPanel = new Infragistics.Win.Misc.UltraPanel().
        this-object:uxBrand = new Infragistics.Win.UltraWinEditors.UltraComboEditor().
        this-object:uxDepartment = new Infragistics.Win.UltraWinEditors.UltraComboEditor().
        this-object:lblDepartment = new Infragistics.Win.Misc.UltraLabel().
        this-object:lblBrand = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxLogin = new Infragistics.Win.Misc.UltraButton().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:uxCancel = new Infragistics.Win.Misc.UltraButton().
        this-object:uxUser = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:uxPassword = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblPassword = new Infragistics.Win.Misc.UltraLabel().
        this-object:ultraToolTipManager1 = new Infragistics.Win.UltraWinToolTip.UltraToolTipManager(this-object:components).
        this-object:uxInputPanel:ClientArea:SuspendLayout().
        this-object:uxInputPanel:SuspendLayout().
        cast(this-object:uxBrand, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxDepartment, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxUser, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxPassword, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* lblUser */
        /*  */
        appearance11:FontData:Name = "Segoe UI".
        appearance11:FontData:SizeInPoints = 12.
        appearance11:TextVAlignAsString = "Middle".
        this-object:lblUser:Appearance = appearance11.
        this-object:lblUser:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblUser:Location = new System.Drawing.Point(9, 54).
        this-object:lblUser:Name = "lblUser".
        this-object:lblUser:Size = new System.Drawing.Size(382, 31).
        this-object:lblUser:TabIndex = 0.
        this-object:lblUser:Text = "User Name".
        /*  */
        /* uxInputPanel */
        /*  */
        appearance5:BackColor = System.Drawing.Color:Silver.
        appearance5:BorderColor = System.Drawing.Color:Black.
        appearance5:ImageBackgroundStyle = Infragistics.Win.ImageBackgroundStyle:Stretched.
        this-object:uxInputPanel:Appearance = appearance5.
        this-object:uxInputPanel:AutoSize = true.
        /*  */
        /* uxInputPanel.ClientArea */
        /*  */
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxBrand).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxDepartment).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:lblDepartment).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:lblBrand).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxLogin).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxCancel).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxUser).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:lblUser).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:uxPassword).
        this-object:uxInputPanel:ClientArea:Controls:Add(this-object:lblPassword).
        this-object:uxInputPanel:Location = new System.Drawing.Point(0, 0).
        this-object:uxInputPanel:Name = "uxInputPanel".
        this-object:uxInputPanel:Size = new System.Drawing.Size(403, 235).
        this-object:uxInputPanel:TabIndex = 21.
        /*  */
        /* uxBrand */
        /*  */
        appearance4:FontData:Name = "Segoe UI".
        appearance4:FontData:SizeInPoints = 12.
        this-object:uxBrand:Appearance = appearance4.
        valueListItem20:DataValue = "chery".
        valueListItem20:DisplayText = "Chery".
        valueListItem18:DataValue = "fjord".
        valueListItem18:DisplayText = "Fjord".
        valueListItem15:DataValue = "hinda".
        valueListItem15:DisplayText = "Hinda".
        valueListItem19:DataValue = "potomoc".
        valueListItem19:DisplayText = "Potomoc".
        valueListItem17:DataValue = "scubaroo".
        valueListItem17:DisplayText = "Scubaroo".
        valueListItem16:DataValue = "toyola".
        valueListItem16:DisplayText = "Toyola".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as Infragistics.Win.ValueListItem extent 6 no-undo.
        arrayvar0[1] = valueListItem20.
        arrayvar0[2] = valueListItem18.
        arrayvar0[3] = valueListItem15.
        arrayvar0[4] = valueListItem19.
        arrayvar0[5] = valueListItem17.
        arrayvar0[6] = valueListItem16.
        this-object:uxBrand:Items:AddRange(arrayvar0).
        this-object:uxBrand:Location = new System.Drawing.Point(151, 17).
        this-object:uxBrand:Name = "uxBrand".
        this-object:uxBrand:Size = new System.Drawing.Size(242, 31).
        this-object:uxBrand:SortStyle = Infragistics.Win.ValueListSortStyle:Ascending.
        this-object:uxBrand:TabIndex = 10.
        /*  */
        /* uxDepartment */
        /*  */
        appearance12:FontData:Name = "Segoe UI".
        appearance12:FontData:SizeInPoints = 12.
        this-object:uxDepartment:Appearance = appearance12.
        valueListItem1:DataValue = "admin".
        valueListItem1:DisplayText = "Administration".
        valueListItem2:DataValue = "factory".
        valueListItem2:DisplayText = "Factory / Manufacturing".
        valueListItem3:DataValue = "field".
        valueListItem3:DisplayText = "Field".
        valueListItem11:DataValue = "finance".
        valueListItem11:DisplayText = "Finance".
        valueListItem12:DataValue = "hr".
        valueListItem12:DisplayText = "Human Resources".
        valueListItem13:DataValue = "sales".
        valueListItem13:DisplayText = "Sales".
        valueListItem14:DataValue = "support".
        valueListItem14:DisplayText = "Support".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Infragistics.Win.ValueListItem extent 7 no-undo.
        arrayvar1[1] = valueListItem1.
        arrayvar1[2] = valueListItem2.
        arrayvar1[3] = valueListItem3.
        arrayvar1[4] = valueListItem11.
        arrayvar1[5] = valueListItem12.
        arrayvar1[6] = valueListItem13.
        arrayvar1[7] = valueListItem14.
        this-object:uxDepartment:Items:AddRange(arrayvar1).
        this-object:uxDepartment:Location = new System.Drawing.Point(151, 91).
        this-object:uxDepartment:Name = "uxDepartment".
        this-object:uxDepartment:Size = new System.Drawing.Size(242, 31).
        this-object:uxDepartment:SortStyle = Infragistics.Win.ValueListSortStyle:Ascending.
        this-object:uxDepartment:TabIndex = 30.
        /*  */
        /* lblDepartment */
        /*  */
        appearance1:FontData:Name = "Segoe UI".
        appearance1:FontData:SizeInPoints = 12.
        appearance1:TextVAlignAsString = "Middle".
        this-object:lblDepartment:Appearance = appearance1.
        this-object:lblDepartment:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblDepartment:Location = new System.Drawing.Point(9, 91).
        this-object:lblDepartment:Name = "lblDepartment".
        this-object:lblDepartment:Size = new System.Drawing.Size(382, 31).
        this-object:lblDepartment:TabIndex = 0.
        this-object:lblDepartment:Text = "Department".
        /*  */
        /* lblBrand */
        /*  */
        appearance6:FontData:Name = "Segoe UI".
        appearance6:FontData:SizeInPoints = 12.
        appearance6:TextVAlignAsString = "Middle".
        this-object:lblBrand:Appearance = appearance6.
        this-object:lblBrand:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblBrand:Location = new System.Drawing.Point(11, 18).
        this-object:lblBrand:Name = "lblBrand".
        this-object:lblBrand:Size = new System.Drawing.Size(382, 31).
        this-object:lblBrand:TabIndex = 0.
        this-object:lblBrand:Text = "Brand".
        /*  */
        /* uxLogin */
        /*  */
        appearance2:FontData:Name = "Segoe UI".
        appearance2:FontData:SizeInPoints = 12.
        appearance2:Image = "Knob Valid Green.png".
        this-object:uxLogin:Appearance = appearance2.
        this-object:uxLogin:DialogResult = System.Windows.Forms.DialogResult:OK.
        this-object:uxLogin:ImageList = this-object:imageList1.
        this-object:uxLogin:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxLogin:Location = new System.Drawing.Point(148, 180).
        this-object:uxLogin:Name = "uxLogin".
        this-object:uxLogin:Size = new System.Drawing.Size(120, 40).
        this-object:uxLogin:TabIndex = 50.
        this-object:uxLogin:Text = "Login".
        this-object:uxLogin:Click:Subscribe(this-object:uxLogin_Click).
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
        appearance3:FontData:Name = "Segoe UI".
        appearance3:FontData:SizeInPoints = 12.
        appearance3:Image = "Knob Snapback.png".
        this-object:uxCancel:Appearance = appearance3.
        this-object:uxCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        this-object:uxCancel:ImageList = this-object:imageList1.
        this-object:uxCancel:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxCancel:Location = new System.Drawing.Point(273, 181).
        this-object:uxCancel:Name = "uxCancel".
        this-object:uxCancel:Size = new System.Drawing.Size(120, 40).
        this-object:uxCancel:TabIndex = 60.
        this-object:uxCancel:Text = "Cancel".
        this-object:uxCancel:Click:Subscribe(this-object:uxCancel_Click).
        /*  */
        /* uxUser */
        /*  */
        appearance10:FontData:Name = "Segoe UI".
        appearance10:FontData:SizeInPoints = 12.
        this-object:uxUser:Appearance = appearance10.
        this-object:uxUser:Location = new System.Drawing.Point(151, 54).
        this-object:uxUser:Name = "uxUser".
        this-object:uxUser:Size = new System.Drawing.Size(242, 31).
        this-object:uxUser:TabIndex = 20.
        ultraToolTipInfo1:ToolTipImage = Infragistics.Win.ToolTipImage:Info.
        ultraToolTipInfo1:ToolTipTextFormatted = resources:GetString("ultraToolTipInfo1.ToolTipTextFormatted").
        ultraToolTipInfo1:ToolTipTextStyle = Infragistics.Win.ToolTipTextStyle:Formatted.
        ultraToolTipInfo1:ToolTipTitle = "User Login Information".
        this-object:ultraToolTipManager1:SetUltraToolTip(this-object:uxUser, ultraToolTipInfo1).
        /*  */
        /* uxPassword */
        /*  */
        appearance8:FontData:Name = "Segoe UI".
        appearance8:FontData:SizeInPoints = 12.
        this-object:uxPassword:Appearance = appearance8.
        this-object:uxPassword:Location = new System.Drawing.Point(151, 126).
        this-object:uxPassword:Name = "uxPassword".
        this-object:uxPassword:PasswordChar = '*'.
        this-object:uxPassword:Size = new System.Drawing.Size(242, 31).
        this-object:uxPassword:TabIndex = 40.
        ultraToolTipInfo2:ToolTipImage = Infragistics.Win.ToolTipImage:Info.
        ultraToolTipInfo2:ToolTipTextFormatted = "<span style=~"font-style:italic;~">letmein </span>&edsp;is a good guess for users.".
        ultraToolTipInfo2:ToolTipTextStyle = Infragistics.Win.ToolTipTextStyle:Formatted.
        ultraToolTipInfo2:ToolTipTitle = "Password Hints".
        this-object:ultraToolTipManager1:SetUltraToolTip(this-object:uxPassword, ultraToolTipInfo2).
        /*  */
        /* lblPassword */
        /*  */
        appearance7:FontData:Name = "Segoe UI".
        appearance7:FontData:SizeInPoints = 12.
        appearance7:TextVAlignAsString = "Middle".
        this-object:lblPassword:Appearance = appearance7.
        this-object:lblPassword:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblPassword:Location = new System.Drawing.Point(9, 126).
        this-object:lblPassword:Name = "lblPassword".
        this-object:lblPassword:Size = new System.Drawing.Size(382, 31).
        this-object:lblPassword:TabIndex = 0.
        this-object:lblPassword:Text = "Password".
        /*  */
        /* ultraToolTipManager1 */
        /*  */
        this-object:ultraToolTipManager1:ContainingControl = this-object.
        /*  */
        /* DealerLoginPanel */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(6, 13).
        this-object:AutoSize = true.
        this-object:AutoSizeMode = System.Windows.Forms.AutoSizeMode:GrowAndShrink.
        this-object:BackColor = System.Drawing.Color:Transparent.
        this-object:Controls:Add(this-object:uxInputPanel).
        this-object:Name = "DealerLoginPanel".
        this-object:Size = new System.Drawing.Size(406, 238).
        this-object:uxInputPanel:ClientArea:ResumeLayout(false).
        this-object:uxInputPanel:ClientArea:PerformLayout().
        this-object:uxInputPanel:ResumeLayout(false).
        this-object:uxInputPanel:PerformLayout().
        cast(this-object:uxBrand, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxDepartment, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxUser, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxPassword, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.


    method override protected void OnLoad(input e as System.EventArgs ):
        super:OnLoad(input e).
        
        this-object:ActiveControl = uxBrand.
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
    
    method private void uxLogin_Click( input sender as System.Object, input e as System.EventArgs ):
        define variable oSecMgr as ISecurityManager no-undo.
        define variable cDomain as character no-undo.
        
        oSecMgr = cast(ServiceManager:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).
        
        cDomain = substitute('&1.employee.&2',
                              uxDepartment:Value:ToString(),
                              uxBrand:Value:ToString()).
        session:set-wait-state('general').
        
        oSecMgr:UserLogin(uxUser:Text, cDomain, uxPassword:Text).
        
        /* do this here in case of error */
        cast(this-object:Parent, Form):Close().
        
        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
        finally:
            session:set-wait-state('').
        end finally.
    end method.

    destructor public DealerLoginPanel ( ):
        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.

end class.
