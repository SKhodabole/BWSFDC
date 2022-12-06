public class OpportunityHandler {
    public static Id cenveoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
    public static Id custoLabelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Custom_Label_Quote_Follow_Up').getRecordTypeId();
    public static Id bandWRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B_W_Sales').getRecordTypeId();
    public static Id mAndARecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('M_A_Tracking').getRecordTypeId();
    
    public static void opportunityPusher(List<Opportunity> newOpportunity, Map<Id,Opportunity> oldMapOpp){
        Date dNewCloseDate;
    	Date dOldCloseDate;
    	Boolean bPushed=false;
        for (Opportunity oIterator : newOpportunity) { //Bulk trigger handler so that you can mass update opportunities and this fires for all'
            
            // gets new values for updated rows
            dNewCloseDate = oIterator.CloseDate; // get the new closedate 
            dOldCloseDate = oldMapOpp.get(oIterator.Id).CloseDate; //get the old closedate for this opportunity
            if (oIterator.PushCount__c == oldMapOpp.get(oIterator.Id).PushCount__c && dOldCloseDate<dNewCloseDate ) { //if the new date is after the old one, look if the month numbers are different
                if (dOldCloseDate.month()<dNewCloseDate.month()) { // the month number is higher, it's been pushed out
                    bPushed=true;
                }
                else {
                    if (dOldCloseDate.year()<dNewCloseDate.year()) { // the month wasn't higher, but the year was, pushed!
                        bPushed=true;
                    }
                }
                
            }
            if (bPushed==true) { // let's go make them sorry
                if (oIterator.PushCount__c==null) {
                    oIterator.PushCount__c=1;
                }
                else {
                    oIterator.PushCount__c++;           
                }
            }
        }
    }

}