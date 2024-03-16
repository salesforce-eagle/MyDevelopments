public class CTX_RectifyCaseAccountMapping {
    
    public static boolean sendBounceEmail = true;
    
    public static void main( List<Case> rectifyCases ){
        
        Map<String, Set<String>>	caseIdEmailSetMap 			= new Map<String, Set<String>>();
        Map<String, Set<String>> 	caseIdEmailDomainSetMap 	= new Map<String, Set<String>>();
        Map<String, Id> 			emailAndAccountIdMap 		= new Map<String, Id>();
        Map<String, Id> 			accountDomainMap 			= new Map<String, Id>();
        Set<String>					actualCustomeremails		= new Set<String>();
        Set<String>					actualCustomeremailDomains	= new Set<String>();
        List<Contact> 				createContas 				= new List<Contact>();
        
        for(Case thisRec : rectifyCases){
            
            if(thisRec.Description != NULL){
                
                Matcher matchFound = getEmailStringRegxMatcher(thisRec.Description);
                while( matchFound.find() ) {
                    
                    String 	email 		= matchFound.group().toLowerCase().removeEnd('.');
                    String	emailDomain = email.split('@')[1];
                    
                    if( 
                        !email.containsIgnoreCase('clear.in') 			&& 
                        !email.containsIgnoreCase('cleartax.in') 		&&
                        !email.containsIgnoreCase('cleartaxmailer.com')
                    ){
                        if(caseIdEmailSetMap.containsKey(thisRec.Id)){
                            caseIdEmailSetMap.get(thisRec.Id).add(email);
                        } else{
                            caseIdEmailSetMap.put(thisRec.Id, new Set<String>{email});
                        }
                        
                        if(caseIdEmailDomainSetMap.containsKey(thisRec.Id)){
                            caseIdEmailDomainSetMap.get(thisRec.Id).add(emailDomain);
                        } else{
                            caseIdEmailDomainSetMap.put(thisRec.Id, new Set<String>{emailDomain});
                        }
                        
                        actualCustomeremails.add(email);
                        actualCustomeremailDomains.add(emailDomain);
                    }
                }
            }
        }
        
        Set<String> actualCustomeremails_Duplicate = new Set<String>(actualCustomeremails);
        for( 
            Contact thisRec : [ SELECT Id, AccountId, Email 
                               FROM Contact WHERE 
                               Email IN :actualCustomeremails ] 
        ){
            emailAndAccountIdMap.put(thisRec.Email, thisRec.Accountid);
            actualCustomeremails_Duplicate.remove(thisRec.Email);
        }
        
        for( Account thisRec : [ SELECT Id, Company_Domain_Name__c FROM Account WHERE Company_Domain_Name__c IN :actualCustomeremailDomains ] ){
            accountDomainMap.put(thisRec.Company_Domain_Name__c, thisRec.Id);
        }
        
List<String> publicDomain = System.Label.Public_Domain.split(',');
        if(actualCustomeremails_Duplicate.size() > 0) {       
            for(String thisSTR : actualCustomeremails){
                
                Boolean isPublicDomain = FALSE;
                String 	domainName 		= thisSTR.split('@')[1];
                if( publicDomain.contains(domainName) || accountDomainMap.get(thisSTR.split('@')[1]) == NULL ){
                    isPublicDomain = TRUE;
                }
                system.debug('thisSTR: '+thisSTR);
                Contact contacts = new Contact(
                    LastName = thisSTR.split('@')[0],
                    Email = thisSTR.toLowerCase(),
                    AccountId = isPublicDomain ? System.Label.Global_Account_for_Untagged_Cases : accountDomainMap.get( thisSTR.split('@')[1] )
                );
                
                createContas.add(contacts);
            }
        }
        
        
        
        
    }
    
    public static void actualDomainCheck( Case thisRec ){
        
        Map<String, Set<String>> 	caseIdEmailSetMap 			= new Map<String, Set<String>>();
        Map<String, Set<String>> 	caseIdEmailDomainSetMap 	= new Map<String, Set<String>>();
        Set<String>					actualCustomeremails		= new Set<String>();
        Set<String>					actualCustomeremailDomains	= new Set<String>();
        
        system.debug('thisRec.Description: '+thisRec.Description);
        system.debug('thisRec.Subject: '+thisRec.Subject);
        
        if( thisRec.Subject + thisRec.Description + thisRec.CCEmailAddress__c != NULL ){
            Matcher m = Pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+').matcher(
                thisRec.Subject+ '\n' + thisRec.Description + '\n' + thisRec.CCEmailAddress__c
            );
            system.debug('thisRec.CCEmailAddress__c: '+thisRec.CCEmailAddress__c);
            system.debug('mmmmm: '+m);
            while (m.find()) {
                String 	email;
                if( m.group().toLowerCase().endsWith('.') )
                    email 		= m.group().toLowerCase().removeEnd('.');
                else if( m.group().toLowerCase().endsWith('--') )
                    email		= m.group().toLowerCase().removeEnd('--');
                else
                    email		= m.group().toLowerCase();
                
                system.debug('email: email: email: '+email);
                
                String	emailDomain = email.split('@')[1];
                if( !System.label.block_contact_creation.contains(emailDomain) ){
                       if(caseIdEmailSetMap.containsKey(thisRec.Id)){
                           caseIdEmailSetMap.get(thisRec.Id).add(email);
                       } else{
                           caseIdEmailSetMap.put(thisRec.Id, new Set<String>{email});
                       }
                       if(caseIdEmailDomainSetMap.containsKey(thisRec.Id)){
                           caseIdEmailDomainSetMap.get(thisRec.Id).add(emailDomain);
                       } else{
                           caseIdEmailDomainSetMap.put(thisRec.Id, new Set<String>{emailDomain});
                       }
                       actualCustomeremails.add(email);
                       actualCustomeremailDomains.add(emailDomain);
                       sendBounceEmail = False;
                   }
            }
        }
        
        system.debug('actualCustomeremails: '+actualCustomeremails);
        system.debug('actualCustomeremailDomains: '+actualCustomeremailDomains);
        Map<String, Id> accountDomainMap = new Map<String, Id>();
        for( Account thisAcc : [ SELECT Id, Domain__c FROM Account WHERE Domain__c IN :actualCustomeremailDomains ] ){
            accountDomainMap.put(thisAcc.Domain__c, thisAcc.Id);
        }
        
        Map<String, Id> emailAndAccountIdMap = new Map<String, Id>();
        Map<String, Id> emailAndContactIdMap = new Map<String, Id>();
        for( Contact thisCon : [ SELECT Id, AccountId, Email, Account.Domain__c FROM Contact WHERE Email IN :actualCustomeremails ] ){
            emailAndAccountIdMap.put(thisCon.Email, thisCon.Accountid);
            emailAndContactIdMap.put(thisCon.Email, thisCon.Id);
        }
        system.debug('emailAndAccountIdMap.size(): '+emailAndAccountIdMap.size());
        system.debug('emailAndContactIdMap.size(): '+emailAndContactIdMap.size());
        
        system.debug('emailAndAccountIdMap: '+emailAndAccountIdMap);
        system.debug('emailAndContactIdMap: '+emailAndContactIdMap);
        
        
        Set<String>	actualCustomeremails_removeExisting		= new Set<String>(actualCustomeremails);
        for(String emails : emailAndAccountIdMap.keySet()){
            actualCustomeremails_removeExisting.remove(emails);
        }
        system.debug('actualCustomeremails Post Removal of existing .size(): '+actualCustomeremails.size());
        List<String> publicDomain = System.Label.Public_Domain.split(',');
            List<Contact> createContas = new List<Contact>();
        for(String thisSTR : actualCustomeremails_removeExisting){
            
            
                Boolean isPublicDomain = FALSE;
                String 	domainName 		= thisSTR.split('@')[1];
                if( publicDomain.contains(domainName) || accountDomainMap.get(thisSTR.split('@')[1]) == NULL ){
                    isPublicDomain = TRUE;
                }
                system.debug('thisSTR: '+thisSTR);
                Contact contacts = new Contact(
                    LastName = thisSTR.split('@')[0],
                    Email = thisSTR.toLowerCase(),
                    AccountId = isPublicDomain ? System.Label.Global_Account_for_Untagged_Cases : accountDomainMap.get( thisSTR.split('@')[1] )
                );
            
            createContas.add(contacts);
        }
        system.debug('createContas: ' +createContas.size());
        insert createContas;
        Map<String, Id> emailAndAccountIdMap1 = new Map<String, Id>();
        Map<String, Id> emailAndContactIdMap1 = new Map<String, Id>();
        for( Contact thisCon : [ SELECT Id, AccountId, Email, Account.Domain__c FROM Contact WHERE Email IN :actualCustomeremails ]  ){
            emailAndAccountIdMap1.put(thisCon.Email, thisCon.Accountid);
            emailAndContactIdMap1.put(thisCon.Email, thisCon.Id);
        }
        system.debug('emailAndAccountIdMap1 Size: '+emailAndAccountIdMap1.size());
        system.debug('emailAndContactIdMap1 Size: '+emailAndContactIdMap1.size());
        
        system.debug('emailAndAccountIdMap1: '+emailAndAccountIdMap1);
        system.debug('emailAndContactIdMap1: '+emailAndContactIdMap1);
        
        
        List<Case> updateCase = new List<Case>();
        if( caseIdEmailSetMap.containsKey(thisRec.Id) ){
            List<String> emailList = new List<String>(caseIdEmailSetMap.get(thisRec.Id));
            String emails              = emailList[0];
            //thisRec.ContactId          = emailAndContactIdMap1.get(emails);
            thisRec.AccountId          = emailAndAccountIdMap1.get(emails);
            if(thisRec.AccountId != System.Label.Global_Account_for_Untagged_Cases && thisRec.ownerId == system.label.GST_L1_Email_Support_Team_QueueID){
                       thisRec.ownerId      = System.Label.ENT_GST_L1_Team_CaseQueueId;
                       thisRec.recordtypeId = CaseConstants.B2B_RecordTypeId;
                
            }
            
            system.debug('thisRec thisRec thisRec thisRec :::: '+thisRec);
            updateCase.add(thisRec);
        }
        
        system.debug('updateCase: '+updateCase.size());
        update updateCase;      
    }
    
    public static void getQuires(){
        
        List<Case> updateCases = [ SELECT 
                                  
                                  Id, CaseNumber, SuppliedEmail, ContactId, ContactEmail, AccountId, 
                                  Description, CreatedDate, Origin, Status, Issue_Type_1__c, Products_Available__c, 
                                  /*Account.Domain__c,*/ Account.Name, RecordType.Name
                                  
                                  FROM Case WHERE 
                                  
                                  Account.Sum_of_ARR_Assets__c >= 1500000 AND
                                  Origin = 'Email' AND
                                  (NOT RecordType.Name IN ('Finance Queries') ) AND 
                                  
                                  SuppliedEmail Like '%Clear.in%' AND 
                                  CreatedDate >= 2023-03-01T00:00:00Z 
                                  
                                  ORDER BY Account.Name ];
    }
    
    public static Matcher getEmailStringRegxMatcher( String matchString ){
        return Pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+').matcher(matchString);
    } 
    
    
}