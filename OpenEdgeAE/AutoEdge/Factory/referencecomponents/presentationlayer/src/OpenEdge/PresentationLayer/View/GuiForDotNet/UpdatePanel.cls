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
    File        : UpdatePanel View component
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 26 13:43:16 EST 2009
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using OpenEdge.PresentationLayer.View.GuiForDotNet.MVPUserControl.
using OpenEdge.PresentationLayer.View.IUpdatePanelView.
using OpenEdge.PresentationLayer.Common.ISelectToolbarAction.
using OpenEdge.PresentationLayer.Common.ToolbarActionEventArgs.
using OpenEdge.PresentationLayer.Common.ActionStateEnum.
using OpenEdge.PresentationLayer.Common.ToolbarActionTypeEnum.
using OpenEdge.PresentationLayer.Common.UndoActionEventArgs.
using OpenEdge.CommonInfrastructure.Common.IComponent.
using OpenEdge.CommonInfrastructure.Common.UpdateActionEnum.
using OpenEdge.Lang.DataTypeEnum.

using Infragistics.Win.UltraWinListView.UltraListViewItem.
using Infragistics.Win.UltraWinListView.UltraListViewMainColumn.

using Progress.Lang.Class.

class OpenEdge.PresentationLayer.View.GuiForDotNet.UpdatePanel 
        inherits MVPUserControl 
        implements IUpdatePanelView: 
    
    define private variable components as System.ComponentModel.IContainer no-undo.

    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.
    define private variable ultraGroupBox1 as Infragistics.Win.Misc.UltraGroupBox no-undo.
    define private variable uxAdd as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxCommit as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxDelete as Infragistics.Win.Misc.UltraButton no-undo.

    define private variable uxUndo as Infragistics.Win.Misc.UltraDropDownButton no-undo.

    define private variable ultraPopupControlContainer1 as Infragistics.Win.Misc.UltraPopupControlContainer no-undo.

    define private variable uxUndoActions as Infragistics.Win.UltraWinListView.UltraListView no-undo.

    define private variable bsUndoAction as Progress.Data.BindingSource no-undo.

    constructor public UpdatePanel (  ):
        super().
        
        PresenterService = Class:GetClass('OpenEdge.PresentationLayer.Presenter.IUpdatePanelPresenter').
        
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
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("OpenEdge.PresentationLayer.View.GuiForDotNet.UpdatePanel").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance2 as Infragistics.Win.Appearance no-undo.
        appearance2 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance1 as Infragistics.Win.Appearance no-undo.
        appearance1 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance6 as Infragistics.Win.Appearance no-undo.
        appearance6 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance5 as Infragistics.Win.Appearance no-undo.
        appearance5 = new Infragistics.Win.Appearance().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:ultraGroupBox1 = new Infragistics.Win.Misc.UltraGroupBox().
        this-object:uxUndoActions = new Infragistics.Win.UltraWinListView.UltraListView().
        this-object:uxUndo = new Infragistics.Win.Misc.UltraDropDownButton().
        this-object:ultraPopupControlContainer1 = new Infragistics.Win.Misc.UltraPopupControlContainer(this-object:components).
        this-object:uxCommit = new Infragistics.Win.Misc.UltraButton().
        this-object:uxDelete = new Infragistics.Win.Misc.UltraButton().
        this-object:uxAdd = new Infragistics.Win.Misc.UltraButton().
        this-object:bsUndoAction = new Progress.Data.BindingSource(this-object:components).
        cast(this-object:ultraGroupBox1, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:ultraGroupBox1:SuspendLayout().
        cast(this-object:uxUndoActions, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bsUndoAction, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* imageList1 */
        /*  */
        this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageList1:Images:SetKeyName(0, "tick.png").
        this-object:imageList1:Images:SetKeyName(1, "add.png").
        this-object:imageList1:Images:SetKeyName(2, "cancel.png").
        this-object:imageList1:Images:SetKeyName(3, "delete.png").
        this-object:imageList1:Images:SetKeyName(4, "arrow_undo.png").
        /*  */
        /* ultraGroupBox1 */
        /*  */
        this-object:ultraGroupBox1:Controls:Add(this-object:uxUndoActions).
        this-object:ultraGroupBox1:Controls:Add(this-object:uxUndo).
        this-object:ultraGroupBox1:Controls:Add(this-object:uxCommit).
        this-object:ultraGroupBox1:Controls:Add(this-object:uxDelete).
        this-object:ultraGroupBox1:Controls:Add(this-object:uxAdd).
        this-object:ultraGroupBox1:HeaderPosition = Infragistics.Win.Misc.GroupBoxHeaderPosition:TopOnBorder.
        this-object:ultraGroupBox1:Location = new System.Drawing.Point(3, 3).
        this-object:ultraGroupBox1:Name = "ultraGroupBox1".
        this-object:ultraGroupBox1:Size = new System.Drawing.Size(332, 48).
        this-object:ultraGroupBox1:TabIndex = 0.
        this-object:ultraGroupBox1:Text = "TableName".
        /*  */
        /* uxUndoActions */
        /*  */
        this-object:uxUndoActions:Location = new System.Drawing.Point(181, -44).
        this-object:uxUndoActions:MainColumn:AllowSorting = Infragistics.Win.DefaultableBoolean:False.
        this-object:uxUndoActions:MainColumn:DataType = Progress.Util.TypeHelper:GetType("System.Int32").
        this-object:uxUndoActions:Name = "uxUndoActions".
        this-object:uxUndoActions:Size = new System.Drawing.Size(121, 97).
        this-object:uxUndoActions:TabIndex = 7.
        this-object:uxUndoActions:Text = "uxUndoActions".
        this-object:uxUndoActions:View = Infragistics.Win.UltraWinListView.UltraListViewStyle:List.
        this-object:uxUndoActions:ViewSettingsDetails:ColumnsShowSortIndicators = false.
        this-object:uxUndoActions:ViewSettingsDetails:FullRowSelect = true.
        this-object:uxUndoActions:ViewSettingsDetails:ImageList = this-object:imageList1.
        this-object:uxUndoActions:ViewSettingsIcons:ImageList = this-object:imageList1.
        this-object:uxUndoActions:ViewSettingsList:ImageList = this-object:imageList1.
        this-object:uxUndoActions:ViewSettingsList:MultiColumn = false.
        this-object:uxUndoActions:Visible = false.
        /*  */
        /* uxUndo */
        /*  */
        appearance2:Image = "arrow_undo.png".
        appearance2:ImageHAlign = Infragistics.Win.HAlign:Right.
        this-object:uxUndo:Appearance = appearance2.
        this-object:uxUndo:ImageList = this-object:imageList1.
        this-object:uxUndo:Location = new System.Drawing.Point(169, 17).
        this-object:uxUndo:Name = "uxUndo".
        this-object:uxUndo:PopupItemKey = "uxUndoActions".
        this-object:uxUndo:PopupItemProvider = this-object:ultraPopupControlContainer1.
        this-object:uxUndo:Size = new System.Drawing.Size(75, 23).
        this-object:uxUndo:Style = Infragistics.Win.Misc.SplitButtonDisplayStyle:DropDownButtonOnly.
        this-object:uxUndo:TabIndex = 6.
        this-object:uxUndo:Text = "Undo".
        /*  */
        /* ultraPopupControlContainer1 */
        /*  */
        this-object:ultraPopupControlContainer1:PopupControl = this-object:uxUndoActions.
        /*  */
        /* uxCommit */
        /*  */
        appearance1:Image = "tick.png".
        appearance1:ImageHAlign = Infragistics.Win.HAlign:Right.
        this-object:uxCommit:Appearance = appearance1.
        this-object:uxCommit:ImageList = this-object:imageList1.
        this-object:uxCommit:Location = new System.Drawing.Point(250, 17).
        this-object:uxCommit:Name = "uxCommit".
        this-object:uxCommit:Size = new System.Drawing.Size(75, 23).
        this-object:uxCommit:TabIndex = 5.
        this-object:uxCommit:Text = "Commit".
        /*  */
        /* uxDelete */
        /*  */
        appearance6:Image = "delete.png".
        appearance6:ImageHAlign = Infragistics.Win.HAlign:Right.
        this-object:uxDelete:Appearance = appearance6.
        this-object:uxDelete:ImageList = this-object:imageList1.
        this-object:uxDelete:Location = new System.Drawing.Point(88, 17).
        this-object:uxDelete:Name = "uxDelete".
        this-object:uxDelete:Size = new System.Drawing.Size(75, 23).
        this-object:uxDelete:TabIndex = 2.
        this-object:uxDelete:Text = "Delete".
        /*  */
        /* uxAdd */
        /*  */
        appearance5:Image = "add.png".
        appearance5:ImageHAlign = Infragistics.Win.HAlign:Right.
        this-object:uxAdd:Appearance = appearance5.
        this-object:uxAdd:ImageList = this-object:imageList1.
        this-object:uxAdd:Location = new System.Drawing.Point(7, 17).
        this-object:uxAdd:Name = "uxAdd".
        this-object:uxAdd:Size = new System.Drawing.Size(75, 23).
        this-object:uxAdd:TabIndex = 0.
        this-object:uxAdd:Text = "Add".
        /*  */
        /* bsUndoAction */
        /*  */
        this-object:bsUndoAction:MaxDataGuess = 0.
        this-object:bsUndoAction:NoLOBs = false.
        this-object:bsUndoAction:TableSchema = ?.
        /*  */
        /* UpdatePanel */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(6, 13).
        this-object:Controls:Add(this-object:ultraGroupBox1).
        this-object:Name = "UpdatePanel".
        this-object:Size = new System.Drawing.Size(338, 56).
        cast(this-object:ultraGroupBox1, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ultraGroupBox1:ResumeLayout(false).
        cast(this-object:uxUndoActions, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bsUndoAction, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    destructor public UpdatePanel ( ):
        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.

    method override public void SubscribeEvents():
        this-object:uxCommit:Click:subscribe(this-object:CommitButtonClick).
        this-object:uxDelete:Click:subscribe(this-object:DeleteButtonClick).
        this-object:uxAdd:Click:subscribe(this-object:AddButtonClick).
        this-object:uxUndo:Click:subscribe(this-object:UndoButtonClick).
    end method.
    
    method override public void UnsubscribeEvents():
        this-object:uxCommit:Click:unsubscribe(this-object:CommitButtonClick).
        this-object:uxDelete:Click:unsubscribe(this-object:DeleteButtonClick).
        this-object:uxAdd:Click:unsubscribe(this-object:AddButtonClick).
        this-object:uxUndo:Click:unsubscribe(this-object:UndoButtonClick).
    end method.
    
    method private void CommitButtonClick( input sender as System.Object, input e as System.EventArgs ):
        SelectToolbarAction(UpdateActionEnum:Commit).
    end method.
    
    method private void DeleteButtonClick( input sender as System.Object, input e as System.EventArgs ):
        SelectToolbarAction(UpdateActionEnum:Delete).
    end method.

    method private void AddButtonClick( input sender as System.Object, input e as System.EventArgs ):
        SelectToolbarAction(UpdateActionEnum:Add).
    end method.        

    method private void UndoButtonClick( input sender as System.Object, input e as System.EventArgs ):
        SelectToolbarAction(UpdateActionEnum:Undo).
    end method.
    
    method protected void SelectToolbarAction (poAction as UpdateActionEnum):
        define variable oArgs as ToolbarActionEventArgs no-undo.
        
        oArgs = new ToolbarActionEventArgs(poAction:ToString(), ToolbarActionTypeEnum:Event).
        oArgs:SetArgValue('Action', poAction:ToString(), DataTypeEnum:Integer).
        
        cast(Presenter, ISelectToolbarAction):SelectToolbarAction(oArgs).                        
    end method.
            
    method public void UpdateStateChange (poActions as UpdateActionEnum extent, poStates as ActionStateEnum extent):
        define variable iLoop as integer no-undo.
        
        do iLoop = 1 to extent(poActions):
            case poActions[iLoop]:
                when UpdateActionEnum:Commit then uxCommit:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
                when UpdateActionEnum:Add then uxAdd:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
                when UpdateActionEnum:Delete then uxDelete:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
                when UpdateActionEnum:Undo then uxUndo:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
            end case.
        end.
    end method.
    
    method public void TableNameChange (pcTable as char):
        ultraGroupBox1:Text = pcTable.
    end method.
        
    method public void AddUndoActionHandler (poSender as IComponent, poEventArgs as UndoActionEventArgs):
        define variable oMainColumn as UltraListViewMainColumn no-undo.
        define variable oItem as UltraListViewItem no-undo.
        
        oItem = uxUndoActions:Items:Add(
            string(poEventArgs:Order),
            poEventArgs:RecordKey[1] ).
            
        oItem:Appearance:Image = "add.png".
        
        /*
        oMainColumn = uxUndoActions:MainColumn.
        oMainColumn:Text = poUndoToolbarActionEventArgs:RecordKey[1].
        */
        
    end method.        
        
end class.
