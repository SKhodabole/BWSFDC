/*
	Apex class having helper methods for Trigger on Name_Mapping_Configuration__c object
*/
public class NameMappingConfigurationTriggerHelper{
    /**
     * Properties and variables
     */
    public static list < Name_Mapping_Configuration__c> newNameMappingConfigurations;
    public static list < Name_Mapping_Configuration__c> oldNameMappingConfigurations;
    public static map < Id, Name_Mapping_Configuration__c> newNameMappingConfigurationsMap;
    public static map < Id, Name_Mapping_Configuration__c> oldNameMappingConfigurationsMap;
    
    /**
     * Method called on before insert
     */
    public static void onBeforeInsert() {
        process(newNameMappingConfigurations);
    }
    
    /**
     * Method called on before update
     */
    
    public static void onBeforeUpdate() {
        list<Name_Mapping_Configuration__c> listNMCUpdated = new list<Name_Mapping_Configuration__c>();
        for(Name_Mapping_Configuration__c nmc : newNameMappingConfigurations) {
            if(newNameMappingConfigurationsMap.get(nmc.id).Type__c != oldNameMappingConfigurationsMap.get(nmc.id).Type__c ||
                newNameMappingConfigurationsMap.get(nmc.id).SFDC_Value__c != oldNameMappingConfigurationsMap.get(nmc.id).SFDC_Value__c){
                listNMCUpdated.add(nmc);
            }
        }
        process(listNMCUpdated);
    }
       
