public class CTX_CustomStringToFormulaParser {
    
    public static Decimal resultRecur = 0;
    
    public static Map<String, Decimal> 	CTX_CustomStringToFormulaParserMethod(Set<Id> productIdSet, List<QuoteLineItem> QLIList ){
        
        try{
            // Map<Integer,String> 		fieldNameMap		= new Map<Integer,String>();
            Map<Id,List<String>>		QLItempArrayMap  	= new Map<Id,List<String>>(); 
            Map<Id,String> 				QLIQueryStringMap	= new Map<Id,String>();
            Map<Integer,List<String>> 	multiIfMap  		= new Map<Integer,List<String>>();
            Map<String,Decimal> 		returnQuoteIdMap  	= new Map<String,Decimal>();
            List<String> 				tempList			= new List<String>{'quoteId,lineNumber'};
                Decimal 				    finalAns			= 0;
            String fieldList;
            String queryString;
            String reformedExpr;
            
            Map<Id,String> 				qliFormulaMap	= new Map<Id,String>();
            
            
            /**	This is where we have the Expresion with only Logical Expression + Special Expressions : START	**/
            for(QuoteLineItem quoteLineIns: QLIList){
                system.debug('quoteLineIns%^&^'+quoteLineIns);
                // fieldNameMap		= new Map<Integer,String>(); 
                QLIQueryStringMap	= new Map<Id,String>();
                multiIfMap  		= new Map<Integer,List<String>>();
                returnQuoteIdMap  	= new Map<String,Decimal>();
                //tempList			= new List<String>{'quoteId,lineNumber'};
                //finalAns			= 0;
                fieldList = '';
                queryString = '';
                reformedExpr = '';
                finalAns = 0;
                
                
                String 						toBeParsed		= quoteLineIns.product_formula__c;
                toBeParsed                      			= toBeParsed.replaceAll( '\\s+', ' ');	/**	Remove multiple whitespaces	**/
                List<String> 				tempArray		= toBeParsed.split(' ');
                
                
                for( String tempIns : tempArray ){
                    if( tempIns.substringBetween('$F','$F') != NULL ){
                        tempList.add(tempIns.substringBetween('$F','$F'));
                        // fieldNameMap.put(++i,tempIns.substringBetween('$F','$F'));
                    }
                }
                
                QLItempArrayMap.put(quoteLineIns.Id,tempArray);
                //tempList.addAll(fieldNameMap.Values());
            }
            
            If( !tempList.isEmpty() ){
                fieldList 	= String.Join(new List<String>(new Set<String>(tempList)),',');
                queryString	= ' SELECT '+fieldList+ ' FROM QuoteLineItem where id IN: QLIList ' ;
                system.debug('queryString: '+queryString);
            } 
            
            /**	Reform formula with actual values : START	**/
            for( Sobject quoteLineIns: database.query(queryString) ){
                
                List<String> tempArray = QLItempArrayMap.get(quoteLineIns.Id);
                for(String tempIns : tempArray){
                    Integer tempIndex = tempArray.indexOf(tempIns);
                    if(tempIns.substringBetween('$F','$F') != NULL){
                        String fieldName = tempIns.substringBetween('$F','$F');
                        system.debug('fieldName^&^'+ fieldName);
                        if(!fieldName.contains('.')){
                            system.debug('fieldName'+fieldName+'fieldNameVal:'+String.ValueOf(quoteLineIns.get(fieldName) == NULL ? 0 : quoteLineIns.get(fieldName)));
                            tempIns=tempIns.replace(fieldName,String.ValueOf(quoteLineIns.get(fieldName) == NULL ? 0 : quoteLineIns.get(fieldName)));
                        }
                        else {
                            String sobjectName = fieldName.substringBefore('.');
                            String refFieldName = fieldName.substringAfter('.');
                            tempIns=tempIns.replace(fieldName,(String.ValueOf(quoteLineIns.getSobject(sobjectName).get(refFieldName) == NULL ? 0 : quoteLineIns.getSobject(sobjectName).get(refFieldName))));
                        }
                    }
                    tempArray[tempIndex] = tempIns;
                }
                
                reformedExpr = String.Join(tempArray,' ');	/**	Reform formula with actual values	**/
                reformedExpr = reformedExpr.remove('$F');	/**	Can be moved up	**/
                qliFormulaMap.put(quoteLineIns.Id, reformedExpr);
                System.debug('reformed#!@#@: '+reformedExpr);
                /**	This is where we have the Expresion with only Logical Expression + Special Expressions : END	**/
                
                //evaluateFormulaByQuoteLineItem(qliFormulaMap);
                Boolean round  		= FALSE;
                Integer roundPar 	= 0;
                
                /**	Entire Expression In ROUND[] : START	**/
                if( 
                    reformedExpr.startsWith('ROUND') && 
                    reformedExpr.endsWith(']')
                ){
                    round 			= TRUE;
                    roundPar 		= Integer.ValueOf(reformedExpr.substringAfter('D').substringBefore('['));
                    reformedExpr 	= reformedExpr.removeStart(reformedExpr.substringBefore(' '));
                    reformedExpr 	= reformedExpr.removeEnd(']');
                    system.debug('roundExpr: '+reformedExpr);
                }
                
                /** if(reformedExpr.contains(';')){
for(String thisSTR : reformedExpr.split(';')){
system.debug('reformedExpr POST Split: '+thisSTR);
}
}**/
                reformedExpr = reformedExpr.trim();
                if( 
                    (
                        reformedExpr.startsWith('MAX{') && reformedExpr.endsWith('}') ||
                        reformedExpr.startsWith('MIN{') && reformedExpr.endsWith('}')
                    ) && !reformedExpr.contains('$C')
                ){
                    system.debug('Inside MAX MIN If: '+reformedExpr);
                    finalAns = Decimal.ValueOf(maxMinEval(reformedExpr));
                } else{
                    system.debug('Inside MAX MIN Else: '+reformedExpr);
                    finalAns = fetchFinalExpVal(reformedExpr);
                }
                
                
                if(round){
                    finalAns = finalAns > RoundPar - 1 ? (finalAns/Math.pow(10,roundPar)).setScale(0) * Math.pow(10,roundPar) : finalAns ;
                }
                
                returnQuoteIdMap.put(quoteLineIns.Id != NULL ? quoteLineIns.Id : (String)quoteLineIns.get('LineNumber'), finalAns);
            }
            /**	Reform formula with actual values : END	**/
            
            return returnQuoteIdMap;
        } catch (exception e){
            
            system.debug('Error: '+e.getMessage());
            throw new CTX_CustomStackUnderflowException(
                'Product Formula Error: '+e.getLineNumber()+', '+e.getMessage()+ 
                '\': Check for blank space after each Number/Field/Operator, valid field API Names enclosed in \'$F\' and join multiple Ternary cases using \'$J+$J\' Symbol !');
        }
        
    }
    public Static String 				maxMinEval(String reformedExprLoc){
        
        Boolean round  		= FALSE;
        Integer roundPar 	= 0;
        reformedExprLoc = reformedExprLoc.trim();
        system.debug('Expr:'+reformedExprLoc);
        // system.debug('LastExpr:'+reformedExprLoc.charAt(reformedExprLoc.length()-1)+'*'+reformedExprLoc.charAt(reformedExprLoc.length()-2)+'*'+reformedExprLoc.charAt(reformedExprLoc.length()-3));
        Decimal finalAnsLoc = -999999999;
        System.debug('reformedExprLoc in Pre MAX Block: '+reformedExprLoc); 
        if(reformedExprLoc.startsWith('MAX{') &&  reformedExprLoc.endsWith('}') ){
            
            //round = TRUE;
            //roundPar = Integer.ValueOf(reformedExpr.substringAfter('D').substringBefore('['));
            reformedExprLoc = reformedExprLoc.removeStart(reformedExprLoc.removeStart('MAX{'));
            reformedExprLoc =  reformedExprLoc.removeStart(reformedExprLoc.substringBefore(' '));
            reformedExprLoc = reformedExprLoc.removeEnd('}');
            system.debug('reformedExprLoc%^^' + reformedExprLoc);
            if(!reformedExprLoc.contains(';')){
                for(String singleExp : reformedExprLoc.Split(',')){
                    system.debug('singleLoc%^^1' + singleExp);
                    
                    singleExp = singleExp.trim();
                    if(singleExp.startsWith('MAX{') && singleExp.endsWith('}')
                       ||
                       singleExp.startsWith('MIN{') && singleExp.endsWith('}')){
                           
                           singleExp = maxMinEval ( singleExp ); 
                       }
                    
                    system.debug('singleLoc%^^2' + singleExp);
                    
                    if(singleExp.startsWith('ROUND') && singleExp.endsWith(']')){
                        round = TRUE;
                        roundPar = Integer.ValueOf(singleExp.substringAfter('D').substringBefore('['));
                        singleExp =  singleExp.removeStart(singleExp.substringBefore(' '));
                        singleExp = singleExp.removeEnd(']');
                    }
                    
                    Decimal temp = fetchFinalExpVal(singleExp); 
                    system.debug('temp%^^'+temp);
                    if(temp > finalAnsLoc){
                        finalAnsLoc = temp;
                    }
                    
                }
            }
            
            for(String singleExp : reformedExprLoc.Split(';')){
                
                system.debug('singleLoc%^^1' + singleExp);
                
                singleExp = singleExp.trim();
                if(singleExp.startsWith('MAX{') && singleExp.endsWith('}')
                   ||
                   singleExp.startsWith('MIN{') && singleExp.endsWith('}')){
                       
                       singleExp = maxMinEval ( singleExp ); 
                   }
                
                system.debug('singleLoc%^^2' + singleExp);
                
                if(singleExp.startsWith('ROUND') && singleExp.endsWith(']')){
                    round = TRUE;
                    roundPar = Integer.ValueOf(singleExp.substringAfter('D').substringBefore('['));
                    singleExp = singleExp.removeStart(singleExp.substringBefore(' '));
                    singleExp = singleExp.removeEnd(']');
                }
                
                Decimal temp = fetchFinalExpVal(singleExp); 
                system.debug('temp%^^'+temp);
                if(temp > finalAnsLoc){
                    finalAnsLoc = temp;
                }
                
            }
            if(round){
                finalAnsLoc = finalAnsLoc > RoundPar - 1 ? (finalAnsLoc/Math.pow(10,roundPar)).setScale(0) * Math.pow(10,roundPar) : finalAnsLoc ;
            }
            return string.ValueOf(finalAnsLoc);
        }
        
        System.debug('reformedExprLoc in Post MAX Block: '+reformedExprLoc); 
        if(reformedExprLoc.startsWith('MIN{') && reformedExprLoc.endsWith('}')){
            //round = TRUE;
            //roundPar = Integer.ValueOf(reformedExpr.substringAfter('D').substringBefore('['));
            System.debug('reformedExprLoc in MIN Block: '+reformedExprLoc);
            if(reformedExprLoc.contains(';')){
                for(String thisSTR : reformedExprLoc.Split(';')){
                    System.debug('reformedExprLoc in MIN Block Split By ; : '+thisSTR);
                }
            }
            reformedExprLoc = reformedExprLoc.removeStart(reformedExprLoc.removeStart('MIN{'));
            reformedExprLoc = reformedExprLoc.removeStart(reformedExprLoc.substringBefore(' '));
            reformedExprLoc = reformedExprLoc.removeEnd('}');
            
            if(!reformedExprLoc.contains(';')){
                Boolean zeroEval;
                for(String singleExp : reformedExprLoc.Split(',')){
                    system.debug('singleLoc%^^1 - MIN' + singleExp);
                    
                    singleExp = singleExp.trim();
                    if(singleExp.startsWith('MAX{') && singleExp.endsWith('}')
                       ||
                       singleExp.startsWith('MIN{') && singleExp.endsWith('}')){
                           
                           singleExp = maxMinEval ( singleExp ); 
                       }
                    
                    system.debug('singleLoc%^^2 - MIN' + singleExp);
                    
                    if(singleExp.startsWith('ROUND') && singleExp.endsWith(']')){
                        round = TRUE;
                        roundPar = Integer.ValueOf(singleExp.substringAfter('D').substringBefore('['));
                        singleExp = singleExp.removeStart(singleExp.substringBefore(' '));
                        singleExp = singleExp.removeEnd(']');
                    }
                    
                    Decimal temp = fetchFinalExpVal(singleExp); 
                   /** if(temp == 0){
                        zeroEval = TRUE;
                    }**/
                    
                    if(finalAnsLoc == -999999999 ){
                        finalAnsLoc= temp;
                    }
                    if(temp < finalAnsLoc ){
                        
                        finalAnsLoc = temp;
                    }
                    system.debug('localAns:123'+ finalAnsLoc) ;
                }
                system.debug('finallocalAns:'+ finalAnsLoc) ;
            }
            else{
            for(String singleExp : reformedExprLoc.Split(';')){
                singleExp = singleExp.trim();
                system.debug('finalExpr%^^'+singleExp);
                if(singleExp.startsWith('MAX{') && singleExp.endsWith('}')
                   ||
                   singleExp.startsWith('MIN{') && singleExp.endsWith('}')){
                       
                       singleExp = maxMinEval ( singleExp ); 
                   }
                if(singleExp.startsWith('ROUND') && singleExp.endsWith(']')){
                    round = TRUE;
                    roundPar = Integer.ValueOf(singleExp.substringAfter('D').substringBefore('['));
                    singleExp = singleExp.removeStart(singleExp.substringBefore(' '));
                    singleExp = singleExp.removeEnd(']');
                }
                
                Decimal temp = fetchFinalExpVal(singleExp); 
                system.debug('temp%^^'+temp);
                    if(finalAnsLoc == -999999999 ){
                        finalAnsLoc= temp;
                    }
                if(temp < finalAnsLoc ){
                    
                    finalAnsLoc = temp;
                }
                
            }
            }
            if(round){
                finalAnsLoc = finalAnsLoc > RoundPar - 1 ? (finalAnsLoc/Math.pow(10,roundPar)).setScale(0) * Math.pow(10,roundPar) : finalAnsLoc ;
            }
            return string.ValueOf(finalAnsLoc);
        }
        return reformedExprLoc;
        
    }
    public Static Decimal 				IfSolver(String ifString){
        ifString = ifString.trim();
        if(ifString.contains('$J')){
            return fetchFinalExpVal(ifString);
        }
        system.debug('IfSolverExpr'+ ifString);
        //List<String> ifMapRawList = ifString.Split('\\?'); // '\\?' = '?'
        Integer ternaryOperator   = 0;
        Decimal tempAns           = 0;
        // system.debug('FinalStrExpr : '+IfMapRawList);
        Boolean round  = False;
        Integer roundPar = 0;
        if(ifString.startsWith('ROUND') && ifString.endsWith(']')){  
            round = TRUE;
            roundPar = Integer.ValueOf(ifString.substringAfter('D').substringBefore('['));
            ifString = ifString.removeStart(ifString.substringBefore(' '));
            ifString = ifString.removeEnd(']');
            system.debug('ifSolverRound:'+ ifString );
        }
        if(ifString.contains('$J') || ifString.contains('$C') || ifString.contains('$R')){
            Decimal resultLoc = fetchFinalExpVal(ifString);
            if(round){
                system.debug('boolResultRound:'+round);
                resultLoc = resultLoc > RoundPar - 1 ? (resultLoc/Math.pow(10,roundPar)).setScale(0) * Math.pow(10,roundPar) : resultLoc ;
            }
            return resultLoc;
        }
        ifString = maxMinEval(ifString);
        //recursion logic
        Decimal boolResult = CTX_CustomEvaluateString.evaluate(ifString.substringBefore('?'));
        system.debug('boolResult@##'+ifString);
        Decimal result=ifString.isnumeric() ? Decimal.ValueOf(ifString) : 0;
        String totalStringAfterCheck = ifString.substringAfter('?');
        Integer breakIndex           = returnTValFVal(totalStringAfterCheck);
        system.debug('breakIndex^$$^' + breakIndex);
        String trueValue  = breakIndex-1 > 0 ? totalStringAfterCheck.substring(0,breakIndex) : '';
        String falseValue = breakIndex+1 > 0 ? totalStringAfterCheck.substring(breakIndex+1) : '';
        system.debug('testTrue'+ trueValue);
        system.debug('testFalse'+ falseValue);
        if(boolResult == 0 && !String.ISBLANK(falseValue)){
            
            result = IfSolver ( falseValue ); 
            
        }
        else If(boolResult == 1 && !String.ISBLANK(trueValue)){
            
            result = IfSolver ( trueValue ); 
        }
        
        else{
            if(round){
                system.debug('boolResultRound:'+round);
                boolResult = boolResult > RoundPar - 1 ? (boolResult/Math.pow(10,roundPar)).setScale(0) * Math.pow(10,roundPar) : boolResult ;
            }
            return boolResult;
        }
        if(round){
            system.debug('resultRound:'+round);
            result = result > RoundPar - 1 ? (result/Math.pow(10,roundPar)).setScale(0) * Math.pow(10,roundPar) : result ;
        }
        resultRecur = result;
        system.debug('resultRecur%^&&' + resultRecur);
        //recursion logic
        return resultRecur;
    }
    public Static Decimal 				fetchFinalExpVal(String reformedExprLoc){
        Decimal finalAns = 0;
        if(reformedExprLoc.contains('$R')){
            List<String> multiIfRawList = reformedExprLoc.Split('\\$R');
            system.debug('multiIfRawList$%'+multiIfRawList);
            List<String> multiIfList = new List<String>();
            for(Integer j = 0; j < multiIfRawList.size(); j++ ){ 
                system.debug('IfSolverExpr'+ multiIfRawList[j]);
                multiIfList.add(math.mod(j,2) == 0 ? String.ValueOf(IfSolver(multiIfRawList[j])) : multiIfRawList[j]);
            }
            finalAns = multiIfList.Size() > 1 ? IfSolver(String.Join(multiIfList,' ')) : Decimal.ValueOf(multiIfList[0]); 
        } else{
            List<String> multiIfRawList = new List<String>();
            if(reformedExprLoc.contains('$C')){
                multiIfRawList = reformedExprLoc.Split('\\$C');   
            }
            else if(reformedExprLoc.contains('$IC') && !reformedExprLoc.contains(';')){
                multiIfRawList = reformedExprLoc.Split('\\$IC');
                system.debug('testInsideCom'+multiIfRawList);
            }
            else{
                multiIfRawList = reformedExprLoc.Split('\\$J');
            }
            system.debug('multiIfRawList$%'+multiIfRawList);
            List<String> multiIfList = new List<String>();
            for(Integer j = 0; j < multiIfRawList.size(); j++ ){ 
                system.debug('IfSolverExpr'+ multiIfRawList[j]);
                multiIfList.add(math.mod(j,2) == 0 ? String.ValueOf(IfSolver(multiIfRawList[j])) : multiIfRawList[j]);
            }
            finalAns = multiIfList.Size() > 1 ? IfSolver(String.Join(multiIfList,' ')) : Decimal.ValueOf(multiIfList[0]); 
            
        }
        
        return finalAns;
        
    }
    public Static Integer 				returnTValFVal(String exprAfterCheck){
        List<String> ifCondTokenList = exprAfterCheck.Split('');
        String prevSplToken= '';
        Integer breakExpr = exprAfterCheck.IndexOf(':');
        Boolean firstEntry = TRUE;
        for(Integer i = 0 ; i < ifCondTokenList.Size()-1 ; i++){
            if(ifCondTokenList[i] == ':' && prevSplToken == ifCondTokenList[i] ){
                breakExpr = i ;
                break;
            }
            if(ifCondTokenList[i] == '?' || ifCondTokenList[i] == ':'){
                prevSplToken = ifCondTokenList[i];
                if(prevSplToken == ':' && firstEntry){
                    breakExpr = i ;
                    break;
                }
                firstEntry = FALSE;
            }
        }
        system.debug('posEle'+ exprAfterCheck.length());
        return breakExpr;
    }
    public static Map<String, Decimal>	evaluateFormulaByQuoteLineItem(Map<Id, String> qliFormulaMap){
        
        if(qliFormulaMap.keySet().size() > 0){
            /**	Check for SPECIAL Expressions	**/
            for(String thisSTR : qliFormulaMap.values()){
                
                system.debug('MIN COUNT : '+thisSTR.countMatches('MIN{'));
                system.debug('MAX COUNT : '+thisSTR.countMatches('MAX{'));
                /**	**/
                if(thisSTR.containsIgnoreCase('ROUND')){}
                if(thisSTR.containsIgnoreCase('MIN')){}
                if(thisSTR.containsIgnoreCase('MAX')){}
            }
        }
        
        
        
        
        return NULL;
    }
    
