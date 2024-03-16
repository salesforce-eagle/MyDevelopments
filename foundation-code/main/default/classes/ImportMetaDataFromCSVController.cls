public class ImportMetaDataFromCSVController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public static final String SELECT_STRING = 'Select type';
    public String selectedType{get;set;}
    public List<SelectOption> cmdTypes{public get;set;}
    public static final String metadataSuffix = '__mdt';
    
    public ImportMetaDataFromCSVController(){
        loadCustomMetadataMetadata();
    }
    
    private void loadCustomMetadataMetadata(){
        List<SObject> entityDefinitions =[select QualifiedApiName from EntityDefinition where IsCustomizable =true];
        for(Sobject entityDefinition : entityDefinitions){
            
            String mdtAPINAME = (String)entityDefinition.get('QualifiedApiName');
            if(mdtAPINAME.endsWith(metadataSuffix)){
                if(cmdTypes==null){
                    cmdTypes = new List<SelectOption>();
                    cmdTypes.add(new SelectOption(SELECT_STRING, SELECT_STRING));
                }
                cmdTypes.add(new SelectOption(mdtAPINAME, mdtAPINAME));                
            }
        }
    }
    
    public void importCSVFile(){
        try{
            
            if(csvFileBody != null && selectedType.endsWith(metadataSuffix)){
                ImportCustomMetadata mtdImp = new ImportCustomMetadata(selectedType, csvFileBody);
                database.executeBatch(mtdImp);
                ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.CONFIRM, 'Batch Submitted Successfully for Execution. Once batch is executed completely you will get notified on your Email.');
                ApexPages.addMessage(successMessage); 
            }
            else{
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'Select a File');
                ApexPages.addMessage(errorMessage);                                                       
                
            }
            //insert acclist;
        }
        catch (Exception e)
        {
            csvFileBody = null;
            csvAsString = null;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
        }  
    }
}