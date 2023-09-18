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
    File        : CustomerOrderDetail
    Purpose     : 
    Syntax      : 
    Description : a
    Author(s)   : pjudge
    Created     : Wed Jul 07 14:21:35 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using System.Drawing.Color.
using System.Drawing.Point.
using AutoEdge.Factory.Client.Order.PresentationLayer.DisapprovalReasonPanel.
using AutoEdge.Factory.Client.Common.PresentationLayer.LightboxForm.

using OpenEdge.CommonInfrastructure.Client.ServiceAdapter.
using OpenEdge.CommonInfrastructure.Common.ISecurityManager.
using OpenEdge.CommonInfrastructure.Common.IServiceManager.
using OpenEdge.CommonInfrastructure.Common.ServiceManager.
using OpenEdge.CommonInfrastructure.Common.IServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.ServiceMessageManager.
using OpenEdge.CommonInfrastructure.Common.SecurityManager.
using OpenEdge.CommonInfrastructure.Common.IConnectionManager.
using OpenEdge.CommonInfrastructure.Common.ConnectionManager.
using OpenEdge.CommonInfrastructure.Common.Connection.ConnectionTypeEnum.
using OpenEdge.CommonInfrastructure.Common.Connection.IServerConnection.
using OpenEdge.CommonInfrastructure.Common.IUserContext.

using OpenEdge.Core.XML.WebServiceInvocationError.
using OpenEdge.Core.System.NotFoundError.
using OpenEdge.Core.System.UnhandledError.
using OpenEdge.Core.System.ApplicationError.

using OpenEdge.Lang.BPM.IBizLogicAPI.
using OpenEdge.Lang.BPM.Task.
using OpenEdge.Lang.BPM.WorkItem.
using OpenEdge.Lang.BPM.WorkItemStatusEnum.
using OpenEdge.Lang.BPM.DataSlotInstance.
using OpenEdge.Lang.String.
using OpenEdge.Lang.ABLSession.
using OpenEdge.Lang.Assert.
using OpenEdge.Lang.WidgetHandle.

using Progress.Windows.Form.
using Progress.Util.TypeHelper.
using Progress.Lang.Class.
using Progress.Lang.Error.

using Progress.Lang.Object.


