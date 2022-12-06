trigger opportunityRevAmtTrigger on Opportunity (before update,after update) {
    List<Opportunity> newOpportunityList = new List<Opportunity>();
    if(Trigger.isUpdate && Trigger.isAfter){
        for(Opportunity opp : Trigger.new){
            if(opp.StageName == 'Closed Won' && (opp.RecordTypeId == OpportunityHandler.bandWRecordTypeId || opp.RecordTypeId == OpportunityHandler.mAndARecordTypeId)){
                //addRevenueDetailOpportunity.addRevenueDetail(opp.id);
            }
        }
        
    }else if(Trigger.isUpdate && Trigger.isBefore){
        for(Opportunity opp : Trigger.new){
            if(opp.CloseDate != Trigger.OldMap.get(opp.id).CloseDate &&( opp.RecordTypeId == OpportunityHandler.cenveoRecordTypeId || opp.RecordTypeId == OpportunityHandler.custoLabelRecordTypeId)){
                newOpportunityList.add(opp);
            }
        }
        if(!newOpportunityList.isEmpty() && newOpportunityList.size() > 0){
            OpportunityHandler.opportunityPusher(newOpportunityList , Trigger.OldMap);
        }
        
    }
}