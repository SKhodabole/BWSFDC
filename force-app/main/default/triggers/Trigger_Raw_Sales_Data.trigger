/*
    Trigger on Raw_Sales_Data__c object
*/
trigger Trigger_Raw_Sales_Data on Raw_Sales_Data__c (before insert, before update) {

   RawSalesDataTriggerHelper.newRawSalesDatas = trigger.new;
    RawSalesDataTriggerHelper.oldRawSalesDatas = trigger.old;
    RawSalesDataTriggerHelper.newRawSalesDatasMap = trigger.newMap;
    RawSalesDataTriggerHelper.oldRawSalesDatasMap = trigger.oldMap;
    
    //Is Before Context of Initation Context
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            RawSalesDataTriggerHelper.onBeforeInsert();
        }
        
        if (trigger.isUpdate) {
            RawSalesDataTriggerHelper.onBeforeUpdate();
        }
    }
}