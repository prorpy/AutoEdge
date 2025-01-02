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
    File        : OrderListForm
    Purpose     :
    Syntax      :
    Description :
    @author pjudge
    Created     : Thu Dec 16 11:33:05 EST 2010
    Notes       :
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.

using Progress.Windows.Form.

using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.IUserContext.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.

using OpenEdge.Lang.WidgetHandle.
using OpenEdge.Lang.String.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Core.System.ApplicationError.
using OpenEdge.Core.System.UnhandledError.
using Progress.Lang.Error.

class AutoEdge.Factory.Client.Order.PresentationLayer.OrderListForm inherits Form:

    define private variable bsOrders as Progress.Data.BindingSource no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable uxOrders as Infragistics.Win.UltraWinGrid.UltraGrid no-undo.

    define private variable mhOrders as handle no-undo.

    /** (mandatory) The session's service manager. Used to determine the ServiceMessageManager and
        other managers for callbacks, context and more. */
    define protected property SvcMgr as IServiceManager no-undo
        get():
            if not valid-object(SvcMgr) then
                SvcMgr = cast(ABLSession:Instance:SessionProperties:Get(ServiceManager:IServiceManagerType), IServiceManager).

            return SvcMgr.
        end get.
        private set.

    /** The ConnectionManager is used plentifully; we keep it as a property so that
        we can get it whenever needed, without fuss. */
    define protected property ConnMgr as IConnectionManager no-undo
        get():
            if not valid-object(ConnMgr) then
                ConnMgr = cast(SvcMgr:GetService(ConnectionManager:IConnectionManagerType) , IConnectionManager).
            return ConnMgr.
        end get.
        private set.

    constructor public OrderListForm (  ):
        super().
        InitializeComponent().

        InitData().

        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
    end constructor.

    method private void InitializeComponent(  ):

        /* NOTE: The following method is automatically generated.

        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.

        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc1 as Progress.Data.TableDesc no-undo.
        tableDesc1 = new Progress.Data.TableDesc("eOrder").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc2 as Progress.Data.TableDesc no-undo.
        tableDesc2 = new Progress.Data.TableDesc("eOrderLine").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc3 as Progress.Data.TableDesc no-undo.
        tableDesc3 = new Progress.Data.TableDesc("eItem").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc4 as Progress.Data.TableDesc no-undo.
        tableDesc4 = new Progress.Data.TableDesc("eFinishedItem").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc5 as Progress.Data.TableDesc no-undo.
        tableDesc5 = new Progress.Data.TableDesc("eComponentItem").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance21 as Infragistics.Win.Appearance no-undo.
        appearance21 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridBand1 as Infragistics.Win.UltraWinGrid.UltraGridBand no-undo.
        ultraGridBand1 = new Infragistics.Win.UltraWinGrid.UltraGridBand("eOrder", -1).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn1 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn1 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("OrderNum").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn2 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn2 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("OrderId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn3 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn3 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("OrderDate").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn4 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn4 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("EnteredDate").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn5 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn5 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("FromEmail").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn6 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn6 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("CustomerNum").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn7 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn7 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("CustomerName").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn8 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn8 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("CustomerPO").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn9 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn9 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("OrderAmount").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn10 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn10 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("OrderStatus").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn11 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn11 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Instructions").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn12 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn12 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("SalesrepCode").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn13 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn13 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("DealerCode").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn14 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn14 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("eOrderLine").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridBand2 as Infragistics.Win.UltraWinGrid.UltraGridBand no-undo.
        ultraGridBand2 = new Infragistics.Win.UltraWinGrid.UltraGridBand("eOrderLine", 0).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn15 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn15 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("OrderId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn16 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn16 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("LineNum").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn17 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn17 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Price").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn18 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn18 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Quantity").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn19 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn19 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Discount").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn20 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn20 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ItemId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn21 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn21 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("OrderLineStatus").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn22 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn22 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("FinishedItemId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn23 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn23 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("eItem").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn24 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn24 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("eFinishedItem").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridBand3 as Infragistics.Win.UltraWinGrid.UltraGridBand no-undo.
        ultraGridBand3 = new Infragistics.Win.UltraWinGrid.UltraGridBand("eItem", 1).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn25 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn25 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ItemId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn26 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn26 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ItemNum").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn27 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn27 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ItemName").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn28 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn28 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ItemType").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn29 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn29 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Description").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn30 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn30 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Price").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridBand4 as Infragistics.Win.UltraWinGrid.UltraGridBand no-undo.
        ultraGridBand4 = new Infragistics.Win.UltraWinGrid.UltraGridBand("eFinishedItem", 1).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn31 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn31 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("FinishedItemId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn32 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn32 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ItemId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn33 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn33 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("StatusDate").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn34 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn34 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("FinishedItemStatus").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn35 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn35 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ExternalId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn36 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn36 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("eComponentItem").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridBand5 as Infragistics.Win.UltraWinGrid.UltraGridBand no-undo.
        ultraGridBand5 = new Infragistics.Win.UltraWinGrid.UltraGridBand("eComponentItem", 3).
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn37 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn37 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("ItemId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn38 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn38 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("FinishedItemId").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable ultraGridColumn39 as Infragistics.Win.UltraWinGrid.UltraGridColumn no-undo.
        ultraGridColumn39 = new Infragistics.Win.UltraWinGrid.UltraGridColumn("Quantity").
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
        define variable appearance20 as Infragistics.Win.Appearance no-undo.
        appearance20 = new Infragistics.Win.Appearance().
        this-object:bsOrders = new Progress.Data.BindingSource(this-object:components).
        this-object:uxOrders = new Infragistics.Win.UltraWinGrid.UltraGrid().
        cast(this-object:bsOrders, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxOrders, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* bsOrders */
        /*  */
        this-object:bsOrders:MaxDataGuess = 0.
        this-object:bsOrders:NoLOBs = false.
        this-object:bsOrders:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc3:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 6 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("ItemId", "", Progress.Data.DataType:CHARACTER).
        arrayvar1[2] = new Progress.Data.ColumnPropDesc("ItemNum", "", Progress.Data.DataType:INTEGER).
        arrayvar1[3] = new Progress.Data.ColumnPropDesc("ItemName", "", Progress.Data.DataType:CHARACTER).
        arrayvar1[4] = new Progress.Data.ColumnPropDesc("ItemType", "", Progress.Data.DataType:CHARACTER).
        arrayvar1[5] = new Progress.Data.ColumnPropDesc("Description", "", Progress.Data.DataType:CHARACTER).
        arrayvar1[6] = new Progress.Data.ColumnPropDesc("Price", "", Progress.Data.DataType:DECIMAL).
        tableDesc3:Columns = arrayvar1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar2 = new "Progress.Data.TableDesc[]"(0).
        tableDesc5:ChildTables = arrayvar2.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar3 as Progress.Data.ColumnPropDesc extent 3 no-undo.
        arrayvar3[1] = new Progress.Data.ColumnPropDesc("ItemId", "", Progress.Data.DataType:CHARACTER).
        arrayvar3[2] = new Progress.Data.ColumnPropDesc("FinishedItemId", "", Progress.Data.DataType:CHARACTER).
        arrayvar3[3] = new Progress.Data.ColumnPropDesc("Quantity", "", Progress.Data.DataType:DECIMAL).
        tableDesc5:Columns = arrayvar3.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar4 as Progress.Data.TableDesc extent 1 no-undo.
        arrayvar4[1] = tableDesc5.
        tableDesc4:ChildTables = arrayvar4.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar5 as Progress.Data.ColumnPropDesc extent 5 no-undo.
        arrayvar5[1] = new Progress.Data.ColumnPropDesc("FinishedItemId", "", Progress.Data.DataType:CHARACTER).
        arrayvar5[2] = new Progress.Data.ColumnPropDesc("ItemId", "", Progress.Data.DataType:CHARACTER).
        arrayvar5[3] = new Progress.Data.ColumnPropDesc("StatusDate", "", Progress.Data.DataType:DATETIME).
        arrayvar5[4] = new Progress.Data.ColumnPropDesc("FinishedItemStatus", "", Progress.Data.DataType:CHARACTER).
        arrayvar5[5] = new Progress.Data.ColumnPropDesc("ExternalId", "", Progress.Data.DataType:CHARACTER).
        tableDesc4:Columns = arrayvar5.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar6 as Progress.Data.TableDesc extent 2 no-undo.
        arrayvar6[1] = tableDesc3.
        arrayvar6[2] = tableDesc4.
        tableDesc2:ChildTables = arrayvar6.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar7 as Progress.Data.ColumnPropDesc extent 8 no-undo.
        arrayvar7[1] = new Progress.Data.ColumnPropDesc("OrderId", "", Progress.Data.DataType:CHARACTER).
        arrayvar7[2] = new Progress.Data.ColumnPropDesc("LineNum", "", Progress.Data.DataType:INTEGER).
        arrayvar7[3] = new Progress.Data.ColumnPropDesc("Price", "", Progress.Data.DataType:DECIMAL).
        arrayvar7[4] = new Progress.Data.ColumnPropDesc("Quantity", "", Progress.Data.DataType:INTEGER).
        arrayvar7[5] = new Progress.Data.ColumnPropDesc("Discount", "", Progress.Data.DataType:INTEGER).
        arrayvar7[6] = new Progress.Data.ColumnPropDesc("ItemId", "", Progress.Data.DataType:CHARACTER).
        arrayvar7[7] = new Progress.Data.ColumnPropDesc("OrderLineStatus", "", Progress.Data.DataType:CHARACTER).
        arrayvar7[8] = new Progress.Data.ColumnPropDesc("FinishedItemId", "", Progress.Data.DataType:CHARACTER).
        tableDesc2:Columns = arrayvar7.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar8 as Progress.Data.TableDesc extent 1 no-undo.
        arrayvar8[1] = tableDesc2.
        tableDesc1:ChildTables = arrayvar8.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar9 as Progress.Data.ColumnPropDesc extent 13 no-undo.
        arrayvar9[1] = new Progress.Data.ColumnPropDesc("OrderNum", "", Progress.Data.DataType:INTEGER).
        arrayvar9[2] = new Progress.Data.ColumnPropDesc("OrderId", "", Progress.Data.DataType:CHARACTER).
        arrayvar9[3] = new Progress.Data.ColumnPropDesc("OrderDate", "", Progress.Data.DataType:DATE).
        arrayvar9[4] = new Progress.Data.ColumnPropDesc("EnteredDate", "", Progress.Data.DataType:DATETIME).
        arrayvar9[5] = new Progress.Data.ColumnPropDesc("FromEmail", "", Progress.Data.DataType:LOGICAL).
        arrayvar9[6] = new Progress.Data.ColumnPropDesc("CustomerNum", "", Progress.Data.DataType:INTEGER).
        arrayvar9[7] = new Progress.Data.ColumnPropDesc("CustomerName", "", Progress.Data.DataType:CHARACTER).
        arrayvar9[8] = new Progress.Data.ColumnPropDesc("CustomerPO", "", Progress.Data.DataType:CHARACTER).
        arrayvar9[9] = new Progress.Data.ColumnPropDesc("OrderAmount", "", Progress.Data.DataType:DECIMAL).
        arrayvar9[10] = new Progress.Data.ColumnPropDesc("OrderStatus", "", Progress.Data.DataType:CHARACTER).
        arrayvar9[11] = new Progress.Data.ColumnPropDesc("Instructions", "", Progress.Data.DataType:CHARACTER).
        arrayvar9[12] = new Progress.Data.ColumnPropDesc("SalesrepCode", "", Progress.Data.DataType:CHARACTER).
        arrayvar9[13] = new Progress.Data.ColumnPropDesc("DealerCode", "", Progress.Data.DataType:CHARACTER).
        tableDesc1:Columns = arrayvar9.
        this-object:bsOrders:TableSchema = tableDesc1.
        /*  */
        /* uxOrders */
        /*  */
        this-object:uxOrders:DataSource = this-object:bsOrders.
        appearance21:BackColor = System.Drawing.SystemColors:Window.
        appearance21:BorderColor = System.Drawing.SystemColors:InactiveCaption.
        this-object:uxOrders:DisplayLayout:Appearance = appearance21.
        ultraGridColumn1:Header:VisiblePosition = 11.
        ultraGridColumn1:RowLayoutColumnInfo:OriginX = 0.
        ultraGridColumn1:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn1:RowLayoutColumnInfo:PreferredCellSize = new System.Drawing.Size(186, 0).
        ultraGridColumn1:RowLayoutColumnInfo:SpanX = 3.
        ultraGridColumn1:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn2:Header:VisiblePosition = 10.
        ultraGridColumn2:Hidden = true.
        ultraGridColumn2:RowLayoutColumnInfo:OriginX = 25.
        ultraGridColumn2:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn2:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn2:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn3:Header:VisiblePosition = 9.
        ultraGridColumn3:RowLayoutColumnInfo:OriginX = 3.
        ultraGridColumn3:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn3:RowLayoutColumnInfo:PreferredCellSize = new System.Drawing.Size(194, 0).
        ultraGridColumn3:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn3:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn4:Header:VisiblePosition = 4.
        ultraGridColumn4:Hidden = true.
        ultraGridColumn4:RowLayoutColumnInfo:OriginX = 2.
        ultraGridColumn4:RowLayoutColumnInfo:OriginY = 2.
        ultraGridColumn4:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn4:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn5:Header:VisiblePosition = 5.
        ultraGridColumn5:Hidden = true.
        ultraGridColumn5:RowLayoutColumnInfo:OriginX = 10.
        ultraGridColumn5:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn5:RowLayoutColumnInfo:PreferredCellSize = new System.Drawing.Size(89, 0).
        ultraGridColumn5:RowLayoutColumnInfo:SpanX = 3.
        ultraGridColumn5:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn6:Header:VisiblePosition = 1.
        ultraGridColumn6:RowLayoutColumnInfo:OriginX = 9.
        ultraGridColumn6:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn6:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn6:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn7:Header:VisiblePosition = 0.
        ultraGridColumn7:RowLayoutColumnInfo:OriginX = 5.
        ultraGridColumn7:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn7:RowLayoutColumnInfo:PreferredCellSize = new System.Drawing.Size(283, 0).
        ultraGridColumn7:RowLayoutColumnInfo:SpanX = 4.
        ultraGridColumn7:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn8:Header:VisiblePosition = 2.
        ultraGridColumn8:Hidden = true.
        ultraGridColumn8:RowLayoutColumnInfo:OriginX = 15.
        ultraGridColumn8:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn8:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn8:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn9:Header:VisiblePosition = 3.
        ultraGridColumn9:RowLayoutColumnInfo:OriginX = 11.
        ultraGridColumn9:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn9:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn9:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn10:Header:VisiblePosition = 12.
        ultraGridColumn10:RowLayoutColumnInfo:OriginX = 9.
        ultraGridColumn10:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn10:RowLayoutColumnInfo:PreferredCellSize = new System.Drawing.Size(184, 0).
        ultraGridColumn10:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn10:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn11:Header:VisiblePosition = 8.
        ultraGridColumn11:Hidden = true.
        ultraGridColumn11:RowLayoutColumnInfo:OriginX = 0.
        ultraGridColumn11:RowLayoutColumnInfo:OriginY = 4.
        ultraGridColumn11:RowLayoutColumnInfo:PreferredCellSize = new System.Drawing.Size(468, 0).
        ultraGridColumn11:RowLayoutColumnInfo:SpanX = 10.
        ultraGridColumn11:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn12:Header:VisiblePosition = 6.
        ultraGridColumn12:RowLayoutColumnInfo:OriginX = 13.
        ultraGridColumn12:RowLayoutColumnInfo:OriginY = 0.
        ultraGridColumn12:RowLayoutColumnInfo:SpanX = 2.
        ultraGridColumn12:RowLayoutColumnInfo:SpanY = 2.
        ultraGridColumn13:Header:VisiblePosition = 7.
        ultraGridColumn13:Hidden = true.
        ultraGridColumn14:Header:VisiblePosition = 13.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar10 as System.Object extent 14 no-undo.
        arrayvar10[1] = ultraGridColumn1.
        arrayvar10[2] = ultraGridColumn2.
        arrayvar10[3] = ultraGridColumn3.
        arrayvar10[4] = ultraGridColumn4.
        arrayvar10[5] = ultraGridColumn5.
        arrayvar10[6] = ultraGridColumn6.
        arrayvar10[7] = ultraGridColumn7.
        arrayvar10[8] = ultraGridColumn8.
        arrayvar10[9] = ultraGridColumn9.
        arrayvar10[10] = ultraGridColumn10.
        arrayvar10[11] = ultraGridColumn11.
        arrayvar10[12] = ultraGridColumn12.
        arrayvar10[13] = ultraGridColumn13.
        arrayvar10[14] = ultraGridColumn14.
        ultraGridBand1:Columns:AddRange(arrayvar10).
        ultraGridBand1:RowLayoutLabelPosition = Infragistics.Win.UltraWinGrid.LabelPosition:Top.
        ultraGridBand1:RowLayoutStyle = Infragistics.Win.UltraWinGrid.RowLayoutStyle:GroupLayout.
        ultraGridColumn15:Header:VisiblePosition = 0.
        ultraGridColumn15:Hidden = true.
        ultraGridColumn16:Header:VisiblePosition = 1.
        ultraGridColumn17:Header:VisiblePosition = 2.
        ultraGridColumn18:Header:VisiblePosition = 3.
        ultraGridColumn19:Header:VisiblePosition = 4.
        ultraGridColumn20:Header:VisiblePosition = 5.
        ultraGridColumn20:Hidden = true.
        ultraGridColumn21:Header:VisiblePosition = 6.
        ultraGridColumn22:Header:VisiblePosition = 7.
        ultraGridColumn22:Hidden = true.
        ultraGridColumn23:Header:VisiblePosition = 8.
        ultraGridColumn24:Header:VisiblePosition = 9.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar11 as System.Object extent 10 no-undo.
        arrayvar11[1] = ultraGridColumn15.
        arrayvar11[2] = ultraGridColumn16.
        arrayvar11[3] = ultraGridColumn17.
        arrayvar11[4] = ultraGridColumn18.
        arrayvar11[5] = ultraGridColumn19.
        arrayvar11[6] = ultraGridColumn20.
        arrayvar11[7] = ultraGridColumn21.
        arrayvar11[8] = ultraGridColumn22.
        arrayvar11[9] = ultraGridColumn23.
        arrayvar11[10] = ultraGridColumn24.
        ultraGridBand2:Columns:AddRange(arrayvar11).
        ultraGridBand2:RowLayoutStyle = Infragistics.Win.UltraWinGrid.RowLayoutStyle:GroupLayout.
        ultraGridColumn25:Header:VisiblePosition = 0.
        ultraGridColumn25:Hidden = true.
        ultraGridColumn26:Header:VisiblePosition = 1.
        ultraGridColumn27:Header:VisiblePosition = 2.
        ultraGridColumn28:Header:VisiblePosition = 3.
        ultraGridColumn29:Header:VisiblePosition = 4.
        ultraGridColumn30:Header:VisiblePosition = 5.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar12 as System.Object extent 6 no-undo.
        arrayvar12[1] = ultraGridColumn25.
        arrayvar12[2] = ultraGridColumn26.
        arrayvar12[3] = ultraGridColumn27.
        arrayvar12[4] = ultraGridColumn28.
        arrayvar12[5] = ultraGridColumn29.
        arrayvar12[6] = ultraGridColumn30.
        ultraGridBand3:Columns:AddRange(arrayvar12).
        ultraGridBand3:RowLayoutStyle = Infragistics.Win.UltraWinGrid.RowLayoutStyle:GroupLayout.
        ultraGridColumn31:Header:VisiblePosition = 0.
        ultraGridColumn32:Header:VisiblePosition = 1.
        ultraGridColumn33:Header:VisiblePosition = 2.
        ultraGridColumn34:Header:VisiblePosition = 3.
        ultraGridColumn35:Header:VisiblePosition = 4.
        ultraGridColumn36:Header:VisiblePosition = 5.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar13 as System.Object extent 6 no-undo.
        arrayvar13[1] = ultraGridColumn31.
        arrayvar13[2] = ultraGridColumn32.
        arrayvar13[3] = ultraGridColumn33.
        arrayvar13[4] = ultraGridColumn34.
        arrayvar13[5] = ultraGridColumn35.
        arrayvar13[6] = ultraGridColumn36.
        ultraGridBand4:Columns:AddRange(arrayvar13).
        ultraGridBand4:Hidden = true.
        ultraGridColumn37:Header:VisiblePosition = 0.
        ultraGridColumn38:Header:VisiblePosition = 1.
        ultraGridColumn39:Header:VisiblePosition = 2.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar14 as System.Object extent 3 no-undo.
        arrayvar14[1] = ultraGridColumn37.
        arrayvar14[2] = ultraGridColumn38.
        arrayvar14[3] = ultraGridColumn39.
        ultraGridBand5:Columns:AddRange(arrayvar14).
        ultraGridBand5:Hidden = true.
        this-object:uxOrders:DisplayLayout:BandsSerializer:Add(ultraGridBand1).
        this-object:uxOrders:DisplayLayout:BandsSerializer:Add(ultraGridBand2).
        this-object:uxOrders:DisplayLayout:BandsSerializer:Add(ultraGridBand3).
        this-object:uxOrders:DisplayLayout:BandsSerializer:Add(ultraGridBand4).
        this-object:uxOrders:DisplayLayout:BandsSerializer:Add(ultraGridBand5).
        this-object:uxOrders:DisplayLayout:BorderStyle = Infragistics.Win.UIElementBorderStyle:Solid.
        this-object:uxOrders:DisplayLayout:CaptionVisible = Infragistics.Win.DefaultableBoolean:False.
        appearance22:BackColor = System.Drawing.SystemColors:ActiveBorder.
        appearance22:BackColor2 = System.Drawing.SystemColors:ControlDark.
        appearance22:BackGradientStyle = Infragistics.Win.GradientStyle:Vertical.
        appearance22:BorderColor = System.Drawing.SystemColors:Window.
        this-object:uxOrders:DisplayLayout:GroupByBox:Appearance = appearance22.
        appearance23:ForeColor = System.Drawing.SystemColors:GrayText.
        this-object:uxOrders:DisplayLayout:GroupByBox:BandLabelAppearance = appearance23.
        this-object:uxOrders:DisplayLayout:GroupByBox:BorderStyle = Infragistics.Win.UIElementBorderStyle:Solid.
        appearance24:BackColor = System.Drawing.SystemColors:ControlLightLight.
        appearance24:BackColor2 = System.Drawing.SystemColors:Control.
        appearance24:BackGradientStyle = Infragistics.Win.GradientStyle:Horizontal.
        appearance24:ForeColor = System.Drawing.SystemColors:GrayText.
        this-object:uxOrders:DisplayLayout:GroupByBox:PromptAppearance = appearance24.
        this-object:uxOrders:DisplayLayout:MaxColScrollRegions = 1.
        this-object:uxOrders:DisplayLayout:MaxRowScrollRegions = 1.
        appearance13:BackColor = System.Drawing.SystemColors:Window.
        appearance13:ForeColor = System.Drawing.SystemColors:ControlText.
        this-object:uxOrders:DisplayLayout:Override:ActiveCellAppearance = appearance13.
        appearance14:BackColor = System.Drawing.SystemColors:Highlight.
        appearance14:ForeColor = System.Drawing.SystemColors:HighlightText.
        this-object:uxOrders:DisplayLayout:Override:ActiveRowAppearance = appearance14.
        this-object:uxOrders:DisplayLayout:Override:BorderStyleCell = Infragistics.Win.UIElementBorderStyle:Dotted.
        this-object:uxOrders:DisplayLayout:Override:BorderStyleRow = Infragistics.Win.UIElementBorderStyle:Dotted.
        appearance15:BackColor = System.Drawing.SystemColors:Window.
        this-object:uxOrders:DisplayLayout:Override:CardAreaAppearance = appearance15.
        appearance16:BorderColor = System.Drawing.Color:Silver.
        appearance16:TextTrimming = Infragistics.Win.TextTrimming:EllipsisCharacter.
        this-object:uxOrders:DisplayLayout:Override:CellAppearance = appearance16.
        this-object:uxOrders:DisplayLayout:Override:CellClickAction = Infragistics.Win.UltraWinGrid.CellClickAction:EditAndSelectText.
        this-object:uxOrders:DisplayLayout:Override:CellPadding = 0.
        appearance17:BackColor = System.Drawing.SystemColors:Control.
        appearance17:BackColor2 = System.Drawing.SystemColors:ControlDark.
        appearance17:BackGradientAlignment = Infragistics.Win.GradientAlignment:Element.
        appearance17:BackGradientStyle = Infragistics.Win.GradientStyle:Horizontal.
        appearance17:BorderColor = System.Drawing.SystemColors:Window.
        this-object:uxOrders:DisplayLayout:Override:GroupByRowAppearance = appearance17.
        appearance18:TextHAlignAsString = "Left".
        this-object:uxOrders:DisplayLayout:Override:HeaderAppearance = appearance18.
        this-object:uxOrders:DisplayLayout:Override:HeaderClickAction = Infragistics.Win.UltraWinGrid.HeaderClickAction:SortMulti.
        this-object:uxOrders:DisplayLayout:Override:HeaderStyle = Infragistics.Win.HeaderStyle:WindowsXPCommand.
        appearance19:BackColor = System.Drawing.SystemColors:Window.
        appearance19:BorderColor = System.Drawing.Color:Silver.
        this-object:uxOrders:DisplayLayout:Override:RowAppearance = appearance19.
        this-object:uxOrders:DisplayLayout:Override:RowSelectors = Infragistics.Win.DefaultableBoolean:False.
        appearance20:BackColor = System.Drawing.SystemColors:ControlLight.
        this-object:uxOrders:DisplayLayout:Override:TemplateAddRowAppearance = appearance20.
        this-object:uxOrders:DisplayLayout:ScrollBounds = Infragistics.Win.UltraWinGrid.ScrollBounds:ScrollToFill.
        this-object:uxOrders:DisplayLayout:ScrollStyle = Infragistics.Win.UltraWinGrid.ScrollStyle:Immediate.
        this-object:uxOrders:DisplayLayout:ViewStyleBand = Infragistics.Win.UltraWinGrid.ViewStyleBand:OutlookGroupBy.
        this-object:uxOrders:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uxOrders:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25, System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(0)).
        this-object:uxOrders:Location = new System.Drawing.Point(0, 0).
        this-object:uxOrders:Name = "uxOrders".
        this-object:uxOrders:Size = new System.Drawing.Size(581, 347).
        this-object:uxOrders:TabIndex = 0.
        this-object:uxOrders:Text = "ultraGrid1".
        /*  */
        /* OrderListForm */
        /*  */
        this-object:ClientSize = new System.Drawing.Size(581, 347).
        this-object:Controls:Add(this-object:uxOrders).
        this-object:Name = "OrderListForm".
        this-object:Text = "OrderListForm".
        cast(this-object:bsOrders, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxOrders, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    destructor public OrderListForm ( ):
        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.

    method protected void InitData():
        define variable oUC as IUserContext no-undo.
        define variable cDealerCode as character no-undo.
        define variable oPropertyValue as String no-undo.
        define variable hServer as handle no-undo.

        oUC = cast(SvcMgr:GetService(SecurityManager:ISecurityManagerType), ISecurityManager):CurrentUserContext.

        oPropertyValue = cast(oUC:UserProperties:Get(new String('Dealer.Code')), String).
        if valid-object(oPropertyValue) then
           cDealerCode = oPropertyValue:Value.

        hServer = cast(ConnMgr:GetServerConnection(ConnectionTypeEnum:AppServer, 'asAutoEdgeTheFactory'):Server, WidgetHandle):Value.
        run AutoEdge/Factory/Server/Order/BusinessComponent/service_listorderdealer.p
               on hServer
                    (input cDealerCode,
                     input oUC:ContextId,
                     output dataset-handle mhOrders).

        bsOrders:handle = mhOrders.
        mhOrders:top-nav-query:query-prepare(mhOrders:top-nav-query:prepare-string + ' by OrderNum descending ').
        mhOrders:top-nav-query:query-open().

    end method.

end class.
