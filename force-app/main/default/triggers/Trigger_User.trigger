/**
 *   Purpose      :  This trigger is handle all the pre and post processing operations for the user trigger
 * 
 *   Created By    :  
 * 
 *   Created Date  :  
 * 
 *   Revision Logs  :  
 *
 **/ 
trigger Trigger_User on User (after update) {
  
  //Check for the request type
  if(Trigger.isAfter) {
    
    //Check for the evenet type
    if(Trigger.isUpdate) {
      
      //Call the helper class method to update the opportunities if user updated
      UserTriggerHelper.updateUserRelatedOpps(Trigger.New, Trigger.oldMap);
    }
  }  
}