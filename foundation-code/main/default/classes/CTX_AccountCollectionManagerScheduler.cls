global class CTX_AccountCollectionManagerScheduler implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        CTX_AccountCollectionManagerLogic acm =new CTX_AccountCollectionManagerLogic();
        Database.executeBatch(acm);
    }

}