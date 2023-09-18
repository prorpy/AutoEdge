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
    File        : HelpAbout
    Purpose     :
    Syntax      :
    Description :
    Author(s)   : pjudge
    Created     : Fri Jun 03 14:18:58 EDT 2011
    Notes       :
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Infragistics.Win.UltraWinTabControl.UltraTab.
using Infragistics.Win.UltraWinGrid.UltraGridColumn.
using Progress.Windows.Form.

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
using OpenEdge.Lang.Collections.IIterator.
using OpenEdge.Lang.BPM.Task.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.WorkItemStatusEnum.
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.BPM.ProcessTemplate.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.String.
using OpenEdge.Lang.Assert.

using Progress.Lang.Class.
using Progress.Lang.Object.

class AutoEdge.Factory.Client.Order.PresentationLayer.HelpAbout inherits Form:

    define private temp-table mSettingData no-undo
        field SettingGroup as character
        field Order as integer
        field Key as character
        field SettingValue as character
        index idx1 as primary SettingGroup Key
        index idx2 SettingGroup Order.
    define private query mQrySettings for mSettingData scrolling.

    define variable moDocType as class Class no-undo.

    define private variable bsSettings as Progress.Data.BindingSource no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.
    define private variable ultraPanel1 as Infragistics.Win.Misc.UltraPanel no-undo.
    define private variable ultraTabPageControl3 as Infragistics.Win.UltraWinTabControl.UltraTabPageControl no-undo.
    DEFINE PRIVATE VARIABLE ultraTabPageControl4 AS Infragistics.Win.UltraWinTabControl.UltraTabPageControl NO-UNDO.
    define private variable ultraTabPageControl5 as Infragistics.Win.UltraWinTabControl.UltraTabPageControl no-undo.
    define private variable ultraTabSharedControlsPage1 as Infragistics.Win.UltraWinTabControl.UltraTabSharedControlsPage no-undo.
    define private variable ultraTabPageControl1 as Infragistics.Win.UltraWinTabControl.UltraTabPageControl no-undo.
    define private variable uxDetail as Infragistics.Win.UltraWinGrid.UltraGrid no-undo.
    define private variable uxFormattedKeyText as Infragistics.Win.FormattedLinkLabel.UltraFormattedLinkLabel no-undo.
    define private variable uxFormattedValueText as Infragistics.Win.FormattedLinkLabel.UltraFormattedLinkLabel no-undo.
    define private variable uxLogo as Infragistics.Win.UltraWinEditors.UltraPictureBox no-undo.
    define private variable uxSettingsGroup as Infragistics.Win.UltraWinTabControl.UltraTabControl no-undo.
    define private variable uxVersionInfo as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.

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

    /** Shows help about a class.

        @param Class The caller of this dialog */
    constructor public HelpAbout(input poCaller as class Class):
        this-object().

        moDocType = poCaller.
        uxSettingsGroup:Tabs['uxCodeDoc']:Enabled = valid-object(poCaller).

        InitCodeDocData().
    end constructor.

    constructor public HelpAbout():
        super().

        InitializeComponent().

        InitData().

        /* default to not show any code documentation */
        uxSettingsGroup:Tabs['uxCodeDoc']:Enabled = false.

        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end constructor.

    method protected void InitVersionInfo():
        define variable cVersion as character no-undo.
        define variable oProperty as String no-undo.
        define variable cFile as character no-undo.

        oProperty = cast(ABLSession:Instance:SessionProperties:Get(new String('Config.Property.APPROOT')), String).
        cFile = search(substitute('&1/version.txt', oProperty:Value)) no-error.
        if cFile eq ? then
            cFile = search('./version.txt') no-error.
        
        if cFile ne ? then
        do:
            input from value(cFile).
                import unformatted cVersion.
            input close.
        end.
                
        if cVersion eq '' or cVersion eq ? then
            cVersion = 'AutoEdge|TheFactory 1.x.x'.
            
        uxVersionInfo:Text = cVersion.
    end method.

    method protected void InitCodeDocData():
        define variable iLoop as integer no-undo.
        define variable cHTML as character no-undo.
        define variable cURL as character no-undo.

        /* AutoDox */
        cURL = BuildAutoDoxURL(moDocType).
        cHTML = substitute('<a href="&1">&2</a>', cURL, moDocType:TypeName).
        iLoop = 1.
        create mSettingData.
        assign mSettingData.SettingGroup = 'CODEDOC'
               mSettingData.Order = iLoop
               iLoop = iLoop + 1
               mSettingData.Key = cHTML
               mSettingData.SettingValue = cURL.
    end method.

    method protected void InitUserData():
        define variable oUC as IUserContext no-undo.
        define variable iLoop as integer no-undo.
        define variable oIterator as IIterator no-undo.
        define variable oKey as Object no-undo.

        iLoop = 1.
        oUC = cast(SecMgr, OpenEdge.CommonInfrastructure.Common.ISecurityManager):CurrentUserContext.
        if valid-object(oUC) then
        do:
            create mSettingData.
            assign mSettingData.SettingGroup = 'USER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'Login Name'
                   mSettingData.SettingValue = oUC:UserName.

            create mSettingData.
            assign mSettingData.SettingGroup = 'USER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'Login Domain'
                   mSettingData.SettingValue = oUC:UserDomain.

            create mSettingData.
            assign mSettingData.SettingGroup = 'USER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'Tenant Name'
                   mSettingData.SettingValue = oUC:TenantName.

            oIterator = oUC:UserProperties:KeySet:Iterator().
            do while oIterator:HasNext():
                oKey = oIterator:Next().

                create mSettingData.
                assign mSettingData.SettingGroup = 'USER'
                       mSettingData.Order = iLoop
                       iLoop = iLoop + 1
                       mSettingData.Key = oKey:ToString()
                       mSettingData.SettingValue = oUC:UserProperties:Get(oKey):ToString().
            end.
        end.
    end method.

    method protected void InitServerData():
        define variable oServerConnection as IServerConnection no-undo.
        define variable iLoop as integer no-undo.
        define variable oIterator as IIterator no-undo.
        define variable oKey as Object no-undo.
        define variable cBpmSessionId as character no-undo.
        define variable cBpmServerHost as character no-undo.
        define variable lBpmServerConnected as logical no-undo.
        define variable cAppServerHost as character no-undo.
        define variable lAppServerConnected as logical no-undo.

        iLoop = 1.
        oServerConnection = ConMgr:GetServerConnection(ConnectionTypeEnum:AppServer, 'asAutoEdgeTheFactory').
        if valid-object(oServerConnection) then
        do:
            assign cAppServerHost = string(oServerConnection:ConnectionParameters:GetConnectionString())
                   lAppServerConnected = oServerConnection:IsConnected.

            create mSettingData.
            assign mSettingData.SettingGroup = 'SERVER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'AppServer Name'
                   mSettingData.SettingValue = 'asAutoEdgeTheFactory'.

            create mSettingData.
            assign mSettingData.SettingGroup = 'SERVER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'AppServer Host'
                   mSettingData.SettingValue = cAppServerHost.

            create mSettingData.
            assign mSettingData.SettingGroup = 'SERVER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'AppServer IsConnected'
                   mSettingData.SettingValue = string(lAppServerConnected).
        end.

        /* spacer */
        create mSettingData.
        assign mSettingData.SettingGroup = 'SERVER'
               mSettingData.Order = iLoop
               iLoop = iLoop + 1
               mSettingData.Key = ''
               mSettingData.SettingValue = ''.

        oServerConnection = ConMgr:GetServerConnection(ConnectionTypeEnum:BpmServer, 'bpmAutoEdgeTheFactory').
        if valid-object(oServerConnection) then
        do:
            assign cBpmServerHost = string(oServerConnection:ConnectionParameters:GetConnectionString())
                   lBpmServerConnected = oServerConnection:IsConnected.

            create mSettingData.
            assign mSettingData.SettingGroup = 'SERVER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'BPM Server Name'
                   mSettingData.SettingValue = 'bpmAutoEdgeTheFactory'.

            create mSettingData.
            assign mSettingData.SettingGroup = 'SERVER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'BPM Server Host'
                   mSettingData.SettingValue = substitute('<a href="&1">&2</a>',
                            substitute('&1/sbm/bpmportal/login.jsp',cBpmServerHost),
                            cBpmServerHost).

            create mSettingData.
            assign mSettingData.SettingGroup = 'SERVER'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = 'BPM Server IsConnected'
                   mSettingData.SettingValue = string(lBpmServerConnected).
        end.
    end method.

    method protected void InitSessionData():
        define variable iLoop as integer no-undo.
        define variable oIterator as IIterator no-undo.
        define variable oKey as Object no-undo.
        define variable oValue as Object no-undo.

        /* Session info */
        oIterator = ABLSession:Instance:SessionProperties:KeySet:Iterator().
        iLoop = 1.
        do while oIterator:HasNext():
            oKey = oIterator:Next().
            if not type-of(oKey, String) then
                next.

            oValue = ABLSession:Instance:SessionProperties:Get(oKey).

            create mSettingData.
            assign mSettingData.SettingGroup = 'SESSION'
                   mSettingData.Order = iLoop
                   iLoop = iLoop + 1
                   mSettingData.Key = oKey:ToString()
                   mSettingData.SettingValue = oValue:ToString().
        end.
    end method.

    method protected void InitData():
        InitVersionInfo().
        InitUserData().
        InitServerData().
        InitSessionData().
    end method.

    method private void InitializeComponent(  ):

        /* NOTE: The following method is automatically generated.

        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.

        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance4 as Infragistics.Win.Appearance no-undo.
        appearance4 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridBand1 as Infragistics.Win.UltraWinGrid.UltraGridBand no-undo.
        ultraGridBand1 = new Infragistics.Win.UltraWinGrid.UltraGridBand("mSettingData", -1).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn3 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn3 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Key").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn4 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn4 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("SettingValue").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance7 as Infragistics.Win.Appearance no-undo.
        appearance7 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance8 as Infragistics.Win.Appearance no-undo.
        appearance8 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance9 as Infragistics.Win.Appearance no-undo.
        appearance9 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance10 as Infragistics.Win.Appearance no-undo.
        appearance10 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance11 as Infragistics.Win.Appearance no-undo.
        appearance11 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance12 as Infragistics.Win.Appearance no-undo.
        appearance12 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance13 as Infragistics.Win.Appearance no-undo.
        appearance13 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance14 as Infragistics.Win.Appearance no-undo.
        appearance14 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance15 as Infragistics.Win.Appearance no-undo.
        appearance15 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance16 as Infragistics.Win.Appearance no-undo.
        appearance16 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance17 as Infragistics.Win.Appearance no-undo.
        appearance17 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance18 as Infragistics.Win.Appearance no-undo.
        appearance18 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance19 as Infragistics.Win.Appearance no-undo.
        appearance19 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("mSettingData").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("AutoEdge.Factory.Client.Order.PresentationLayer.HelpAbout").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance1 as Infragistics.Win.Appearance no-undo.
        appearance1 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraTab3 as Infragistics.Win.UltraWinTabControl.UltraTab no-undo.
        ultraTab3 = new Infragistics.Win.UltraWinTabControl.UltraTab().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance6 as Infragistics.Win.Appearance no-undo.
        appearance6 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraTab2 as Infragistics.Win.UltraWinTabControl.UltraTab no-undo.
        ultraTab2 = new Infragistics.Win.UltraWinTabControl.UltraTab().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance5 as Infragistics.Win.Appearance no-undo.
        appearance5 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraTab4 as Infragistics.Win.UltraWinTabControl.UltraTab no-undo.
        ultraTab4 = new Infragistics.Win.UltraWinTabControl.UltraTab().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance2 as Infragistics.Win.Appearance no-undo.
        appearance2 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraTab5 as Infragistics.Win.UltraWinTabControl.UltraTab no-undo.
        ultraTab5 = new Infragistics.Win.UltraWinTabControl.UltraTab().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance3 as Infragistics.Win.Appearance no-undo.
        appearance3 = new Infragistics.Win.Appearance().
        this-object:uxFormattedKeyText = new Infragistics.Win.FormattedLinkLabel.UltraFormattedLinkLabel().
        this-object:uxFormattedValueText = new Infragistics.Win.FormattedLinkLabel.UltraFormattedLinkLabel().
        this-object:ultraTabPageControl1 = new Infragistics.Win.UltraWinTabControl.UltraTabPageControl().
        this-object:ultraTabPageControl3 = new Infragistics.Win.UltraWinTabControl.UltraTabPageControl().
        this-object:ultraTabPageControl4 = new Infragistics.Win.UltraWinTabControl.UltraTabPageControl().
        this-object:ultraTabPageControl5 = new Infragistics.Win.UltraWinTabControl.UltraTabPageControl().
        this-object:uxDetail = new Infragistics.Win.UltraWinGrid.UltraGrid().
        this-object:bsSettings = new Progress.Data.BindingSource(this-object:components).
        this-object:ultraPanel1 = new Infragistics.Win.Misc.UltraPanel().
        this-object:uxLogo = new Infragistics.Win.UltraWinEditors.UltraPictureBox().
        this-object:uxVersionInfo = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:uxSettingsGroup = new Infragistics.Win.UltraWinTabControl.UltraTabControl().
        this-object:ultraTabSharedControlsPage1 = new Infragistics.Win.UltraWinTabControl.UltraTabSharedControlsPage().
        this-object:ultraTabPageControl1:SuspendLayout().
        cast(this-object:uxDetail, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bsSettings, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:ultraPanel1:ClientArea:SuspendLayout().
        this-object:ultraPanel1:SuspendLayout().
        cast(this-object:uxVersionInfo, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxSettingsGroup, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:uxSettingsGroup:SuspendLayout().
        this-object:ultraTabSharedControlsPage1:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* uxFormattedKeyText */
        /*  */
        this-object:uxFormattedKeyText:Location = new System.Drawing.Point(118, 129).
        this-object:uxFormattedKeyText:Name = "uxFormattedKeyText".
        this-object:uxFormattedKeyText:Size = new System.Drawing.Size(130, 23).
        this-object:uxFormattedKeyText:TabIndex = 2.
        this-object:uxFormattedKeyText:TabStop = true.
        this-object:uxFormattedKeyText:TreatValueAs = Infragistics.Win.FormattedLinkLabel.TreatValueAs:Auto.
        this-object:uxFormattedKeyText:Value = "".
        this-object:uxFormattedKeyText:Visible = false.
        this-object:uxFormattedKeyText:WrapText = false.
        /*  */
        /* uxFormattedValueText */
        /*  */
        this-object:uxFormattedValueText:Location = new System.Drawing.Point(208, 100).
        this-object:uxFormattedValueText:Name = "uxFormattedValueText".
        this-object:uxFormattedValueText:Size = new System.Drawing.Size(130, 23).
        this-object:uxFormattedValueText:TabIndex = 3.
        this-object:uxFormattedValueText:TabStop = true.
        this-object:uxFormattedValueText:TreatValueAs = Infragistics.Win.FormattedLinkLabel.TreatValueAs:Auto.
        this-object:uxFormattedValueText:Value = "".
        this-object:uxFormattedValueText:Visible = false.
        this-object:uxFormattedValueText:WrapText = false.
        /*  */
        /* ultraTabPageControl1 */
        /*  */
        this-object:ultraTabPageControl1:Controls:Add(this-object:uxFormattedValueText).
        this-object:ultraTabPageControl1:Controls:Add(this-object:uxFormattedKeyText).
        this-object:ultraTabPageControl1:Controls:Add(this-object:uxDetail).
        this-object:ultraTabPageControl1:Location = new System.Drawing.Point(38, 1).
        this-object:ultraTabPageControl1:Name = "ultraTabPageControl1".
        this-object:ultraTabPageControl1:Size = new System.Drawing.Size(452, 248).
        /*  */
        /* ultraTabPageControl3 */
        /*  */
        this-object:ultraTabPageControl3:Location = new System.Drawing.Point(-10000, -10000).
        this-object:ultraTabPageControl3:Name = "ultraTabPageControl3".
        this-object:ultraTabPageControl3:Size = new System.Drawing.Size(452, 248).
        /*  */
        /* ultraTabPageControl4 */
        /*  */
        this-object:ultraTabPageControl4:Location = new System.Drawing.Point(-10000, -10000).
        this-object:ultraTabPageControl4:Name = "ultraTabPageControl4".
        this-object:ultraTabPageControl4:Size = new System.Drawing.Size(452, 248).
        /*  */
        /* ultraTabPageControl5 */
        /*  */
        this-object:ultraTabPageControl5:Location = new System.Drawing.Point(-10000, -10000).
        this-object:ultraTabPageControl5:Name = "ultraTabPageControl5".
        this-object:ultraTabPageControl5:Size = new System.Drawing.Size(452, 248).
        /*  */
        /* uxDetail */
        /*  */
        this-object:uxDetail:DataSource = this-object:bsSettings.
        appearance4:BackColor = System.Drawing.SystemColors:Window.
        appearance4:BorderColor = System.Drawing.SystemColors:InactiveCaption.
        this-object:uxDetail:DisplayLayout:Appearance = appearance4.
        ultraGridBand1:ColHeadersVisible = false.
        ultraGridColumn3:AutoSizeMode = Infragistics.Win.UltraWinGrid.ColumnAutoSizeMode:AllRowsInBand.
        ultraGridColumn3:CellActivation = Infragistics.Win.UltraWinGrid.Activation:ActivateOnly.
        ultraGridColumn3:EditorComponent = this-object:uxFormattedKeyText.
        ultraGridColumn3:Header:Fixed = true.
        ultraGridColumn3:Header:VisiblePosition = 0.
        ultraGridColumn3:Width = 183.
        ultraGridColumn4:AllowGroupBy = Infragistics.Win.DefaultableBoolean:False.
        ultraGridColumn4:CellActivation = Infragistics.Win.UltraWinGrid.Activation:NoEdit.
        ultraGridColumn4:EditorComponent = this-object:uxFormattedValueText.
        ultraGridColumn4:Header:Fixed = true.
        ultraGridColumn4:Header:VisiblePosition = 1.
        ultraGridColumn4:Width = 267.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as System.Object extent 2 no-undo.
        arrayvar0[1] = ultraGridColumn3.
        arrayvar0[2] = ultraGridColumn4.
        ultraGridBand1:Columns:AddRange(arrayvar0).
        this-object:uxDetail:DisplayLayout:BandsSerializer:Add(ultraGridBand1).
        this-object:uxDetail:DisplayLayout:BorderStyle = Infragistics.Win.UIElementBorderStyle:Solid.
        appearance7:FontData:Name = "Segoe UI".
        appearance7:ForeColor = System.Drawing.SystemColors:InactiveCaptionText.
        appearance7:TextHAlignAsString = "Center".
        this-object:uxDetail:DisplayLayout:CaptionAppearance = appearance7.
        this-object:uxDetail:DisplayLayout:CaptionVisible = Infragistics.Win.DefaultableBoolean:True.
        appearance8:BackColor = System.Drawing.SystemColors:ActiveBorder.
        appearance8:BackColor2 = System.Drawing.SystemColors:ControlDark.
        appearance8:BackGradientStyle = Infragistics.Win.GradientStyle:Vertical.
        appearance8:BorderColor = System.Drawing.SystemColors:Window.
        this-object:uxDetail:DisplayLayout:GroupByBox:Appearance = appearance8.
        appearance9:ForeColor = System.Drawing.SystemColors:GrayText.
        this-object:uxDetail:DisplayLayout:GroupByBox:BandLabelAppearance = appearance9.
        this-object:uxDetail:DisplayLayout:GroupByBox:BorderStyle = Infragistics.Win.UIElementBorderStyle:Solid.
        this-object:uxDetail:DisplayLayout:GroupByBox:Hidden = true.
        appearance10:BackColor = System.Drawing.SystemColors:ControlLightLight.
        appearance10:BackColor2 = System.Drawing.SystemColors:Control.
        appearance10:BackGradientStyle = Infragistics.Win.GradientStyle:Horizontal.
        appearance10:ForeColor = System.Drawing.SystemColors:GrayText.
        this-object:uxDetail:DisplayLayout:GroupByBox:PromptAppearance = appearance10.
        this-object:uxDetail:DisplayLayout:MaxColScrollRegions = 1.
        this-object:uxDetail:DisplayLayout:MaxRowScrollRegions = 1.
        appearance11:BackColor = System.Drawing.SystemColors:Window.
        appearance11:ForeColor = System.Drawing.SystemColors:ControlText.
        this-object:uxDetail:DisplayLayout:Override:ActiveCellAppearance = appearance11.
        appearance12:BackColor = System.Drawing.SystemColors:Highlight.
        appearance12:ForeColor = System.Drawing.SystemColors:HighlightText.
        this-object:uxDetail:DisplayLayout:Override:ActiveRowAppearance = appearance12.
        this-object:uxDetail:DisplayLayout:Override:AllowAddNew = Infragistics.Win.UltraWinGrid.AllowAddNew:No.
        this-object:uxDetail:DisplayLayout:Override:AllowColSizing = Infragistics.Win.UltraWinGrid.AllowColSizing:Free.
        this-object:uxDetail:DisplayLayout:Override:AllowDelete = Infragistics.Win.DefaultableBoolean:False.
        this-object:uxDetail:DisplayLayout:Override:AllowUpdate = Infragistics.Win.DefaultableBoolean:False.
        this-object:uxDetail:DisplayLayout:Override:BorderStyleCell = Infragistics.Win.UIElementBorderStyle:None.
        this-object:uxDetail:DisplayLayout:Override:BorderStyleRow = Infragistics.Win.UIElementBorderStyle:None.
        appearance13:BackColor = System.Drawing.SystemColors:Window.
        this-object:uxDetail:DisplayLayout:Override:CardAreaAppearance = appearance13.
        appearance14:BorderColor = System.Drawing.Color:Silver.
        appearance14:TextTrimming = Infragistics.Win.TextTrimming:EllipsisCharacter.
        this-object:uxDetail:DisplayLayout:Override:CellAppearance = appearance14.
        this-object:uxDetail:DisplayLayout:Override:CellClickAction = Infragistics.Win.UltraWinGrid.CellClickAction:EditAndSelectText.
        this-object:uxDetail:DisplayLayout:Override:CellPadding = 0.
        this-object:uxDetail:DisplayLayout:Override:ColumnSizingArea = Infragistics.Win.UltraWinGrid.ColumnSizingArea:EntireColumn.
        appearance15:BackColor = System.Drawing.SystemColors:Control.
        appearance15:BackColor2 = System.Drawing.SystemColors:ControlDark.
        appearance15:BackGradientAlignment = Infragistics.Win.GradientAlignment:Element.
        appearance15:BackGradientStyle = Infragistics.Win.GradientStyle:Horizontal.
        appearance15:BorderColor = System.Drawing.SystemColors:Window.
        this-object:uxDetail:DisplayLayout:Override:GroupByRowAppearance = appearance15.
        appearance16:TextHAlignAsString = "Left".
        this-object:uxDetail:DisplayLayout:Override:HeaderAppearance = appearance16.
        this-object:uxDetail:DisplayLayout:Override:HeaderStyle = Infragistics.Win.HeaderStyle:WindowsXPCommand.
        appearance17:BackColor = System.Drawing.SystemColors:GradientInactiveCaption.
        this-object:uxDetail:DisplayLayout:Override:RowAlternateAppearance = appearance17.
        appearance18:BackColor = System.Drawing.SystemColors:Window.
        appearance18:BorderColor = System.Drawing.Color:Silver.
        this-object:uxDetail:DisplayLayout:Override:RowAppearance = appearance18.
        this-object:uxDetail:DisplayLayout:Override:RowSelectors = Infragistics.Win.DefaultableBoolean:False.
        appearance19:BackColor = System.Drawing.SystemColors:ControlLight.
        this-object:uxDetail:DisplayLayout:Override:TemplateAddRowAppearance = appearance19.
        this-object:uxDetail:DisplayLayout:RowConnectorStyle = Infragistics.Win.UltraWinGrid.RowConnectorStyle:None.
        this-object:uxDetail:DisplayLayout:ScrollBounds = Infragistics.Win.UltraWinGrid.ScrollBounds:ScrollToFill.
        this-object:uxDetail:DisplayLayout:ScrollStyle = Infragistics.Win.UltraWinGrid.ScrollStyle:Immediate.
        this-object:uxDetail:DisplayLayout:ViewStyle = Infragistics.Win.UltraWinGrid.ViewStyle:SingleBand.
        this-object:uxDetail:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uxDetail:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25, System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        this-object:uxDetail:Location = new System.Drawing.Point(0, 0).
        this-object:uxDetail:Name = "uxDetail".
        this-object:uxDetail:Size = new System.Drawing.Size(452, 248).
        this-object:uxDetail:TabIndex = 1.
        this-object:uxDetail:Text = "User Detail".
        /*  */
        /* bsSettings */
        /*  */
        this-object:bsSettings:MaxDataGuess = 0.
        this-object:bsSettings:NoLOBs = false.
        this-object:bsSettings:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar1 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 2 no-undo.
        arrayvar2[1] = new Progress.Data.ColumnPropDesc("Key", "Key", Progress.Data.DataType:CHARACTER).
        arrayvar2[2] = new Progress.Data.ColumnPropDesc("SettingValue", "Value", Progress.Data.DataType:CHARACTER).
        tableDesc1:Columns = arrayvar2.
        this-object:bsSettings:TableSchema = tableDesc1.
        /*  */
        /* ultraPanel1 */
        /*  */
        /*  */
        /* ultraPanel1.ClientArea */
        /*  */
        this-object:ultraPanel1:ClientArea:Controls:Add(this-object:uxLogo).
        this-object:ultraPanel1:Dock = System.Windows.Forms.DockStyle:Top.
        this-object:ultraPanel1:Location = new System.Drawing.Point(0, 0).
        this-object:ultraPanel1:Name = "ultraPanel1".
        this-object:ultraPanel1:Size = new System.Drawing.Size(491, 55).
        this-object:ultraPanel1:TabIndex = 0.
        /*  */
        /* uxLogo */
        /*  */
        this-object:uxLogo:BorderShadowColor = System.Drawing.Color:Empty.
        this-object:uxLogo:Dock = System.Windows.Forms.DockStyle:Top.
        this-object:uxLogo:Image = cast(resources:GetObject("uxLogo.Image"), System.Object).
        this-object:uxLogo:Location = new System.Drawing.Point(0, 0).
        this-object:uxLogo:Name = "uxLogo".
        this-object:uxLogo:Size = new System.Drawing.Size(491, 50).
        this-object:uxLogo:TabIndex = 1.
        /*  */
        /* uxVersionInfo */
        /*  */
        appearance1:BackColor = System.Drawing.Color:White.
        appearance1:BackColorDisabled = System.Drawing.Color:White.
        appearance1:ForeColorDisabled = System.Drawing.SystemColors:ControlText.
        appearance1:TextHAlignAsString = "Center".
        this-object:uxVersionInfo:Appearance = appearance1.
        this-object:uxVersionInfo:BackColor = System.Drawing.Color:White.
        this-object:uxVersionInfo:Dock = System.Windows.Forms.DockStyle:Top.
        this-object:uxVersionInfo:Enabled = false.
        this-object:uxVersionInfo:Location = new System.Drawing.Point(0, 55).
        this-object:uxVersionInfo:Multiline = true.
        this-object:uxVersionInfo:Name = "uxVersionInfo".
        this-object:uxVersionInfo:ShowOverflowIndicator = true.
        this-object:uxVersionInfo:Size = new System.Drawing.Size(491, 32).
        this-object:uxVersionInfo:TabIndex = 0.
        this-object:uxVersionInfo:TabStop = false.
        /*  */
        /* imageList1 */
        /*  */
        this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageList1:Images:SetKeyName(0, "aetf.ico").
        this-object:imageList1:Images:SetKeyName(1, "progress.ico").
        this-object:imageList1:Images:SetKeyName(2, "aetf_logo.png").
        this-object:imageList1:Images:SetKeyName(3, "source_p_32x32.png").
        this-object:imageList1:Images:SetKeyName(4, "services_32x32.png").
        this-object:imageList1:Images:SetKeyName(5, "bpmstudio_32x32.ico").
        this-object:imageList1:Images:SetKeyName(6, "system_info_32x32.png").
        this-object:imageList1:Images:SetKeyName(7, "user_info_32x32.png").
        /*  */
        /* uxSettingsGroup */
        /*  */
        this-object:uxSettingsGroup:Controls:Add(this-object:ultraTabSharedControlsPage1).
        this-object:uxSettingsGroup:Controls:Add(this-object:ultraTabPageControl1).
        this-object:uxSettingsGroup:Controls:Add(this-object:ultraTabPageControl3).
        this-object:uxSettingsGroup:Controls:Add(this-object:ultraTabPageControl5).
        this-object:uxSettingsGroup:Controls:Add(this-object:ultraTabPageControl4).
        this-object:uxSettingsGroup:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uxSettingsGroup:ImageList = this-object:imageList1.
        this-object:uxSettingsGroup:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxSettingsGroup:Location = new System.Drawing.Point(0, 87).
        this-object:uxSettingsGroup:Name = "uxSettingsGroup".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar3 as System.Windows.Forms.Control extent 1 no-undo.
        arrayvar3[1] = this-object:uxDetail.
        this-object:uxSettingsGroup:SharedControls:AddRange(arrayvar3).
        this-object:uxSettingsGroup:SharedControlsPage = this-object:ultraTabSharedControlsPage1.
        this-object:uxSettingsGroup:Size = new System.Drawing.Size(491, 250).
        this-object:uxSettingsGroup:TabButtonStyle = Infragistics.Win.UIElementButtonStyle:Borderless.
        this-object:uxSettingsGroup:TabIndex = 1.
        this-object:uxSettingsGroup:TabOrientation = Infragistics.Win.UltraWinTabs.TabOrientation:LeftTop.
        appearance6:Image = "user_info_32x32.png".
        appearance6:ImageHAlign = Infragistics.Win.HAlign:Center.
        appearance6:ImageVAlign = Infragistics.Win.VAlign:Middle.
        ultraTab3:Appearance = appearance6.
        ultraTab3:Key = "uxUserInfo".
        ultraTab3:TabPage = this-object:ultraTabPageControl1.
        ultraTab3:Text = "".
        ultraTab3:ToolTipText = "Application settings".
        appearance5:Image = "services_32x32.png".
        appearance5:ImageHAlign = Infragistics.Win.HAlign:Center.
        appearance5:ImageVAlign = Infragistics.Win.VAlign:Middle.
        ultraTab2:Appearance = appearance5.
        ultraTab2:Key = "uxServerInfo".
        ultraTab2:TabPage = this-object:ultraTabPageControl3.
        ultraTab2:Text = "".
        ultraTab2:ToolTipText = "AppServer settings".
        appearance2:Image = "system_info_32x32.png".
        appearance2:ImageHAlign = Infragistics.Win.HAlign:Center.
        appearance2:ImageVAlign = Infragistics.Win.VAlign:Middle.
        ultraTab4:Appearance = appearance2.
        ultraTab4:Key = "uxSessionInfo".
        ultraTab4:TabPage = this-object:ultraTabPageControl4.
        ultraTab4:Text = "".
        ultraTab4:ToolTipText = "System information".
        appearance3:Image = "source_p_32x32.png".
        appearance3:ImageHAlign = Infragistics.Win.HAlign:Center.
        appearance3:ImageVAlign = Infragistics.Win.VAlign:Middle.
        ultraTab5:Appearance = appearance3.
        ultraTab5:Key = "uxCodeDoc".
        ultraTab5:TabPage = this-object:ultraTabPageControl5.
        ultraTab5:Text = "".
        ultraTab5:ToolTipText = "AutoDox2 code documentation".
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar4 as Infragistics.Win.UltraWinTabControl.UltraTab extent 4 no-undo.
        arrayvar4[1] = ultraTab3.
        arrayvar4[2] = ultraTab2.
        arrayvar4[3] = ultraTab4.
        arrayvar4[4] = ultraTab5.
        this-object:uxSettingsGroup:Tabs:AddRange(arrayvar4).
        this-object:uxSettingsGroup:UseFlatMode = Infragistics.Win.DefaultableBoolean:False.
        this-object:uxSettingsGroup:ViewStyle = Infragistics.Win.UltraWinTabControl.ViewStyle:Office2007.
        this-object:uxSettingsGroup:ActiveTabChanging:Subscribe(this-object:uxSettingsGroup_ActiveTabChanging).
        /*  */
        /* ultraTabSharedControlsPage1 */
        /*  */
        this-object:ultraTabSharedControlsPage1:Controls:Add(this-object:uxDetail).
        this-object:ultraTabSharedControlsPage1:Location = new System.Drawing.Point(-10000, -10000).
        this-object:ultraTabSharedControlsPage1:Name = "ultraTabSharedControlsPage1".
        this-object:ultraTabSharedControlsPage1:Size = new System.Drawing.Size(452, 248).
        /*  */
        /* HelpAbout */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(491, 337).
        this-object:Controls:Add(this-object:uxSettingsGroup).
        this-object:Controls:Add(this-object:uxVersionInfo).
        this-object:Controls:Add(this-object:ultraPanel1).
        this-object:Icon = cast(resources:GetObject("$this.Icon"), System.Drawing.Icon).
        this-object:MinimumSize = new System.Drawing.Size(370, 325).
        this-object:Name = "HelpAbout".
        this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
        this-object:Text = "About".
        this-object:ultraTabPageControl1:ResumeLayout(false).
        cast(this-object:uxDetail, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bsSettings, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ultraPanel1:ClientArea:ResumeLayout(false).
        this-object:ultraPanel1:ResumeLayout(false).
        cast(this-object:uxVersionInfo, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxSettingsGroup, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:uxSettingsGroup:ResumeLayout(false).
        this-object:ultraTabSharedControlsPage1:ResumeLayout(false).
        this-object:ResumeLayout(false).
        this-object:PerformLayout().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    /*------------------------------------------------------------------------------
            Purpose:
            Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void uxSettingsGroup_ActiveTabChanging( input sender as System.Object, input e as Infragistics.Win.UltraWinTabControl.ActiveTabChangingEventArgs ):
        case string(e:Tab:Key):
            when 'uxUserInfo' then ShowDetailGrid('USER', 'User Detail', '').
            when 'uxServerInfo' then ShowDetailGrid('SERVER', 'Server Detail', '').
            when 'uxSessionInfo' then ShowDetailGrid('SESSION', 'Session Detail', '').
/*            when 'uxCodeDoc' then ShowUrl('CODEDOC').*/
            when 'uxCodeDoc' then ShowDetailGrid('CODEDOC', 'AutoDox2 Code Documentation', 'SettingValue').
        end case.
    end method.

    method private character BuildAutoDoxURL(input poCaller as class Class):
        define variable cProtocolRoot as character no-undo.
        define variable cPackageRoot as character no-undo.
        define variable cAutoDoxRoot as character no-undo.
        define variable cDocumentName as character no-undo.
        define variable oProperty as String no-undo.
        define variable cSplitType as character extent no-undo.
        define variable cSplitPath as character extent no-undo.
        define variable cSplitAppRoot as character extent no-undo.

        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable iMin as integer no-undo.

        /* things we always know */
        cProtocolRoot = 'http://localhost/aetf'.

        if valid-object(poCaller) then
        do:
            assign cAutoDoxRoot = '/doc/autodox2' /* by convention */
                   cDocumentName = substitute('/&1.cls.html', replace(poCaller:TypeName, '.', '~/'))
                   iMin = 1
                   oProperty = cast(ABLSession:Instance:SessionProperties:Get(new String('Config.Property.AppRoot')), String).
            if valid-object(oProperty) then
                assign cSplitAppRoot = String:Split(replace(oProperty:Value, '~\','~/'), '~/')
                       iMin = extent(cSplitAppRoot) + 1.

            file-info:file-name = search(replace(poCaller:TypeName, '.', '~/') + '.cls').
            cSplitPath = String:Split(replace(file-info:full-pathname, '~\','~/'), '~/').
            cSplitType = String:Split(poCaller:TypeName, '.').

            /* last element will be 'src' or 'bin' */
            iMax = extent(cSplitPath) - extent(cSplitType) - 1.

            do iLoop = iMin to iMax:
                cPackageRoot = cPackageRoot + '/' + cSplitPath[iLoop].
            end.
        end.
        else
            assign cPackageRoot = ''
                   cAutoDoxRoot = '/doc'
                   cDocumentName = '/autodox2-index.html'.

        return (cProtocolRoot + cPackageRoot + cAutoDoxRoot + cDocumentName).
    end method.

    method private void ShowDetailGrid(input pcGroup as character,
                                       input pcCaption as character,
                                       input pcHideColumns as character):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.

        iMax = uxDetail:DisplayLayout:Bands[0]:Columns:Count.
        do iLoop = 0 to (iMax - 1):
            uxDetail:DisplayLayout:Bands[0]:Columns[iLoop]:Hidden = lookup(pcHideColumns, uxDetail:DisplayLayout:Bands[0]:Columns[iLoop]:Key) gt 0.
        end.

        open query mQrySettings preselect each mSettingData where mSettingData.SettingGroup eq pcGroup by mSettingData.Order.
        bsSettings:Handle = query mQrySettings:handle.

        uxDetail:Text = pcCaption.
    end method.

    destructor public HelpAbout ( ):
        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.

end class.
