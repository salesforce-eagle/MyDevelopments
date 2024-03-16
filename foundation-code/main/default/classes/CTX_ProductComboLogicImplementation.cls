/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-29-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_ProductComboLogicImplementation {
    
    public static void getQLIDetailsFromQuote(Map<Id, Quote> incomingQuoteMap){
        
        Map<Id, Integer> 								quoteAndProductCount_ARR_Map	= new Map<Id, Integer>();
        Map<Id, List<QuoteLineItem>>					quoteAndQLI_ARR_Map				= new Map<Id, List<QuoteLineItem>>();
        Map<String, Product_Combo_Discount_Logic__mdt>	comboDiscountMap_ARR			= new Map<String, Product_Combo_Discount_Logic__mdt>();
        Map<String, Product_Combo_Discount_Logic__mdt>	comboDiscountMap_OTP			= new Map<String, Product_Combo_Discount_Logic__mdt>();
        Map<String, Product_Combo_Discount_Logic__mdt>	comboDiscountMap				= new Map<String, Product_Combo_Discount_Logic__mdt>();
        Map<String, Product_Combo_Logic_Inclusion__mdt>	comboLogicMap_ARR 				= new Map<String, Product_Combo_Logic_Inclusion__mdt>();
        Map<String, Product_Combo_Logic_Inclusion__mdt>	comboLogicMap_OTP 				= new Map<String, Product_Combo_Logic_Inclusion__mdt>();
        Set<String>										noOfInclusionProduct			= new Set<String>();
        Set<String>										comboLogicApplicableCodes		= new Set<String>();
        List<QuoteLineItem>								updateQuoteLineItemsWithCombo	= new List<QuoteLineItem>();
        
        
        Map<Id, Boolean>								quoteIntegrationPriceMap		= new Map<Id, Boolean>();
        
        
        /**	Fetch Metadata Results : START	**/
        for(
            Product_Combo_Logic_Inclusion__mdt thisRec : Product_Combo_Logic_Inclusion__mdt.getAll()?.values()
        ){
            if(thisRec.Billing_Type__c == 'ARR'){
                comboLogicMap_ARR.put(thisRec.Product_Code__c, thisRec);
            } else if(thisRec.Billing_Type__c == 'OTP'){
                comboLogicMap_OTP.put(thisRec.Product_Code__c, thisRec);
            }
            comboLogicApplicableCodes.add(thisRec.Product_Code__c);
        }
        
        for(
            Product_Combo_Discount_Logic__mdt thisRec : Product_Combo_Discount_Logic__mdt.getAll()?.values()
        ){
            comboDiscountMap.put(thisRec.DeveloperName, thisRec);
        }
        /**	Fetch Metadata Results : END	**/
        List<QuoteLineItem> quoteLineItemsToUpdateComboLogic = new List<QuoteLineItem>(); 
        List<String> RTList = new List<String>(system.label.Pricing_Applicable_RT.split(','));
        
        for(
            Quote thisQuote : [ SELECT Id,Opportunity.recordtype.name, 
                               ( SELECT Id, QuoteId, Sale_Price__c, Threshold_Price__c, Pre_Discount_Price__c, 
                                Threshold_List_Price_E__c, Threshold_Sale_Price_E__c, Type_of_Integration__c,
                                ListPrice, UnitPrice, Threshold_List_Price__c, Period_Start_date__c, Period_End_date__c,  
                                Product_Billing_Type_Formula__c, Is_Special_Price_Applicable__c, Combo_Discount_On_QLI__c,  
                                Product2Id, Product2.Product_Line__c, Product2.ProductCode, Product2.Billing_Type__c,  
                                Product2.Threshold_Price__c, Product2.Threshold_List_Price__c, Is_Combo_Price_Applicable__c,
                                Line_Item_Type__c
                                
                                FROM QuoteLineItems WHERE 
                                Product2.ProductCode IN :comboLogicApplicableCodes AND 
                                 Type_of_Integration__c EXCLUDES ('API- Only by Customer')  AND Line_Item_Type__c  IN :RTList
                                ORDER BY Period_Start_date__c ASC ) 
                               
                               FROM Quote WHERE 
                               Id IN :incomingQuoteMap.keySet()]
        ){
            
            system.debug('thisQuote: '+thisQuote.Id);
                
                
                if( thisQuote.QuoteLineItems != NULL ){
                    
                    Boolean 							isGST 				= FALSE;
                    Boolean 							isMAX 				= FALSE;
                    Boolean 							isComboApplicable 	= FALSE;
                    
                    /**	Year Wise Separation of Quote Line Items : START	**/
                    Map<String, List<QuoteLineItem>> 	yearlyQLIMap 		= new Map<String, List<QuoteLineItem>>();
                    Map<String, List<QuoteLineItem>> 	yearlyQLIMap_ARR	= new Map<String, List<QuoteLineItem>>();
                    Map<String, Boolean> 				yearlyBooleanMap 	= new Map<String, Boolean>();
                    Map<String, Decimal> 				yearlyDiscountMap 	= new Map<String, Decimal>();
                    /**	Year Wise Separation of Quote Line Items : END	**/
                    
                    for(QuoteLineItem thisRec : thisQuote.QuoteLineItems){	/**	This may have QLIs of Multi Year	**/
                        
                        String	multiYearKey = 'Year_'+thisRec.Period_Start_date__c?.Year();
                        
                        if(yearlyQLIMap.containsKey(multiYearKey)){
                            yearlyQLIMap.get(multiYearKey).add(thisRec);
                        } else{
                            yearlyQLIMap.put( multiYearKey, new List<QuoteLineItem>{thisRec} );
                        }
                        
                        
                        /**	if you get both the Product Line : Then Mark as True and deduct 25%	**/
                        
                        
                        
                    }	/**	This may have QLIs of Multi Year : END	**/
                    system.debug('yearlyQLIMap: '+yearlyQLIMap);
                    system.debug('yearlyQLIMap Keys: '+yearlyQLIMap.keySet());
                    
                    
                    for(String thisSTR : yearlyQLIMap.keySet()){
                        if(yearlyQLIMap.get(thisSTR) != NULL){
                            
                            Boolean 							isGST1 				= FALSE;
                            Boolean 							isMAX1 				= FALSE;
                            Boolean								isEINVOTP			= FALSE;
                            Boolean								isEWBOTP			= FALSE;
                            
                            for( QuoteLineItem thisRec : yearlyQLIMap.get(thisSTR) ){
                                if(thisRec.Product2.Billing_Type__c == 'ARR'){
                                    
                                    if(comboLogicMap_ARR.containsKey(thisRec.Product2.ProductCode)){
                                        
                                        isComboApplicable = TRUE;
                                        if( comboLogicMap_ARR.get(thisRec.Product2.ProductCode).Is_Special_Product__c ){
                                            
                                            if( thisRec.Product2.Product_Line__c == 'GST'){
                                                isGST1 = TRUE;
                                            }
                                            if( thisRec.Product2.Product_Line__c == 'Max'){
                                                isMAX1 = TRUE;
                                            }
                                        }
                                        
                                        if( yearlyQLIMap_ARR.containsKey(thisSTR) ){
                                            yearlyQLIMap_ARR.get(thisSTR).add(thisRec);
                                        } else{
                                            yearlyQLIMap_ARR.put( thisSTR, new List<QuoteLineItem>{thisRec} );
                                        }
                                        
                                    }
                                } else{
                                    /**	OTP	**/
                                    if(comboLogicMap_OTP.containsKey('INTGR_Einv_ASP_API')){
                                        if(thisRec.Product2.ProductCode == 'INTGR_Einv_ASP_API'){
                                        isEINVOTP 			= TRUE;
                                        isComboApplicable 	= TRUE;
                                    }
                                    }
                                    
                                    if(comboLogicMap_OTP.containsKey('INTGR_EWB_ASP_API')){  
                                        if(thisRec.Product2.ProductCode == 'INTGR_EWB_ASP_API'){
                                        isEWBOTP 			= TRUE;
                                        isComboApplicable 	= TRUE;
                                    }
                                    }
                                    
                                }
                                
                            }
                            
                            Boolean isComboSpecialPrice = FALSE;
                            if(isGST1 && isMAX1)
                                isComboSpecialPrice = TRUE;
                            yearlyBooleanMap.put(thisSTR, isComboSpecialPrice);
                            
                            if(isEINVOTP && isEWBOTP)
                                quoteIntegrationPriceMap.put(thisQuote.Id, TRUE);
                            
                        }
                    }
                    system.debug('yearlyBooleanMap: '+yearlyBooleanMap);
                    system.debug('yearlyBooleanMap Keys: '+yearlyBooleanMap.keySet());
                    system.debug('quoteIntegrationPriceMap: '+quoteIntegrationPriceMap);
                    system.debug('yearlyQLIMap_ARR: '+yearlyQLIMap_ARR.keySet());
                    /**	END	**/
                    
                    /**	Get Year Wise Discount Percentage : START	**/
                    Double productComboDiscount = System.label.ProductComboDiscount != NULL ? Double.ValueOf(System.label.ProductComboDiscount) : 0;
                    for( String thisSTR : yearlyQLIMap.keySet() ){
                        
                        if(yearlyQLIMap.get(thisSTR) != NULL){
                            system.debug('yearlyQLIMap thisSTR: '+thisSTR);
                            
                            for( Product_Combo_Discount_Logic__mdt thisLogic : comboDiscountMap.values() ){
                                
                                Decimal discountPercentage	= 0;
                                //system.debug('yearlyQLIMap_ARR.get(thisSTR).size(): '+yearlyQLIMap_ARR.get(thisSTR).size());
                                
                                if(yearlyQLIMap_ARR.containsKey(thisSTR) && yearlyQLIMap_ARR.get(thisSTR).size() >= 4){
                                    if( 4 == thisLogic.Product_Quantity__c ){
                                        if( 
                                            yearlyBooleanMap.get(thisSTR) == thisLogic.Is_Special_Product_Price__c 
                                        ){
                                            discountPercentage = thisLogic.Discount_Rate__c != NULL ? thisLogic.Discount_Rate__c : 0;
                                            yearlyDiscountMap.put(thisSTR, discountPercentage);
                                        }
                                        
                                    }
                                } else if(yearlyQLIMap_ARR.containsKey(thisSTR) && yearlyQLIMap_ARR.get(thisSTR).size() == thisLogic.Product_Quantity__c ){
                                    if( 
                                        yearlyBooleanMap.get(thisSTR) == thisLogic.Is_Special_Product_Price__c 
                                    ){
                                        discountPercentage = thisLogic.Discount_Rate__c != NULL ? thisLogic.Discount_Rate__c : 0;
                                        yearlyDiscountMap.put(thisSTR, discountPercentage);
                                    }
                                    
                                }
                                
                                system.debug('discountPercentage: '+discountPercentage);
                            }
                        }
                        system.debug('yearlyDiscountMap: '+yearlyDiscountMap);
                    }	/**	Get Year Wise Discount Percentage : END	**/
                    
                    
                    for(QuoteLineItem thisRec : thisQuote.QuoteLineItems){
                        
                        Integer poYear = thisRec.Period_Start_date__c?.Year();
                        system.debug('BEFORE thisRec.UnitPrice: '+thisRec.UnitPrice);
                        
                        thisRec.Pre_Discount_Price__c 			= thisRec.UnitPrice;
                        
                        thisRec.Is_Combo_Price_Applicable__c 	= isComboApplicable;
                        thisRec.Is_Special_Price_Applicable__c 	= yearlyBooleanMap.get('Year_'+poYear);
                        system.debug('yearlyDiscountMap Outside: '+yearlyDiscountMap);
                        if( yearlyDiscountMap.size() > 0 && yearlyDiscountMap != NULL ){
                            system.debug('yearlyDiscountMap Inside: '+yearlyDiscountMap);
                            system.debug('thisRec.Product2.Billing_Type__c '+thisRec.Product2.Billing_Type__c);
                            if(thisRec.Product2.Billing_Type__c != 'OTP'){
                                
                                thisRec.Combo_Discount_On_QLI__c 	    = yearlyDiscountMap.get('Year_'+poYear);
                                
                                if(yearlyDiscountMap.get('Year_'+poYear) != NULL ){
                                    thisRec.UnitPrice 					= ( thisRec.UnitPrice - (( thisRec.UnitPrice * yearlyDiscountMap.get('Year_'+poYear) )/100) );
                                }
                                
                                if(thisRec.UnitPrice !=thisRec.Pre_Discount_Price__c )
                                {
                                    thisRec.Is_Formula_Price_Applicable__c 	= FALSE;
                                }
                                if(yearlyDiscountMap.get('Year_'+poYear) != NULL){
                                    thisRec.Threshold_List_Price_E__c	    = ( thisRec.Threshold_List_Price__c - (( thisRec.Threshold_List_Price__c * yearlyDiscountMap.get('Year_'+poYear) )/100) );
                                    thisRec.Threshold_Sale_Price_E__c	    = ( thisRec.Threshold_Price__c - (( thisRec.Threshold_Price__c * yearlyDiscountMap.get('Year_'+poYear) )/100) );   
                                }
                            } else{
                                system.debug('In OTP Block');
                                if(quoteIntegrationPriceMap.size() > 0){
                                    if(quoteIntegrationPriceMap.containsKey(thisRec.QuoteId)){
                                        
                                        system.debug('OTP Calculation Block');
                                        thisRec.Pre_Discount_Price__c 			= thisRec.UnitPrice;
                                        thisRec.Is_Special_Price_Applicable__c 	= TRUE;
                                        thisRec.Is_Combo_Price_Applicable__c	= TRUE;
                                        thisRec.Is_Formula_Price_Applicable__c 	= FALSE;
                                        thisRec.UnitPrice 						= ( thisRec.UnitPrice - (( thisRec.UnitPrice * productComboDiscount )/100) );
                                        thisRec.Threshold_List_Price_E__c	    = ( thisRec.Threshold_List_Price__c - (( thisRec.Threshold_List_Price__c * productComboDiscount )/100) );
                                        thisRec.Threshold_Sale_Price_E__c	    = ( thisRec.Threshold_Price__c - (( thisRec.Threshold_Price__c * productComboDiscount )/100) );   
                                        thisRec.Combo_Discount_On_QLI__c		= productComboDiscount;
                                    }
                                }
                            }
                        } else if(thisRec.Product2.Billing_Type__c != 'ARR'){
                            
                            system.debug('In OTP Block');
                            if(quoteIntegrationPriceMap.size() > 0){
                                if(quoteIntegrationPriceMap.containsKey(thisRec.QuoteId)){
                                    
                                    system.debug('OTP Calculation Block');
                                    thisRec.Pre_Discount_Price__c 			= thisRec.UnitPrice;
                                    thisRec.Is_Special_Price_Applicable__c 	= TRUE;
                                    thisRec.Is_Combo_Price_Applicable__c	= TRUE;
                                    thisRec.Is_Formula_Price_Applicable__c 	= FALSE;
                                    thisRec.UnitPrice 						= ( thisRec.UnitPrice - (( thisRec.UnitPrice * productComboDiscount )/100) );
                                    thisRec.Threshold_List_Price_E__c	    = ( thisRec.Threshold_List_Price__c - (( thisRec.Threshold_List_Price__c * productComboDiscount )/100) );
                                    thisRec.Threshold_Sale_Price_E__c	    = ( thisRec.Threshold_Price__c - (( thisRec.Threshold_Price__c * productComboDiscount )/100) );   
                                    thisRec.Combo_Discount_On_QLI__c		= productComboDiscount;
                                }
                            } else{
                                thisRec.Combo_Discount_On_QLI__c 	= 0;
                                thisRec.UnitPrice 					= thisRec.UnitPrice;
                                thisRec.Threshold_List_Price_E__c	= thisRec.Threshold_List_Price_E__c;
                                thisRec.Threshold_Sale_Price_E__c	= thisRec.Threshold_Sale_Price_E__c;
                            }
                        }
                        
                        
                        
                        system.debug('AFTER thisRec.UnitPrice: '+thisRec.UnitPrice);
                        
                        updateQuoteLineItemsWithCombo.add(thisRec);
                    }
                }           
        }
        
        system.debug('updateQuoteLineItemsWithCombo: '+updateQuoteLineItemsWithCombo);
        update updateQuoteLineItemsWithCombo;
    }
    
}