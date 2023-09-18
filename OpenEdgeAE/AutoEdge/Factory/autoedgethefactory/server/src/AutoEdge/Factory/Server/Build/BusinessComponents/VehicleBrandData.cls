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
    File        : VehicleBrandData
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : pjudge
    Created     : Mon Aug 02 09:28:42 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using AutoEdge.Factory.Server.Build.BusinessComponents.DealerModel.
using AutoEdge.Factory.Server.Build.BusinessComponents.VehicleBrandData.

class AutoEdge.Factory.Server.Build.BusinessComponents.VehicleBrandData:
    define public property Brand as character no-undo get. private set.
    define public property DealerNames as longchar no-undo get. private set.
    
    define public property CompactModels as longchar no-undo get. private set.
    define public property TruckModels as longchar no-undo get. private set.
    define public property SuvModels as longchar no-undo get. private set.
    define public property PremiumModels as longchar no-undo get. private set.
    define public property SedanModels as longchar no-undo get. private set.
    
    define public property InteriorTrimMaterial as longchar no-undo get. private set.
    define public property InteriorTrimColour as longchar no-undo get. private set.
    define public property InteriorAccessories as longchar no-undo get. private set.
    define public property ExteriorColour as longchar no-undo get. private set.
    define public property Moonroof as longchar no-undo get. private set.
    define public property Wheels as longchar no-undo get. private set.
    
    define private static temp-table ttModel   no-undo
        field Brand as character
        field ModelName as character
        field Style as character
        field Price as decimal
        index idx1 Brand Style
        .

    define private static temp-table ttEngine no-undo
        field Id as character
        field Engine as character
        field Premium as logical
        field Price as decimal
        .
    
    define private static temp-table ttOption no-undo
        field OptionGroup as character serialize-hidden 
        field OptionCode as character  serialize-name 'value'
        field OptionName as character  serialize-name 'label'
        field BaseOption as logical    serialize-name 'selected'
        field Price as decimal serialize-hidden
        index idx1 OptionGroup OptionCode.
    
    define private static dataset dsBrandData for ttModel, ttOption.
                
    constructor static VehicleBrandData():
        VehicleBrandData:InitData().
    end constructor.
    
    constructor public VehicleBrandData (pcBrand as character):
        Brand  = pcBrand.
        
        CompactModels = GetModels('compact').
        TruckModels = GetModels('truck').
        SedanModels = GetModels('sedan').
        SuvModels = GetModels('suv').
        PremiumModels = GetModels('premium').
        
        InteriorTrimMaterial = GetOptions('int-trim-mat').
        InteriorTrimColour = GetOptions('int-trim-colour').
        InteriorAccessories = GetOptions('int-accessories').
        ExteriorColour = GetOptions('ext-colour').
        Moonroof = GetOptions('moonroof').
        Wheels = GetOptions('wheels').
        
        DealerNames = GetDealers().
    end constructor.
    
    method static private void InitData():
        InitEngines().
        InitModels().
        InitOptions().
    end method.
    
    method static private void InitEngines():
        create ttEngine.
        assign ttEngine.Id = guid(generate-uuid)
               ttEngine.Engine = '1.8'
               ttEngine.Premium = no
               ttEngine.Price = 300. 
        
        create ttEngine.
        assign ttEngine.Id = guid(generate-uuid)
               ttEngine.Engine = '2.0 T'
               ttEngine.Premium = false
               ttEngine.Price = 450. 
        
        create ttEngine.
        assign ttEngine.Id = guid(generate-uuid)
               ttEngine.Engine = '2.0 TDi'
               ttEngine.Premium = no
               ttEngine.Price = 700. 

        create ttEngine.
        assign ttEngine.Id = guid(generate-uuid)
               ttEngine.Engine = '3.0 V6'
               ttEngine.Premium = true
               ttEngine.Price = 650. 

        create ttEngine.
        assign ttEngine.Id = guid(generate-uuid)
               ttEngine.Engine = '2.3 T'
               ttEngine.Premium = true
               ttEngine.Price = 700. 
    end method.
    
    method static private void InitOptions():
        /* moonroof */ 
        create ttOption.
        assign ttOption.OptionGroup = 'moonroof' 
               ttOption.OptionCode = 'none'
               ttOption.OptionName = 'None'
               ttOption.BaseOption = true
               ttOption.Price = 0
               .
        create ttOption.
        assign ttOption.OptionGroup = 'moonroof' 
               ttOption.OptionCode = 'panoramic'
               ttOption.OptionName = 'Panoramic Moonroof'
               ttOption.BaseOption = false
               ttOption.Price = 300
               .
        create ttOption.
        assign ttOption.OptionGroup = 'moonroof' 
               ttOption.OptionCode = 'standard'
               ttOption.OptionName = 'Standard Moonroof'
               ttOption.BaseOption = false
               ttOption.Price = 225
               .
        create ttOption.
        assign ttOption.OptionGroup = 'moonroof' 
               ttOption.OptionCode = 'sunroof'
               ttOption.OptionName = 'Sunroof Only'
               ttOption.BaseOption = false
               ttOption.Price = 150
               .
               
        /* wheels */
        create ttOption.
        assign ttOption.OptionGroup = 'wheels' 
               ttOption.OptionCode = '14std'
               ttOption.OptionName = 'Standard 14 inch'
               ttOption.BaseOption = true
               ttOption.Price = 0                                      
               .
        create ttOption.
        assign ttOption.OptionGroup = 'wheels' 
               ttOption.OptionCode = '20alloylo'
               ttOption.OptionName = '20 inch low-profile alloy'
               ttOption.BaseOption = false
               ttOption.Price = 365
               .
        create ttOption.
        assign ttOption.OptionGroup = 'wheels' 
               ttOption.OptionCode = 'offroad'
               ttOption.OptionName = 'Off-road'
               ttOption.BaseOption = false
               ttOption.Price = 550
               .
        /* exterior colour */
        create ttOption.
        assign ttOption.OptionGroup = 'ext-colour' 
               ttOption.OptionCode = 'White'
               ttOption.OptionName = 'White'
               ttOption.BaseOption = true
               ttOption.Price = 0
               .
        create ttOption.
        assign ttOption.OptionGroup = 'ext-colour' 
               ttOption.OptionCode = 'LightSteelBlue'
               ttOption.OptionName = 'Light Steel Blue'
               ttOption.BaseOption = false
               ttOption.Price = 0            
               .
        create ttOption.
        assign ttOption.OptionGroup = 'ext-colour' 
               ttOption.OptionCode = 'DarkGray'
               ttOption.OptionName = 'Charcoal'
               ttOption.BaseOption = false
               ttOption.Price = 0
               .
        create ttOption.
        assign ttOption.OptionGroup = 'ext-colour' 
               ttOption.OptionCode = 'DarkSeaGreen'
               ttOption.OptionName = 'Dark Green'
               ttOption.BaseOption = false
               ttOption.Price = 0
               .
        create ttOption.
        assign ttOption.OptionGroup = 'ext-colour' 
               ttOption.OptionCode = 'NavajoWhite'
               ttOption.OptionName = 'Champagne'
               ttOption.BaseOption = false
               ttOption.Price = 100
               .       
        /* trim material */
        create ttOption.
        assign ttOption.OptionGroup = 'int-trim-mat' 
               ttOption.OptionCode = 'pec-microfiber'
               ttOption.OptionName = 'Plush-E-Comfort Microfiber'
               ttOption.BaseOption = true
               ttOption.Price = 0
               .
        create ttOption.
        assign ttOption.OptionGroup = 'int-trim-mat' 
               ttOption.OptionCode = 'leather'
               ttOption.OptionName = 'Leather'
               ttOption.BaseOption = false
               ttOption.Price = 85
               .
        create ttOption.
        assign ttOption.OptionGroup = 'int-trim-mat' 
               ttOption.OptionCode = 'fabric'
               ttOption.OptionName = 'Fabric'
               ttOption.BaseOption = false
               ttOption.Price = 0
               .      
        /* trim colour */
        create ttOption.
        assign ttOption.OptionGroup = 'int-trim-colour' 
               ttOption.OptionCode = 'LightGray'
               ttOption.OptionName = 'Light Grey'
               ttOption.BaseOption = true
               ttOption.Price = 0
               .
        create ttOption.
        assign ttOption.OptionGroup = 'int-trim-colour' 
               ttOption.OptionCode = 'DarkSlateGray'
               ttOption.OptionName = 'Dark Slate Gray'
               ttOption.BaseOption = false
               ttOption.Price = 0
               .
        create ttOption.
        assign ttOption.OptionGroup = 'int-trim-colour' 
               ttOption.OptionCode = 'Tan'
               ttOption.OptionName = 'Tan'
               ttOption.BaseOption = false
               .
        create ttOption.
        assign ttOption.OptionGroup = 'int-trim-colour' 
               ttOption.OptionCode = 'Black'
               ttOption.OptionName = 'Charcoal'
               ttOption.BaseOption = false
               ttOption.Price = 0
               .
        /* accessories */
        create ttOption.
        assign ttOption.OptionGroup = 'int-accessories' 
               ttOption.OptionCode = 'nav'
               ttOption.OptionName = 'In-dash navigation'
               ttOption.BaseOption = false
               ttOption.Price = 275
               .        
        create ttOption.
        assign ttOption.OptionGroup = 'int-accessories' 
               ttOption.OptionCode = 'prem-sound'
               ttOption.OptionName = 'Premium Sound System'
               ttOption.BaseOption = false
               ttOption.Price = 455
               .      
        create ttOption.
        assign ttOption.OptionGroup = 'int-accessories' 
               ttOption.OptionCode = 'bluetooth'
               ttOption.OptionName = 'Bluetooth'
               ttOption.BaseOption = false
               ttOption.Price = 100
               .
    end method.
    
    method static private void InitModels():
        /* models */
        /* hinda */
        create ttModel.
        assign ttModel.Brand = 'Hinda'
               ttModel.ModelName = 'Civoc'
               ttModel.Style = 'compact'
               ttModel.Price = 9000
               .
        create ttModel.
        assign ttModel.Brand = 'Hinda'
               ttModel.ModelName = 'Accorn'
               ttModel.Style = 'sedan'
               ttModel.Price = 11000
               .
        create ttModel.
        assign ttModel.Brand = 'Hinda'
               ttModel.ModelName = 'CR-W'
               ttModel.Style = 'SUV'
               ttModel.Price = 12000
               .
        create ttModel.
        assign ttModel.Brand = 'Hinda'
               ttModel.ModelName = 'Odysey'
               ttModel.Style = 'SUV'
               ttModel.Price = 15000
               .
        /* Chery */
        create ttModel.
        assign ttModel.Brand = 'Chery'
               ttModel.ModelName = 'Avalanche'
               ttModel.Style = 'Truck'
               ttModel.Price = 12000
               .
        create ttModel.
        assign ttModel.Brand = 'Chery'
               ttModel.ModelName = 'Blazen'
               ttModel.Style = 'SUV'
               ttModel.Price = 16000
               .
        create ttModel.
        assign ttModel.Brand = 'Chery'
               ttModel.ModelName = 'Curve'
               ttModel.Style = 'Compact'
               ttModel.Price = 7000
               .
        create ttModel.
        assign ttModel.Brand = 'Chery'
               ttModel.ModelName = 'Siverado'
               ttModel.Style = 'Truck'
               ttModel.Price = 10000
               .
        /* potomoc */
        create ttModel.
        assign ttModel.Brand = 'Potomoc'
               ttModel.ModelName = 'GTO-X'
               ttModel.Style = 'premium'
               ttModel.Price = 17000
               .
        create ttModel.
        assign ttModel.Brand = 'Potomoc'
               ttModel.ModelName = 'Azteck'
               ttModel.Style = 'sedan'
               ttModel.Price = 14000
               .
        create ttModel.
        assign ttModel.Brand = 'Potomoc'
               ttModel.ModelName = 'Grandeur'
               ttModel.Style = 'sedan'
               ttModel.Price = 15000
               .
        create ttModel.
        assign ttModel.Brand = 'Potomoc'
               ttModel.ModelName = 'BM3'
               ttModel.Style = 'premium'
               ttModel.Price = 20000
               .
        create ttModel.
        assign ttModel.Brand = 'Potomoc'
               ttModel.ModelName = 'Stripe'
               ttModel.Style = 'compact'
               ttModel.Price = 10400
               .
        /* toyola */
        create ttModel.
        assign ttModel.Brand = 'Toyola'
               ttModel.ModelName = 'Crown'
               ttModel.Style = 'premium'
               ttModel.Price = 20000
               .            
        create ttModel.
        assign ttModel.Brand = 'Toyola'
               ttModel.ModelName = 'BV4'
               ttModel.Style = 'SUV'
               ttModel.Price = 19000
               .            
        create ttModel.
        assign ttModel.Brand = 'Toyola'
               ttModel.ModelName = 'Highland'
               ttModel.Style = 'premium'
               ttModel.Price = 22000
               .
        create ttModel.
        assign ttModel.Brand = 'Toyola'
               ttModel.ModelName = 'Tucoma'
               ttModel.Style = 'truck'
               ttModel.Price = 18500
               .
    end method.
    
    method protected longchar GetDealers():
        define variable oDealerModel as DealerModel no-undo.
        oDealerModel = new DealerModel(). 
        
        return oDealerModel:GetBrandDealer(Brand). 
    end method.
    
    method protected longchar GetModels(pcStyle as char):
        define variable cModels as longchar no-undo.
        define query qryEngine for ttEngine.
        
        if pcStyle eq 'premium' then
            open query qryEngine for each ttEngine where ttEngine.Premium = true by ttEngine.Engine.
        else
            open query qryEngine for each ttEngine where ttEngine.Premium = false by ttEngine.Engine.
        
        for each ttModel where
                 ttModel.Brand = this-object:Brand and
                 ttModel.Style = pcStyle
                 by ttModel.ModelName:
            
            get first qryEngine.
            do while not query-off-end('qryEngine'):
                cModels = cModels + ',' + ttModel.ModelName + ' - ' + ttEngine.Engine.
                get next qryEngine.
            end.
        end.
        
        close query qryEngine.
        
        return left-trim(cModels, ',').
    end method.
    
    method protected longchar GetOptions(pcGroup as char):
        define variable cOptions as longchar no-undo.
        
        cOptions = '['.
        for each ttOption where ttOption.OptionGroup = pcGroup:
            cOptions = cOptions + '~{'
                     + '~"selected~":' + string(ttOption.BaseOption, 'true/false') + ','
                     + '~"value~": ~"' + ttOption.OptionCode + '~",'
                     + '~"label~": ~"' + ttOption.OptionName + '~"'
                     + '~},'.
        end.
        
        cOptions = right-trim(cOptions, ',')  + ']'.
        
        return cOptions.
    end method.
    
    method static public decimal PriceVehicle(pcOrder as longchar):
        define variable dVehiclePrice as decimal no-undo.
        define variable hTable as handle no-undo.
        define variable hBuffer as handle no-undo.
        
        if pcOrder eq '' or pcOrder eq ? then
            return -1.
        
        /* ABL needs to know the/some/any tt name before read-json() works */
        if substring(left-trim(pcOrder), 1, 1) eq '[' then
            pcOrder = '~{' + quoter("ttOrder")  + ':' + pcOrder + '~}'.
        
        create temp-table hTable.
        hTable:read-json('longchar', pcOrder).
        hBuffer = hTable:default-buffer-handle.
        
        hBuffer:find-first().
        
        find ttModel where
             ttModel.Brand = hBuffer::Brand and
             ttModel.ModelName = trim(entry(1, hBuffer::Model, '-'))
             no-error.
        if available ttModel then
            dVehiclePrice = ttModel.Price.
        
        find ttEngine where ttEngine.Engine = trim(entry(2, hBuffer::Model, '-')) no-error.
        if available ttEngine then
            dVehiclePrice = dVehiclePrice + ttEngine.Price.                         
        
        dVehiclePrice = dVehiclePrice + VehicleBrandData:PriceOption(hBuffer::InteriorTrimMaterial).
        dVehiclePrice = dVehiclePrice + VehicleBrandData:PriceOption(hBuffer::InteriorTrimColour).
        dVehiclePrice = dVehiclePrice + VehicleBrandData:PriceOption(hBuffer::InteriorAccessories).
        dVehiclePrice = dVehiclePrice + VehicleBrandData:PriceOption(hBuffer::ExteriorColour).
        dVehiclePrice = dVehiclePrice + VehicleBrandData:PriceOption(hBuffer::Moonroof).
        dVehiclePrice = dVehiclePrice + VehicleBrandData:PriceOption(hBuffer::Wheels).
        
        return dVehiclePrice. 
        finally:
            delete object hBuffer no-error.
            delete object hTable no-error.
        end finally.        
    end method.
    
    method static private decimal PriceOption (pcOptions as character):
        define variable dOptionPrice as decimal no-undo.
        define variable iLoop as int no-undo.
        
        do iLoop = 1 to num-entries(pcOptions):
            find ttOption where ttOption.OptionCode = entry(iLoop, pcOptions) no-error.
            if available ttOption then
                dOptionPrice = dOptionPrice + ttOption.Price. 
        end.
        
        return dOptionPrice.
    end method.
    
end class.
