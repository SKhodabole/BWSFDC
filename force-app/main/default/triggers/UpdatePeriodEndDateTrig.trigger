trigger UpdatePeriodEndDateTrig on Sales_Data__c (before insert, before update,after delete, after insert, after update) {
    
    //Check for Event type
    if(Trigger.isbefore) {

        //Check for request type
        if(Trigger.isInsert || Trigger.isUpdate) {
            List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
            //List<RecordType> rtypes = [SELECT DeveloperName,  Name, id FROM RecordType WHERE sObjectType='Sales_Data__c' and isActive=true and DeveloperName = 'Forecast_Sales_Data' ];   
            for(Sales_Data__c sd : Trigger.new){
                if(sd.Period_End_Date__c == null){
                    sdlist.add(sd);
                }
            }
            UpdatePeriodEndDateUtil.setMode('Trigger');
            UpdatePeriodEndDateUtil.updatePeriodEndDate(sdlist);
            
        }
    }
    
    //Check for Event type
    if(Trigger.isafter) {

        //Check for request type
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
            //SM UpdatePeriodEndDateUtil.rollUpBudgetOnAccount(Trigger.New,Trigger.oldMap);
            
        }
    }
    
}