trigger updateTaskSubjectOnOpp on Task (after insert, after update, after delete) {
     //Variables
     Set<Id> activityOppIds = new Set<Id>();
     Set<Id> activityAccIds = new Set<Id>();
     Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
     Map<Id, Account> accMap = new Map<Id, Account>();
     Time zeroTime = Time.newInstance(0,0,0,0);
      
     if(Trigger.isUpdate || Trigger.isInsert){
        for (Task t : Trigger.new) {                       
            if(t.WhatId != null && String.valueOf(t.whatId).startsWith('006')){
               /* if(Trigger.isInsert){
                    activityOppIds.add(t.whatid);
                }else{
                    if( t.Subject != Trigger.oldMap.get(t.Id).subject ||
                        t.status != trigger.oldMap.get(t.Id).status){
                        activityOppIds.add(t.whatid);
                    }
                } */
                activityOppIds.add(t.whatid);
            }else if(t.WhatId != null && String.valueOf(t.whatId).startsWith('001')){
                /*if(Trigger.isInsert){
                    activityAccIds.add(t.whatid);
                }else{
                    if( t.Subject != Trigger.oldMap.get(t.Id).subject ||
                        t.status != trigger.oldMap.get(t.Id).status){
                        activityAccIds.add(t.whatid);
                    }
                }*/
                activityAccIds.add(t.whatid);
            }             
        }
     }else{
         for(Task t : Trigger.old) {           
            if(t.WhatId != null && String.valueOf(t.whatId).startsWith('006')){
                activityOppIds.add(t.whatid);
            }else if(t.WhatId != null && String.valueOf(t.whatId).startsWith('001')){
                activityAccIds.add(t.whatid);
            }
         }
     }
     
     if(!activityOppIds.isEmpty()){
          for(Opportunity opp : [SELECT ID,Open_Activities__c, (Select ActivityDate,Subject,Owner.Name,who.name From Tasks where isClosed = false and RecurrenceActivityId = null order by ActivityDate desc),(Select StartDateTime, Subject,Owner.Name,who.name from Events where RecurrenceActivityId=null and StartDateTime >= TODAY order by startdatetime desc)  FROM Opportunity WHERE ID IN:activityOppIds
                                AND (RecordType.DeveloperName = 'Custom_Label_Quote_Follow_Up' OR RecordType.DeveloperName = 'Cenveo')]){
              String openTasks = '';
              String openEvents = '';
              if(opp.tasks != null && opp.tasks.size() > 0){
                  for(Task tsk : opp.Tasks){
                      if(tsk.subject != null && tsk.subject.trim() != '' && tsk.ActivityDate != null){
                          openTasks = openTasks + DateTime.newInstance(tsk.ActivityDate,zeroTime).format('MM/dd/yyyy') + ' - ' + tsk.Owner.Name + ' - ' + tsk.subject + (tsk.who.Name == null ? '' : ' - ' + tsk.who.Name) + '\n'; 
                      }
                  }
              }
              if(opp.Events != null && opp.Events.size() > 0){
                  for(Event evt : opp.Events){
                      if(evt.subject != null && evt.subject.trim() != ''){
                          openEvents = openEvents + evt.startDateTime.format('MM/dd/yyyy') + ' - ' + evt.Owner.Name + ' - ' + evt.subject +(evt.who.Name == null ? '' : ' - ' + evt.who.Name) + '\n'; 
                      }
                  }
              }
              opp.Open_Activities__c = openTasks + openEvents ;
              oppMap.put(opp.Id, opp);
          }
      }
      
      if(!activityAccIds.isEmpty()){
          for(Account acc : [SELECT ID,Open_Activities__c, (Select ActivityDate,Subject,Owner.Name,who.name From Tasks where RecurrenceActivityId=null and isClosed = false order by ActivityDate desc),(Select StartDateTime, Subject,Owner.Name,who.name from Events where RecurrenceActivityId=null and StartDateTime >= TODAY order by startdatetime desc)  FROM Account WHERE ID IN:activityAccIds
                            AND RecordType.DeveloperName = 'Cenveo']){
              String openTasks = '';
              String openEvents = '';
              if(acc.tasks != null && acc.tasks.size() > 0){
                  for(Task tsk : acc.Tasks){
                      if(tsk.subject != null && tsk.subject.trim() != '' && tsk.ActivityDate != null){
                          openTasks = openTasks + DateTime.newInstance(tsk.ActivityDate,zeroTime).format('MM/dd/yyyy') + ' - ' + tsk.Owner.Name + ' - ' + tsk.subject + (tsk.who.Name == null ? '' : ' - ' + tsk.who.Name) + '\n'; 
                      }
                  }
              }
              if(acc.Events != null && acc.Events.size() > 0){
                  for(Event evt : acc.Events){
                      if(evt.subject != null && evt.subject.trim() != ''){
                          openEvents = openEvents + evt.startDateTime.format('MM/dd/yyyy') + ' - ' + evt.Owner.Name + ' - ' + evt.subject +(evt.who.Name == null ? '' : ' - ' + evt.who.Name) + '\n'; 
                      }
                  }
              }
              acc.Open_Activities__c = openTasks + openEvents ;
              accMap.put(acc.Id, acc);
          }
      }
      
      if(!oppMap.isEmpty()){
          update oppMap.values();
      }
      
      if(!accMap.isEmpty()){
          update accMap.values();
      }
}