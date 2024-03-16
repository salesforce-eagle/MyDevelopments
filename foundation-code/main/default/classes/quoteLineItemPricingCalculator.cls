public class quoteLineItemPricingCalculator {
    public static Map<id,Quote> mapOfQuotes;
    public static Map<id,product2> mapOfProducts;
    public static QuoteLineItem productPriceCalculator(QuoteLineItem temp){
            try{
                    if(temp.Sale_Price__c < temp.UnitPrice){
                        system.debug('Dis '+((temp.UnitPrice - temp.Sale_Price__c) / (temp.UnitPrice))*100);
                        decimal tempDiscount = ((temp.UnitPrice - temp.Sale_Price__c) / (temp.UnitPrice))*100;
                        if(tempDiscount < 0){
                            tempDiscount = -tempDiscount;
                        }
                        temp.Discount = tempDiscount.setScale(2);
                        temp.MarkUp__c = null;
                    }else If (temp.Sale_Price__c > temp.UnitPrice){
                        decimal tempMarkup = ((temp.Sale_Price__c - temp.UnitPrice) / (temp.UnitPrice))*100;
                        if(tempMarkup < 0){
                            tempMarkup = -tempMarkup;
                        }
                        temp.MarkUp__c = tempMarkup.setScale(2);
                        temp.Discount = null;
                    }else{
                        temp.MarkUp__c = null;
                        temp.Discount = null;
                    }
                    //End of Change List Price Editable in Pricing Calculator on 5th Feb 2021
                return temp;
            }
            catch(Exception E){
                System.debug('Pricing Error '+ E);
                System.debug('Exception Msg '+E.getMessage());
                System.debug('Exception Line number '+E.getLineNumber());
                /*temp.addError('Error occured please contact admin. Possible errors <br/> 1.Please specify non-zero List Price(E), as per the Pricing Calculator or KAM Dashboard.<br/>'+
                              +'2.Product formula value missing<br/>'
                              +'3.Multiplier or Price Per Invoice value missing<br/>'+
                              +'4.Product formula is having issue.');*/
                
        return NULL;
            }
        
                        
        
    }
    
    public static boolean checkNullValues(List<multiplierAndPPIBReplacer.results> results , QuoteLineItem LineItemRecord){
        System.debug('*&*& results '+results);
        set<string> fieldEmpty = new set<String>();
        for(multiplierAndPPIBReplacer.results result : results){
            for(string tempString : result.objectWithFields.Keyset() ){
                for(String tempField : result.objectWithFields.get(tempString) ){
                    If(mapOfQuotes.get(LineItemRecord.QuoteId).get(tempField) == null || mapOfQuotes.get(LineItemRecord.QuoteId).get(tempField) == ''){
                        fieldEmpty.add(Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap().get(tempField).getDescribe().getLabel());
                    }
                }
            }
        }
        System.debug('*&*& fieldEmpty '+fieldEmpty);
        if(fieldEmpty.size()>0){
            System.debug('*&*& ');
            string errorFields = '';
            integer counter = 1;
            for(string errorMsg : fieldEmpty){
                errorFields = errorFields + counter+'. '+ errorMsg + '<br/>';
                counter++;
            }
            System.debug('*&*& counter '+counter);
            System.debug('LineItemRecord '+LineItemRecord);
            LineItemRecord.addError('Please Enter values of <br/>'+ errorFields + ' in Quote for Product '+mapOfProducts.get(LineItemRecord.Product2Id).Name );
            return true;
        }else{
            System.debug('*&*& returning false');
            return false;
        }
    }
    
    public static List<String> getAllMatches(String text, String regex) {
        List<String> matches = new List<String>();
        System.debug('*&*& text '+text);
        System.debug('*&*& regex '+regex);
        Matcher m = Pattern.compile('(?=(' + regex + '))').matcher(text);
        System.debug('*&*& m '+m);
        while(m.find()) {
            System.debug('*&*& m.group(1) '+m.group(1));
            matches.add(m.group(1));
        }
        System.debug('*&*& matches '+matches);
        return matches;
    }
    
}