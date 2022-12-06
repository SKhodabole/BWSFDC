/*
    Apex class having helper method for trigger on Raw_Sales_Data__c object
*/
public class RawSalesDataTriggerHelper{
    /**
     * Properties and variables
     */
    public static list <Raw_Sales_Data__c> newRawSalesDatas;
    public static list <Raw_Sales_Data__c> oldRawSalesDatas;
    public static map <Id, Raw_Sales_Data__c> newRawSalesDatasMap;
    public static map <Id, Raw_Sales_Data__c> oldRawSalesDatasMap;
     
    /**
     * Method called on before insert
     */
    public static void onBeforeInsert() {
        list<Raw_Sales_Data__c> listRSDUpdated = new list<Raw_Sales_Data__c>();
        for(Raw_Sales_Data__c rsd : newRawSalesDatas) {
            if(rsd.Moved_to_Sales_Data__c == null)
                listRSDUpdated.add(rsd);
        }
        
        if(listRSDUpdated.size() > 0)
            process(newRawSalesDatas);
    }
    
    /**
     * Method called on before update
     */
    public static void onBeforeUpdate() {
        list<Raw_Sales_Data__c> listRSDUpdated = new list<Raw_Sales_Data__c>();
        for(Raw_Sales_Data__c rsd : newRawSalesDatas) {
            if(rsd.Moved_to_Sales_Data__c == null && (newRawSalesDatasMap.get(rsd.id).Admin_Forced_Account_Id__c != oldRawSalesDatasMap.get(rsd.id).Admin_Forced_Account_Id__c ||
                newRawSalesDatasMap.get(rsd.id).Admin_Forced_Account_Name__c != oldRawSalesDatasMap.get(rsd.id).Admin_Forced_Account_Name__c ||
                newRawSalesDatasMap.get(rsd.id).Admin_Forced_Plant_Product_Id__c != oldRawSalesDatasMap.get(rsd.id).Admin_Forced_Plant_Product_Id__c ||
                newRawSalesDatasMap.get(rsd.id).Admin_Forced_Plant_Product_Name__c != oldRawSalesDatasMap.get(rsd.id).Admin_Forced_Plant_Product_Name__c)){
                    listRSDUpdated.add(rsd);
            }
        }
        
        if(listRSDUpdated.size() > 0)
            process(newRawSalesDatas);
    }
    
    /**
    * Method called process
    * Populated Admin Forced Account and Plant Name
    */
    static void process(list<Raw_Sales_Data__c> listRSD) {
        set<string> setAccountId = new set<string>();
        set<string> setAccountName = new set<string>();
        set<string> setProductId = new set<string>();
        set<string> setProductName = new set<string>();
        
        for(Raw_Sales_Data__c rsd : listRSD) {
            if(rsd.Admin_Forced_Account_Id__c != null)
                setAccountId.add(rsd.Admin_Forced_Account_Id__c);
            if(rsd.Admin_Forced_Account_Name__c != null)
                setAccountName.add(rsd.Admin_Forced_Account_Name__c);
            if(rsd.Admin_Forced_Plant_Product_Id__c != null)
                setProductId.add(rsd.Admin_Forced_Plant_Product_Id__c);
            if(rsd.Admin_Forced_Plant_Product_Name__c != null)
                setProductName.add(rsd.Admin_Forced_Plant_Product_Name__c);
        }
        
        // get Account map
        Map<String, List<Account>> mapAccounts = new Map<String, List<Account>>();
        for(Account acc : [select Id, Name from Account Where Type != 'Parent' AND (Id IN : setAccountId OR Name IN : setAccountName)]){
            if(acc.Id != null){
                String mapKey = acc.Id;
                if(!mapAccounts.containsKey(mapKey)) {
                    mapAccounts.put(mapKey, new list<Account>());
                }
                mapAccounts.get(mapKey).add(acc);
            }
            
            if(acc.Name != null){
                String mapKey = acc.Name.trim().toLowerCase();
                if(!mapAccounts.containsKey(mapKey)) {
                    mapAccounts.put(mapKey, new list<Account>());
                }
                mapAccounts.get(mapKey).add(acc);
            }
        }
        
        // get PlantProducts map
        Map<String, List<Plant_Products__c>> mapPlantProducts = new Map<String, List<Plant_Products__c>>();
        for(Plant_Products__c pp : [select Id, Name from Plant_Products__c Where Id IN : setProductId OR Name IN : setProductName]){
            if(pp.Id != null){
                String mapKey = pp.Id;
                if(!mapPlantProducts.containsKey(mapKey)) {
                    mapPlantProducts.put(mapKey, new list<Plant_Products__c>());
                }
                mapPlantProducts.get(mapKey).add(pp);
            }
            
            if(pp.Name != null){
                String mapKey = pp.Name.trim().toLowerCase();
                if(!mapPlantProducts.containsKey(mapKey)) {
                    mapPlantProducts.put(mapKey, new list<Plant_Products__c>());
                }
                mapPlantProducts.get(mapKey).add(pp);
            }
        }
        
        
        //retrive
        for(Raw_Sales_Data__c rsd : listRSD) {
            //Populate Account
            rsd.Admin_Forced_Account_Match__c = null;
            if(rsd.Admin_Forced_Account_Id__c != null){
                rsd.Admin_Forced_Account_Match__c = (mapAccounts.containsKey(rsd.Admin_Forced_Account_Id__c) ? mapAccounts.get(rsd.Admin_Forced_Account_Id__c)[0].Id : null);
            }
            
            if(rsd.Admin_Forced_Account_Match__c == null && rsd.Admin_Forced_Account_Name__c != null){
                String nameAsKey = rsd.Admin_Forced_Account_Name__c.trim().toLowerCase();
                rsd.Admin_Forced_Account_Match__c = (mapAccounts.containsKey(nameAsKey) && mapAccounts.get(nameAsKey).size() == 1 ? mapAccounts.get(nameAsKey)[0].Id : null);
            }
            
            
            //Populate Plant_Product
            rsd.Admin_Forced_Plant_Product_Match__c = null;
            if(rsd.Admin_Forced_Plant_Product_Id__c != null){
                rsd.Admin_Forced_Plant_Product_Match__c = (mapPlantProducts.containsKey(rsd.Admin_Forced_Plant_Product_Id__c) ? mapPlantProducts.get(rsd.Admin_Forced_Plant_Product_Id__c)[0].Id : null);
            }
            
            if(rsd.Admin_Forced_Plant_Product_Match__c == null && rsd.Admin_Forced_Plant_Product_Name__c != null){
                String nameAsKey = rsd.Admin_Forced_Plant_Product_Name__c.trim().toLowerCase();
                rsd.Admin_Forced_Plant_Product_Match__c = (mapPlantProducts.containsKey(nameAsKey) && mapPlantProducts.get(nameAsKey).size() == 1 ? mapPlantProducts.get(nameAsKey)[0].Id : null);
            }
        }
    }
}