class AutoEdge.Factory.Client.Order.PresentationLayer.CustomerOrderDetail inherits Form: 
    
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable lblAccessories as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblModel as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblExtColour as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblBrand as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblMoonroof as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblOrderDate as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblTrimColour as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblWheels as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable uxAccessories as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxBrand as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxCustomerName as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable lblOrderNumber as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable lblCustomerName as Infragistics.Win.Misc.UltraLabel no-undo.
    define private variable uxDisapprove as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable uxApprove as Infragistics.Win.Misc.UltraButton no-undo.
    define private variable imageList1 as System.Windows.Forms.ImageList no-undo.
    define private variable uxExtColour as Infragistics.Win.UltraWinEditors.UltraColorPicker no-undo.
    define private variable uxInStock as Infragistics.Win.UltraWinEditors.UltraCheckEditor no-undo.
    define private variable uxIntTrimColour as Infragistics.Win.UltraWinEditors.UltraColorPicker no-undo.
    define private variable uxModel as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxMoonroof as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxOrderDate as Infragistics.Win.UltraWinEditors.UltraDateTimeEditor no-undo.
    define private variable uxOrderDetail as Infragistics.Win.Misc.UltraGroupBox no-undo.
    define private variable uxOrderNumber as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.
    define private variable uxWheels as Infragistics.Win.UltraWinEditors.UltraTextEditor no-undo.

    define public property CurrentTask as Task no-undo get. private set.
    define public property CurrentOrder as integer no-undo get. private set.
    
    define protected property BpmServer as IBizLogicAPI no-undo get. set.
    
    define public event TaskCompleted signature void(input poSender as Object, input poTask as Task).
    
    /** (mandatory) The session's service manager. Used to determine the ServiceMessageManager and 
        other managers for callbacks, context and more. */
    define protected property ServiceManager as IServiceManager no-undo
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

    
    /** The ServicemessageManager is used plentifully; we keep it as a property so that
        we can get it whenever needed, without fuss. */
    define protected property ServiceMessageManager as IServiceMessageManager no-undo
        get():
            if not valid-object(ServiceMessageManager) then
                ServiceMessageManager = cast(ServiceManager:GetService(OpenEdge.CommonInfrastructure.Common.ServiceMessageManager:IServiceMessageManagerType) , IServiceMessageManager).
            
            return ServiceMessageManager.
        end get.
        private set.
    
    /** The ConnectionManager is used plentifully; we keep it as a property so that
        we can get it whenever needed, without fuss. */
    define protected property ConnectionManager as IConnectionManager no-undo
        get():
            if not valid-object(ConnectionManager) then
                ConnectionManager = cast(ServiceManager:GetService(OpenEdge.CommonInfrastructure.Common.ConnectionManager:IConnectionManagerType) , IConnectionManager).
            
            return ConnectionManager.
        end get.
        private set.
        
    define private variable mhOrders as handle no-undo.        
    
    constructor public CustomerOrderDetail(input poBpmServer as IBizLogicAPI,
                                           input poCurrentTask as Task):
        define variable iOrderNum as integer no-undo.

        this-object().

        Assert:ArgumentNotNull(poCurrentTask, 'Current task').
        Assert:ArgumentNotNull(poBpmServer, 'BPM Server').

        assign CurrentTask = poCurrentTask
               BpmServer = poBpmServer.

        iOrderNum = integer(cast(CurrentTask:DataSlots:Get(new String('OrderNum')), DataSlotInstance):Value).
        InitData(iOrderNum).
        InitUI(iOrderNum).
        
        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
    end constructor.
    
    constructor public CustomerOrderDetail(  ):
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
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("AutoEdge.Factory.Client.Order.PresentationLayer.CustomerOrderDetail").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance1 as Infragistics.Win.Appearance no-undo.
        appearance1 = new Infragistics.Win.Appearance().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable appearance2 as Infragistics.Win.Appearance no-undo.
        appearance2 = new Infragistics.Win.Appearance().
        this-object:uxOrderDetail = new Infragistics.Win.Misc.UltraGroupBox().
        this-object:uxAccessories = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblAccessories = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxWheels = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblWheels = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxMoonroof = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblMoonroof = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxExtColour = new Infragistics.Win.UltraWinEditors.UltraColorPicker().
        this-object:lblTrimColour = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxIntTrimColour = new Infragistics.Win.UltraWinEditors.UltraColorPicker().
        this-object:lblExtColour = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxModel = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblModel = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxBrand = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblBrand = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxInStock = new Infragistics.Win.UltraWinEditors.UltraCheckEditor().
        this-object:uxOrderDate = new Infragistics.Win.UltraWinEditors.UltraDateTimeEditor().
        this-object:imageList1 = new System.Windows.Forms.ImageList(this-object:components).
        this-object:lblOrderDate = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxOrderNumber = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblOrderNumber = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxCustomerName = new Infragistics.Win.UltraWinEditors.UltraTextEditor().
        this-object:lblCustomerName = new Infragistics.Win.Misc.UltraLabel().
        this-object:uxApprove = new Infragistics.Win.Misc.UltraButton().
        this-object:uxDisapprove = new Infragistics.Win.Misc.UltraButton().
        cast(this-object:uxOrderDetail, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:uxOrderDetail:SuspendLayout().
        cast(this-object:uxAccessories, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxWheels, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxMoonroof, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxExtColour, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxIntTrimColour, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxModel, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxBrand, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxInStock, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxOrderDate, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxOrderNumber, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:uxCustomerName, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* uxOrderDetail */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        this-object:uxOrderDetail:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:uxOrderDetail:Controls:Add(this-object:uxAccessories).
        this-object:uxOrderDetail:Controls:Add(this-object:lblAccessories).
        this-object:uxOrderDetail:Controls:Add(this-object:uxWheels).
        this-object:uxOrderDetail:Controls:Add(this-object:lblWheels).
        this-object:uxOrderDetail:Controls:Add(this-object:uxMoonroof).
        this-object:uxOrderDetail:Controls:Add(this-object:lblMoonroof).
        this-object:uxOrderDetail:Controls:Add(this-object:uxExtColour).
        this-object:uxOrderDetail:Controls:Add(this-object:lblTrimColour).
        this-object:uxOrderDetail:Controls:Add(this-object:uxIntTrimColour).
        this-object:uxOrderDetail:Controls:Add(this-object:lblExtColour).
        this-object:uxOrderDetail:Controls:Add(this-object:uxModel).
        this-object:uxOrderDetail:Controls:Add(this-object:lblModel).
        this-object:uxOrderDetail:Controls:Add(this-object:uxBrand).
        this-object:uxOrderDetail:Controls:Add(this-object:lblBrand).
        this-object:uxOrderDetail:Controls:Add(this-object:uxInStock).
        this-object:uxOrderDetail:Controls:Add(this-object:uxOrderDate).
        this-object:uxOrderDetail:Controls:Add(this-object:lblOrderDate).
        this-object:uxOrderDetail:Controls:Add(this-object:uxOrderNumber).
        this-object:uxOrderDetail:Controls:Add(this-object:lblOrderNumber).
        this-object:uxOrderDetail:Controls:Add(this-object:uxCustomerName).
        this-object:uxOrderDetail:Controls:Add(this-object:lblCustomerName).
        this-object:uxOrderDetail:Controls:Add(this-object:uxApprove).
        this-object:uxOrderDetail:Controls:Add(this-object:uxDisapprove).
        this-object:uxOrderDetail:Location = new System.Drawing.Point(12, 12).
        this-object:uxOrderDetail:Name = "uxOrderDetail".
        this-object:uxOrderDetail:Size = new System.Drawing.Size(625, 212).
        this-object:uxOrderDetail:TabIndex = 1.
        this-object:uxOrderDetail:Text = "Order".
        /*  */
        /* uxAccessories */
        /*  */
        this-object:uxAccessories:Location = new System.Drawing.Point(428, 104).
        this-object:uxAccessories:Name = "uxAccessories".
        this-object:uxAccessories:ReadOnly = true.
        this-object:uxAccessories:ShowOverflowIndicator = true.
        this-object:uxAccessories:Size = new System.Drawing.Size(170, 21).
        this-object:uxAccessories:TabIndex = 32.
        /*  */
        /* lblAccessories */
        /*  */
        this-object:lblAccessories:AutoSize = true.
        this-object:lblAccessories:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblAccessories:Location = new System.Drawing.Point(357, 108).
        this-object:lblAccessories:Name = "lblAccessories".
        this-object:lblAccessories:Size = new System.Drawing.Size(65, 14).
        this-object:lblAccessories:TabIndex = 31.
        this-object:lblAccessories:Text = "Accessories".
        /*  */
        /* uxWheels */
        /*  */
        this-object:uxWheels:Location = new System.Drawing.Point(99, 131).
        this-object:uxWheels:Name = "uxWheels".
        this-object:uxWheels:ReadOnly = true.
        this-object:uxWheels:Size = new System.Drawing.Size(170, 21).
        this-object:uxWheels:TabIndex = 30.
        /*  */
        /* lblWheels */
        /*  */
        this-object:lblWheels:AutoSize = true.
        this-object:lblWheels:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblWheels:Location = new System.Drawing.Point(51, 135).
        this-object:lblWheels:Name = "lblWheels".
        this-object:lblWheels:Size = new System.Drawing.Size(42, 14).
        this-object:lblWheels:TabIndex = 29.
        this-object:lblWheels:Text = "Wheels".
        /*  */
        /* uxMoonroof */
        /*  */
        this-object:uxMoonroof:Location = new System.Drawing.Point(99, 157).
        this-object:uxMoonroof:Name = "uxMoonroof".
        this-object:uxMoonroof:ReadOnly = true.
        this-object:uxMoonroof:Size = new System.Drawing.Size(170, 21).
        this-object:uxMoonroof:TabIndex = 28.
        /*  */
        /* lblMoonroof */
        /*  */
        this-object:lblMoonroof:AutoSize = true.
        this-object:lblMoonroof:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblMoonroof:Location = new System.Drawing.Point(41, 162).
        this-object:lblMoonroof:Name = "lblMoonroof".
        this-object:lblMoonroof:Size = new System.Drawing.Size(52, 14).
        this-object:lblMoonroof:TabIndex = 27.
        this-object:lblMoonroof:Text = "Moonroof".
        /*  */
        /* uxExtColour */
        /*  */
        this-object:uxExtColour:Location = new System.Drawing.Point(99, 104).
        this-object:uxExtColour:Name = "uxExtColour".
        this-object:uxExtColour:ReadOnly = true.
        this-object:uxExtColour:Size = new System.Drawing.Size(170, 21).
        this-object:uxExtColour:TabIndex = 26.
        this-object:uxExtColour:Text = "Control".
        /*  */
        /* lblTrimColour */
        /*  */
        this-object:lblTrimColour:AutoSize = true.
        this-object:lblTrimColour:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblTrimColour:Location = new System.Drawing.Point(359, 81).
        this-object:lblTrimColour:Name = "lblTrimColour".
        this-object:lblTrimColour:Size = new System.Drawing.Size(63, 14).
        this-object:lblTrimColour:TabIndex = 25.
        this-object:lblTrimColour:Text = "Trim Colour".
        /*  */
        /* uxIntTrimColour */
        /*  */
        this-object:uxIntTrimColour:Location = new System.Drawing.Point(428, 77).
        this-object:uxIntTrimColour:Name = "uxIntTrimColour".
        this-object:uxIntTrimColour:ReadOnly = true.
        this-object:uxIntTrimColour:Size = new System.Drawing.Size(170, 21).
        this-object:uxIntTrimColour:TabIndex = 24.
        this-object:uxIntTrimColour:Text = "Control".
        /*  */
        /* lblExtColour */
        /*  */
        this-object:lblExtColour:AutoSize = true.
        this-object:lblExtColour:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblExtColour:Location = new System.Drawing.Point(13, 108).
        this-object:lblExtColour:Name = "lblExtColour".
        this-object:lblExtColour:Size = new System.Drawing.Size(80, 14).
        this-object:lblExtColour:TabIndex = 22.
        this-object:lblExtColour:Text = "Exterior Colour".
        /*  */
        /* uxModel */
        /*  */
        this-object:uxModel:Location = new System.Drawing.Point(99, 77).
        this-object:uxModel:Name = "uxModel".
        this-object:uxModel:ReadOnly = true.
        this-object:uxModel:Size = new System.Drawing.Size(170, 21).
        this-object:uxModel:TabIndex = 21.
        /*  */
        /* lblModel */
        /*  */
        this-object:lblModel:AutoSize = true.
        this-object:lblModel:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblModel:Location = new System.Drawing.Point(58, 80).
        this-object:lblModel:Name = "lblModel".
        this-object:lblModel:Size = new System.Drawing.Size(35, 14).
        this-object:lblModel:TabIndex = 20.
        this-object:lblModel:Text = "Model".
        /*  */
        /* uxBrand */
        /*  */
        this-object:uxBrand:Location = new System.Drawing.Point(99, 50).
        this-object:uxBrand:Name = "uxBrand".
        this-object:uxBrand:ReadOnly = true.
        this-object:uxBrand:Size = new System.Drawing.Size(170, 21).
        this-object:uxBrand:TabIndex = 19.
        /*  */
        /* lblBrand */
        /*  */
        this-object:lblBrand:AutoSize = true.
        this-object:lblBrand:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblBrand:Location = new System.Drawing.Point(59, 54).
        this-object:lblBrand:Name = "lblBrand".
        this-object:lblBrand:Size = new System.Drawing.Size(34, 14).
        this-object:lblBrand:TabIndex = 18.
        this-object:lblBrand:Text = "Brand".
        /*  */
        /* uxInStock */
        /*  */
        this-object:uxInStock:Location = new System.Drawing.Point(359, 136).
        this-object:uxInStock:Name = "uxInStock".
        this-object:uxInStock:Size = new System.Drawing.Size(120, 20).
        this-object:uxInStock:TabIndex = 17.
        this-object:uxInStock:Text = "Vehicle On Lot?".
        /*  */
        /* uxOrderDate */
        /*  */
        this-object:uxOrderDate:ImageList = this-object:imageList1.
        this-object:uxOrderDate:Location = new System.Drawing.Point(428, 50).
        this-object:uxOrderDate:MaskInput = "~{date~}".
        this-object:uxOrderDate:Name = "uxOrderDate".
        this-object:uxOrderDate:ReadOnly = true.
        this-object:uxOrderDate:Size = new System.Drawing.Size(170, 21).
        this-object:uxOrderDate:TabIndex = 16.
        /*  */
        /* imageList1 */
        /*  */
        this-object:imageList1:ImageStream = cast(resources:GetObject("imageList1.ImageStream"), System.Windows.Forms.ImageListStreamer).
        this-object:imageList1:TransparentColor = System.Drawing.Color:Transparent.
        this-object:imageList1:Images:SetKeyName(0, "Knob Valid Green.png").
        this-object:imageList1:Images:SetKeyName(1, "Knob Remove Red.png").
        this-object:imageList1:Images:SetKeyName(2, "Knob Snapback.png").
        this-object:imageList1:Images:SetKeyName(3, "error_16x16.png").
        /*  */
        /* lblOrderDate */
        /*  */
        this-object:lblOrderDate:AutoSize = true.
        this-object:lblOrderDate:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblOrderDate:Location = new System.Drawing.Point(358, 54).
        this-object:lblOrderDate:Name = "lblOrderDate".
        this-object:lblOrderDate:Size = new System.Drawing.Size(64, 14).
        this-object:lblOrderDate:TabIndex = 15.
        this-object:lblOrderDate:Text = "Ordered On".
        /*  */
        /* uxOrderNumber */
        /*  */
        this-object:uxOrderNumber:Location = new System.Drawing.Point(428, 23).
        this-object:uxOrderNumber:Name = "uxOrderNumber".
        this-object:uxOrderNumber:ReadOnly = true.
        this-object:uxOrderNumber:Size = new System.Drawing.Size(170, 21).
        this-object:uxOrderNumber:TabIndex = 6.
        /*  */
        /* lblOrderNumber */
        /*  */
        this-object:lblOrderNumber:AutoSize = true.
        this-object:lblOrderNumber:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblOrderNumber:Location = new System.Drawing.Point(346, 27).
        this-object:lblOrderNumber:Name = "lblOrderNumber".
        this-object:lblOrderNumber:Size = new System.Drawing.Size(76, 14).
        this-object:lblOrderNumber:TabIndex = 5.
        this-object:lblOrderNumber:Text = "Order Number".
        /*  */
        /* uxCustomerName */
        /*  */
        this-object:uxCustomerName:Location = new System.Drawing.Point(99, 23).
        this-object:uxCustomerName:Name = "uxCustomerName".
        this-object:uxCustomerName:ReadOnly = true.
        this-object:uxCustomerName:Size = new System.Drawing.Size(170, 21).
        this-object:uxCustomerName:TabIndex = 4.
        /*  */
        /* lblCustomerName */
        /*  */
        this-object:lblCustomerName:AutoSize = true.
        this-object:lblCustomerName:Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25).
        this-object:lblCustomerName:Location = new System.Drawing.Point(7, 27).
        this-object:lblCustomerName:Name = "lblCustomerName".
        this-object:lblCustomerName:Size = new System.Drawing.Size(86, 14).
        this-object:lblCustomerName:TabIndex = 3.
        this-object:lblCustomerName:Text = "Customer Name".
        /*  */
        /* uxApprove */
        /*  */
        appearance1:Image = "Knob Valid Green.png".
        this-object:uxApprove:Appearance = appearance1.
        this-object:uxApprove:ImageList = this-object:imageList1.
        this-object:uxApprove:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxApprove:Location = new System.Drawing.Point(355, 162).
        this-object:uxApprove:Name = "uxApprove".
        this-object:uxApprove:Size = new System.Drawing.Size(120, 40).
        this-object:uxApprove:TabIndex = 2.
        this-object:uxApprove:Text = "Approve".
        this-object:uxApprove:Click:Subscribe(this-object:uxApprove_Click).
        /*  */
        /* uxDisapprove */
        /*  */
        appearance2:Image = "Knob Remove Red.png".
        this-object:uxDisapprove:Appearance = appearance2.
        this-object:uxDisapprove:ImageList = this-object:imageList1.
        this-object:uxDisapprove:ImageSize = new System.Drawing.Size(32, 32).
        this-object:uxDisapprove:Location = new System.Drawing.Point(478, 162).
        this-object:uxDisapprove:Name = "uxDisapprove".
        this-object:uxDisapprove:Size = new System.Drawing.Size(120, 40).
        this-object:uxDisapprove:TabIndex = 1.
        this-object:uxDisapprove:Text = "Disapprove".
        this-object:uxDisapprove:Click:Subscribe(this-object:uxDisapprove_Click).
        /*  */
        /* CustomerOrderDetail */
        /*  */
        this-object:AutoScroll = true.
        this-object:AutoSize = true.
        this-object:AutoSizeMode = System.Windows.Forms.AutoSizeMode:GrowAndShrink.
        this-object:ClientSize = new System.Drawing.Size(650, 271).
        this-object:Controls:Add(this-object:uxOrderDetail).
        this-object:Icon = cast(resources:GetObject("$this.Icon"), System.Drawing.Icon).
        this-object:Name = "CustomerOrderDetail".
        this-object:Text = "CustomerOrderDetail".
        cast(this-object:uxOrderDetail, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:uxOrderDetail:ResumeLayout(false).
        this-object:uxOrderDetail:PerformLayout().
        cast(this-object:uxAccessories, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxWheels, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxMoonroof, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxExtColour, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxIntTrimColour, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxModel, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxBrand, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxInStock, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxOrderDate, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxOrderNumber, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:uxCustomerName, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

    method private void uxApprove_Click( input sender as System.Object, input e as System.EventArgs ):
        ApproveOrder().
        
        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
    end method.

    method private void uxDisapprove_Click( input sender as System.Object, input e as System.EventArgs ):
        DisapproveOrder().

        catch oAppError as ApplicationError:
            oAppError:ShowError().
        end catch.
        catch oError as Error:
            define variable oUHError as UnhandledError no-undo.
            oUHError = new UnhandledError(oError).
            oUHError:ShowError().
        end catch.
    end method.
    
    method protected void InitData(input piOrderNum as integer):
        define variable oUC as IUserContext no-undo.
        define variable iOrderNum as integer extent 1 no-undo.
        define variable hServer as handle no-undo.

        oUC = cast(ServiceManager:GetService(SecurityManager:ISecurityManagerType), ISecurityManager):CurrentUserContext.

        hServer = cast(ConnectionManager:GetServerConnection(ConnectionTypeEnum:AppServer, 'asAutoEdgeTheFactory'):Server, WidgetHandle):Value.

        iOrderNum[1] = piOrderNum.

        run AutoEdge/Factory/Server/Order/BusinessComponent/service_orderbynumber.p on hServer
                    (input iOrderNum,
                     input oUC:ContextId,
                     output dataset-handle mhOrders).
    end method.
        
    method protected void InitUI(input piOrderNum as integer):
        define variable cDTZ as datetime  no-undo.
        define variable cDateFormat as character no-undo.
        define variable hOrderBuffer as handle no-undo.
        define variable hOLineBuffer as handle no-undo.
        define variable hFinishedItemBuffer as handle no-undo.
        define variable hItemBuffer as handle no-undo.
        define variable hComponentItemBuffer as handle no-undo.
        define variable hQuery as handle no-undo.

        cDateFormat = session:date-format.
        /* needed to convert ISO dates into ABL datetime-tz */
        session:date-format = 'ymd'.

        assign hOrderBuffer = mhOrders:get-buffer-handle('eOrder')
               hOLineBuffer = mhOrders:get-buffer-handle('eOrderLine')
               hFinishedItemBuffer = mhOrders:get-buffer-handle('eFinishedItem')
               hComponentItemBuffer = mhOrders:get-buffer-handle('eComponentItem')
               hItemBuffer = mhOrders:get-buffer-handle('eItem').

        hOrderBuffer:find-first(' where eOrder.OrderNum = ' + quoter(piOrderNum) ) no-error.
        if hOrderBuffer:available then
        do:
            hOLineBuffer:find-first(' where eOrderLine.LineNum = 1 and eOrderLine.OrderId = ' + quoter(hOrderBuffer::OrderId)) no-error.  
            hFinishedItemBuffer:find-first(' where eFinishedItem.FinishedItemId = ' + quoter(hOLineBuffer::FinishedItemId)) no-error.
            hItemBuffer:find-first(' where eItem.ItemId = ' + quoter(hFinishedItemBuffer::ItemId)) no-error.

            assign cDTZ = datetime(hOrderBuffer::OrderDate) 
                   uxOrderDate:DateTime = cDTZ
                   uxBrand:Text = SecMgr:CurrentUserContext:TenantName
                   uxCustomerName:Text = hOrderBuffer::CustomerName
                   uxModel:Text = hItemBuffer::ItemName.
            
            create query hQuery.
            hQuery:set-buffers(hComponentItemBuffer, hItemBuffer).
            hQuery:query-prepare(' for each eComponentItem where eComponentItem.FinishedItemId = ' + quoter(hFinishedItemBuffer::FinishedItemId)
                                + ', each eItem where eItem.ItemId = eComponentItem.ItemId ').
            hQuery:query-open().
            
            hQuery:get-first().
            do while hComponentItemBuffer:available:
                case string(hItemBuffer::ItemType):
                    when 'wheels' then uxWheels:Text = hItemBuffer::ItemName.
                    when 'ext-colour' then 
                    do:
                        uxExtColour:Text = hItemBuffer::ItemName.
                        
                        if System.Enum:IsDefined(TypeHelper:GetType('System.Drawing.KnownColor'), hItemBuffer::ItemName) then
                            uxExtColour:Color = Color:FromName(hItemBuffer::ItemName).
                        else
                            uxExtColour:Color = Color:Empty.
                    end.    /* ext-colour */
                    when 'moonroof' then uxMoonroof:Text = hItemBuffer::ItemName.
                    when 'accessories' then uxAccessories:Text = uxAccessories:Text + ', ' + hItemBuffer::ItemName. 
                    when 'trim-colour' then
                    do:
                        if System.Enum:IsDefined(TypeHelper:GetType('System.Drawing.KnownColor'), hItemBuffer::ItemName) then
                            uxIntTrimColour:Color = Color:FromName(hItemBuffer::ItemName).
                        else
                            uxIntTrimColour:Color = Color:Empty.
                    end.
                end case.
                hQuery:get-next().
            end.
            hQuery:query-close().
            delete object hQuery.
            
            uxOrderNumber:Text = hOrderBuffer::OrderNum.
            this-object:Text = 'Order - ' + hOrderBuffer::OrderNUm.
        end.
        else
        do:
            message
                'Unable to retrieve order detail'
            view-as alert-box error title 'AutoEdge|TheFactory Help'.

            assign uxApprove:Enabled = false
                   uxDisapprove:Enabled = false.
            
            undo, throw new NotFoundError('Order Detail ', substitute(' WorkItem &1', CurrentTask:WorkItem:Name)).
        end.
        
        finally:
            session:date-format = cDateFormat.
        end finally.
    end method.    
    
    method protected void ApproveOrder():
        CurrentTask:SetDataSlotValue('OrderApproved', 'true').
        CompleteTask(CurrentTask).
    end method.
    
    method protected void DisapproveOrder():
        define variable oDisapprovalForm as LightboxForm no-undo.
        define variable oFrame as DisapprovalReasonPanel extent 1 no-undo. 
        
        oFrame[1] = new DisapprovalReasonPanel(this-object).
        
        /* position where we want it on *this* form */
        oFrame[1]:Location = new Point(
            int((this-object:Size:Width / 2) - (oFrame[1]:Size:Width / 2 )),
            int((this-object:Size:Height / 2) - (oFrame[1]:Size:Height / 2 ) )).
        
        oDisapprovalForm = new LightboxForm(this-object, oFrame).
        oDisapprovalForm:Show().
    end method.
    
    method public void DisapproveOrder(input pcReason as character):
        CurrentTask:SetDataSlotValue('OrderApproved', 'false').
        CurrentTask:SetDataSlotValue('OrderRejectionReason', pcReason). 
        
        CompleteTask(CurrentTask).
    end method. 

    destructor public CustomerOrderDetail ( ):
        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.

    method public void ReassignTask(poTask as Task, pcPerformer as character):
        case poTask:WorkItem:Status:
            when WorkItemStatusEnum:Assigned then
                BpmServer:ReassignWorkItem(poTask:WorkItem:Id, pcPerformer).
            otherwise
                BpmServer:AssignWorkItem(poTask:WorkItem:Id, pcPerformer).
        end case.
        
        if pcPerformer ne poTask:WorkItem:Performer then
            OnCurrentTaskCompleted(poTask).
        
        catch oError as WebServiceInvocationError:
            oError:LogError().
        end catch.        
    end method.
    
    method public void CompleteTask(poTask as Task):
        if CurrentTask:WorkItem:Status:Equals(WorkItemStatusEnum:Available) then
            BpmServer:AssignWorkItem(
                        CurrentTask:WorkItem:Id,
                        lc(substitute('&1@&2',
                                SecMgr:CurrentUserContext:UserName,
                                SecMgr:CurrentUserContext:TenantName))).
        
        CurrentTask:SetDataSlotValue('OrderReviewed', 'true').
        CurrentTask:SetDataSlotValue('VehicleInStock', string(uxInStock:Checked, 'true/false')).
        
        BpmServer:CompleteTask(poTask).
        
        OnCurrentTaskCompleted(poTask).
        
        catch oError as WebServiceInvocationError:
            oError:ShowError().
            oError:LogError().
        end catch.
    end method.
    
    method protected void OnCurrentTaskCompleted(input poTask as Task):
        TaskCompleted:Publish(this-object, poTask).
    end method.
    
end class.
