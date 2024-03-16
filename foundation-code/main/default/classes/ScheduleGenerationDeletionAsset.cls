global class ScheduleGenerationDeletionAsset implements Schedulable

{
    
    global static void execute(SchedulableContext sc)
        
    {
        
        CTX_GenerationDeletionAsset b = new CTX_GenerationDeletionAsset(); // Your batch class
        
        database.executeBatch(b);
        Datetime sysTime = System.now();
        
        // this would increase the time to 1 minute after current time
        sysTime = sysTime.addMinutes(5);
        
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('ScheduleGenerationDeletionAsset' + sysTime.getTime(),chron_exp, new ScheduleGenerationDeletionAsset());
        
        
    }
    
}