    public static Decimal customFormulaPriceCalculator(QuoteLineItem quoteLineIns, String formula){
        Decimal 				    finalAns		= 0;
        String reformedExpr;
        Map<Id,String> 				qliFormulaMap	= new Map<Id,String>();
        
        String 						toBeParsed		= formula;
        toBeParsed                      			= toBeParsed.replaceAll( '\\s+', ' ');	/**	Remove multiple whitespaces	**/
        List<String> 				tempArray		= toBeParsed.split(' ');
        
        System.debug('##formula : '+ formula);
        System.debug('##toBeParsed : '+ toBeParsed);
        /*List<String> 				tempList		= new List<String>{'quoteId,lineNumber'};
        String 						fieldList		= '';
        String 						queryString 	= '';
        
        for( String tempIns : tempArray ){
            if( tempIns.substringBetween('$F','$F') != NULL ){
                tempList.add(tempIns.substringBetween('$F','$F'));
            }
        }
    
        If( !tempList.isEmpty() ){
            fieldList 	= String.Join(new List<String>(new Set<String>(tempList)),',');
            queryString	= ' SELECT '+fieldList+ ' FROM QuoteLineItem where id IN: qliId ' ;
            system.debug('queryString: '+queryString);
        }*/
        //QuoteLineItem quoteLineIns = database.query(queryString);
        for(String tempIns : tempArray){
            Integer tempIndex = tempArray.indexOf(tempIns);
            if(tempIns.substringBetween('$F','$F') != NULL){
                String fieldName = tempIns.substringBetween('$F','$F');
                system.debug('fieldName^&^'+ fieldName);
                if(!fieldName.contains('.')){
                    system.debug('fieldName'+fieldName+'fieldNameVal:'+String.ValueOf(quoteLineIns.get(fieldName) == NULL ? 0 : quoteLineIns.get(fieldName)));
                    tempIns=tempIns.replace(fieldName,String.ValueOf(quoteLineIns.get(fieldName) == NULL ? 0 : quoteLineIns.get(fieldName)));
                }
                else {
                    String sobjectName = fieldName.substringBefore('.');
                    String refFieldName = fieldName.substringAfter('.');
                    tempIns=tempIns.replace(fieldName,(String.ValueOf(quoteLineIns.getSobject(sobjectName).get(refFieldName) == NULL ? 0 : quoteLineIns.getSobject(sobjectName).get(refFieldName))));
                }
            }
            tempArray[tempIndex] = tempIns;
        }
        
        System.debug('tempArray#!@#@: '+tempArray);
        reformedExpr = String.Join(tempArray,' ');	/**	Reform formula with actual values	**/
        reformedExpr = reformedExpr.remove('$F');	/**	Can be moved up	**/
        qliFormulaMap.put(quoteLineIns.Id, reformedExpr);
        System.debug('reformed#!@#@: '+reformedExpr);
        /**	This is where we have the Expresion with only Logical Expression + Special Expressions : END	**/
        
        //evaluateFormulaByQuoteLineItem(qliFormulaMap);
        Boolean round  		= FALSE;
        Integer roundPar 	= 0;
        
        /**	Entire Expression In ROUND[] : START	**/
        if( 
            reformedExpr.startsWith('ROUND') && 
            reformedExpr.endsWith(']')
        ){
            round 			= TRUE;
            roundPar 		= Integer.ValueOf(reformedExpr.substringAfter('D').substringBefore('['));
            reformedExpr 	= reformedExpr.removeStart(reformedExpr.substringBefore(' '));
            reformedExpr 	= reformedExpr.removeEnd(']');
            system.debug('roundExpr: '+reformedExpr);
        }
        
        /** if(reformedExpr.contains(';')){
for(String thisSTR : reformedExpr.split(';')){
system.debug('reformedExpr POST Split: '+thisSTR);
}
}**/
        reformedExpr = reformedExpr.trim();
        if( 
            (
                reformedExpr.startsWith('MAX{') && reformedExpr.endsWith('}') ||
                reformedExpr.startsWith('MIN{') && reformedExpr.endsWith('}')
            ) && !reformedExpr.contains('$C')
        ){
            system.debug('Inside MAX MIN If: '+reformedExpr);
            finalAns = Decimal.ValueOf(maxMinEval(reformedExpr));
        } else{
            system.debug('Inside MAX MIN Else: '+reformedExpr);
            finalAns = fetchFinalExpVal(reformedExpr);
        }
        
        
        if(round){
            finalAns = finalAns > RoundPar - 1 ? (finalAns/Math.pow(10,roundPar)).setScale(0) * Math.pow(10,roundPar) : finalAns ;
        }
        return finalAns;
	}
    
}