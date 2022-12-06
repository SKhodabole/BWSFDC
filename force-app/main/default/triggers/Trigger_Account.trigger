trigger Trigger_Account on Account (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {

    if( !AccountTriggerHelper.runTrigger ) {
        //return;
    }

    AccountTriggerHelper.newAccounts = trigger.new;
    AccountTriggerHelper.oldAccounts = trigger.old;
    AccountTriggerHelper.newMapAccounts = trigger.newMap;
    AccountTriggerHelper.oldMapAccounts = trigger.oldMap;

    if( trigger.IsBefore ) {
        if( trigger.isInsert ) {
            
            // call method to populate parent id
            AccountTriggerHelper.populateParentId();
            
            //Call the helper class method to validate the outlook reporting flag
            if(AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING) {
                   
                //Call method
                //AccountTriggerHelper.validateIsEligibleForReporting(trigger.newMap);
            }
        }
        if( trigger.isUpdate ) {
            // call method to populate parent id
            AccountTriggerHelper.populateParentId();

            // call method to populate old owner
            AccountTriggerHelper.populateOldOwner();

            // call method calcualte rollup and overwrite any changes
          //SM  AccountTriggerHelper.rollUpCalcOnParentAccountToOverwriteChange();
            
            //Call the helper class method to validate the outlook reporting flag
            if(AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING) {
                
                //Call method
               // AccountTriggerHelper.validateIsEligibleForReporting(trigger.newMap);
            }
        }
    }

    if( trigger.IsAfter ) {
        if( trigger.isInsert ) {
            // call method calcualte rollup on insert of any child record
          //SM  AccountTriggerHelper.rollUpCalculationsOnParentAccountFromTrigger();
            AccountTriggerHelper.updateUserOnOwnerChange();
        }
        if( trigger.isUpdate ) {
            
            AccountTriggerHelper.updateUserOnOwnerChange();
            
            // call method calcualte rollup on update of any child record
         //SM   AccountTriggerHelper.rollUpCalculationsOnParentAccountFromTrigger();
            
            //call method for blank update T&E records
            AccountTriggerHelper.updateTAndEBlank(trigger.new , trigger.oldMap);
        }
        if( trigger.isDelete ) {
            // call method calcualte rollup on delete of any child record
         //SM   AccountTriggerHelper.rollUpCalculationsOnParentAccountFromTrigger();
        }
    }
}