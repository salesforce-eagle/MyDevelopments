public class AssetCreationOnOpptyClosure implements Queueable{
    
    private List<Asset> asstetsToProcess;
    private List<OrderItem> oiToUpdate;
    
    public AssetCreationOnOpptyClosure(List<Asset> asstetsToProcess, List<OrderItem> oiToUpdate) {
        this.asstetsToProcess     =      asstetsToProcess;
        this.oiToUpdate          =      oiToUpdate;
    }
    
    public void execute(QueueableContext context) {
        system.debug('asstetsToProcess '+asstetsToProcess);
        try{
            if(!asstetsToProcess.isEmpty()){
                AssetConstants.isRun = FALSE;
                insert asstetsToProcess;
                AssetConstants.isRun = TRUE;
            }
            if(!oiToUpdate.isEmpty()){
                insert oiToUpdate;
            }
        }
        catch(Exception e){
            System.debug('Exception on creating asset and Orer Item on closing opportunity at '+e.getLineNumber() + ' StackTrace '+e.getStackTraceString());
        }
    }
}