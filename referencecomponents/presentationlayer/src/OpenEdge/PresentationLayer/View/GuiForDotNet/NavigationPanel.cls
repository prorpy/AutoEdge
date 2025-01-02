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
    File        : NavigationPanel
    Purpose     : 
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 05 15:34:22 EST 2009
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw. 

using OpenEdge.PresentationLayer.View.INavigationPanelView.
using OpenEdge.PresentationLayer.View.GuiForDotNet.MVPUserControl.
using OpenEdge.PresentationLayer.Common.ISelectToolbarAction.
using OpenEdge.PresentationLayer.Common.NavigationActionEnum.
using OpenEdge.PresentationLayer.Common.ActionStateEnum.
using OpenEdge.PresentationLayer.Common.ToolbarActionEventArgs.
using OpenEdge.PresentationLayer.Common.ToolbarActionTypeEnum.
using OpenEdge.Lang.DataTypeEnum.

using Progress.Lang.Error.

class OpenEdge.PresentationLayer.View.GuiForDotNet.NavigationPanel
        inherits MVPUserControl
        implements INavigationPanelView:
    
    define private variable components as System.ComponentModel.IContainer no-undo.

    define private variable uxFirst as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxLast as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxNext as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxPrev as Infragistics.Win.Misc.UltraButton no-undo.

    define private variable uxGroupBox as Infragistics.Win.Misc.UltraGroupBox no-undo.

    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.

    constructor public NavigationPanel (  ):
        super().
        InitializeComponent().
        
        catch e as Error:            
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
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("OpenEdge.PresentationLayer.View.GuiForDotNet.NavigationPanel").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance2 as Infragistics.Win.Appearance no-undo.
        appearance2 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance3 as Infragistics.Win.Appearance no-undo.
        appearance3 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance4 as Infragistics.Win.Appearance no-undo.
        appearance4 = new Infragistics.Win.Appearance().
        this-object:uxFirst = new Infragistics.Win.Misc.UltraButton().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:uxLast = new Infragistics.Win.Misc.UltraButton().
        this-object:uxNext = new Infragistics.Win.Misc.UltraButton().
        this-object:uxPrev = new Infragistics.Win.Misc.UltraButton().
        this-object:uxGroupBox = new Infragistics.Win.Misc.UltraGroupBox().
        cast(this-object:uxGroupBox, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:uxGroupBox:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* uxFirst */
        /*  */
        appearance1:Image = "resultset_first.png".
        this-object:uxFirst:Appearance = appearance1.
        this-object:uxFirst:ImageList = this-object:imageList1.
        this-object:uxFirst:Location = new System.Drawing.Point(6, 5).
        this-object:uxFirst:Name = "uxFirst".
        this-object:uxFirst:Size = new System.Drawing.Size(75, 23).
        this-object:uxFirst:TabIndex = 0.
        this-object:uxFirst:Text = "First".
        /*  */
        /* imageList1 */
        /*  */
        this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageList1:Images:SetKeyName(0, "resultset_previous.png").
        this-object:imageList1:Images:SetKeyName(1, "resultset_first.png").
        this-object:imageList1:Images:SetKeyName(2, "resultset_last.png").
        this-object:imageList1:Images:SetKeyName(3, "resultset_next.png").
        /*  */
        /* uxLast */
        /*  */
        appearance2:Image = "resultset_last.png".
        appearance2:ImageHAlign = Infragistics.Win.HAlign:Right.
        this-object:uxLast:Appearance = appearance2.
        this-object:uxLast:ImageList = this-object:imageList1.
        this-object:uxLast:Location = new System.Drawing.Point(249, 5).
        this-object:uxLast:Name = "uxLast".
        this-object:uxLast:Size = new System.Drawing.Size(75, 23).
        this-object:uxLast:TabIndex = 1.
        this-object:uxLast:Text = "Last".
        /*  */
        /* uxNext */
        /*  */
        appearance3:Image = "resultset_next.png".
        appearance3:ImageHAlign = Infragistics.Win.HAlign:Right.
        this-object:uxNext:Appearance = appearance3.
        this-object:uxNext:ImageList = this-object:imageList1.
        this-object:uxNext:Location = new System.Drawing.Point(168, 5).
        this-object:uxNext:Name = "uxNext".
        this-object:uxNext:Size = new System.Drawing.Size(75, 23).
        this-object:uxNext:TabIndex = 2.
        this-object:uxNext:Text = "Next".
        /*  */
        /* uxPrev */
        /*  */
        appearance4:Image = "resultset_previous.png".
        this-object:uxPrev:Appearance = appearance4.
        this-object:uxPrev:ImageList = this-object:imageList1.
        this-object:uxPrev:Location = new System.Drawing.Point(87, 5).
        this-object:uxPrev:Name = "uxPrev".
        this-object:uxPrev:Size = new System.Drawing.Size(75, 23).
        this-object:uxPrev:TabIndex = 3.
        this-object:uxPrev:Text = "Prev".
        /*  */
        /* uxGroupBox */
        /*  */
        this-object:uxGroupBox:Controls:Add(this-object:uxFirst).
        this-object:uxGroupBox:Controls:Add(this-object:uxLast).
        this-object:uxGroupBox:Controls:Add(this-object:uxNext).
        this-object:uxGroupBox:Controls:Add(this-object:uxPrev).
        this-object:uxGroupBox:Location = new System.Drawing.Point(3, 3).
        this-object:uxGroupBox:Name = "uxGroupBox".
        this-object:uxGroupBox:Size = new System.Drawing.Size(328, 35).
        this-object:uxGroupBox:TabIndex = 4.
        /*  */
        /* NavigationPanel */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(6, 13).
        this-object:Controls:Add(this-object:uxGroupBox).
        this-object:Name = "NavigationPanel".
        this-object:Size = new System.Drawing.Size(332, 40).
        cast(this-object:uxGroupBox, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:uxGroupBox:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.
    
    method protected void SelectAction (poAction as NavigationActionEnum):
        define variable oArgs as ToolbarActionEventArgs no-undo.
        
        oArgs = new ToolbarActionEventArgs(poAction:ToString(), ToolbarActionTypeEnum:Event).
        oArgs:SetArgValue('Action', poAction:ToString(), DataTypeEnum:Integer).
        
        cast(Presenter, ISelectToolbarAction):SelectToolbarAction(oArgs).                        
    end method.        
    
    method private void FirstButtonClick( input sender as System.Object, input e as System.EventArgs ):        
        SelectAction(NavigationActionEnum:First).
    end method.

    method private void PrevButtonClick( input sender as System.Object, input e as System.EventArgs ):
        SelectAction(NavigationActionEnum:Prev).
    end method.        

    method private void NextButtonClick( input sender as System.Object, input e as System.EventArgs ):
        SelectAction(NavigationActionEnum:Next).
    end method.        

    method private void LastButtonClick( input sender as System.Object, input e as System.EventArgs ):
        SelectAction(NavigationActionEnum:Last).
    end method.
            
    method public void NavigationStateChange (poActions as NavigationActionEnum extent, poStates as ActionStateEnum extent):
        define variable iLoop as integer no-undo.
        
        do iLoop = 1 to extent(poActions):
            case poActions[iLoop]:
                when NavigationActionEnum:First then uxFirst:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
                when NavigationActionEnum:Prev then uxPrev:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
                when NavigationActionEnum:Next then uxNext:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
                when NavigationActionEnum:Last then uxLast:Enabled = poStates[iLoop] eq ActionStateEnum:Enable.
            end case.
        end.
    end method.
        
    method override public void SubscribeEvents():
        this-object:uxFirst:Click:subscribe(this-object:FirstButtonClick).            
        this-object:uxPrev:Click:subscribe(this-object:PrevButtonClick).
        this-object:uxNext:Click:subscribe(this-object:NextButtonClick).
        this-object:uxLast:Click:subscribe(this-object:LastButtonClick).
    end method.

    destructor public NavigationPanel ( ):

        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.

    end destructor.

    method public void TableNameChange (pcTable as char):
        /* nothing doing */
    end method.
            
end class.
