public class ImportCustomMetadata implements Database.Batchable<String>,Database.Stateful {
    private string selectedType;
    private Blob file;
    private string ExceptionMessage;
    public List<String> fieldsHeader;
    public ImportCustomMetadata(string selectedType, Blob file){
        this.selectedType = selectedType;
        this.file = file;
    }
    public Iterable<String> start(Database.BatchableContext BC){
        try{
            if(file != null){              
                String csvFileBody = file.toString();
                String fileHeaders = csvFileBody.substring(0,csvFileBody.indexOf('\n')).trim();
                fieldsHeader = fileHeaders.split(',');
                String finalbody = csvFileBody.substring(csvFileBody.indexOf('\n')+1);
                if(finalbody.contains('\r\n')){
                    return new CSVIterator(finalbody, '\r\n');
                }else{
                    return new CSVIterator(finalbody, '\n');
                }
            }
            else{
                return new List<String>();
            }
        }
        catch(Exception ex){
            ExceptionMessage = ex.getTypeName() +' : '+ ex.getMessage() + '\n' + ex.getStackTraceString();
            return new List<String>();
        }
    }
    public void execute (Database.BatchableContext BC, List<String> scope){
        try{
            String csvFile = '';
            for(integer k = 0; k<scope.size(); K++)
            {
                if(k == scope.size()-1){
                    csvFile += scope[k];
                }
                else{
                    csvFile += scope[k] + '\r\n';
                }
            }
            List<List<String>> mdtrows = this.parseCSV(csvFile,false);
            Integer totalRows = mdtrows.size();
            
            List<SObject> mdtList = new List<Sobject>();
            //List<String> FieldsApi = fieldsHeader;
            
            Integer Size = fieldsHeader.size();
            
            //To Get FieldAPi
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(selectedType);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            
            //To Get FieldType
            SObjectType r = ((SObject)(Type.forName('Schema.'+selectedType).newInstance())).getSObjectType();
            DescribeSObjectResult d = r.getDescribe();
            
            for(Integer j=0;j<totalRows;j++){
                sObject sObj = Schema.getGlobalDescribe().get(selectedType).newSObject();
                
                for(integer i=0; i<Size; i++){                       
                    string[] csvRecordData = mdtrows[j];
                    
                    DescribeFieldResult fieldDesc = fieldMap.get(fieldsHeader[i].trim()).getDescribe();
                    String fieldQualifiedApiName = fieldDesc.getName();
                    String value = csvRecordData[i];                                                              
                    Schema.DisplayType fieldtype = d.fields.getMap().get(fieldsHeader[i]).getDescribe().getType();
                    if(fieldtype == Schema.DisplayType.BOOLEAN){
                        boolean bvalue = value.equals('TRUE');
                        sObj.put(fieldQualifiedApiName, bvalue);                                                                       
                    }
                    else if(fieldtype == Schema.DisplayType.DATE){
                        sObj.put(fieldQualifiedApiName, date.valueOf(value));
                    }
                    else if(fieldtype == Schema.DisplayType.DATETIME){
                        sObj.put(fieldQualifiedApiName, Datetime.valueOfGmt(value));
                    }
                    else if(fieldtype == Schema.DisplayType.ID){
                        if(value == ''){
                            sObj.put(fieldQualifiedApiName, null);
                        }
                        else{
                            sObj.put(fieldQualifiedApiName, String.valueOf(value));
                        }
                    }
                    else if(fieldtype == Schema.DisplayType.REFERENCE){
                        if(value == ''){
                            sObj.put(fieldQualifiedApiName, null);
                        }
                        else{
                            sObj.put(fieldQualifiedApiName, String.valueOf(value));
                        }
                    }
                    else if(fieldtype == Schema.DisplayType.DOUBLE){
                        if(value == ''){
                            sObj.put(fieldQualifiedApiName, null);
                        } else {
                            if(value.contains('.')){
                                sObj.put(fieldQualifiedApiName, double.valueOf(value));
                            }
                            else{
                                sObj.put(fieldQualifiedApiName, double.valueOf(long.valueOf(value)));
                            }   
                        }
                    }
                    else{
                        if(value.contains(',')){
                            sObj.put(fieldQualifiedApiName, value.substring(1, value.length()-1));
                        }
                        else{
                            sObj.put(fieldQualifiedApiName, value);
                        }
                    }
                }
                mdtList.add(sObj);
            }
            
            if(mdtList.size()>0){
                if(selectedType.endsWith('__mdt')){
                    //Metadata Import Starts
                    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                    for(Sobject mdt : mdtList){
    
                        String nameSpacePrefix ='';  
                        String devName= (String)mdt.get('DeveloperName');
                        Metadata.CustomMetadata rec =  new Metadata.CustomMetadata();
                        String label = (String)mdt.get('Label'); 
                        rec.fullName = nameSpacePrefix+selectedType+'.'+mdt.get('DeveloperName');

                        if(label.contains(',')){
                            rec.label= label.substring(1, label.length()-1);
                        }
                        else{
                            rec.label = label;
                        }
                        
                        
                        for(String Field : fieldsHeader){
                            if(Field.toLowerCase().endsWith('__c')){
                                Metadata.CustomMetadataValue field1 = new Metadata.CustomMetadataValue();
                                field1.field = Field;
                                field1.value = mdt.get(Field);
                                rec.values.add(field1);
                            }
                        }                       
                        
                        mdContainer.addMetadata(rec);  
                    } 
                    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
 					//Metadata Import Ends
                }
            }
        }
        catch(Exception ex){
            ExceptionMessage = ex.getTypeName() +' : '+ ex.getMessage() + '\n' + ex.getStackTraceString();
        }
    }
    Public void finish(database.BatchableContext BC){
        
    }
    
    //To Handle Comma in csv
    public List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        if(contents == null || contents == '') {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'ERROR_FILE_MISSING');
            ApexPages.addMessage(errorMessage);
            return null;
        }
        
        //String contents = csvFileBody.toString();
        
        List<List<String>> allFields = new List<List<String>>();
        
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        //system.debug('contents1: '+ contents);
        //windows case - replace all carriage + new line character to just new line character
        contents = contents.replaceAll('\r\n','\n');
        //system.debug('contents2: '+ contents);
        //now replace all return char to new line character
        contents = contents.replaceAll('\r','\n');
        //system.debug('contents3: '+ contents);
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
            //system.debug('lines: '+ lines);
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',', -1);  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"').replaceAll('"','').trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"').trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"').trim());
                }
            }
            //system.debug('cleanFields: '+ cleanFields);
            allFields.add(cleanFields);
            //system.debug('allFields: '+ allFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }

}