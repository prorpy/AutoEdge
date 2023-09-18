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
/** ------------------------------------------------------------------------
    File        : DealerReview
    Purpose     :
    Syntax      :
    Description :
    @author pjudge
    Created     : Wed Jul 07 11:55:28 EDT 2010
    Notes       :
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarGroup.
using Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarItem.
using Infragistics.Win.Appearance.
using Infragistics.Win.UltraWinToolbars.ToolBase.
using Infragistics.Win.UltraWinToolbars.ButtonTool.
using System.Windows.Forms.DialogResult.
using System.Drawing.Point.
using System.Windows.Forms.FormClosedEventArgs.

using AutoEdge.Factory.Client.Order.PresentationLayer.HelpAbout.
using AutoEdge.Factory.Client.Common.PresentationLayer.DealerLoginPanel.
using AutoEdge.Factory.Client.Common.PresentationLayer.LightboxForm.
using AutoEdge.Factory.Client.Order.PresentationLayer.CustomerOrderDetail.
using AutoEdge.Factory.Client.Order.PresentationLayer.TaskDetailForm.
using AutoEdge.Factory.Client.Order.PresentationLayer.OrderListForm.
using AutoEdge.Factory.Client.Common.PresentationLayer.CreateProcessInstance.
using OpenEdge.PresentationLayer.View.GuiForDotNet.TagWrapper.

using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.BpmServerConnection.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.

using OpenEdge.CommonInfrastructure.Client.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.CommonInfrastructure.Common.IApplicationStart.

using OpenEdge.Core.System.UnhandledError.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.XML.WebServiceInvocationError.
using OpenEdge.Lang.BPM.Task.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.WorkItemStatusEnum.
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.BPM.ProcessTemplate.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.

using Progress.Windows.Form.
using Progress.Lang.AppError.
using Progress.Lang.Error.
using Progress.Lang.Class.
using Progress.Lang.Object.

class AutoEdge.Factory.Client.Order.PresentationLayer.DealerReview inherits Form
        implements IApplicationStart:

    define private variable imageListSmall as System.Windows.Forms.ImageList no-undo.
    define private variable imageListLarge as System.Windows.Forms.ImageList no-undo.
    define private variable m_DealerReview_Toolbars_Dock_Area_Top as Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea no-undo.
    define private variable m_DealerReview_Toolbars_Dock_Area_Right as Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea no-undo.
    define private variable m_DealerReview_Toolbars_Dock_Area_Left as Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea no-undo.
    define private variable m_DealerReview_Toolbars_Dock_Area_Bottom as Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable splitter1 as System.Windows.Forms.Splitter no-undo.
    define private variable ultraTabbedMdiManager1 as Infragistics.Win.UltraWinTabbedMdi.UltraTabbedMdiManager no-undo.
    define private variable ultraToolbarsManager1 as Infragistics.Win.UltraWinToolbars.UltraToolbarsManager no-undo.

    define private variable uxAccordion as Infragistics.Win.UltraWinExplorerBar.UltraExplorerBar no-undo.
    define private variable uxStatus as Infragistics.Win.UltraWinStatusBar.UltraStatusBar no-undo.

    define public property ServiceManager as IServiceManager no-undo
        get():
            if not valid-object(ServiceManager) then
                ServiceManager = cast(ABLSession:Instance:SessionProperties:Get(OpenEdge.CommonInfrastructure.Common.ServiceManager:IServiceManagerType), IServiceManager).
            return ServiceManager.
        end get.
        private set.

    define protected property SecMgr as ISecurityManager no-undo
        get():
            if not valid-object(SecMgr) then
                SecMgr = cast(ServiceManager:GetService(SecurityManager:ISecurityManagerType), ISecurityManager).
            return SecMgr.
        end get.
        private set.

    define protected property ConMgr as IConnectionManager no-undo
        get():
            if not valid-object(ConMgr) then
                ConMgr = cast(ServiceManager:GetService(ConnectionManager:IConnectionManagerType), IConnectionManager).
            return ConMgr.
        end get.
        private set.

    define protected property BizLogicService as IBizLogicAPI no-undo
        get():
            define variable oServerConnection as IServerConnection no-undo.
            if not valid-object(BizLogicService) then
            do:
                oServerConnection = ConMgr:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
                if valid-object(oServerConnection) then
                do:
                    if not oServerConnection:IsConnected then
                        oServerConnection:Connect().
                    BizLogicService = cast(oServerConnection:Server, IBizLogicAPI).
                end.
            end.
            return BizLogicService.
        end get.
        set.

    constructor public DealerReview (  ):
        super().

        InitializeComponent().
        InitUI().

        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end constructor.

    method protected void InitUI():
        define variable cTool as character extent no-undo.

        uxAccordion:Groups:Item["Orders"]:Enabled = false.
        uxAccordion:Groups:Item["AllTasks"]:Enabled = false.

        extent(cTool) = ?.
        extent(cTool) = 1.
        cTool[1] = 'DealerLogin'.
        SetToolState(cTool, true).

        extent(cTool) = ?.
        extent(cTool) = 2.
        cTool[1] = 'DealerLogout'.
        cTool[2] = 'RefreshTasksList'.
        SetToolState(cTool, false).
    end method.

    method private void InitializeComponent(  ):

        /* NOTE: The following method is automatically generated.

        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.

        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraToolbar1 as Infragistics.Win.UltraWinToolbars.UltraToolbar no-undo.
        ultraToolbar1 = new Infragistics.Win.UltraWinToolbars.UltraToolbar("UltraToolbar1").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool8 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool8 = new Infragistics.Win.UltraWinToolbars.ButtonTool("DealerLogin").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool15 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool15 = new Infragistics.Win.UltraWinToolbars.ButtonTool("DealerLogout").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool4 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool4 = new Infragistics.Win.UltraWinToolbars.ButtonTool("RefreshTasksList").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool16 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool16 = new Infragistics.Win.UltraWinToolbars.ButtonTool("Help").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool2 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool2 = new Infragistics.Win.UltraWinToolbars.ButtonTool("Help").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance11 as Infragistics.Win.Appearance no-undo.
        appearance11 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool3 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool3 = new Infragistics.Win.UltraWinToolbars.ButtonTool("RefreshTasksList").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance17 as Infragistics.Win.Appearance no-undo.
        appearance17 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance18 as Infragistics.Win.Appearance no-undo.
        appearance18 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool11 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool11 = new Infragistics.Win.UltraWinToolbars.ButtonTool("DealerLogin").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance26 as Infragistics.Win.Appearance no-undo.
        appearance26 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance25 as Infragistics.Win.Appearance no-undo.
        appearance25 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable buttonTool13 as Infragistics.Win.UltraWinToolbars.ButtonTool no-undo.
        buttonTool13 = new Infragistics.Win.UltraWinToolbars.ButtonTool("DealerLogout").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("AutoEdge.Factory.Client.Order.PresentationLayer.DealerReview").
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
        define variable appearance1 as Infragistics.Win.Appearance no-undo.
        appearance1 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraExplorerBarGroup1 as Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarGroup no-undo.
        ultraExplorerBarGroup1 = new Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarGroup().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraExplorerBarGroup4 as Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarGroup no-undo.
        ultraExplorerBarGroup4 = new Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarGroup().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraExplorerBarItem1 as Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarItem no-undo.
        ultraExplorerBarItem1 = new Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarItem().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance23 as Infragistics.Win.Appearance no-undo.
        appearance23 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance24 as Infragistics.Win.Appearance no-undo.
        appearance24 = new Infragistics.Win.Appearance().
        this-object:ultraToolbarsManager1 = new Infragistics.Win.UltraWinToolbars.UltraToolbarsManager(this-object:components).
        this-object:imageListLarge = new System.Windows.Forms.ImageList(this-object:components).
        this-object:imageListSmall = new System.Windows.Forms.ImageList(this-object:components).
        this-object:uxStatus = new Infragistics.Win.UltraWinStatusBar.UltraStatusBar().
        this-object:m_DealerReview_Toolbars_Dock_Area_Left = new Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea().
        this-object:m_DealerReview_Toolbars_Dock_Area_Right = new Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea().
        this-object:m_DealerReview_Toolbars_Dock_Area_Top = new Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea().
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom = new Infragistics.Win.UltraWinToolbars.UltraToolbarsDockArea().
        this-object:ultraTabbedMdiManager1 = new Infragistics.Win.UltraWinTabbedMdi.UltraTabbedMdiManager(this-object:components).
        this-object:uxAccordion = new Infragistics.Win.UltraWinExplorerBar.UltraExplorerBar().
        this-object:splitter1 = new System.Windows.Forms.Splitter().
        cast(this-object:ultraToolbarsManager1, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:ultraTabbedMdiManager1, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxAccordion, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* ultraToolbarsManager1 */
        /*  */
        this-object:ultraToolbarsManager1:AlwaysShowMenusExpanded = Infragistics.Win.DefaultableBoolean:True.
        this-object:ultraToolbarsManager1:DesignerFlags = 1.
        this-object:ultraToolbarsManager1:DockWithinContainer = this-object.
        this-object:ultraToolbarsManager1:DockWithinContainerBaseType = Progress.Util.TypeHelper:GetType("Progress.Windows.Form").
        this-object:ultraToolbarsManager1:ImageListLarge = this-object:imageListLarge.
        this-object:ultraToolbarsManager1:ImageListSmall = this-object:imageListSmall.
        this-object:ultraToolbarsManager1:ImageSizeLarge = new System.Drawing.Size(24, 24).
        this-object:ultraToolbarsManager1:ShowFullMenusDelay = 500.
        ultraToolbar1:DockedColumn = 0.
        ultraToolbar1:DockedRow = 0.
        buttonTool4:InstanceProps:IsFirstInGroup = true.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as Infragistics.Win.UltraWinToolbars.ToolBase extent 4 no-undo.
        arrayvar0[1] = buttonTool8.
        arrayvar0[2] = buttonTool15.
        arrayvar0[3] = buttonTool4.
        arrayvar0[4] = buttonTool16.
        ultraToolbar1:NonInheritedTools:AddRange(arrayvar0).
        ultraToolbar1:Settings:AllowCustomize = Infragistics.Win.DefaultableBoolean:False.
        ultraToolbar1:Settings:AllowFloating = Infragistics.Win.DefaultableBoolean:False.
        ultraToolbar1:Settings:FillEntireRow = Infragistics.Win.DefaultableBoolean:True.
        ultraToolbar1:Settings:ToolDisplayStyle = Infragistics.Win.UltraWinToolbars.ToolDisplayStyle:ImageAndText.
        ultraToolbar1:Text = "UltraToolbar1".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Infragistics.Win.UltraWinToolbars.UltraToolbar extent 1 no-undo.
        arrayvar1[1] = ultraToolbar1.
        this-object:ultraToolbarsManager1:Toolbars:AddRange(arrayvar1).
        this-object:ultraToolbarsManager1:ToolbarSettings:UseLargeImages = Infragistics.Win.DefaultableBoolean:True.
        appearance11:Image = 8.
        buttonTool2:SharedPropsInternal:AppearancesSmall:Appearance = appearance11.
        buttonTool2:SharedPropsInternal:Caption = "Help".
        buttonTool2:SharedPropsInternal:DisplayStyle = Infragistics.Win.UltraWinToolbars.ToolDisplayStyle:ImageAndText.
        appearance17:Image = 4.
        buttonTool3:SharedPropsInternal:AppearancesLarge:Appearance = appearance17.
        appearance18:Image = 3.
        buttonTool3:SharedPropsInternal:AppearancesSmall:Appearance = appearance18.
        buttonTool3:SharedPropsInternal:Caption = "Refresh Tasks".
        appearance26:Image = cast(resources:GetObject("appearance26.Image"), System.Object).
        buttonTool11:SharedPropsInternal:AppearancesLarge:Appearance = appearance26.
        appearance25:Image = cast(resources:GetObject("appearance25.Image"), System.Object).
        buttonTool11:SharedPropsInternal:AppearancesSmall:Appearance = appearance25.
        buttonTool11:SharedPropsInternal:Caption = "Login".
        buttonTool13:SharedPropsInternal:Caption = "Logout".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as Infragistics.Win.UltraWinToolbars.ToolBase extent 4 no-undo.
        arrayvar2[1] = buttonTool2.
        arrayvar2[2] = buttonTool3.
        arrayvar2[3] = buttonTool11.
        arrayvar2[4] = buttonTool13.
        this-object:ultraToolbarsManager1:Tools:AddRange(arrayvar2).
        this-object:ultraToolbarsManager1:ToolClick:Subscribe(this-object:ultraToolbarsManager1_ToolClick).
        /*  */
        /* imageListLarge */
        /*  */
        this-object:imageListLarge:ImageStream = cast(resources:GetObject("imageListLarge.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageListLarge:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageListLarge:Images:SetKeyName(0, "date_error_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(1, "date_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(2, "system_emblem_32x29.png").
        this-object:imageListLarge:Images:SetKeyName(3, "cog_go32x32.png").
        this-object:imageListLarge:Images:SetKeyName(4, "date_go_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(5, "connect_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(6, "disconnect_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(7, "server_connect_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(8, "help_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(9, "exclamation_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(10, "basket_go_32x32.png").
        this-object:imageListLarge:Images:SetKeyName(11, "basket_32x32.png").
        /*  */
        /* imageListSmall */
        /*  */
        this-object:imageListSmall:ImageStream = cast(resources:GetObject("imageListSmall.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageListSmall:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageListSmall:Images:SetKeyName(0, "date_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(1, "date_error_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(2, "system_emblem_16x15.png").
        this-object:imageListSmall:Images:SetKeyName(3, "date_go_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(4, "cog_go_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(5, "server_connect_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(6, "connect_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(7, "disconnect_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(8, "help_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(9, "exclamation_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(10, "basket_go_16x16.png").
        this-object:imageListSmall:Images:SetKeyName(11, "basket_16x16.png").
        /*  */
        /* uxStatus */
        /*  */
        this-object:uxStatus:Location = new System.Drawing.Point(0, 530).
        this-object:uxStatus:Name = "uxStatus".
        ultraStatusPanel1:SizingMode = Infragistics.Win.UltraWinStatusBar.PanelSizingMode:Spring.
        ultraStatusPanel2:Style = Infragistics.Win.UltraWinStatusBar.PanelStyle:Date.
        ultraStatusPanel3:SizingMode = Infragistics.Win.UltraWinStatusBar.PanelSizingMode:Automatic.
        ultraStatusPanel3:Style = Infragistics.Win.UltraWinStatusBar.PanelStyle:Time.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar3 as Infragistics.Win.UltraWinStatusBar.UltraStatusPanel extent 3 no-undo.
        arrayvar3[1] = ultraStatusPanel1.
        arrayvar3[2] = ultraStatusPanel2.
        arrayvar3[3] = ultraStatusPanel3.
        this-object:uxStatus:Panels:AddRange(arrayvar3).
        this-object:uxStatus:Size = new System.Drawing.Size(974, 23).
        this-object:uxStatus:TabIndex = 0.
        this-object:uxStatus:Text = "ultraStatusBar1".
        /*  */
        /* m_DealerReview_Toolbars_Dock_Area_Left */
        /*  */
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:AccessibleRole = System.Windows.Forms.AccessibleRole:Grouping.
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:BackColor = System.Drawing.SystemColors:Control.
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:DockedPosition = Infragistics.Win.UltraWinToolbars.DockedPosition:Left.
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:ForeColor = System.Drawing.SystemColors:ControlText.
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:Location = new System.Drawing.Point(0, 60).
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:Name = "m_DealerReview_Toolbars_Dock_Area_Left".
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:Size = new System.Drawing.Size(0, 470).
        this-object:m_DealerReview_Toolbars_Dock_Area_Left:ToolbarsManager = this-object:ultraToolbarsManager1.
        /*  */
        /* m_DealerReview_Toolbars_Dock_Area_Right */
        /*  */
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:AccessibleRole = System.Windows.Forms.AccessibleRole:Grouping.
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:BackColor = System.Drawing.SystemColors:Control.
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:DockedPosition = Infragistics.Win.UltraWinToolbars.DockedPosition:Right.
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:ForeColor = System.Drawing.SystemColors:ControlText.
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:Location = new System.Drawing.Point(974, 60).
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:Name = "m_DealerReview_Toolbars_Dock_Area_Right".
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:Size = new System.Drawing.Size(0, 470).
        this-object:m_DealerReview_Toolbars_Dock_Area_Right:ToolbarsManager = this-object:ultraToolbarsManager1.
        /*  */
        /* m_DealerReview_Toolbars_Dock_Area_Top */
        /*  */
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:AccessibleRole = System.Windows.Forms.AccessibleRole:Grouping.
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:BackColor = System.Drawing.SystemColors:Control.
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:DockedPosition = Infragistics.Win.UltraWinToolbars.DockedPosition:Top.
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:ForeColor = System.Drawing.SystemColors:ControlText.
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:Location = new System.Drawing.Point(0, 0).
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:Name = "m_DealerReview_Toolbars_Dock_Area_Top".
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:Size = new System.Drawing.Size(974, 60).
        this-object:m_DealerReview_Toolbars_Dock_Area_Top:ToolbarsManager = this-object:ultraToolbarsManager1.
        /*  */
        /* m_DealerReview_Toolbars_Dock_Area_Bottom */
        /*  */
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:AccessibleRole = System.Windows.Forms.AccessibleRole:Grouping.
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:BackColor = System.Drawing.SystemColors:Control.
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:DockedPosition = Infragistics.Win.UltraWinToolbars.DockedPosition:Bottom.
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:ForeColor = System.Drawing.SystemColors:ControlText.
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:Location = new System.Drawing.Point(0, 530).
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:Name = "m_DealerReview_Toolbars_Dock_Area_Bottom".
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:Size = new System.Drawing.Size(974, 0).
        this-object:m_DealerReview_Toolbars_Dock_Area_Bottom:ToolbarsManager = this-object:ultraToolbarsManager1.
        /*  */
        /* ultraTabbedMdiManager1 */
        /*  */
        this-object:ultraTabbedMdiManager1:AllowMaximize = true.
        this-object:ultraTabbedMdiManager1:MdiParent = this-object.
        /*  */
        /* uxAccordion */
        /*  */
        appearance1:FontData:Name = "Segoe UI".
        appearance1:FontData:SizeInPoints = 12.
        this-object:uxAccordion:Appearance = appearance1.
        this-object:uxAccordion:Dock = System.Windows.Forms.DockStyle:Left.
        ultraExplorerBarGroup1:Key = "AllTasks".
        ultraExplorerBarGroup1:Text = "Orders For Review".
        ultraExplorerBarItem1:Key = "ListOrders".
        appearance23:Image = "basket_32x32.png".
        ultraExplorerBarItem1:Settings:AppearancesLarge:Appearance = appearance23.
        appearance24:Image = "basket_16x16.png".
        ultraExplorerBarItem1:Settings:AppearancesSmall:Appearance = appearance24.
        ultraExplorerBarItem1:Text = "Show Orders".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar4 as Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarItem extent 1 no-undo.
        arrayvar4[1] = ultraExplorerBarItem1.
        ultraExplorerBarGroup4:Items:AddRange(arrayvar4).
        ultraExplorerBarGroup4:Key = "Orders".
        ultraExplorerBarGroup4:Text = "Orders".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar5 as Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarGroup extent 2 no-undo.
        arrayvar5[1] = ultraExplorerBarGroup1.
        arrayvar5[2] = ultraExplorerBarGroup4.
        this-object:uxAccordion:Groups:AddRange(arrayvar5).
        this-object:uxAccordion:GroupSettings:Style = Infragistics.Win.UltraWinExplorerBar.GroupStyle:LargeImagesWithText.
        this-object:uxAccordion:ImageListLarge = this-object:imageListLarge.
        this-object:uxAccordion:ImageListSmall = this-object:imageListSmall.
        this-object:uxAccordion:ItemSettings:Style = Infragistics.Win.UltraWinExplorerBar.ItemStyle:Button.
        this-object:uxAccordion:Location = new System.Drawing.Point(0, 60).
        this-object:uxAccordion:Name = "uxAccordion".
        this-object:uxAccordion:Size = new System.Drawing.Size(261, 470).
        this-object:uxAccordion:Style = Infragistics.Win.UltraWinExplorerBar.UltraExplorerBarStyle:Listbar.
        this-object:uxAccordion:TabIndex = 12.
        this-object:uxAccordion:ItemClick:Subscribe(this-object:uxAccordion_ItemClick).
        /*  */
        /* splitter1 */
        /*  */
        this-object:splitter1:Location = new System.Drawing.Point(261, 60).
        this-object:splitter1:Name = "splitter1".
        this-object:splitter1:Size = new System.Drawing.Size(10, 470).
        this-object:splitter1:TabIndex = 13.
        this-object:splitter1:TabStop = false.
        /*  */
        /* DealerReview */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(974, 553).
        this-object:Controls:Add(this-object:splitter1).
        this-object:Controls:Add(this-object:uxAccordion).
        this-object:Controls:Add(this-object:m_DealerReview_Toolbars_Dock_Area_Left).
        this-object:Controls:Add(this-object:m_DealerReview_Toolbars_Dock_Area_Right).
        this-object:Controls:Add(this-object:m_DealerReview_Toolbars_Dock_Area_Top).
        this-object:Controls:Add(this-object:m_DealerReview_Toolbars_Dock_Area_Bottom).
        this-object:Controls:Add(this-object:uxStatus).
        this-object:Icon = cast(resources:GetObject("$this.Icon"), System.Drawing.Icon).
        this-object:IsMdiContainer = true.
        this-object:Name = "DealerReview".
        this-object:Text = "AutoEdge|TheFactory: Customer Order Review".
        this-object:TransparencyKey = System.Drawing.Color:Fuchsia.
        cast(this-object:ultraToolbarsManager1, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:ultraTabbedMdiManager1, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxAccordion, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    method public void TaskCompletedHandler(input poSender as Object, input poTask as Task):
        define variable oGroup as UltraExplorerBarGroup no-undo.
        define variable oItem as UltraExplorerBarItem no-undo.
        define variable oForm as Form no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oTag as TagWrapper no-undo.

        oItem = uxAccordion:Groups:Item['AllTasks']:Items:Item[string(poTask:WorkItem:Id)].
        oTag = cast(oItem:Tag, TagWrapper).

        iMax = MdiChildren:Length - 1.
        do iLoop = iMax to 0 by -1:
            oForm = cast(MdiChildren:GetValue(iLoop), Form).
            if type-of(oForm, CustomerOrderDetail) and
               cast(oForm, CustomerOrderDetail):CurrentTask:Equals(cast(oTag:PABLO, Task)) then
                oForm:Close().
        end.

        uxAccordion:Groups:Item['AllTasks']:Items:Remove(oItem).
    end method.

    method private void uxAccordion_ItemClick( input sender as System.Object, input e as Infragistics.Win.UltraWinExplorerBar.ItemEventArgs):
        define variable oTags as TagWrapper extent no-undo.
        define variable oTask as Task no-undo.
        define variable oForm as Form no-undo.

        case e:Item:Group:Key:
            when 'AllTasks' then
            do:
                oTask = cast(cast(e:Item:Tag, TagWrapper):PABLO, Task).
                oForm = new CustomerOrderDetail(BizLogicService, oTask).

                oForm:FormClosed:Subscribe(CustomerOrderDetail_FormClosed).

                cast(oForm, CustomerOrderDetail):TaskCompleted:Subscribe(TaskCompletedHandler).
            end.
            otherwise
            do:
                case e:Item:Key:
                    when 'ListOrders' then
                        oForm = new OrderListForm().
                end case.
            end.
        end case.

        if valid-object(oForm) then
        do:
            oForm:MdiParent = this-object.
            oForm:Show().
        end.

        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
    end method.

    method private void ultraToolbarsManager1_ToolClick( input sender as System.Object, input e as Infragistics.Win.UltraWinToolbars.ToolClickEventArgs ):
        do on error undo, throw:
            case e:Tool:Key:
                when 'DealerLogin' then DealerLogin().
                when 'DealerLogout' then DealerLogout().
                when 'RefreshTasksList' then RefreshTasksList().
                when 'Help' then ShowHelp().
            end case.
            /* catch ApplicationErrors since we don't want them becoming UnhandledErrors */
            catch oApplError as ApplicationError:
                undo, throw oApplError.
            end catch.
            catch oError as Error:
                undo, throw new UnhandledError(oError).
            end catch.
        end.
        /* catch both the former PLE and ApplError errors from DO block above */
        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
    end method.

    method protected void ShowHelp():
        define variable oHelpAbout as HelpAbout no-undo.
        define variable oCurrentType as class Class no-undo.

        if valid-object(this-object:ActiveControl) then
            oCurrentType = this-object:ActiveControl:GetClass().
        else
            oCurrentType = this-object:GetClass().

        oHelpAbout = new HelpAbout(oCurrentType).
        wait-for oHelpAbout:ShowDialog().

        oHelpAbout = ?.
    end method.

    method protected void RefreshTasksList():
        session:set-wait-state('general').

        /* Empty all the existing orders */
        ClearUI('AllTasks', Class:GetClass('AutoEdge.Factory.Client.Order.PresentationLayer.CustomerOrderDetail')).

        PopulateTaskList(BizLogicService:GetAssignedTasks()).
        PopulateTaskList(BizLogicService:GetAvailableTasks()).

        finally:
            session:set-wait-state('').
        end finally.
    end method.

    method protected void SetToolState(pcTool as character extent, plEnable as logical):
        def var iIndex as integer no-undo.
        def var iLoop as integer no-undo.
        define variable oTool as ToolBase no-undo.

        do iLoop = 1 to extent(pcTool):
            iIndex = ultraToolbarsManager1:Tools:IndexOf(pcTool[iLoop]).
            if iIndex ge 0 then
                oTool = cast(ultraToolbarsManager1:Tools:GetItem(iIndex), ButtonTool).

            if valid-object(oTool) then
                oTool:SharedProps:Enabled = plEnable.
        end.
    end method.

    method protected void DealerLogout():
        define variable cTool as character extent no-undo.

        SecMgr:UserLogout().

        ClearUI('Orders', Class:GetClass('AutoEdge.Factory.Client.Order.PresentationLayer.OrderListForm')).
        ClearUI('AllTasks', Class:GetClass('AutoEdge.Factory.Client.Order.PresentationLayer.CustomerOrderDetail')).

        InitUI().
    end method.

    method protected void DealerLogin():
        define variable oFrame as DealerLoginPanel extent 1 no-undo.
        define variable oDealerLoginForm as LightboxForm no-undo.

        oFrame[1] = new DealerLoginPanel().

        /* position where we want it on *this* form */
        oFrame[1]:Location = new Point(
            int((this-object:Size:Width / 2) - (oFrame[1]:Size:Width / 2 )),
            int((this-object:Size:Height / 2) - (oFrame[1]:Size:Height / 2 ) )).

        oDealerLoginForm = new LightboxForm(this-object, oFrame).

        oDealerLoginForm:FormClosed:Subscribe(this-object:DealerLogin_FormClosed).
        oDealerLoginForm:Show().
    end method.

    method public void CustomerOrderDetail_FormClosed( input sender as System.Object, input e as FormClosedEventArgs):
        cast(sender, CustomerOrderDetail):TaskCompleted:Unsubscribe(TaskCompletedHandler).
    end method.

    method public void DealerLogin_FormClosed( input sender as System.Object, input e as FormClosedEventArgs):
        define variable oUC as IUserContext no-undo.
        define variable oPropertyValue as String no-undo.
        define variable cText as character no-undo.
        define variable cTool as character extent no-undo.
        define variable lValidBpmSession as logical no-undo.

        lValidBpmSession = false.
        oUC = cast(SecMgr, OpenEdge.CommonInfrastructure.Common.ISecurityManager):CurrentUserContext.

        if valid-object(oUC) then
        do:
            lValidBpmSession = valid-object(BizLogicService) and BizLogicService:IsSessionValid().

            extent(cTool) = ?.
            extent(cTool) = 1.
            cTool[1] = 'RefreshTasksList'.
            SetToolState(cTool, lValidBpmSession).

            extent(cTool) = ?.
            extent(cTool) = 1.
            cTool[1] = 'DealerLogin'.
            SetToolState(cTool, false).

            extent(cTool) = ?.
            extent(cTool) = 1.
            cTool[1] = 'DealerLogout'.
            SetToolState(cTool, true).

            if lValidBpmSession then
                RefreshTasksList().

            uxAccordion:Groups:Item["AllTasks"]:Enabled = lValidBpmSession.
            uxAccordion:Groups:Item["Orders"]:Enabled = true.
        end.


        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUnhandledError as UnhandledError no-undo.
            oUnhandledError = new UnhandledError(oError).
            oUnhandledError:ShowError().
        end catch.
    end method.

    method private void PopulateTaskList(input poTaskList as Task extent):
        define variable cOrderNum as character no-undo.
        define variable cDealerCode as character no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable oTag as TagWrapper no-undo.
        define variable oAppLarge as Appearance no-undo.
        define variable oAppSmall as Appearance no-undo.
        define variable cLabel as character no-undo.
        define variable oGroup as UltraExplorerBarGroup no-undo.
        define variable oItem as UltraExplorerBarItem no-undo.
        define variable oDSI as DataSlotInstance no-undo.
        define variable oPropertyValue as String no-undo.

        oGroup = uxAccordion:Groups:Item['AllTasks'].
        if valid-object(oGroup) and extent(poTaskList) ne ? then
        do:
            oPropertyValue = cast(cast(SecMgr, OpenEdge.CommonInfrastructure.Common.ISecurityManager)
                                :CurrentUserContext:UserProperties:Get(new String('Dealer.Code')), String).
            if valid-object(oPropertyValue) then
                cDealerCode = oPropertyValue:Value.

            iMax = extent(poTaskList).
            do iLoop = 1 to iMax:
                if valid-object(poTaskList[iLoop]) and poTaskList[iLoop]:WorkItem:WorkStepName eq 'DealerReview' then
                do:
                    oDSI = cast(poTaskList[iLoop]:DataSlots:Get(new String('DealerCode')), DataSlotInstance).
                    /* Only show order for the current dealer (per login) */
                    if not valid-object(oDSI) or oDSI:Value ne cDealerCode then
                        next.

                    oDSI = cast(poTaskList[iLoop]:DataSlots:Get(new String('OrderNum')), DataSlotInstance).
                    if valid-object(oDSI) then
                        cLabel = string(oDSI:Value).
                    else
                        cLabel = poTaskList[iLoop]:WorkItem:ProcessInstanceName.

                    oItem = oGroup:Items:Add(string(poTaskList[iLoop]:WorkItem:Id), cLabel).

                    if ReviewIsOverdue(poTaskList[iLoop]:WorkItem:duedate) then
                        assign oItem:Settings:AppearancesLarge:Appearance:Image = 'date_error_32x32.png'
                               oItem:Settings:AppearancesSmall:Appearance:Image = 'date_error_16x16.png'.
                    else
                        assign oItem:Settings:AppearancesLarge:Appearance:Image = 'date_32x32.png'
                               oItem:Settings:AppearancesSmall:Appearance:Image = 'date_16x16.png'.

                    oTag = new TagWrapper(poTaskList[iLoop]).
                    oItem:Tag = oTag.
                end.
            end.
        end.
    end method.

    method public logical ReviewIsOverdue (pcDueDate as datetime-tz):
        return (interval(today, pcDueDate, 'hours') ge 6).
    end method.

    method protected void ClearUI(input pcGroupName as character,
                                  input poFormType as class Class):
        define variable oGroup as UltraExplorerBarGroup no-undo.
        define variable oForm as Form no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.

        oGroup = uxAccordion:Groups:Item[pcGroupName].
        if valid-object(oGroup) then
        do:
            oGroup:Items:Clear().
            iMax = MdiChildren:Length - 1.
            do iLoop = iMax to 0 by -1:
                if MdiChildren:GetValue(iLoop):GetClass():IsA(poFormType) then
                do:
                    oForm = cast(MdiChildren:GetValue(iLoop), Form).
                    oForm:Close().
                end.
            end.
        end.
    end method.

    destructor public DealerReview ( ):
        SecMgr:UserLogout().

        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.

end class.
