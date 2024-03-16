global class CTX_GenerationDeletionAsset implements Database.Batchable<AggregateResult> {
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {
        return new AggregateResultIterable(
            'SELECT AssetId Id,Field,MAX(CreatedDate) FROM AssetHistory WHERE (Field = \'Parent\' AND DataType = \'EntityId\' AND Asset.ParentId = null AND CreatedBy.Profile.Name = \'System Administrator\') GROUP BY Field,AssetId'
        );
    }
    public void execute(Database.BatchableContext bc, List<AggregateResult> scope){
      Map<Id,AggregateResult> parentIdMap = new Map<Id,AggregateResult>(scope);
        
        //delete([SELECT Id from Asset WHERE Id IN : parentIdMap.keySet()]);
    }
    public void finish(Database.BatchableContext bc){

    }
}