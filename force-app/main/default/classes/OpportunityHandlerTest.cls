@isTest
public class OpportunityHandlerTest {

 private static sObject[] OpptyList; 
 private static List<Opportunity> testOpptys = new List<Opportunity>();
private static Integer myYear = Date.today().year();
    static testMethod void myOppUnitTest() {
        Id cenveoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
   		Id custoLabelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Custom_Label_Quote_Follow_Up').getRecordTypeId();
        // create an oppty
        Opportunity oTestOppty=createOppty('testOppty',cenveoRecordTypeId);
        // set the date to Jan 1 of next year
        
        oTestOppty.CloseDate=date.newinstance(myYear+1,1,1);
        update oTestOppty;
        
		//check the push counter        
        Opportunity oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug('Push counter is: ' + oReadOppty.PushCount__c);
        //System.assert(oReadOppty.PushCount__c==1);
        
        // update the close date to the 15th of January
        oTestOppty.CloseDate=date.newinstance(myYear+1,1,15);
        update oTestOppty;
        oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug('After the first update, the push counter is: ' + oReadOppty.PushCount__c);
        //System.assert(oReadOppty.PushCount__c==1);
        
        // move it out to the following year
        oTestOppty.CloseDate=date.newInstance(myYear+2, 1,1);
        update oTestOppty;
        oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug('After the 2nd update, the push counter is: ' + oReadOppty.PushCount__c);
        //System.assertEquals(oReadOppty.PushCount__c, 2);
        
        // don't change the date, no change
        oTestOppty.CloseDate=date.newInstance(myYear+2,1,1);
        update oTestOppty;
        oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug('After the 3rd update, the push counter is: ' + oReadOppty.PushCount__c + ' (Should be the same)');
        //System.assertEquals(oReadOppty.PushCount__c,2);
        
    }
    
    private static Opportunity createOppty(String sOppName, Id recordtypeId) {
        Opportunity oNewOpp= new Opportunity(name= sOppName,closedate= date.newinstance(myYear,11,11),stagename='Prospecting',RecordTypeId = recordtypeId);

    insert oNewOpp;
        testOpptys.add(oNewOpp);
        return oNewOpp;
    }
   
}