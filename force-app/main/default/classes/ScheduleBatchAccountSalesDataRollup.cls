/*
   Apex class to schedule BatchAccountSalesDataRollup Batch
*/
global without sharing class ScheduleBatchAccountSalesDataRollup implements Schedulable {
   
       global void execute(SchedulableContext sc) {
    
          BatchAccountSalesDataRollup rr = new BatchAccountSalesDataRollup();
          id batchstart= Database.executeBatch(rr, 10);
          
       }
}