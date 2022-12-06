/**
 *  Description     :   T&E trigger.
 * 
 *  Created By      :   
 * 
 *  Created Date    :   
 * 
 *  Revision Logs   :   
 *                   
 **/

trigger TE on T_E__c (before insert, before update) {
    
    //Check for the request type
    if(trigger.isBefore){
        
        //Check the request type
        if(Trigger.isInsert || Trigger.isUpdate){
            
            TETriggerHelper.populateTEData(trigger.new);
            
        }
        
    }   
}