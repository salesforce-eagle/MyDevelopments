public class CTX_CreatePartnerUser implements Queueable {
    
    public set<Id> partnerAccountIds;
    public set<String> masterEmailIds;
    
    public CTX_CreatePartnerUser(set<Id> partnerAccountIds, set<String> masterEmailIds) {
        this.partnerAccountIds 	= partnerAccountIds;
        this.masterEmailIds 	= masterEmailIds;
    }
    
    public void execute(QueueableContext context){
        List<User> userToCreate = new List<User>();
        List<Contact> conList = [SELECT Id, Email, FirstName, LastName, AccountId, Is_Communicable__c
                          			FROM Contact 
                          			WHERE AccountId IN : partnerAccountIds AND 
                          			Email IN : masterEmailIds];
   		for(Contact con: conList)
        {
            userToCreate.add(createUserInstance(con));
            con.Is_Communicable__c 	= true;
            con.Department 			= 'Business';
        }
        
        insert userToCreate;
        updateContact(JSON.serialize(conList));
    }
    
    
    @future
    public static void updateContact(String conListJSON) {  
        List<Contact> conList = (List<Contact>)JSON.deserialize(conListJSON, List<Contact>.class);
        update conList;
    }
    
    public static User createUserInstance(Contact con) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Partner Manager' LIMIT 1];
        
        User 	newUser = new User(
            Alias				=	getAlias(con),
            Email				=	con.Email,
            EmailEncodingKey	=	'UTF-8',
            FirstName			=	con.FirstName,
            LastName			=	con.LastName,
            contactId			=	con.Id,
            LanguageLocaleKey	=	'en_US',
            LocaleSidKey		=	'en_US',
            TimeZoneSidKey		=	'Asia/Kolkata',
            Username			=	con.Email,
            CommunityNickname	=	getAlias(con),
            IsActive			=	true,
            ProfileId			=	profile.Id
        );
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        
        dmo.EmailHeader.triggerUserEmail 			= true;       
        dmo.EmailHeader.triggerOtherEmail 			= true;
        dmo.EmailHeader.triggerAutoResponseEmail 	= true;       
        dmo.optAllOrNone = false;
        
        newUser.setOptions(dmo);
        return newUser;
    }
    
    public static String getAlias (Contact con) {
        String alias;
        if(con.FirstName != null){
            if(con.FirstName.trim().length() >= 2){
                if(con.LastName.trim().length() >= 5){
                    alias = con.FirstName.trim().substring(0,1) + con.LastName.trim().substring(0,4);
                } else {
                    alias = con.FirstName.trim().substring(0,1) + con.LastName.trim().substring(0);
                }
            } else {
                if(con.LastName.trim().length() >= 5){
                    alias = con.FirstName.trim().substring(0) + con.LastName.trim().substring(0,4);
                } else {
                    alias = con.FirstName.trim().substring(0) + con.LastName.trim().substring(0);
                }
            }
        } else {
            if(con.LastName.trim().length() >= 6){
                    alias = con.LastName.trim().substring(0,5);
                } else {
                    alias = con.LastName.trim().substring(0);
                }
        }
        
        return alias.toLowerCase();        
    }
}