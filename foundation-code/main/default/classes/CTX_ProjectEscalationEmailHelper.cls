public class CTX_ProjectEscalationEmailHelper {
    
    public static void performEscalationEmailogic(List<Asset> filteredAsset){
        
        Map<String, Map<String, Escalation_Matrice__mdt>> 	priorityListLevelMatriceMap 	= CTX_EscalationMatricesExtract.fetchEscalationMapping();
        List<Messaging.SingleEmailMessage> 					mailList 						= new List<Messaging.SingleEmailMessage>();
        CTX_EscalationMatricesExtract.RecipientDetails 		returnWrapper					= CTX_EscalationMatricesExtract.fetchRecipientDetails();
        Boolean												isSuccess						= FALSE;
        List<String> 										errorMessages 					= new List<String>();
        Id 													defaultMailId 					= [ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        String 												IntegrationAsset_RecordTypeId 	= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Integration_Asset').getRecordTypeId();
        String												GeneralCrowdEmails				= Label.Integartion_Escalation_General_Emails;
        
        
        for(Asset thisRec : filteredAsset){
            
            Set<String>		recipients 		= new Set<String>();
            List<String> 	finalRecipients = new List<String>();
            String 			level 			= calculateEscalationLevel(thisRec.Account_ARR_Type__c, (Integer)thisRec.Escalation_Days_Count__c, thisRec.Project_Stage__c);
            system.debug('level: '+level);
            
            /**	Field Reference Mapping: START	**/
            /**	Team Salesforce	**/
            recipients.add('team-salesforce@cleartax.in');
            /**	CSM L1	**/
            recipients.add(thisRec.Account.Onboarding_Owner__r.Email);
            recipients.add(thisRec.Account.Onboarding_Owner__r.Manager.Email);
            /**	Integration L1	**/
            recipients.add(thisRec.Project_PM_Owner_Email_Field__c);
            recipients.add(thisRec.Project_Solution_Engineer_Email_Field__c);
            /**	Dynamic Field Mapping	**/
            if(thisRec.Priority_List__c == 'KAM'){
                recipients.add(thisRec.Account.Owner.Email);
            } 
            if(thisRec.Priority_List__c == 'Sales'){
                recipients.add(thisRec.Account.Sales_Owner__r.Email);
                if(level == 'L2'){
                    recipients.add(thisRec.Account.Sales_Owner__r.Manager.Email);
                }
                if(level == 'L3' || level == 'L4'){
                    recipients.add(thisRec.Account.Sales_Owner__r.Manager.Email);
                    recipients.add(thisRec.Account.Sales_Owner__r.Manager.Manager.Email);
                }
            }
            /**	Field Reference Mapping: END	**/
            
            if(priorityListLevelMatriceMap.containsKey(thisRec.Priority_List__c)){
                Map<String, Escalation_Matrice__mdt> resultMap = priorityListLevelMatriceMap.get(thisRec.Priority_List__c);
                
                if(resultMap.containsKey(level)){
                    Escalation_Matrice__mdt myRec = resultMap.get(level);
                    
                    if(returnWrapper.recipentList.containsKey(myRec.Id)){
                        recipients.addAll(returnWrapper.recipentList.get(myRec.Id));
                    }
                }
            }
            
            /**	Integration	**/
            Map<String, Escalation_Matrice__mdt> integrationResultMap = priorityListLevelMatriceMap.get('Integration');
            if(integrationResultMap.containsKey(level)){
                Escalation_Matrice__mdt myRec = integrationResultMap.get(level);
                
                if(returnWrapper.recipentList.containsKey(myRec.Id)){
                    
                    recipients.addAll(returnWrapper.recipentList.get(myRec.Id));
                }
            }
            
            /**	CSM	**/
            Map<String, Escalation_Matrice__mdt> csmResultMap = priorityListLevelMatriceMap.get('CSM');
            if(csmResultMap.containsKey(level)){
                Escalation_Matrice__mdt myRec = csmResultMap.get(level);
                
                if(returnWrapper.recipentList.containsKey(myRec.Id)){
                    
                    recipients.addAll(returnWrapper.recipentList.get(myRec.Id));
                }
            }
            
            /**	General Crowd Emails	**/
            if(level == 'L2' || Level == 'L3' || Level == 'L4'){
                recipients.addAll(Label.Integartion_Escalation_General_Emails.split(','));
            }
            
            System.debug('recipients: '+recipients);
            for(String thisSTR : recipients){
                if(thisSTR != NULL){
                    finalRecipients.add(thisSTR);
                }
            }
            System.debug('finalRecipients: '+finalRecipients);
            
            /**	Email Messaging Construction: START	*/
            
            if(thisRec.Escalation_Mail_Level__c != level){
            
            Date startDate;
            if(thisRec.PurchaseDate != NULL)
                startDate = Date.newinstance(thisRec.PurchaseDate.year(), thisRec.PurchaseDate.month(), thisRec.PurchaseDate.day());
            
            String recordLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+thisRec.Project_Id__c;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String Subject = 'Escalation '+calculateColorCodeForLevel(level)+' - Action Needed. '
                +thisRec.Product2.Name+' - Price '+thisRec.Price+' is awaiting '+thisRec.Project_Stage__c+' for '
                +thisRec.Escalation_Days_Count__c+' days.';
            mail.setSubject(Subject);
            String body = '<b>Account Name : </b>'+thisRec.Account.Name+'<br/>';
            body += '<b>Client Segment : </b>'+thisRec.Account.PGSB__c+'<br/>';
            body += '<b>Asset Price : </b>'+thisRec.Price+'<br/>';
            body += '<b>PO Start Date : </b>'+' '+String.valueOf(startDate)+'<br/>';
            body += '<b>Project Name : </b>'+thisRec.Project_Name__c+'<br/>';
            body += '<b>Project Url : </b>'+recordLink+'<br/>';
            body += '<b>Client ERP : </b>'+thisRec.Project_Client_ERP__c+'<br/>';
            body += '<b>Project Last Updated Date :</b>'+' '+String.valueOf(thisRec.Project_Last_Modified_Date_Field__c)+'<br/>';
            body += '<b>Stage : </b>'+' '+thisRec.Project_Stage__c+'<br/>';
            body += '<b>Overall Aging : </b>'+' '+thisRec.Escalation_Days_Count__c+'<br/>';
            body += '<b>Aging in the current Stage : </b>'+' '+thisRec.Aging_In_Stage__c+'<br/>';
            body += '<b>Escalation Level : </b>'+calculateColorCodeForLevel(level)+' '+level+'<br/>';
            body += '<b>Issue Type : </b>'+thisRec.Project_Issue_Type__c+'<br/>';
            body += '<b>Issue Description : </b>'+' '+thisRec.Project_Issue_Description_Field__c+'<br/>';
            body += '<b>Comment :</b>'+' '+thisRec.Project_Comment_Field__c+'<br/>';
            body += '<b>CSM Owner :</b>'+' '+thisRec.Account.Onboarding_Owner__r.Name+'<br/>';
            body += '<b>Account Owner :</b>'+' '+thisRec.Account.Owner.Name+'<br/>';
            body += '<b>Integration Owner :</b>'+thisRec.PM_Project_Owner_Name__c+'<br/>';
            body += ''+'<br/>';
            body += '<b>If this information is incorrect/imcomplete, please update the latest information in SF.'+'<br/>'; 
            body += ''+'<br/>';
            body += ''+'<br/>';
            body +='Thanks,'+',<br/>'+'\n SF Team'+'<br/>';
            mail.setHtmlBody(body);
            mail.setToAddresses(finalRecipients);
            mail.setOrgWideEmailAddressId(defaultMailId);
            mailList.add(mail);
            
            }	/**	Email Messaging Construction: END	*/
            
        }
        system.debug('mailList: '+mailList.size());
        
        if( !mailList.isEmpty() ) {
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList, FALSE);
            
            for(Messaging.SendEmailResult thisRec : results){
                if(thisRec.isSuccess()){
                    system.debug('I am Successfully Sent: ');
                } else{
                    System.debug('The email failed to send: '+ results[0].errors[0].message);
                }
                
            }
            
            isSuccess = TRUE; 
        }
        
        List<Asset> assetsToUpdate = new List<Asset>();
        if(isSuccess){
            for(Asset thisRec : filteredAsset){
                
                thisRec.Id 							= thisRec.Id;
                thisRec.Escalation_Mail_Level__c 	
                    = calculateEscalationLevel(thisRec.Account_ARR_Type__c, (Integer)thisRec.Escalation_Days_Count__c, thisRec.Project_Stage__c);
                
                assetsToUpdate.add(thisRec);
            }
            
            Database.update(assetsToUpdate,FALSE);
        }
        
        
    }
    
    public static string calculateColorCodeForLevel(String EscalationLevel){
        
        String colorCode = '';
        if(EscalationLevel == 'L1'){
            colorCode = 'Code Blue';
        }else if(EscalationLevel == 'L2'){
            colorCode = 'Code Yellow';
        }else if(EscalationLevel == 'L2'){
            colorCode = 'Code Yellow';
        }else if(EscalationLevel == 'L3'){
            colorCode = 'Code Orange';
        }else if(EscalationLevel == 'L4'){
            colorCode = 'Code Red';
        }
        return colorCode;
    }
    
    public static string calculateEscalationLevel(String accountArrType, Integer escalationDaysCount, String projectStage){
        
        String escalationLevel = '';
        
        if(projectStage == 'Awaiting Kick-off'){
            
            system.debug(' am at Awaiting Kick-off: '+escalationDaysCount);
            if( 
                escalationDaysCount == ProjectConstants.AWAITING_KICK_OFF_1 || 
                escalationDaysCount < ProjectConstants.AWAITING_KICK_OFF_2
            ){
                
                if(accountArrType == 'A1' || accountArrType == 'A2'){
                    escalationLevel = 'L1';
                } else if(accountArrType == 'A3'){
                    escalationLevel = 'L1';
                } else if(accountArrType == 'A4'){
                    escalationLevel = 'L1';
                }
            } else if(
                escalationDaysCount == ProjectConstants.AWAITING_KICK_OFF_2 || 
                escalationDaysCount < ProjectConstants.AWAITING_KICK_OFF_3
            ){
                if(accountArrType == 'A1' || accountArrType == 'A2'){
                    escalationLevel = 'L2';
                } else if(accountArrType == 'A3'){
                    escalationLevel = 'L1';
                } else if(accountArrType == 'A4'){
                    escalationLevel = 'L1';
                }
            } else if(
                escalationDaysCount == ProjectConstants.AWAITING_KICK_OFF_3 ||
                escalationDaysCount < ProjectConstants.AWAITING_KICK_OFF_4
            ){
                if(accountArrType == 'A1' || accountArrType == 'A2'){
                    escalationLevel = 'L3';
                } else if(accountArrType == 'A3'){
                    escalationLevel = 'L2';
                } else if(accountArrType == 'A4'){
                    escalationLevel = 'L2';
                }
            } else if(
                escalationDaysCount == ProjectConstants.AWAITING_KICK_OFF_4 ||
                escalationDaysCount < ProjectConstants.AWAITING_KICK_OFF_5
            ){
                if(accountArrType == 'A1' || accountArrType == 'A2'){
                    escalationLevel = 'L4';
                } else if(accountArrType == 'A3'){
                    escalationLevel = 'L3';
                } else if(accountArrType == 'A4'){
                    escalationLevel = 'L3';
                }
            } else if(
                escalationDaysCount == ProjectConstants.AWAITING_KICK_OFF_5 ||
                escalationDaysCount < ProjectConstants.AWAITING_KICK_OFF_6 
            ){
                system.debug('I am at Level Check');
                if(accountArrType == 'A1' || accountArrType == 'A2'){
                    escalationLevel = 'L4';
                } else if(accountArrType == 'A3'){
                    escalationLevel = 'L4';
                } else if(accountArrType == 'A4'){
                    escalationLevel = 'L4';
                }
            } else if(
                escalationDaysCount >= ProjectConstants.AWAITING_KICK_OFF_6
            ){
                if(accountArrType == 'A1' || accountArrType == 'A2'){
                    escalationLevel = 'L4';
                } else if(accountArrType == 'A3'){
                    escalationLevel = 'L4';
                }else if(accountArrType == 'A4'){
                    escalationLevel = 'L4';
                }
            }
            
            system.debug('escalationLevel: '+escalationLevel);
        }
        
        if(projectStage == 'Project Plan'){
            
            if(
                escalationDaysCount == ProjectConstants.PROJECT_PLAN_1 || 
                escalationDaysCount < ProjectConstants.PROJECT_PLAN_2){
                    if(accountArrType == 'A1' || accountArrType == 'A2'){
                        escalationLevel = 'L1';
                    }else if(accountArrType == 'A3'){
                        escalationLevel = 'L1';
                    }else if(accountArrType == 'A4'){
                        escalationLevel = 'L1';
                    }
                    
                }else if(escalationDaysCount == ProjectConstants.PROJECT_PLAN_2 || 
                         escalationDaysCount < ProjectConstants.PROJECT_PLAN_3){
                             if(accountArrType == 'A1' || accountArrType == 'A2'){
                                 escalationLevel = 'L2';
                             }else if(accountArrType == 'A3'){
                                 escalationLevel = 'L1';
                             }else if(accountArrType == 'A4'){
                                 escalationLevel = 'L1';
                             }
                         }else if(escalationDaysCount == ProjectConstants.PROJECT_PLAN_3 || 
                                  escalationDaysCount < ProjectConstants.PROJECT_PLAN_4){
                                      if(accountArrType == 'A1' || accountArrType == 'A2'){
                                          escalationLevel = 'L3';
                                      }else if(accountArrType == 'A3'){
                                          escalationLevel = 'L2';
                                      }else if(accountArrType == 'A4'){
                                          escalationLevel = 'L2';
                                      }
                                  }else if(escalationDaysCount == ProjectConstants.PROJECT_PLAN_4 || 
                                           escalationDaysCount < ProjectConstants.PROJECT_PLAN_5){
                                               if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                   escalationLevel = 'L4';
                                               }else if(accountArrType == 'A3'){
                                                   escalationLevel = 'L3';
                                               }else if(accountArrType == 'A4'){
                                                   escalationLevel = 'L3';
                                               }
                                           }else if(escalationDaysCount == ProjectConstants.PROJECT_PLAN_5 || 
                                                    escalationDaysCount < ProjectConstants.PROJECT_PLAN_6){
                                                        if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                            escalationLevel = 'L4';
                                                        }else if(accountArrType == 'A3'){
                                                            escalationLevel = 'L4';
                                                        }else if(accountArrType == 'A4'){
                                                            escalationLevel = 'L4';
                                                        }
                                                    }else if(escalationDaysCount >= ProjectConstants.PROJECT_PLAN_6){
                                                        if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                            escalationLevel = 'L4';
                                                        }else if(accountArrType == 'A3'){
                                                            escalationLevel = 'L4';
                                                        }else if(accountArrType == 'A4'){
                                                            escalationLevel = 'L4';
                                                        }
                                                    }
        }
        
        if(projectStage == 'Implementation'){
            if(escalationDaysCount == ProjectConstants.IMPLEMENTAION_1 || 
               escalationDaysCount < ProjectConstants.IMPLEMENTAION_2){
                   if(accountArrType == 'A1' || accountArrType == 'A2'){
                       escalationLevel = 'L1';
                   }else if(accountArrType == 'A3'){
                       escalationLevel = 'L1';
                   }else if(accountArrType == 'A4'){
                       escalationLevel = 'L1';
                   }
                   
               }else if(escalationDaysCount == ProjectConstants.IMPLEMENTAION_2 || 
                        escalationDaysCount < ProjectConstants.IMPLEMENTAION_3){
                            if(accountArrType == 'A1' || accountArrType == 'A2'){
                                escalationLevel = 'L2';
                            }else if(accountArrType == 'A3'){
                                escalationLevel = 'L1';
                            }else if(accountArrType == 'A4'){
                                escalationLevel = 'L1';
                            }
                        }else if(escalationDaysCount == ProjectConstants.IMPLEMENTAION_3 || 
                                 escalationDaysCount < ProjectConstants.IMPLEMENTAION_4){
                                     if(accountArrType == 'A1' || accountArrType == 'A2'){
                                         escalationLevel = 'L3';
                                     }else if(accountArrType == 'A3'){
                                         escalationLevel = 'L2';
                                     }else if(accountArrType == 'A4'){
                                         escalationLevel = 'L1';
                                     }
                                 }else if(escalationDaysCount == ProjectConstants.IMPLEMENTAION_4 || 
                                          escalationDaysCount < ProjectConstants.IMPLEMENTAION_5){
                                              if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                  escalationLevel = 'L4';
                                              }else if(accountArrType == 'A3'){
                                                  escalationLevel = 'L3';
                                              }else if(accountArrType == 'A4'){
                                                  escalationLevel = 'L2';
                                              }
                                          }else if(escalationDaysCount == ProjectConstants.IMPLEMENTAION_5 || 
                                                   escalationDaysCount < ProjectConstants.IMPLEMENTAION_6){
                                                       if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A3'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A4'){
                                                           escalationLevel = 'L3';
                                                       }
                                                   }else if(escalationDaysCount >= ProjectConstants.IMPLEMENTAION_6){
                                                       if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A3'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A4'){
                                                           escalationLevel = 'L4';
                                                       }
                                                   }
        }
        
        if(projectStage == 'UAT'){
            if(escalationDaysCount == ProjectConstants.UAT_1 || 
               escalationDaysCount < ProjectConstants.UAT_2){
                   if(accountArrType == 'A1' || accountArrType == 'A2'){
                       escalationLevel = 'L1';
                   }else if(accountArrType == 'A3'){
                       escalationLevel = 'L1';
                   }else if(accountArrType == 'A4'){
                       escalationLevel = 'L1';
                   }
                   
               }else if(escalationDaysCount == ProjectConstants.UAT_2 || 
                        escalationDaysCount < ProjectConstants.UAT_3){
                            if(accountArrType == 'A1' || accountArrType == 'A2'){
                                escalationLevel = 'L2';
                            }else if(accountArrType == 'A3'){
                                escalationLevel = 'L1';
                            }else if(accountArrType == 'A4'){
                                escalationLevel = 'L1';
                            }
                        }else if(escalationDaysCount == ProjectConstants.UAT_3 || 
                                 escalationDaysCount < ProjectConstants.UAT_4){
                                     if(accountArrType == 'A1' || accountArrType == 'A2'){
                                         escalationLevel = 'L3';
                                     }else if(accountArrType == 'A3'){
                                         escalationLevel = 'L2';
                                     }else if(accountArrType == 'A4'){
                                         escalationLevel = 'L1';
                                     }
                                 }else if(escalationDaysCount == ProjectConstants.UAT_4 || 
                                          escalationDaysCount < ProjectConstants.UAT_5){
                                              if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                  escalationLevel = 'L4';
                                              }else if(accountArrType == 'A3'){
                                                  escalationLevel = 'L3';
                                              }else if(accountArrType == 'A4'){
                                                  escalationLevel = 'L2';
                                              }
                                          }else if(escalationDaysCount == ProjectConstants.UAT_5 || 
                                                   escalationDaysCount < ProjectConstants.UAT_6){
                                                       if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A3'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A4'){
                                                           escalationLevel = 'L3';
                                                       }
                                                   }else if(escalationDaysCount >= ProjectConstants.UAT_6){
                                                       if(accountArrType == 'A1' || accountArrType == 'A2'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A3'){
                                                           escalationLevel = 'L4';
                                                       }else if(accountArrType == 'A4'){
                                                           escalationLevel = 'L4';
                                                       }
                                                   }
        }
        
        return escalationLevel;
    }
    
    
}