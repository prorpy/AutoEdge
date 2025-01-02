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
    File        : SavvionTaskDetailUC
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Wed Jul 07 12:04:00 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Infragistics.Win.UltraWinGrid.UltraGridAction.
using Infragistics.Win.UltraWinGrid.SortIndicator.            
using Infragistics.Win.UltraWinGrid.UltraGridColumn.
using Infragistics.Win.UltraWinGrid.UltraGridRow.

using OpenEdge.PresentationLayer.View.GuiForDotNet.TagWrapper.

using OpenEdge.Core.System.Query.
using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.Task.
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.BPM.WorkItemStatusEnum.
using OpenEdge.Lang.BPM.SavvionType.
using OpenEdge.Lang.Assert.

using Progress.Windows.UserControl.
using Progress.Util.EnumHelper.
using Progress.Lang.Class.
using Progress.Lang.Object.

class AutoEdge.Factory.Client.Common.PresentationLayer.SavvionTaskDetailUC use-widget-pool inherits UserControl: 
    
    define private variable bsDataSlots as Progress.Data.BindingSource no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.
    define private variable lblProcessInstanceCreator as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblPTID as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblReassignPerformer as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblWIID as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblWIStatus as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblWSName as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lbPiid as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable uxDataslots as Infragistics.Win.UltraWinGrid.UltraGrid no-undo.
    define private variable uxPriority as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxDueDate as Infragistics.Win.UltraWinEditors.UltraDateTimeEditor no-undo.
    define private variable uxCurrentPerformer as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxCreatedDate as Infragistics.Win.UltraWinEditors.UltraDateTimeEditor no-undo.
    define private variable lblTaskNameLabel as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblProcessInstanceName as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblPriority as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblDueDate as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblCurrentPerformer as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblCreatedDate as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable uxProcessInstanceCreator as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxProcessInstanceId as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxProcessInstanceName as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxProcessTemplateID as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxReassignToPerformer as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxReassignPerformer as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxTaskDetail as Infragistics.Win.Misc.UltraGroupBox no-undo.
    define private variable uxCompleteTask as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxWorkItemId as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxWorkItemStatus as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxWorkStepName as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxWorkItemName as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    
    define public property CurrentTask as Task no-undo get. set.
    define protected property BpmServer as IBizLogicAPI no-undo get. set.
    
    define public event TaskCompleted signature void(input poSender as Object, input poTask as Task).
        
    constructor public SavvionTaskDetailUC (  ):
        super().
        InitializeComponent().
        
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end constructor.

    method public void SetTask(poCurrentTask as Task, poBpmServer as IBizLogicAPI):
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        define variable hDataslots as handle no-undo.
        define variable hQuery as handle no-undo.
        
        Assert:ArgumentNotNull(poCurrentTask, 'Current task').
        Assert:ArgumentNotNull(poBpmServer, 'BPM Server').
        
        assign CurrentTask = poCurrentTask
               BpmServer = poBpmServer
               
               uxProcessInstanceName:Text = CurrentTask:WorkItem:ProcessInstanceName
               uxProcessInstanceCreator:Text = CurrentTask:WorkItem:ProcessInstanceCreator
               uxProcessInstanceId:Text = string(CurrentTask:WorkItem:ProcessInstanceId)
               uxProcessTemplateId:Text = string(CurrentTask:WorkItem:ProcessTemplateId)
               uxPriority:Text = CurrentTask:WorkItem:Priority:ToString()
               uxDueDate:DateTime = box(CurrentTask:WorkItem:DueDate)
               uxCreatedDate:DateTime = box(CurrentTask:WorkItem:TimeStarted)
               
               uxCurrentPerformer:Text = CurrentTask:WorkItem:Performer
               
               uxWorkItemName:Text = CurrentTask:WorkItem:Name
               uxWorkItemId:Text = string(CurrentTask:WorkItem:Id)
               uxWorkItemStatus:Text = CurrentTask:WorkItem:Status:ToString()
               uxWorkStepName:Text = CurrentTask:WorkItem:WorkStepName.
               
        SavvionType:ArrayToTable(Class:GetClass('OpenEdge.Lang.BPM.DataSlotInstance'),
                                 cast(CurrentTask:DataSlots:Values:ToArray(), DataSlotInstance),
                                 output table-handle hDataslots).
        
        create query hQuery.
        hQuery:set-buffers(hDataslots:default-buffer-handle).
        hQuery:query-prepare(' preselect each ' + hDataslots:default-buffer-handle:name).
        hQuery:query-open.
        
        bsDataSlots:Handle = hQuery.
    end method.
    
    method private void InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance13 as Infragistics.Win.Appearance no-undo.
        appearance13 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridBand1 as Infragistics.Win.UltraWinGrid.UltraGridBand no-undo.
        ultraGridBand1 = new Infragistics.Win.UltraWinGrid.UltraGridBand("DataSlotInstance", -1).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn1 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn1 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Choices").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn2 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn2 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ReadOnly").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn3 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn3 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("WriteOnly").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn4 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn4 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Name").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn5 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn5 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ProcessInstanceId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn6 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn6 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ProcessTemplateId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn7 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn7 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Type").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn8 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn8 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("DataSlotValue").
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
        define variable appearance20 as Infragistics.Win.Appearance no-undo.
        appearance20 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance21 as Infragistics.Win.Appearance no-undo.
        appearance21 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance22 as Infragistics.Win.Appearance no-undo.
        appearance22 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance23 as Infragistics.Win.Appearance no-undo.
        appearance23 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance24 as Infragistics.Win.Appearance no-undo.
        appearance24 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("DataSlotInstance").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance26 as Infragistics.Win.Appearance no-undo.
        appearance26 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("AutoEdge.Factory.Client.Common.PresentationLayer.SavvionTaskDetailUC").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance27 as Infragistics.Win.Appearance no-undo.
        appearance27 = new Infragistics.Win.Appearance().
        this-object:uxTaskDetail = new Infragistics.Win.Misc.UltraGroupBox().
        this-object:uxDataslots = new Infragistics.Win.UltraWinGrid.UltraGrid().
        this-object:bsDataSlots = new Progress.Data.BindingSource(this-object:components).
        this-object:uxWorkItemStatus = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblWIStatus = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxWorkStepName = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblWSName = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxWorkItemId = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblWIID = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxProcessInstanceCreator = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblProcessInstanceCreator = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxProcessTemplateID = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblPTID = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxProcessInstanceId = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lbPiid = new Infragistics.Win.Misc.UltraLabel().
        this-object:lblReassignPerformer = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxDueDate = new Infragistics.Win.UltraWinEditors.UltraDateTimeEditor().
        this-object:lblDueDate = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxCreatedDate = new Infragistics.Win.UltraWinEditors.UltraDateTimeEditor().
        this-object:lblCreatedDate = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxCurrentPerformer = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblCurrentPerformer = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxPriority = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblPriority = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxReassignToPerformer = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:uxReassignPerformer = new Infragistics.Win.Misc.UltraButton().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:uxProcessInstanceName = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblProcessInstanceName = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxWorkItemName = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblTaskNameLabel = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxCompleteTask = new Infragistics.Win.Misc.UltraButton().
        cast(this-object:uxTaskDetail, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:uxTaskDetail:SuspendLayout().
        cast(this-object:uxDataslots, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bsDataSlots, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxWorkItemStatus, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxWorkStepName, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxWorkItemId, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxProcessInstanceCreator, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxProcessTemplateID, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxProcessInstanceId, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxDueDate, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxCreatedDate, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxCurrentPerformer, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxPriority, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxReassignToPerformer, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxProcessInstanceName, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxWorkItemName, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* uxTaskDetail */
        /*  */
        this-object:uxTaskDetail:CaptionAlignment = Infragistics.Win.Misc.GroupBoxCaptionAlignment:Center.
        this-object:uxTaskDetail:Controls:Add(this-object:uxDataslots).
        this-object:uxTaskDetail:Controls:Add(this-object:uxWorkItemStatus).
        this-object:uxTaskDetail:Controls:Add(this-object:lblWIStatus).
        this-object:uxTaskDetail:Controls:Add(this-object:uxWorkStepName).
        this-object:uxTaskDetail:Controls:Add(this-object:lblWSName).
        this-object:uxTaskDetail:Controls:Add(this-object:uxWorkItemId).
        this-object:uxTaskDetail:Controls:Add(this-object:lblWIID).
        this-object:uxTaskDetail:Controls:Add(this-object:uxProcessInstanceCreator).
        this-object:uxTaskDetail:Controls:Add(this-object:lblProcessInstanceCreator).
        this-object:uxTaskDetail:Controls:Add(this-object:uxProcessTemplateID).
        this-object:uxTaskDetail:Controls:Add(this-object:lblPTID).
        this-object:uxTaskDetail:Controls:Add(this-object:uxProcessInstanceId).
        this-object:uxTaskDetail:Controls:Add(this-object:lbPiid).
        this-object:uxTaskDetail:Controls:Add(this-object:lblReassignPerformer).
        this-object:uxTaskDetail:Controls:Add(this-object:uxDueDate).
        this-object:uxTaskDetail:Controls:Add(this-object:lblDueDate).
        this-object:uxTaskDetail:Controls:Add(this-object:uxCreatedDate).
        this-object:uxTaskDetail:Controls:Add(this-object:lblCreatedDate).
        this-object:uxTaskDetail:Controls:Add(this-object:uxCurrentPerformer).
        this-object:uxTaskDetail:Controls:Add(this-object:lblCurrentPerformer).
        this-object:uxTaskDetail:Controls:Add(this-object:uxPriority).
        this-object:uxTaskDetail:Controls:Add(this-object:lblPriority).
        this-object:uxTaskDetail:Controls:Add(this-object:uxReassignToPerformer).
        this-object:uxTaskDetail:Controls:Add(this-object:uxReassignPerformer).
        this-object:uxTaskDetail:Controls:Add(this-object:uxProcessInstanceName).
        this-object:uxTaskDetail:Controls:Add(this-object:lblProcessInstanceName).
        this-object:uxTaskDetail:Controls:Add(this-object:uxWorkItemName).
        this-object:uxTaskDetail:Controls:Add(this-object:lblTaskNameLabel).
        this-object:uxTaskDetail:Controls:Add(this-object:uxCompleteTask).
        this-object:uxTaskDetail:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uxTaskDetail:Location = new System.Drawing.Point(0, 0).
        this-object:uxTaskDetail:Name = "uxTaskDetail".
        this-object:uxTaskDetail:Size = new System.Drawing.Size(623, 494).
        this-object:uxTaskDetail:TabIndex = 0.
        this-object:uxTaskDetail:Text = "Task Details".
        /*  */
        /* uxDataslots */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        this-object:uxDataslots:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:uxDataslots:DataMember = ?.
        this-object:uxDataslots:DataSource = this-object:bsDataSlots.
        appearance13:BackColor = System.Drawing.SystemColors:Window.
        appearance13:BorderColor = System.Drawing.SystemColors:InactiveCaption.
        this-object:uxDataslots:DisplayLayout:Appearance = appearance13.
        ultraGridColumn1:Header:VisiblePosition = 5.
        ultraGridColumn2:Header:VisiblePosition = 2.
        ultraGridColumn3:Header:VisiblePosition = 3.
        ultraGridColumn4:Header:VisiblePosition = 0.
        ultraGridColumn5:Header:VisiblePosition = 6.
        ultraGridColumn6:Header:VisiblePosition = 7.
        ultraGridColumn7:Header:VisiblePosition = 4.
        ultraGridColumn8:Header:VisiblePosition = 1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as System.Object extent 8 no-undo.
        arrayvar0[1] = ultraGridColumn1.
        arrayvar0[2] = ultraGridColumn2.
        arrayvar0[3] = ultraGridColumn3.
        arrayvar0[4] = ultraGridColumn4.
        arrayvar0[5] = ultraGridColumn5.
        arrayvar0[6] = ultraGridColumn6.
        arrayvar0[7] = ultraGridColumn7.
        arrayvar0[8] = ultraGridColumn8.
        ultraGridBand1:Columns:AddRange(arrayvar0).
        this-object:uxDataslots:DisplayLayout:BandsSerializer:Add(ultraGridBand1).
        this-object:uxDataslots:DisplayLayout:BorderStyle = Infragistics.Win.UIElementBorderStyle:Solid.
        this-object:uxDataslots:DisplayLayout:CaptionVisible = Infragistics.Win.DefaultableBoolean:False.
        appearance14:BackColor = System.Drawing.SystemColors:ActiveBorder.
        appearance14:BackColor2 = System.Drawing.SystemColors:ControlDark.
        appearance14:BackGradientStyle = Infragistics.Win.GradientStyle:Vertical.
        appearance14:BorderColor = System.Drawing.SystemColors:Window.
        this-object:uxDataslots:DisplayLayout:GroupByBox:Appearance = appearance14.
        appearance15:ForeColor = System.Drawing.SystemColors:GrayText.
        this-object:uxDataslots:DisplayLayout:GroupByBox:BandLabelAppearance = appearance15.
        this-object:uxDataslots:DisplayLayout:GroupByBox:BorderStyle = Infragistics.Win.UIElementBorderStyle:Solid.
        appearance16:BackColor = System.Drawing.SystemColors:ControlLightLight.
        appearance16:BackColor2 = System.Drawing.SystemColors:Control.
        appearance16:BackGradientStyle = Infragistics.Win.GradientStyle:Horizontal.
        appearance16:ForeColor = System.Drawing.SystemColors:GrayText.
        this-object:uxDataslots:DisplayLayout:GroupByBox:PromptAppearance = appearance16.
        this-object:uxDataslots:DisplayLayout:MaxColScrollRegions = 1.
        this-object:uxDataslots:DisplayLayout:MaxRowScrollRegions = 1.
        appearance17:BackColor = System.Drawing.SystemColors:Window.
        appearance17:ForeColor = System.Drawing.SystemColors:ControlText.
        this-object:uxDataslots:DisplayLayout:Override:ActiveCellAppearance = appearance17.
        appearance18:BackColor = System.Drawing.SystemColors:Highlight.
        appearance18:ForeColor = System.Drawing.SystemColors:HighlightText.
        this-object:uxDataslots:DisplayLayout:Override:ActiveRowAppearance = appearance18.
        this-object:uxDataslots:DisplayLayout:Override:AllowAddNew = Infragistics.Win.UltraWinGrid.AllowAddNew:Yes.
        this-object:uxDataslots:DisplayLayout:Override:AllowDelete = Infragistics.Win.DefaultableBoolean:False.
        this-object:uxDataslots:DisplayLayout:Override:AllowUpdate = Infragistics.Win.DefaultableBoolean:True.
        this-object:uxDataslots:DisplayLayout:Override:BorderStyleCell = Infragistics.Win.UIElementBorderStyle:Dotted.
        this-object:uxDataslots:DisplayLayout:Override:BorderStyleRow = Infragistics.Win.UIElementBorderStyle:Dotted.
        appearance19:BackColor = System.Drawing.SystemColors:Window.
        this-object:uxDataslots:DisplayLayout:Override:CardAreaAppearance = appearance19.
        appearance20:BorderColor = System.Drawing.Color:Silver.
        appearance20:TextTrimming = Infragistics.Win.TextTrimming:EllipsisCharacter.
        this-object:uxDataslots:DisplayLayout:Override:CellAppearance = appearance20.
        this-object:uxDataslots:DisplayLayout:Override:CellClickAction = Infragistics.Win.UltraWinGrid.CellClickAction:Edit.
        this-object:uxDataslots:DisplayLayout:Override:CellPadding = 0.
        appearance21:BackColor = System.Drawing.SystemColors:Control.
        appearance21:BackColor2 = System.Drawing.SystemColors:ControlDark.
        appearance21:BackGradientAlignment = Infragistics.Win.GradientAlignment:Element.
        appearance21:BackGradientStyle = Infragistics.Win.GradientStyle:Horizontal.
        appearance21:BorderColor = System.Drawing.SystemColors:Window.
        this-object:uxDataslots:DisplayLayout:Override:GroupByRowAppearance = appearance21.
        appearance22:TextHAlignAsString = "Left".
        this-object:uxDataslots:DisplayLayout:Override:HeaderAppearance = appearance22.
        this-object:uxDataslots:DisplayLayout:Override:HeaderClickAction = Infragistics.Win.UltraWinGrid.HeaderClickAction:ExternalSortSingle.
        this-object:uxDataslots:DisplayLayout:Override:HeaderStyle = Infragistics.Win.HeaderStyle:WindowsXPCommand.
        appearance23:BackColor = System.Drawing.SystemColors:Window.
        appearance23:BorderColor = System.Drawing.Color:Silver.
        this-object:uxDataslots:DisplayLayout:Override:RowAppearance = appearance23.
        this-object:uxDataslots:DisplayLayout:Override:RowSelectors = Infragistics.Win.DefaultableBoolean:False.
        appearance24:BackColor = System.Drawing.SystemColors:ControlLight.
        this-object:uxDataslots:DisplayLayout:Override:TemplateAddRowAppearance = appearance24.
        this-object:uxDataslots:DisplayLayout:ScrollBounds = Infragistics.Win.UltraWinGrid.ScrollBounds:ScrollToFill.
        this-object:uxDataslots:DisplayLayout:ScrollStyle = Infragistics.Win.UltraWinGrid.ScrollStyle:Immediate.
        this-object:uxDataslots:DisplayLayout:ViewStyleBand = Infragistics.Win.UltraWinGrid.ViewStyleBand:OutlookGroupBy.
        this-object:uxDataslots:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25, System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        this-object:uxDataslots:Location = new System.Drawing.Point(4, 259).
        this-object:uxDataslots:Name = "uxDataslots".
        this-object:uxDataslots:Size = new System.Drawing.Size(616, 232).
        this-object:uxDataslots:TabIndex = 29.
        this-object:uxDataslots:Text = "Dataslots".
        this-object:uxDataslots:AfterSortChange:Subscribe(this-object:uxDataslots_AfterSortChange).
        this-object:uxDataslots:BeforeRowUpdate:Subscribe(this-object:uxDataslots_BeforeRowUpdate).
        /*  */
        /* bsDataSlots */
        /*  */
        this-object:bsDataSlots:MaxDataGuess = 0.
        this-object:bsDataSlots:NoLOBs = false.
        this-object:bsDataSlots:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar1 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 8 no-undo.
        arrayvar2[1] = new Progress.Data.ColumnPropDesc("Choices", "", Progress.Data.DataType:CHARACTER).
        arrayvar2[2] = new Progress.Data.ColumnPropDesc("ReadOnly", "", Progress.Data.DataType:LOGICAL).
        arrayvar2[3] = new Progress.Data.ColumnPropDesc("WriteOnly", "", Progress.Data.DataType:LOGICAL).
        arrayvar2[4] = new Progress.Data.ColumnPropDesc("Name", "", Progress.Data.DataType:CHARACTER).
        arrayvar2[5] = new Progress.Data.ColumnPropDesc("ProcessInstanceId", "", Progress.Data.DataType:INT64).
        arrayvar2[6] = new Progress.Data.ColumnPropDesc("ProcessTemplateId", "", Progress.Data.DataType:INT64).
        arrayvar2[7] = new Progress.Data.ColumnPropDesc("Type", "", Progress.Data.DataType:CHARACTER).
        arrayvar2[8] = new Progress.Data.ColumnPropDesc("DataSlotValue", "Value", Progress.Data.DataType:CHARACTER).
        tableDesc1:Columns = arrayvar2.
        this-object:bsDataSlots:TableSchema = tableDesc1.
        /*  */
        /* uxWorkItemStatus */
        /*  */
        this-object:uxWorkItemStatus:Location = new System.Drawing.Point(458, 100).
        this-object:uxWorkItemStatus:Name = "uxWorkItemStatus".
        this-object:uxWorkItemStatus:ReadOnly = true.
        this-object:uxWorkItemStatus:ShowOverflowIndicator = true.
        this-object:uxWorkItemStatus:Size = new System.Drawing.Size(149, 21).
        this-object:uxWorkItemStatus:TabIndex = 28.
        /*  */
        /* lblWIStatus */
        /*  */
        this-object:lblWIStatus:AutoSize = true.
        this-object:lblWIStatus:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblWIStatus:Location = new System.Drawing.Point(361, 104).
        this-object:lblWIStatus:Name = "lblWIStatus".
        this-object:lblWIStatus:Size = new System.Drawing.Size(91, 14).
        this-object:lblWIStatus:TabIndex = 27.
        this-object:lblWIStatus:Text = "Work Item Status".
        /*  */
        /* uxWorkStepName */
        /*  */
        this-object:uxWorkStepName:Location = new System.Drawing.Point(458, 73).
        this-object:uxWorkStepName:Name = "uxWorkStepName".
        this-object:uxWorkStepName:ReadOnly = true.
        this-object:uxWorkStepName:ShowOverflowIndicator = true.
        this-object:uxWorkStepName:Size = new System.Drawing.Size(149, 21).
        this-object:uxWorkStepName:TabIndex = 26.
        /*  */
        /* lblWSName */
        /*  */
        this-object:lblWSName:AutoSize = true.
        this-object:lblWSName:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblWSName:Location = new System.Drawing.Point(367, 77).
        this-object:lblWSName:Name = "lblWSName".
        this-object:lblWSName:Size = new System.Drawing.Size(85, 14).
        this-object:lblWSName:TabIndex = 25.
        this-object:lblWSName:Text = "Workstep Name".
        /*  */
        /* uxWorkItemId */
        /*  */
        this-object:uxWorkItemId:Location = new System.Drawing.Point(458, 46).
        this-object:uxWorkItemId:Name = "uxWorkItemId".
        this-object:uxWorkItemId:ReadOnly = true.
        this-object:uxWorkItemId:ShowOverflowIndicator = true.
        this-object:uxWorkItemId:Size = new System.Drawing.Size(149, 21).
        this-object:uxWorkItemId:TabIndex = 24.
        /*  */
        /* lblWIID */
        /*  */
        this-object:lblWIID:AutoSize = true.
        this-object:lblWIID:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblWIID:Location = new System.Drawing.Point(384, 50).
        this-object:lblWIID:Name = "lblWIID".
        this-object:lblWIID:Size = new System.Drawing.Size(68, 14).
        this-object:lblWIID:TabIndex = 23.
        this-object:lblWIID:Text = "Work Item Id".
        /*  */
        /* uxProcessInstanceCreator */
        /*  */
        this-object:uxProcessInstanceCreator:Location = new System.Drawing.Point(146, 100).
        this-object:uxProcessInstanceCreator:Name = "uxProcessInstanceCreator".
        this-object:uxProcessInstanceCreator:ReadOnly = true.
        this-object:uxProcessInstanceCreator:ShowOverflowIndicator = true.
        this-object:uxProcessInstanceCreator:Size = new System.Drawing.Size(149, 21).
        this-object:uxProcessInstanceCreator:TabIndex = 22.
        /*  */
        /* lblProcessInstanceCreator */
        /*  */
        this-object:lblProcessInstanceCreator:AutoSize = true.
        this-object:lblProcessInstanceCreator:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblProcessInstanceCreator:Location = new System.Drawing.Point(8, 104).
        this-object:lblProcessInstanceCreator:Name = "lblProcessInstanceCreator".
        this-object:lblProcessInstanceCreator:Size = new System.Drawing.Size(132, 14).
        this-object:lblProcessInstanceCreator:TabIndex = 21.
        this-object:lblProcessInstanceCreator:Text = "Process Instance Creator".
        /*  */
        /* uxProcessTemplateID */
        /*  */
        this-object:uxProcessTemplateID:Location = new System.Drawing.Point(146, 73).
        this-object:uxProcessTemplateID:Name = "uxProcessTemplateID".
        this-object:uxProcessTemplateID:ReadOnly = true.
        this-object:uxProcessTemplateID:ShowOverflowIndicator = true.
        this-object:uxProcessTemplateID:Size = new System.Drawing.Size(149, 21).
        this-object:uxProcessTemplateID:TabIndex = 20.
        /*  */
        /* lblPTID */
        /*  */
        this-object:lblPTID:AutoSize = true.
        this-object:lblPTID:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblPTID:Location = new System.Drawing.Point(30, 77).
        this-object:lblPTID:Name = "lblPTID".
        this-object:lblPTID:Size = new System.Drawing.Size(110, 14).
        this-object:lblPTID:TabIndex = 19.
        this-object:lblPTID:Text = "Process Template ID".
        /*  */
        /* uxProcessInstanceId */
        /*  */
        this-object:uxProcessInstanceId:Location = new System.Drawing.Point(146, 46).
        this-object:uxProcessInstanceId:Name = "uxProcessInstanceId".
        this-object:uxProcessInstanceId:ReadOnly = true.
        this-object:uxProcessInstanceId:ShowOverflowIndicator = true.
        this-object:uxProcessInstanceId:Size = new System.Drawing.Size(149, 21).
        this-object:uxProcessInstanceId:TabIndex = 18.
        /*  */
        /* lbPiid */
        /*  */
        this-object:lbPiid:AutoSize = true.
        this-object:lbPiid:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lbPiid:Location = new System.Drawing.Point(35, 50).
        this-object:lbPiid:Name = "lbPiid".
        this-object:lbPiid:Size = new System.Drawing.Size(105, 14).
        this-object:lbPiid:TabIndex = 17.
        this-object:lbPiid:Text = "Process Instance ID".
        /*  */
        /* lblReassignPerformer */
        /*  */
        this-object:lblReassignPerformer:AutoSize = true.
        this-object:lblReassignPerformer:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblReassignPerformer:Location = new System.Drawing.Point(331, 187).
        this-object:lblReassignPerformer:Name = "lblReassignPerformer".
        this-object:lblReassignPerformer:Size = new System.Drawing.Size(121, 14).
        this-object:lblReassignPerformer:TabIndex = 15.
        this-object:lblReassignPerformer:Text = "Reassign To Performer".
        /*  */
        /* uxDueDate */
        /*  */
        this-object:uxDueDate:Location = new System.Drawing.Point(146, 156).
        this-object:uxDueDate:MaskInput = "~{date~} ~{time~}".
        this-object:uxDueDate:Name = "uxDueDate".
        this-object:uxDueDate:ReadOnly = true.
        this-object:uxDueDate:Size = new System.Drawing.Size(144, 21).
        this-object:uxDueDate:TabIndex = 14.
        /*  */
        /* lblDueDate */
        /*  */
        this-object:lblDueDate:AutoSize = true.
        this-object:lblDueDate:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblDueDate:Location = new System.Drawing.Point(97, 160).
        this-object:lblDueDate:Name = "lblDueDate".
        this-object:lblDueDate:Size = new System.Drawing.Size(43, 14).
        this-object:lblDueDate:TabIndex = 13.
        this-object:lblDueDate:Text = "Due On".
        /*  */
        /* uxCreatedDate */
        /*  */
        this-object:uxCreatedDate:DateTime = Progress.Util.DateTimeHelper:Create(2010, 7, 9, 0, 0, 32, 0).
        this-object:uxCreatedDate:Location = new System.Drawing.Point(146, 129).
        this-object:uxCreatedDate:MaskInput = "~{date~} ~{time~}".
        this-object:uxCreatedDate:Name = "uxCreatedDate".
        this-object:uxCreatedDate:ReadOnly = true.
        this-object:uxCreatedDate:Size = new System.Drawing.Size(144, 21).
        this-object:uxCreatedDate:TabIndex = 12.
        this-object:uxCreatedDate:Value = Progress.Util.DateTimeHelper:Create(2010, 7, 9, 0, 0, 32, 0).
        /*  */
        /* lblCreatedDate */
        /*  */
        this-object:lblCreatedDate:AutoSize = true.
        this-object:lblCreatedDate:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblCreatedDate:Location = new System.Drawing.Point(77, 133).
        this-object:lblCreatedDate:Name = "lblCreatedDate".
        this-object:lblCreatedDate:Size = new System.Drawing.Size(63, 14).
        this-object:lblCreatedDate:TabIndex = 11.
        this-object:lblCreatedDate:Text = "Created On".
        /*  */
        /* uxCurrentPerformer */
        /*  */
        this-object:uxCurrentPerformer:Location = new System.Drawing.Point(458, 156).
        this-object:uxCurrentPerformer:Name = "uxCurrentPerformer".
        this-object:uxCurrentPerformer:ReadOnly = true.
        this-object:uxCurrentPerformer:ShowOverflowIndicator = true.
        this-object:uxCurrentPerformer:Size = new System.Drawing.Size(149, 21).
        this-object:uxCurrentPerformer:TabIndex = 10.
        /*  */
        /* lblCurrentPerformer */
        /*  */
        this-object:lblCurrentPerformer:AutoSize = true.
        this-object:lblCurrentPerformer:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblCurrentPerformer:Location = new System.Drawing.Point(361, 160).
        this-object:lblCurrentPerformer:Name = "lblCurrentPerformer".
        this-object:lblCurrentPerformer:Size = new System.Drawing.Size(95, 14).
        this-object:lblCurrentPerformer:TabIndex = 9.
        this-object:lblCurrentPerformer:Text = "Current Performer".
        /*  */
        /* uxPriority */
        /*  */
        this-object:uxPriority:Location = new System.Drawing.Point(458, 129).
        this-object:uxPriority:Name = "uxPriority".
        this-object:uxPriority:ReadOnly = true.
        this-object:uxPriority:ShowOverflowIndicator = true.
        this-object:uxPriority:Size = new System.Drawing.Size(149, 21).
        this-object:uxPriority:TabIndex = 8.
        /*  */
        /* lblPriority */
        /*  */
        this-object:lblPriority:AutoSize = true.
        this-object:lblPriority:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblPriority:Location = new System.Drawing.Point(412, 133).
        this-object:lblPriority:Name = "lblPriority".
        this-object:lblPriority:Size = new System.Drawing.Size(40, 14).
        this-object:lblPriority:TabIndex = 7.
        this-object:lblPriority:Text = "Priority".
        /*  */
        /* uxReassignToPerformer */
        /*  */
        this-object:uxReassignToPerformer:Location = new System.Drawing.Point(458, 183).
        this-object:uxReassignToPerformer:Name = "uxReassignToPerformer".
        this-object:uxReassignToPerformer:Size = new System.Drawing.Size(149, 21).
        this-object:uxReassignToPerformer:TabIndex = 6.
        /*  */
        /* uxReassignPerformer */
        /*  */
        appearance26:Image = "arrow_switch_32x32.png".
        this-object:uxReassignPerformer:Appearance = appearance26.
        this-object:uxReassignPerformer:ImageList = this-object:imageList1.
        this-object:uxReassignPerformer:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxReassignPerformer:Location = new System.Drawing.Point(458, 209).
        this-object:uxReassignPerformer:Name = "uxReassignPerformer".
        this-object:uxReassignPerformer:Size = new System.Drawing.Size(149, 40).
        this-object:uxReassignPerformer:TabIndex = 5.
        this-object:uxReassignPerformer:Text = "Reassign Performer".
        this-object:uxReassignPerformer:Click:Subscribe(this-object:uxReassignPerformer_Click).
        /*  */
        /* imageList1 */
        /*  */
        this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageList1:Images:SetKeyName(0, "Knob Forward.png").
        this-object:imageList1:Images:SetKeyName(1, "arrow_switch_32x32.png").
        /*  */
        /* uxProcessInstanceName */
        /*  */
        this-object:uxProcessInstanceName:Location = new System.Drawing.Point(146, 19).
        this-object:uxProcessInstanceName:Name = "uxProcessInstanceName".
        this-object:uxProcessInstanceName:ReadOnly = true.
        this-object:uxProcessInstanceName:ShowOverflowIndicator = true.
        this-object:uxProcessInstanceName:Size = new System.Drawing.Size(149, 21).
        this-object:uxProcessInstanceName:TabIndex = 4.
        /*  */
        /* lblProcessInstanceName */
        /*  */
        this-object:lblProcessInstanceName:AutoSize = true.
        this-object:lblProcessInstanceName:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblProcessInstanceName:Location = new System.Drawing.Point(16, 23).
        this-object:lblProcessInstanceName:Name = "lblProcessInstanceName".
        this-object:lblProcessInstanceName:Size = new System.Drawing.Size(124, 14).
        this-object:lblProcessInstanceName:TabIndex = 3.
        this-object:lblProcessInstanceName:Text = "Process Instance Name".
        /*  */
        /* uxWorkItemName */
        /*  */
        this-object:uxWorkItemName:Location = new System.Drawing.Point(458, 19).
        this-object:uxWorkItemName:Name = "uxWorkItemName".
        this-object:uxWorkItemName:ReadOnly = true.
        this-object:uxWorkItemName:ShowOverflowIndicator = true.
        this-object:uxWorkItemName:Size = new System.Drawing.Size(149, 21).
        this-object:uxWorkItemName:TabIndex = 2.
        /*  */
        /* lblTaskNameLabel */
        /*  */
        this-object:lblTaskNameLabel:AutoSize = true.
        this-object:lblTaskNameLabel:Location = new System.Drawing.Point(390, 23).
        this-object:lblTaskNameLabel:Name = "lblTaskNameLabel".
        this-object:lblTaskNameLabel:Size = new System.Drawing.Size(62, 14).
        this-object:lblTaskNameLabel:TabIndex = 1.
        this-object:lblTaskNameLabel:Text = "Task Name".
        /*  */
        /* uxCompleteTask */
        /*  */
        appearance27:Image = "Knob Forward.png".
        this-object:uxCompleteTask:Appearance = appearance27.
        this-object:uxCompleteTask:ImageList = this-object:imageList1.
        this-object:uxCompleteTask:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxCompleteTask:Location = new System.Drawing.Point(303, 209).
        this-object:uxCompleteTask:Name = "uxCompleteTask".
        this-object:uxCompleteTask:Size = new System.Drawing.Size(149, 40).
        this-object:uxCompleteTask:TabIndex = 0.
        this-object:uxCompleteTask:Text = "Complete Task".
        this-object:uxCompleteTask:Click:Subscribe(this-object:uxCompleteTask_Click).
        /*  */
        /* SavvionTaskDetailUC */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(6, 13).
        this-object:Controls:Add(this-object:uxTaskDetail).
        this-object:Name = "SavvionTaskDetailUC".
        this-object:Size = new System.Drawing.Size(623, 494).
        cast(this-object:uxTaskDetail, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:uxTaskDetail:ResumeLayout(false).
        this-object:uxTaskDetail:PerformLayout().
        cast(this-object:uxDataslots, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bsDataSlots, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxWorkItemStatus, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxWorkStepName, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxWorkItemId, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxProcessInstanceCreator, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxProcessTemplateID, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxProcessInstanceId, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxDueDate, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxCreatedDate, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxCurrentPerformer, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxPriority, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxReassignToPerformer, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxProcessInstanceName, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxWorkItemName, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    method private void uxCompleteTask_Click( input sender as System.Object, input e as System.EventArgs ):
        BpmServer:CompleteTask(CurrentTask).
    end method.

    @VisualDesigner.
    method private void uxDataslots_BeforeRowUpdate( input sender as System.Object, input e as Infragistics.Win.UltraWinGrid.CancelableRowEventArgs ):
        define variable oRow as UltraGridRow no-undo.
        
        define variable oDSI as DataSlotInstance no-undo.        
        define variable hBuffer as handle no-undo.
        define variable cValue as longchar no-undo.
        
        uxDataslots:PerformAction(UltraGridAction:ExitEditMode).
        
        /* write screen contents to dataset */
        bsDataSlots:Assign().
        
        hBuffer = bsDataSlots:Handle:get-buffer-handle('DataSlotInstance').
        
        do transaction:
            oDSI = cast(hBuffer::DataSlotInstance, DataSlotInstance).
            oDSI:Value = hBuffer::DataSlotValue.
        end.
    end method.

    method private void uxReassignPerformer_Click( input sender as System.Object, input e as System.EventArgs ):
        ReassignTask(CurrentTask, uxReassignPerformer:Text).
        
        uxReassignPerformer:Text = ''.
    end method.
    
    destructor public SavvionTaskDetailUC ( ):
        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.

    @VisualDesigner.
    method private void uxDataslots_AfterSortChange( input sender as System.Object, input e as Infragistics.Win.UltraWinGrid.BandEventArgs ):
        define variable hQuery as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable cKey as character extent no-undo.
        define variable cSort as character no-undo.
        define variable oSortedColumn as UltraGridColumn no-undo.
        define variable iLoop as integer no-undo.
        define variable iMax as integer no-undo.
        
        hQuery = bsDataSlots:Handle.
        hBuffer = hQuery:get-buffer-handle(1).
        
        cKey = Query:GetCurrentRowKey(hQuery). 
        
        iMax = e:Band:SortedColumns:Count.
        
        do iLoop = 0 to (iMax - 1):
            oSortedColumn = e:Band:SortedColumns[iLoop].
            cSort = cSort 
                  + ' by ' + oSortedColumn:Band:Key + '.' + oSortedColumn:Key.
            
            if EnumHelper:AreEqual(oSortedColumn:SortIndicator, SortIndicator:Descending) then
                cSort = cSort + ' descending '.
        end.
        
        hQuery:query-prepare('preselect each ' + hBuffer:name + cSort).
        hQuery:query-open().
        
        Query:Reposition(hQuery, cKey).
    end method.
    
    method public void ReassignTask(poTask as Task, pcPerformer as character):
        case poTask:WorkItem:Status:
            when WorkItemStatusEnum:Assigned then
                BpmServer:ReassignWorkItem(poTask:WorkItem:Id, pcPerformer).
            otherwise
                BpmServer:AssignWorkItem(poTask:WorkItem:Id, pcPerformer).
        end case.
    end method.
    
    method public void CompleteTask(poTask as Task):
        BpmServer:CompleteTask(poTask).
        
        OnCurrentTaskCompleted(poTask).
    end method.
    
    method protected void OnCurrentTaskCompleted(input poTask as Task):
        TaskCompleted:Publish(this-object, poTask).
    end method.
    
end class.