    /**
     * Method called process
     */
    static void process(list<Name_Mapping_Configuration__c> listNMC) {
        
        map<string, string> mapNMCAccount = new map<string, string>();
        map<string, string> mapNMCUser = new map<string, string>();
        map<string, string> mapNMCPlantProduct = new map<string, string>();
        map<string, string> mapNMCBillingAccountNumber = new map<string, string>();
        
        for(Name_Mapping_Configuration__c nmc : listNMC) {
        	
            if(nmc.Type__c != null && nmc.Type__c.trim() != '' && nmc.SFDC_Value__c != null && nmc.SFDC_Value__c.trim() != '')  {
                
                if(nmc.Type__c == 'Account Name') {
                    mapNMCAccount.put(nmc.SFDC_Value__c.trim().toLowerCase(), nmc.Mapped_Value__c.trim().toLowerCase());
                }
                else if(nmc.Type__c == 'User Name') {
                    mapNMCUser.put(nmc.SFDC_Value__c.trim().toLowerCase(), nmc.Mapped_Value__c.trim().toLowerCase());
                }
                else if(nmc.Type__c == 'Plant Product Name') {
                    mapNMCPlantProduct.put(nmc.SFDC_Value__c.trim().toLowerCase(), nmc.Mapped_Value__c.trim().toLowerCase());
                }
                else if(nmc.Type__c == 'Billing Account Number') {
                    if( nmc.Account__c == null ) {
                    	mapNMCBillingAccountNumber.put(nmc.SFDC_Value__c.trim().toLowerCase(), nmc.Mapped_Value__c.trim().toLowerCase());
                    }
                }
            }
        }
        
        // get Account map where account name is key and list of account value for map
        Map<String, List<Account>> mapAccountNameToListAccounts = new Map<String, List<Account>>();
        for(Account acc : [select Id, Name from Account Where Name IN : mapNMCAccount.keySet()]){
            if(acc.Name != null){
                String mapKey = acc.Name.trim().toLowerCase();
                if(!mapAccountNameToListAccounts.containsKey(mapKey)) {
                    mapAccountNameToListAccounts.put(mapKey, new list<Account>());
                }
                mapAccountNameToListAccounts.get(mapKey).add(acc);
            }
        }

        // get user map where user's name is key and list of user value for map
        Map<String, List<User>> mapNameOfUserToListUsers = new Map<String, List<User>>();
        for(User usr : [select Id, Name, ManagerId, IsActive from User Where Name IN : mapNMCUser.keySet()]){
            if(usr.Name != null){
                String mapKey = usr.Name.trim().toLowerCase();
                if(!mapNameOfUserToListUsers.containsKey(mapKey)) {
                    mapNameOfUserToListUsers.put(mapKey, new list<User>());
                }
                mapNameOfUserToListUsers.get(mapKey).add(usr);
            }
        }

        // get Plant map where plant name is key and list of plant value for map
        Map<String, List<Plant_Products__c>> mapPlantNameToListPlants = new Map<String, List<Plant_Products__c>>();
        for(Plant_Products__c plant : [select Id, Name from Plant_Products__c Where Name IN : mapNMCPlantProduct.keySet()]){
            if(plant.Name != null){
                String mapKey = plant.Name.trim().toLowerCase();
                if(!mapPlantNameToListPlants.containsKey(mapKey))
                    mapPlantNameToListPlants.put(mapKey, new list<Plant_Products__c>());
                mapPlantNameToListPlants.get(mapKey).add(plant);
            }
        }
        
        // get Account map where Billing Account Number is key and list of account value for map
        Map<String, List<Account>> mapBillingAccountNumberToListAccounts = new Map<String, List<Account>>();
        /*
        for(Account acc : [select Id, 
        						  Billing_Account_Number__c 
    					   from Account 
    					   Where Billing_Account_Number__c IN : mapNMCBillingAccountNumber.keySet()
    					   And Type != 'Parent' ]) {
    					   	
            if(acc.Billing_Account_Number__c != null){
                String mapKey = string.valueOf(acc.Billing_Account_Number__c).trim().toLowerCase();
                if(!mapBillingAccountNumberToListAccounts.containsKey(mapKey)) {
                    mapBillingAccountNumberToListAccounts.put(mapKey, new list<Account>());
                }
                mapBillingAccountNumberToListAccounts.get(mapKey).add(acc);
            }
        }
        */
        //retrive
        for(Name_Mapping_Configuration__c nmc : listNMC) {
            
            String nameAsKey = (nmc.SFDC_Value__c != null ? nmc.SFDC_Value__c.trim().toLowerCase(): '');
            
            if(nmc.Type__c == 'Account Name'){
                if(mapAccountNameToListAccounts.containsKey(nameAsKey) && mapAccountNameToListAccounts.get(nameAsKey).size() == 1) {
                    nmc.Account__c = mapAccountNameToListAccounts.get(nameAsKey)[0].Id;
                    nmc.Message__c = '';
                }
                else {
                    nmc.Account__c = null;
                    nmc.User__c = null;
                    nmc.Plant_Product__c = null; 
                    nmc.Message__c = (mapAccountNameToListAccounts.containsKey(nameAsKey) ? System.label.Multiple_Account_Match_Found : System.label.No_Account_Match_Found);
                }
            } 
            else if(nmc.Type__c == 'User Name'){
                if(mapNameOfUserToListUsers.containsKey(nameAsKey ) && mapNameOfUserToListUsers.get(nameAsKey ).size() == 1) {
                    if(mapNameOfUserToListUsers.get(nameAsKey)[0].IsActive){
                        nmc.User__c = mapNameOfUserToListUsers.get(nameAsKey)[0].Id;
                        nmc.Message__c = '';
                    }
                    else{   
                        nmc.Account__c = null;
                        nmc.User__c = null;
                        nmc.Plant_Product__c = null;  
                        nmc.Message__c = System.label.Sales_Rep_is_InActive;
                    }
                } 
                else {
                    nmc.Account__c = null;
                    nmc.User__c = null;
                    nmc.Plant_Product__c = null; 
                    nmc.Message__c = (mapNameOfUserToListUsers.containsKey(nameAsKey) ? System.label.Multiple_Rep_Match_Found : System.label.No_Rep_Match_Found);
                }
            } 
            else if(nmc.Type__c == 'Plant Product Name'){
                
                if(mapPlantNameToListPlants.containsKey(nameAsKey) && mapPlantNameToListPlants.get(nameAsKey).size() == 1) {
                    nmc.Plant_Product__c = mapPlantNameToListPlants.get(nameAsKey)[0].Id;
                    nmc.Message__c = ''; 
                } 
                else {
                    nmc.Account__c = null;
                    nmc.User__c = null;
                    nmc.Plant_Product__c = null; 
                    nmc.Message__c = (mapPlantNameToListPlants.containsKey(nameAsKey) ? System.label.Multiple_Plant_Name_Match_Found : System.label.No_Plant_Name_Match_Found);
                }
            } else if(nmc.Type__c == 'Billing Account Number'){
                
                if(mapBillingAccountNumberToListAccounts.containsKey(nameAsKey) && mapBillingAccountNumberToListAccounts.get(nameAsKey).size() == 1) {
                    nmc.Account__c = mapBillingAccountNumberToListAccounts.get(nameAsKey)[0].Id;
                    nmc.Message__c = '';
                }
                else {
	                    nmc.User__c = null;
	                    nmc.Plant_Product__c = null;
	                    if( nmc.Account__c == null ) { 
	                    	nmc.Message__c = (mapBillingAccountNumberToListAccounts.containsKey(nameAsKey) ? System.label.Multiple_Account_Match_Found : System.label.No_Account_Match_Found);
	                    }
                }
            }
        }
    }
}