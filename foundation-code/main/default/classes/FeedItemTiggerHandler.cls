public class FeedItemTiggerHandler {
    
    public static void UpdateFeedItemToChildCases(list<feedItem> FeedItemList){
        map<string,FeedItem> ParentCaseIDToFeedItem=new map<string,FeedItem>();
        list<FeedItem> listOfFeedItem = new list<FeedItem>();
        for(FeedItem fe : FeedItemList){
            String caseIds = fe.ParentId;
            if (caseIds.left(3) == '500') {    
                ParentCaseIDToFeedItem.put(caseIds,fe);     
            }        
        }
        
        list<case> caseList=[select id,(select id from cases) from case where id in:ParentCaseIDToFeedItem.keySet() and type='Problem'];
        for(case c:caseList){
            for(case cs:c.cases){
                FeedItem feed = ParentCaseIDToFeedItem.get(c.Id).Clone(false,true,true,false);
                feed.ParentId = cs.Id ;              
                listOfFeedItem.add(feed);
                
            }
        }
        
        if(!listOfFeedItem.isEmpty()){
            insert listOfFeedItem;
        }
    }
    
    // START :: Update Chatter Feed on Project :: bhaveshjindal
    public static void UpdateFieldOnProject(List<FeedItem> newfeedItemList, boolean isUpdated){
        system.debug('<<---- :: START : UpdateFieldOnProject :: ---->>');
        set<Id> projectIds = new set<Id>();
        set<Id> userIds = new set<Id>();
        
        for(FeedItem thisRec : newFeedItemList){
            if(thisRec.Type == 'TextPost'){
                projectIds.add(thisRec.ParentId);
                userIds.add(thisRec.CreatedById);
            }
        }
        
        Map<Id,User> userMap = new Map<Id,User>([ SELECT Id, Name FROM User WHERE Id IN :userIds ]);
        system.debug('userMap :: '+userMap);
        Map<Id,Project__c> projectMap = new Map<Id,Project__c>([ SELECT Id, Issue_Description__c	 
                                                                FROM Project__c WHERE Id IN :projectIds ]);
        List<Project__c> projectListToUpdate = new List<Project__c>();
        system.debug('projectMap :: '+projectMap);
        
        if(projectMap != NULL){
            for(FeedItem thisRec : newFeedItemList){
                String post = thisRec.Body;
                String trimmedPost = post;//'<Html><Body>'++'</body></html>';//.remove('</p>').replace('<p>',' ').replace('&#39;','\'');
                String postedDate = string.valueOf(thisRec.CreatedDate.format('dd MMM, yyyy'));
                Project__c project = projectMap.get(thisRec.ParentId);
                if(project != NULL){
                    if(isUpdated){
                        String issueDescription = '[Edited Post] : <b>'+ postedDate +' : '+ userMap.get(thisRec.CreatedById).Name +' : </b>'+ trimmedPost +'\n' + project.Issue_Description__c;
                        project.Issue_Description__c = issueDescription.remove('null');
                    }else{
                        String issueDescription = '<b>'+postedDate +' : '+ userMap.get(thisRec.CreatedById).Name +' : </b>'+ trimmedPost +'\n' + project.Issue_Description__c;
                        project.Issue_Description__c = issueDescription.remove('null');
                    }
                    projectListToUpdate.add(project);
                }
            }
        }
        
        if(projectListToUpdate.size()>0){
            update projectListToUpdate;
        }
        system.debug('<<---- :: END : UpdateFieldOnProject :: ---->>');
    }
    // END :: Update Chatter Feed on Project :: bhaveshjindal
    
    // START :: Update Chatter Feed on Asset :: bhaveshjindal
    public static void UpdateFieldOnAsset(List<FeedItem> newfeedItemList, boolean isUpdated){
        system.debug('<<---- :: START : UpdateFieldOnAsset :: ---->>');
        set<Id> assetIds = new set<Id>();
        set<Id> userIds = new set<Id>();
        
        for(FeedItem thisRec : newFeedItemList){
            if(thisRec.Type == 'TextPost'){
                assetIds.add(thisRec.ParentId);
                userIds.add(thisRec.CreatedById);
            }
        }
        
        Map<Id,User> userMap = new Map<Id,User>([ SELECT Id, Name FROM User WHERE Id IN :userIds ]);
        system.debug('userMap :: '+userMap);
        Map<Id,Asset> assetMap = new Map<Id,Asset>([ SELECT Id, Asset_Updates__c 	 
                                                                FROM Asset WHERE Id IN :assetIds ]);
        List<Asset> assetListToUpdate = new List<Asset>();
        system.debug('assetMap :: '+assetMap);
        
        if(assetMap != NULL){
            for(FeedItem thisRec : newFeedItemList){
                String post = thisRec.Body;
                String trimmedPost = post;//'<Html><Body>'++'</body></html>';//.remove('</p>').replace('<p>',' ').replace('&#39;','\'');
                String postedDate = string.valueOf(thisRec.CreatedDate.format('dd MMM, yyyy'));
                Asset assetInstance = assetMap.get(thisRec.ParentId);
                if(assetInstance != NULL){
                    if(isUpdated){
                        String issueDescription = '[Edited Post] : '+ postedDate +' : '+ userMap.get(thisRec.CreatedById).Name +' : '+ trimmedPost +'\n' + assetInstance.Asset_Updates__c ;
                        assetInstance.Asset_Updates__c  = issueDescription.remove('null');
                    }else{
                        String issueDescription = postedDate +' : '+ userMap.get(thisRec.CreatedById).Name +' : '+ trimmedPost +'\n' + assetInstance.Asset_Updates__c ;
                        assetInstance.Asset_Updates__c  = issueDescription.remove('null');
                    }
                    assetListToUpdate.add(assetInstance);
                }
                
            }
        }
        
        if(assetListToUpdate.size()>0){
            update assetListToUpdate;
        }
        system.debug('<<---- :: END : UpdateFieldOnAsset :: ---->>');
    }
    // END :: Update Chatter Feed on Asset :: bhaveshjindal
    
    // START :: Update Chatter Feed on Billing&Risk
    public static void UpdateFieldOnBillingDetails(List<FeedItem> newfeedItemList, boolean isUpdated){
        set<Id> billingIds = new set<Id>();
        set<Id> userIds = new set<Id>();
        
        for(FeedItem thisRec : newFeedItemList){
            if(thisRec.Type == 'TextPost'){
                billingIds.add(thisRec.ParentId);
                userIds.add(thisRec.CreatedById);
            }
        }
        
        Map<Id,User> userMap = new Map<Id,User>([ SELECT Id, Name FROM User WHERE Id IN :userIds ]);
        
        Map<Id,Billing_Details__c> billingDetailsMap = new Map<Id,Billing_Details__c>([ SELECT Id, Detailed_Reason__c 	 
                                                                FROM Billing_Details__c WHERE Id IN :billingIds ]);
        
        List<Billing_Details__c> billingListToUpdate = new List<Billing_Details__c>();
        
        system.debug('billingDetailsMap :: '+billingDetailsMap);
        
        if(billingDetailsMap != NULL){
            for(FeedItem thisRec : newFeedItemList){
                if(thisRec.Body.containsIgnoreCase(System.Label.FeedTag_Billing )){
                    String post = thisRec.Body;
                    String trimmedPost = post.remove('@ClientLog');
                    String postedDate = string.valueOf(thisRec.CreatedDate.format('dd MMM, yyyy'));
                    Billing_Details__c thisBillingRec = billingDetailsMap.get(thisRec.ParentId);
                    if(thisBillingRec != NULL ){
                        if(isUpdated){
                            String issueDescription = '[Edited Post] : '+ postedDate +' : '+ userMap.get(thisRec.CreatedById).Name +' : '+ trimmedPost +'\n' + thisBillingRec.Detailed_Reason__c;
                            thisBillingRec.Detailed_Reason__c = issueDescription.remove('null');
                        }else{
                            String issueDescription = postedDate +' : '+ userMap.get(thisRec.CreatedById).Name +' : '+ trimmedPost +'\n' + thisBillingRec.Detailed_Reason__c;
                            thisBillingRec.Detailed_Reason__c = issueDescription.remove('null');
                        }
                        billingListToUpdate.add(thisBillingRec);
                    }
                }
            }
        }
        
        if(billingListToUpdate.size()>0){
            update billingListToUpdate;
        }
    }
    
}