/*
 *  Purpose       :      Apex class having controller class for VFP SalesDataUploadSummary
 *
 *  Created By      :      S Sharma
 *
 *  Created Date    :      02/03/2015
 *
 *  Revision Logs   :      V1.0 - Created
 **/
public class SalesDataUploadSummaryController {

    public class SalesDataUploadSummaryControllerException extends exception {}
    
    private map<String, String> mapMonths;
    private boolean isMoveSalesData;
    public Raw_Sales_Data__c rawSalesData{get; set;}
    public string selectedMonth{get;set;}
    public list<SelectOption> months{get;set;}
 
    public string selectedBusinessUnit{get;set;}
    public list<SelectOption> businesUnits{get;set;}

    public list<String> plants{get;set;}
    public map<String, Decimal> mapPlants{get; set;}
    public map<String, Decimal> mapActualUnits{get; set;}
    public map<String, Decimal> mapGMPerctanges{get; set;}
    
    public integer processRecordlimits{get; set;}
    public list<Raw_Sales_Data__c> recordsToProcess{get;set;}
    public integer pagecounterProcess{get; set;}
    public boolean isNextProcess{get; set;}
    private map<Integer, list<Raw_Sales_Data__c>> mapRecordProcessMoved;
    
    public integer withoutErrorRecordlimits{get; set;}
    public list<Raw_Sales_Data__c> recordsWithoutError{get;set;}
    public integer pagecounterWithoutError{get; set;}
    public boolean isNextWithoutError{get; set;}
    private map<Integer, list<Raw_Sales_Data__c>> mapRecordWithoutErrorMoved;
    
    public integer successRecordlimits{get; set;}
    public list<Raw_Sales_Data__c> recordSuccessfullyMoved{get;set;}
    public integer pagecounter{get; set;}
    public boolean isNext{get; set;}
    private map<Integer, list<Raw_Sales_Data__c>> mapRecordSuccessfullyMoved;
    public integer withErrorRecordlimits{get; set;}
    public list<Raw_Sales_Data__c> recordsWithError{get;set;}
    public integer pagecounterWithError{get; set;}
    public boolean isNextWithError{get; set;}
    private map<Integer, list<Raw_Sales_Data__c>> mapRecordWithErrorMoved;
    public Name_Mapping_Configuration__c nmc{get; set;}
    private Map<Id, Id> mapRSDIdToNearMatchAccountId { get;set; }
    private Map<String, Map<Id, Account>> mapAccountNameToAccountsFromMapping = new Map<String, Map<Id, Account>>();
    private Map<String, Map<Id, User>> mapNameOfUserToMapOfUsersFromMappings = new Map<String, Map<Id, User>>();
    private Map<String, Map<Id, Plant_Products__c>> plantProductNameToMapOfPlantProductNameFromMappings = new Map<String, Map<Id, Plant_Products__c>>();
    
    // constuctor
    public SalesDataUploadSummaryController(){
        try {
        	
            // get configurations
            Sales_Data_Upload_Configurations__c uploadConfig = Sales_Data_Upload_Configurations__c.getOrgDefaults();
            processRecordlimits = (uploadConfig.Process_Records_Limit__c != null ? Integer.valueOf(uploadConfig.Process_Records_Limit__c) : 200);
            withoutErrorRecordlimits = (uploadConfig.Without_Error_Records_Limit__c != null ? Integer.valueOf(uploadConfig.Without_Error_Records_Limit__c) : 200);
            successRecordlimits = (uploadConfig.Successfully_Records_Limit__c!= null ? Integer.valueOf(uploadConfig.Successfully_Records_Limit__c) : 200);
            withErrorRecordlimits = (uploadConfig.With_Error_Records_Limit__c!= null ? Integer.valueOf(uploadConfig.With_Error_Records_Limit__c) : 200);
        	
        	// populate month picklist options
            populateYearMonths();

            DateTime todayDate = datetime.now();
            selectedMonth = todayDate.addMonths(-1).format('MMM').trim();
            rawSalesData = new Raw_Sales_Data__c(Period__c = mapMonths.get(selectedMonth), Year__c = ''+todayDate.year());

            nmc = new Name_Mapping_Configuration__c();
            mapRSDIdToNearMatchAccountId = new Map<Id, Id>();
            refresh();
        }
        catch( Exception e ) {
            ApexPages.addMessages(e);
        }
    }

    
    public decimal grandTotal{get; set;}
    public decimal grandTotalAU{get; set;}
    public decimal grandTotalGM{get; set;}
    
   
    /**
    * @description : Method to refresh page view data when processing is done
    */
    public void refresh(){
		    
        plants = new list<String>();
        grandTotal = 0;
        grandTotalAU = 0;
        grandTotalGM = 0;
        mapPlants = new map<String, Decimal>();
        mapActualUnits = new map<String, Decimal>();
        mapGMPerctanges = new map<String, Decimal>();

        businesUnits = new list<SelectOption>();
        businesUnits.add(new SelectOption('', '--None--'));
        
        rsdSetProcess = new set<string>();
        rsdSetWithoutError = new set<string>();
        rsdSet = new set<string>();
        rsdSetWithError = new set<string>();
               
        isMoveSalesData = false;

        set<string> setRemoveDuplicacyBU = new set<string>();
        
        // Query Raw Sales Data for the selected Business Unit, Year and Month
        for(Raw_Sales_Data__c r : [ SELECT Admin_Forced_Account_Match__r.OwnerId,
                                           Admin_Forced_Account_Match__c,
                                           Admin_Forced_Plant_Product_Match__c,          
                                    	   Match_Success_Log__c, Billing_System__c, Billing_Account_Number__c, 
                                    	   Plant_Name__c, Account_Name__c, Actual__c, Actual_Unit__c, GMDollars__c
                                    FROM Raw_Sales_Data__c
                                    WHERE Year__c =: rawSalesData.Year__c
                                    AND Period__c =: mapMonths.get(selectedMonth)
                                    ORDER BY Billing_System__c ASC ]){
          
            if(!setRemoveDuplicacyBU.contains(r.Billing_System__c) && r.Billing_System__c != null){
            	// populate various business units available for the selected month and year
                businesUnits.add(new SelectOption(r.Billing_System__c, r.Billing_System__c ));
                setRemoveDuplicacyBU.add(r.Billing_System__c);
            }
        }

        if(Test.isRunningTest())
            selectedBusinessUnit = businesUnits.get(1).getValue();
		
		// Query Raw Sales Data for the selected Business Unit, Year and Month and do the sum of actuals and actual units 
        for(Raw_Sales_Data__c r : [ SELECT Admin_Forced_Account_Match__r.OwnerId,
                                           Admin_Forced_Account_Match__c,
                                           Admin_Forced_Plant_Product_Match__c,          
                                           Match_Success_Log__c, Billing_System__c, Billing_Account_Number__c, 
                                           Plant_Name__c, Account_Name__c, Actual__c, Actual_Unit__c, GMDollars__c
                                    FROM Raw_Sales_Data__c
                                    WHERE Billing_System__c =: selectedBusinessUnit
                                    AND Year__c =: rawSalesData.Year__c
                                    AND Period__c =: mapMonths.get(selectedMonth)
                                    ORDER BY Plant_Name__c ASC]){
                                    	
            if(r.Plant_Name__c != null){

                if(!mapPlants.containskey(r.Plant_Name__c)){
                    plants.add( r.Plant_Name__c );
                    mapPlants.put(r.Plant_Name__c, 0);
                }

                if(r.Actual__c != null){
                    Decimal actual = mapPlants.get(r.Plant_Name__c) + r.Actual__c;
                    mapPlants.put(r.Plant_Name__c, actual);
                    grandTotal += r.Actual__c;
                }

                if(!mapActualUnits.containskey(r.Plant_Name__c))
                    mapActualUnits.put(r.Plant_Name__c, 0);

                if(r.Actual_Unit__c != null){
                    Decimal actual = mapActualUnits.get(r.Plant_Name__c) + decimal.valueof(r.Actual_Unit__c);
                    mapActualUnits.put(r.Plant_Name__c, actual);
                    grandTotalAU += decimal.valueof(r.Actual_Unit__c);
                }

                if(!mapGMPerctanges.containskey(r.Plant_Name__c))
                    mapGMPerctanges.put(r.Plant_Name__c, 0);

                if(r.GMDollars__c != null){
                    Decimal actual = mapGMPerctanges.get(r.Plant_Name__c) + r.GMDollars__c;
                    mapGMPerctanges.put(r.Plant_Name__c, actual);
                    grandTotalGM += r.GMDollars__c;
                }
            }
        }
        
        mapRecordProcessMoved = new map<Integer, list<Raw_Sales_Data__c>>();
        pagecounterProcess = 1;
        // get records to process
        searchresultProcess();
        
        mapRecordWithoutErrorMoved = new map<Integer, list<Raw_Sales_Data__c>>();
        pagecounterWithoutError = 1;
        // get records processed without errors
        searchresultWithoutError();
        
        mapRecordSuccessfullyMoved = new map<Integer, list<Raw_Sales_Data__c>>();
        pagecounter = 1;
        // get records to process successfully and moved to salesdata
        searchresult();
        
        mapRecordWithErrorMoved = new map<Integer, list<Raw_Sales_Data__c>>();
        pagecounterWithError = 1;
        // get records to processed with error
        searchresultWithError();
    }

    /**
    * @description : Method to populate year months
    */
    public void populateYearMonths(){
        populateMonths();
        list<String> listMonth = new list<String>{'Jan', 'Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

        months = new list<SelectOption>();
        for(string month : listMonth){
            months.add(new SelectOption(month, month));
        }
    }

    /**
    * @description : Method to populate months
    */
    public void populateMonths(){
        mapMonths = new map<String, String>();
        mapMonths.put('Jan', '1');
        mapMonths.put('Feb', '2');
        mapMonths.put('Mar', '3');
        mapMonths.put('Apr', '4');
        mapMonths.put('May', '5');
        mapMonths.put('Jun', '6');
        mapMonths.put('Jul', '7');
        mapMonths.put('Aug', '8');
        mapMonths.put('Sep', '9');
        mapMonths.put('Oct', '10');
        mapMonths.put('Nov', '11');
        mapMonths.put('Dec', '12');
    }
    
	/**
    * @description : method to populate collections from the mapping object
    */
    private void getCollectionsFromMappings( Set<String> mappedNames ) {

        mapBillingAccountNumberFromMappingToMapAccounts = new Map<String, Map<Id, Account>>();
        mapAccountNameToAccountsFromMapping = new Map<String, Map<Id, Account>>();
        mapNameOfUserToMapOfUsersFromMappings = new Map<String, Map<Id, User>>();
        plantProductNameToMapOfPlantProductNameFromMappings = new Map<String, Map<Id, Plant_Products__c>>();
        
        // Query mappings
        String soqlQuery =   ' select Message__c, User__c, User__r.ManagerId, User__r.IsActive '
               + ' , Plant_Product__c, Plant_Product__r.Name '
               + ' , Account__c, Account__r.Name, Account__r.OwnerId, Account__r.Type '
               + ' , Mapped_Value__c, SFDC_Value__c, Type__c '
               + ' From Name_Mapping_Configuration__c '
               + ' Where Message__c = NULL '
               + ' And Is_Excluded__c = False '
               + ' And ( Mapped_Value__c in: mappedNames ) '
               + ' And Billing_System__c INCLUDES (\'All\', \'' + selectedBusinessUnit + '\') '
               + ' Order By LastModifiedDate DESC ';

        List<Name_Mapping_Configuration__c> listNMC = Database.query( soqlQuery );

        // loop over mapping records
        for( Name_Mapping_Configuration__c nmc : listNMC ) {

            if( nmc.Type__c != null &&  nmc.Mapped_Value__c != null && nmc.SFDC_Value__c != null ) {
            	// when mapping is for account name
                if(nmc.Type__c == 'Account Name' && nmc.Account__c != null){

                    String mapKey = nmc.Mapped_Value__c.trim().toLowerCase();
                    Map<Id, Account> mapAccounts = new Map<Id, Account>();
                    if( mapAccountNameToAccountsFromMapping.containsKey(mapKey)) {
                        mapAccounts = mapAccountNameToAccountsFromMapping.get(mapKey);
                    }
                    Account acc = new Account( Id = nmc.Account__c,
                                               Name = nmc.Account__r.Name,
                                               OwnerId = nmc.Account__r.OwnerId,
                                               Type = nmc.Account__r.Type );
                                               
                    mapAccounts.put( acc.Id, acc );
                    mapAccountNameToAccountsFromMapping.put( mapKey, mapAccounts );
                    mapAccountIdToAccount.put( acc.Id, acc );
                }
				// when mapping is for User Name
                if(nmc.Type__c == 'User Name' && nmc.User__c !=  null ) {
                    String mapKey = nmc.Mapped_Value__c.trim().toLowerCase();
                    Map<Id, User> mapUsers = new Map<Id, User>();
                    if( mapNameOfUserToMapOfUsersFromMappings.containsKey(mapKey)) {
                        mapUsers = mapNameOfUserToMapOfUsersFromMappings.get(mapKey);
                    }
                    User u = new User( Id = nmc.User__c, ManagerId = nmc.User__r.ManagerId,
                                        IsActive = nmc.User__r.IsActive );
                    mapUsers.put( u.Id, u );
                    mapNameOfUserToMapOfUsersFromMappings.put( mapKey, mapUsers );
                }
                // when mapping is for Plant Product Name
                if(nmc.Type__c == 'Plant Product Name' && nmc.Plant_Product__c !=  null ) {
                    String mapKey = nmc.Mapped_Value__c.trim().toLowerCase();
                    Map<Id, Plant_Products__c> mapPlantProducts = new Map<Id, Plant_Products__c>();
                    if( plantProductNameToMapOfPlantProductNameFromMappings.containsKey(mapKey)) {
                        mapPlantProducts = plantProductNameToMapOfPlantProductNameFromMappings.get(mapKey);
                    }

                    Plant_Products__c plantProductObj = new Plant_Products__c( Id = nmc.Plant_Product__c,
                                                                               Name = nmc.Plant_Product__r.Name );
                    mapPlantProducts.put( plantProductObj.Id, plantProductObj );
                    plantProductNameToMapOfPlantProductNameFromMappings.put( mapKey, mapPlantProducts );
                }
                // when mapping is for Billing Account Number
                if(nmc.Type__c == 'Billing Account Number' && nmc.Account__c !=  null ) {
                    
                    String mapKey = nmc.Mapped_Value__c.trim();
                    if( mapKey != '' ) {
                        Map<Id, Account> mapAccounts = new Map<Id, Account>();
                        if( mapBillingAccountNumberFromMappingToMapAccounts.containsKey(mapKey) ) {
                            mapAccounts = mapAccountNameToAccountsFromMapping.get(mapKey);
                        }
                        Account acc = new Account( Id = nmc.Account__c,
                                                   Name = nmc.Account__r.Name,
                                                   OwnerId = nmc.Account__r.OwnerId,
                                                   Type = nmc.Account__r.Type );
                                                   
                        mapAccounts.put( acc.Id, acc );
                        mapBillingAccountNumberFromMappingToMapAccounts.put( mapKey, mapAccounts );
                        mapAccountIdToAccount.put( acc.Id, acc );
                    }
                }
            }
        }

    }

    private Map<Id, Account> mapAccountIdToAccount = new Map<Id, Account>();
    private Map<String, Map<Id, Account>> mapAccountNumberToMapAccounts = new Map<String, Map<Id, Account>>();
    private Map<String, Map<Id, Account>> mapPeopleSoftAccountNumberToMapAccounts = new Map<String, Map<Id, Account>>();
    private Map<String, Map<Id, Account>> mapAccountNameToMapAccounts = new Map<String, Map<Id, Account>>();
    private Map<String, Map<Id, Account>> mapCFIAccountNumberToMapOfAccounts = new Map<String, Map<Id, Account>>();
	private Map<String, Map<Id, Account>> mapPeopleSoftCFIAccountNumberToMapOfAccounts = new Map<String, Map<Id, Account>>();
	private Map<String, Map<Id, Account>> mapBillingAccountNumberFromMappingToMapAccounts = new Map<String, Map<Id, Account>>();
	
	/**
    * @description : Method to set collections to be used for Account Match from records in database 
    */
    private void getMapsForAccountMatchFromDatabaseSearch( set<string> accountNames,
                                                           set<string> accountNumbers ) {

        // get Account map where account number is key and list of account value for map
        mapAccountNumberToMapAccounts = new Map<String, Map<Id, Account>>();
        // get Account map where account name is key and list of account value for map
        mapAccountNameToMapAccounts = new Map<String, Map<Id, Account>>();

        for(Account acc : [ Select Id, Name, Type, OwnerId,
                                   Billing_Account_Number__c,
                                   PeopleSoft_Acct__c 
                            From Account
                            Where ( Name IN : accountNames
                            OR Billing_Account_Number__c IN : accountNumbers 
                            OR PeopleSoft_Acct__c in: accountNumbers )
                            And Type != 'Parent'
                           ]){
                
                if( acc.Billing_Account_Number__c != null && acc.PeopleSoft_Acct__c == null ){
                    String mapKey = acc.Billing_Account_Number__c.trim();
                    Map<Id, Account> mapAccounts = new Map<Id, Account>();
                    if( mapAccountNumberToMapAccounts.containsKey(mapKey) ) {
                        mapAccounts = mapAccountNumberToMapAccounts.get(mapKey);
                    }
                    mapAccounts.put( acc.Id, acc );
                    mapAccountNumberToMapAccounts.put(mapKey, mapAccounts );
                }
                
                if(acc.PeopleSoft_Acct__c != null){
                    String mapKey = acc.PeopleSoft_Acct__c.trim();
                    Map<Id, Account> mapAccounts = new Map<Id, Account>();
                    if( mapPeopleSoftAccountNumberToMapAccounts.containsKey(mapKey) ) {
                        mapAccounts = mapPeopleSoftAccountNumberToMapAccounts.get(mapKey);
                    }
                    mapAccounts.put( acc.Id, acc );
                    mapPeopleSoftAccountNumberToMapAccounts.put(mapKey, mapAccounts );
                }
                
                if(acc.Name != null){
                    String mapKey = acc.Name.trim().toLowerCase();
                    Map<Id, Account> mapAccounts = new Map<Id, Account>();
                    if( mapAccountNameToMapAccounts.containsKey(mapKey) ) {
                        mapAccounts = mapAccountNameToMapAccounts.get(mapKey);
                    }
                    mapAccounts.put( acc.Id, acc );
                    mapAccountNameToMapAccounts.put(mapKey, mapAccounts );
                }
                mapAccountIdToAccount.put( acc.Id, acc );
        }

        // Search Cenveo Finance Information andpopulate collections
        fillMapFinanceInformation(accountNumbers);
    }


    private Map<String, Map<Id, User>> mapNameOfUserToMapOfUsers = new Map<String, Map<Id, User>>();
    /**
    * @description : Method for setting collection for Rep Search
    */
    private void getMapsForUserMatchFromDatabaseSearch( set<string> repNames ) {

        // get user map where user's name is key and list of user value for map
        mapNameOfUserToMapOfUsers = new Map<String, Map<Id, User>>();
        List<User> listUsersForRep = [select Id, Name, ManagerId, IsActive from User Where Name IN : repNames ];
        for(User usr : listUsersForRep ){

            if(usr.Name != null){

                String mapKey = usr.Name.trim().toLowerCase();
                Map<Id, User> mapUsers = new Map<Id, User>();
                if( mapNameOfUserToMapOfUsers.containsKey(mapKey)) {
                    mapUsers = mapNameOfUserToMapOfUsers.get(mapKey);
                }
                User u = usr;
                mapUsers.put( u.Id, u );
                mapNameOfUserToMapOfUsers.put( mapKey , mapUsers );

            }
        }
    }

    private Map<String, Map<Id, Plant_Products__c>> plantProductNameToMapOfPlantProductName = new Map<String, Map<Id, Plant_Products__c>>();
    /**
    * @description : Method to set collection for plant product search
    */
    private void getMapsForPlantProductMatchFromDatabaseSearch( set<string> platNames ) {
        // get Plant map where plant name is key and list of plant value for map
        plantProductNameToMapOfPlantProductName = new Map<String, Map<Id, Plant_Products__c>>();
        for(Plant_Products__c plant : [select Id, Name from Plant_Products__c Where Name IN : platNames ]){
            if( plant.Name != null ){

                String mapKey = plant.Name.trim().toLowerCase();
                Map<Id, Plant_Products__c> mapPlantProducts = new Map<Id, Plant_Products__c>();
                if( plantProductNameToMapOfPlantProductName.containsKey(mapKey)) {
                    mapPlantProducts = plantProductNameToMapOfPlantProductName.get(mapKey);
                }
                mapPlantProducts.put( plant.Id, plant );
                plantProductNameToMapOfPlantProductName.put( mapKey, mapPlantProducts );
            }
        }
    }

    /**
    * @description : Method to Process the raw sales data
    */
    public void process(){

        try {
                if( selectedBusinessUnit != null && selectedBusinessUnit.trim() != ''
                    && selectedBusinessUnit.trim() != '--None--' ){

                        //Generate list of searchable
                        set<string> accountNames = new set<string>();
                        set<string> accountNumbers = new set<string>();
                        set<string> repNames = new set<string>();
                        set<string> platNames = new set<string>();
                        set<string> billingAccountNumber = new set<string>();

                        List<Raw_Sales_Data__c> recordsToProcessAll = new List<Raw_Sales_Data__c>();
						// When user is moving the data to Sales Data
                        if(isMoveSalesData){
                            // add records to process which are successfully processed earlier
                            for(Raw_Sales_Data__c r : [SELECT Admin_Forced_Account_Match__r.OwnerId,
                                                              Admin_Forced_Account_Match__c,
                                                              Admin_Forced_Plant_Product_Match__c,          
                                Match_Success_Log__c, Billing_System__c, Billing_Account_Number__c, Sales_Rep__c , Actual_Unit__c, Plant_Product__c, Account__c, Account_Name__c, Plant_Name__c, Rep_Name__c, OwnerId, Manager__c, Actual__c, GMDollars__c, GM__c,
                                Budget__c , Forecast__c,Margin_Sales_Dollars__c, Period__c, Period_End_Date__c,  Year__c, Sales_Data__c, Account__r.Name, Sales_Rep__r.Name, Plant_Product__r.Name, Manager__r.Name
                                FROM Raw_Sales_Data__c
                                WHERE Processed__c = true
                                AND Error_In_Processing__c =: FALSE
                                AND Billing_System__c =: selectedBusinessUnit
                                AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth) AND Moved_to_Sales_Data__c = null]){
                                    recordsToProcessAll.add(r);
                            }
                        }
                        else{
                                // add records to process which are not processed
                                for(Raw_Sales_Data__c r : [SELECT Admin_Forced_Account_Match__r.OwnerId,
                                                                  Admin_Forced_Account_Match__c,
                                                                  Admin_Forced_Plant_Product_Match__c,          
                                                                  Match_Success_Log__c, Billing_System__c, Billing_Account_Number__c, 
                                                                  Actual_Unit__c, Plant_Product__c,
                                                                  Sales_Rep__c, Account__c, Account_Name__c, Rep_Name__c, 
                                                                  Plant_Name__c, OwnerId, Manager__c, Actual__c,
                                                                  Error_In_Processing__c,
                                                                  Error_Log__c,
                                                                  Processed__c, GMDollars__c, GM__c,
                                                                  Account__r.Name, Sales_Rep__r.Name, 
                                                                  Plant_Product__r.Name, Manager__r.Name
                                                            FROM Raw_Sales_Data__c
                                                            WHERE Processed__c = false
                                                            AND Billing_System__c =: selectedBusinessUnit
                                                            AND Year__c =: rawSalesData.Year__c 
                                                            AND Period__c =: mapMonths.get(selectedMonth)
                                                            ]) {
                                                                
                                    recordsToProcessAll.add(r);
                                }
                                
                                // add records to process which are not successfully processed earlier
                                for(Raw_Sales_Data__c r : [SELECT Admin_Forced_Account_Match__r.OwnerId,
                                                                  Admin_Forced_Account_Match__c,
                                                                  Admin_Forced_Plant_Product_Match__c,          
                                                                  Match_Success_Log__c, Billing_System__c, Billing_Account_Number__c, 
                                                                  Actual_Unit__c, 
                                                                  Plant_Product__c, Account__c, Sales_Rep__c, 
                                                                  Account_Name__c, Plant_Name__c, Rep_Name__c, 
                                                                  OwnerId, Manager__c, Actual__c,
                                                                  Error_In_Processing__c,
                                                                  Error_Log__c,
                                                                  GMDollars__c, GM__c,
                                                            Account__r.Name, Sales_Rep__r.Name, Plant_Product__r.Name, Manager__r.Name
                                                            FROM Raw_Sales_Data__c
                                                            WHERE Processed__c = true
                                                            AND Error_In_Processing__c =: TRUE
                                                            And Moved_to_Sales_Data__c =: null
                                                            AND Billing_System__c =: selectedBusinessUnit
                                                            AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth)
                                                            ]){
                                     recordsToProcessAll.add(r);
                                }                            
                        }

                        Set<String> mappedNames = new Set<String>();
                        for(Raw_Sales_Data__c rsd : recordsToProcessAll){

                            if(rsd.Account_Name__c != null && rsd.Account_Name__c.trim() != '') {
                                accountNames.add(rsd.Account_Name__c);
                            }
                            if(rsd.Billing_Account_Number__c != null && rsd.Billing_Account_Number__c.trim() != '') {
                                accountNumbers.add(rsd.Billing_Account_Number__c);
                            }

                            if(rsd.Rep_Name__c != null && rsd.Rep_Name__c.trim() != '') {
                                repNames.add(rsd.Rep_Name__c);
                            }
                            if(rsd.Plant_Name__c != null && rsd.Plant_Name__c.trim() != '') {
                                platNames.add(rsd.Plant_Name__c);
                            }
                            
                            if(rsd.Billing_Account_Number__c!= null && rsd.Billing_Account_Number__c.trim() != '') {
                                billingAccountNumber.add(rsd.Billing_Account_Number__c);
                            }
                        }

                        mappedNames.addAll(accountNames);
                        mappedNames.addAll(repNames);
                        mappedNames.addAll(platNames);
                        mappedNames.addAll(billingAccountNumber);
                        
                        getCollectionsFromMappings( mappedNames );

                        getMapsForAccountMatchFromDatabaseSearch( accountNames, accountNumbers );
                        getMapsForUserMatchFromDatabaseSearch( repNames );
                        getMapsForPlantProductMatchFromDatabaseSearch( platNames );
						// process records
                        processRecords( recordsToProcessAll,
                                        mapAccountNumberToMapAccounts,
                                        mapPeopleSoftAccountNumberToMapAccounts,
                                        mapBillingAccountNumberFromMappingToMapAccounts,
                                        mapCFIAccountNumberToMapOfAccounts,
                                        mapPeopleSoftCFIAccountNumberToMapOfAccounts,
                                        mapAccountNameToAccountsFromMapping,
                                        mapAccountNameToMapAccounts,
                                        mapNameOfUserToMapOfUsersFromMappings,
                                        mapNameOfUserToMapOfUsers,
                                        plantProductNameToMapOfPlantProductNameFromMappings,
                                        plantProductNameToMapOfPlantProductName );
                        //Refresh
                        refresh();
                }
        }
        catch( Exception e ) {
            //ApexPages.addMessages(e);
            String errorMessage = recordsWithError + ' ' +  recordsWithoutError + ' '  + e.getMessage() + ' ****** ' + e.getLineNumber();
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage( errorMsg );
        }
    }

    private static String repMatchErrorLog = '';
    private static String accountMatchErrorLog = '';
    private static String plantProductMatchErrorLog = '';
    private static String matchSucceesLog = '';
	private static String accountMatchSucessLog = '';
	
	private static Set<Id> inActiveRepMatchIds = new Set<Id>();
	
    private static Map<Id, User> possibleRepMatchs = new Map<Id, User>();
    
    /**
    * @description : Method to process the records
    */
    private void processRecords( List<Raw_Sales_Data__c> recordsToProcessAll,
                                 Map<String, Map<Id, Account>> mapAccountNumberToMapAccounts,
                                 Map<String, Map<Id, Account>> mapPeopleSoftAccountNumberToMapAccounts,
                                 Map<String, Map<Id, Account>>  mapBillingAccountNumberFromMappingToMapAccounts,
                                 Map<String, Map<Id, Account>> mapCFIAccountNumberToMapOfAccounts,
                                 Map<String, Map<Id, Account>> mapPeopleSoftCFIAccountNumberToMapOfAccounts,
                                 Map<String, Map<Id, Account>> mapAccountNameToAccountsFromMapping,
                                 Map<String, Map<Id, Account>> mapAccountNameToMapAccounts,
                                 Map<String, Map<Id, User>> mapNameOfUserToMapOfUsersFromMappings,
                                 Map<String, Map<Id, User>> mapNameOfUserToMapOfUsers,
                                 Map<String, Map<Id, Plant_Products__c>> plantProductNameToMapOfPlantProductNameFromMappings,
                                 Map<String, Map<Id, Plant_Products__c>> plantProductNameToMapOfPlantProductName ) {
                                    
        // loop over the records to process                            
        for( Raw_Sales_Data__c rsd : recordsToProcessAll ) {
 					
 					mapRSDIdToNearMatchAccountId = new Map<Id, Id>();			
                    possibleRepMatchs = new Map<Id, User>();
                    
                    rsd.Account__c = null;
                    rsd.Sales_Rep__c = null;
                    rsd.Manager__c = null;
                    rsd.Plant_Product__c = null;
                    rsd.Error_Log__c = '';
                    rsd.Error_In_Processing__c = false;

                    repMatchErrorLog = '';
                    accountMatchErrorLog = '';
                    plantProductMatchErrorLog = '';
                    matchSucceesLog = '';
                    accountMatchSucessLog = '';
                    inActiveRepMatchIds = new Set<Id>();
    				Id possibleAccountId;                
                    rsd = populateUsingAdminForceMatch( rsd );
                    
                    if( ( rsd.Account_Name__c != null || rsd.Billing_Account_Number__c != null ) 
                    	  && rsd.Rep_Name__c != null && rsd.Plant_Name__c != null )	{

                        if( rsd.Sales_Rep__c == null ) {
                            // from mappings
                            rsd = populateSalesRep( rsd, mapNameOfUserToMapOfUsersFromMappings, true );
                        }
                        if( rsd.Sales_Rep__c == null ) {
                            // from search results from databasse
                            rsd = populateSalesRep( rsd, mapNameOfUserToMapOfUsers, false );
                        }
                        system.debug( '****** rsd.Sales_Rep__c ' + rsd.Sales_Rep__c );
                        if( rsd.Billing_Account_Number__c != null ) {
                        	
                            if( !checkFromPeopleSoftAcctNumber( rsd )) {
                                
                                if(rsd.Account__c == null){
                                    
                                    rsd = populateUsingAccountNumber( rsd, mapBillingAccountNumberFromMappingToMapAccounts, true );
                                }
        
                                if(rsd.Account__c == null){
        
                                    rsd = populateUsingAccountNumber( rsd, mapAccountNumberToMapAccounts, false );
                                }
        
                                // match from cenveo finance
                                if(rsd.Account__c == null){
                                    rsd = populateAccountCenveoFinanceInformation( rsd, mapCFIAccountNumberToMapOfAccounts);
                                }
                            }
                            else {
                                
                                if(rsd.Account__c == null){
        
                                    rsd = populateUsingPeopleSoftAccountNumber( rsd, mapPeopleSoftAccountNumberToMapAccounts, false );
                                }
                                
                                // match from cenveo finance
                                if(rsd.Account__c == null){
                                    rsd = populateAccountCenveoFinanceInformation( rsd, mapPeopleSoftCFIAccountNumberToMapOfAccounts );
                                }
                            }
                        }
                        // when no billing account number in raw sales data record
                        else { 
                            if(rsd.Account__c == null){
                                rsd = populateUsingAccountName( rsd, mapAccountNameToAccountsFromMapping, true );
                            }
    
                            if(rsd.Account__c == null){
                                rsd = populateUsingAccountName( rsd, mapAccountNameToMapAccounts, false );
                            }
                        }
                        
                        if( rsd.Plant_Product__c == null ) {
                            rsd = populatePlantName( rsd, plantProductNameToMapOfPlantProductNameFromMappings, true );
                        }

                        if( rsd.Plant_Product__c == null ) {
                            rsd = populatePlantName( rsd, plantProductNameToMapOfPlantProductName, false );
                        }

                        if( rsd.Account__c == null ) {
                            
                            if( mapRSDIdToNearMatchAccountId.containsKey( rsd.Id )) {
                                
                                rsd.Account__c = mapRSDIdToNearMatchAccountId.get( rsd.id );
                                matchSucceesLog += lineBreak;
                                matchSucceesLog += accountMatchSucessLog;
                                
                            }
                        }
                        
                        Boolean inactiveRepFoundFromPossibleMatch  =  false; 
                        if( rsd.Account__c != null ) {
                            if( possibleRepMatchs != null  
                                && mapAccountIdToAccount != null
                                && mapAccountIdToAccount.get(rsd.Account__c) != null 
                                && possibleRepMatchs.containsKey( mapAccountIdToAccount.get(rsd.Account__c).OwnerId) ) {
                                
                                User userObj = possibleRepMatchs.get(mapAccountIdToAccount.get(rsd.Account__c).OwnerId);
                                inactiveRepFoundFromPossibleMatch = ( !userObj.isActive );
                                if( inactiveRepFoundFromPossibleMatch ) {
                                	repMatchErrorLog = ' Inactive Rep found from Matched Account Onwer. ' 
                                					    + lineBreak + repMatchErrorLog;	
                                }
                                 	
                                rsd.Sales_Rep__c = userObj.Id;
                                
                                matchSucceesLog += lineBreak;
                                matchSucceesLog += ' Rep Matched Found From Matched Account Onwer ';
                            	
                            	Account matchedAccount = mapAccountIdToAccount.get( rsd.Account__c );
                            	if( matchedAccount != null && matchedAccount.Type.equalsIgnoreCase( 'Prospect' )
	                                 || matchedAccount.Type.equalsIgnoreCase('Customer')) {
	                        			system.debug( '***** Error Message Removed ');
	                            		accountMatchErrorLog = ''; 
                                }
                            }
                        }
                        
                        rsd.Error_Log__c += accountMatchErrorLog;
                        system.debug( '***** inactiveRepFoundFromPossibleMatch ' + inactiveRepFoundFromPossibleMatch);
                        if( rsd.Sales_Rep__c == null || inactiveRepFoundFromPossibleMatch ) {
                            rsd.Error_Log__c += repMatchErrorLog;
                        }
                        
                        if( rsd.Plant_Product__c == null ) {
                            rsd.Error_Log__c += plantProductMatchErrorLog;
                        }

                        rsd.Match_Success_Log__c = matchSucceesLog;
                        // when error message exists then set error in processing to true
                        if( rsd.Error_Log__c != null && rsd.Error_Log__c.trim().length() > 0 )  {
                            rsd.Error_In_Processing__c = true;
                        }
                    }
                    rsd.Processed__c = true;
        }

        // Update Raw_Sales_Data__c
        if( recordsToProcessAll.size() > 0 ) {
            update recordsToProcessAll;
        }
        
    }

    /**
    * @description : Method to Populate Account using Admin Forced Account
    */
    private Raw_Sales_Data__c populateUsingAdminForceMatch( Raw_Sales_Data__c rsd ) {
    
        if( rsd.Admin_Forced_Account_Match__c != null ) {
            rsd.Account__c = rsd.Admin_Forced_Account_Match__c;
            rsd.Sales_Rep__c = rsd.Admin_Forced_Account_Match__r.OwnerId;
            matchSucceesLog += lineBreak;
            matchSucceesLog += ' Admin Forced Account ';
        }
        
        if( rsd.Admin_Forced_Plant_Product_Match__c != null ) {
            rsd.Plant_Product__c = rsd.Admin_Forced_Plant_Product_Match__c;
            matchSucceesLog += lineBreak;
            matchSucceesLog += ' Admin Forced Plant Product ';
        }
        return rsd;
    }
    
	/**
    * @description : Method to check for the owner match
    */
    private Boolean ownerMatch( Id accId, Id repId ) {
        // when owner matches return true
        Boolean ownerMatched = ( repId == null ? false : mapAccountIdToAccount.get(accId).OwnerId == repId );
        return ownerMatched;
    }

    /**
    * @description : Method to Populate Account using People Soft Acount number
    */
    private Raw_Sales_Data__c populateUsingPeopleSoftAccountNumber( Raw_Sales_Data__c rsd,
                                                                    Map<String, Map<Id, Account>> mapPeopleSoftAccountNumberToMapAccounts,
                                                                    Boolean fromMapping ) {

        Boolean hasError = false;
        String errorMessage = '';
        if( rsd.Account__c == null && rsd.Billing_Account_Number__c != null && rsd.Billing_Account_Number__c.trim() != '') {

            errorMessage += lineBreak;
            errorMessage += fromMapping ?  ' Account Number ( People Soft ) Match From Mapping - ' : ' Account Number ( People Soft ) Match - ';
            String accNumberAsKey = rsd.Billing_Account_Number__c.trim();
            if( mapPeopleSoftAccountNumberToMapAccounts.containsKey(accNumberAsKey)) {

                List<Account> listMatchedAccounts = mapPeopleSoftAccountNumberToMapAccounts.get(accNumberAsKey).values();
                List<Account> matchedAccountsWithOwnerMatch = new List<Account>();
                for( Account acc : listMatchedAccounts ) {
                    if( ownerMatch( acc.Id, rsd.Sales_Rep__c )) {
                        matchedAccountsWithOwnerMatch.add(acc);
                    }
                }
                
                String successMessage = fromMapping ? ' Account matched from Mapping - ' : ' Account matched from Database Search - ';
            	successMessage += 'Billing Account Number ( People Soft )';
                        
                if( matchedAccountsWithOwnerMatch.size() > 0 ) {
                    if( matchedAccountsWithOwnerMatch.size() == 1 ) {
                        
                        Account matchedAccount = matchedAccountsWithOwnerMatch.get(0);
                        Id accountId = matchedAccount.Id;
                        
                        if( matchedAccount.Type != null 
                            && ( matchedAccount.Type.equalsIgnoreCase( 'Prospect' )
                                 || matchedAccount.Type.equalsIgnoreCase('Customer') )) {
                                
                                rsd.Account__c = accountId;
                                matchSucceesLog += lineBreak;
                                matchSucceesLog += successMessage;
                                accountMatchErrorLog = '';
                        }
                        else {
                        	    if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
                        	    	mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
                        	    	accountMatchSucessLog = successMessage;
                        	    }
                        		hasError = true;
                                errorMessage += 'Account match found with Id "' + accountId + '" but type not Customer or Prospect.';
                        }
                    }
                    else {
                    	hasError = true;
                        errorMessage += 'Multiple account matched with owner match.';
                    }
                }
                else {
                    if( listMatchedAccounts.size() ==  1 ){
                        Id accountId = listMatchedAccounts.get(0).Id;
                        if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
                	    	mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
                	    	accountMatchSucessLog = successMessage;
                	    }
                        
                        hasError = true;
                        errorMessage += getAccountMatchWhenAccountMatchWithoutOwnerMatch( accountId );    
                    }
                    else {
                    	hasError = true;
                        errorMessage += 'Multiple Account match found but owner ( active user ) did not match in any one.';
                    }
                }

            }
            else {
	            	hasError = true;
	                errorMessage += System.label.No_Account_Match_Found;
            }
        }

        accountMatchErrorLog += ( hasError ? errorMessage :  '' );
        return rsd;
    }
        
    /**
    * @description : Method to Populate Account using Acount number match
    */
    private Raw_Sales_Data__c populateUsingAccountNumber( Raw_Sales_Data__c rsd,
                                                          Map<String, Map<Id, Account>> mapAccountNumberToMapAccounts,
                                                          Boolean fromMapping ) {

        String errorMessage = '';
        Boolean hasError = false;
        if( rsd.Account__c == null && rsd.Billing_Account_Number__c != null && rsd.Billing_Account_Number__c.trim() != '') {
			
            errorMessage += lineBreak;
            errorMessage += fromMapping ?  ' Account Number Match From Mapping - ' : ' Account Number Match - ';
            String accNumberAsKey = rsd.Billing_Account_Number__c.trim();
            if( mapAccountNumberToMapAccounts.containsKey(accNumberAsKey)) {

                List<Account> listMatchedAccounts = mapAccountNumberToMapAccounts.get(accNumberAsKey).values();
                List<Account> matchedAccountsWithOwnerMatch = new List<Account>();
                for( Account acc : listMatchedAccounts ) {
                    if( ownerMatch( acc.Id, rsd.Sales_Rep__c )) {
                        matchedAccountsWithOwnerMatch.add(acc);
                    }
                }
                
                String successMessage = fromMapping ? ' Account matched from Mapping - ' : ' Account matched from Database Search - ';
                successMessage += 'Billing Account Number';
                if( matchedAccountsWithOwnerMatch.size() > 0 ) {
                    if( matchedAccountsWithOwnerMatch.size() == 1 ) {
                        
                        Account matchedAccount = matchedAccountsWithOwnerMatch.get(0);
                        Id accountId = matchedAccount.Id;
                        if( matchedAccount.Type != null 
                            && ( matchedAccount.Type.equalsIgnoreCase( 'Prospect' )
                                 || matchedAccount.Type.equalsIgnoreCase('Customer') )) {
                                
                                rsd.Account__c = accountId;
                                matchSucceesLog += lineBreak;
                                matchSucceesLog += successMessage;
                                accountMatchErrorLog = '';
                        }
                        else {
                        		if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
                        	    	mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
                        	    	accountMatchSucessLog = successMessage;
                        	    }
                                hasError = true;
                                errorMessage += 'Account match found with Id "' + accountId + '" but type not Customer or Prospect.';
                        }
                    }
                    else {
                    	hasError = true;
                        errorMessage += 'Multiple account matched with owner match.';
                    }
                }
                else {
                    if( listMatchedAccounts.size() ==  1 ){
                    	
                        Id accountId = listMatchedAccounts.get(0).Id;
                        if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
                	    	mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
                	    	accountMatchSucessLog = successMessage;
                	    }
                        hasError = true;
                    	errorMessage += getAccountMatchWhenAccountMatchWithoutOwnerMatch( accountId );
                    }
                    else {
                    	hasError = true;
                        errorMessage += 'Multiple Account match found but owner ( active user ) did not match in any one.';
                    }
                }

            }
            else {
	            	hasError = true;
	                errorMessage += System.label.No_Account_Match_Found;
            }
        }

        accountMatchErrorLog += ( hasError ? errorMessage : '' );
        return rsd;
    }

	/**
    * @description : Method to get Error Message for Account Match When Owner Does not match or Inactive 
    */
	private string getAccountMatchWhenAccountMatchWithoutOwnerMatch( Id accountId ) {
		
		String errorMessageWhenAccountMatchWithoutOwnerMatch = '';
		Id accountOwnerId = mapAccountIdToAccount.containsKey(accountId) != null ? mapAccountIdToAccount.get(accountId).OwnerId : null;
        if( accountOwnerId != null && inActiveRepMatchIds.contains( accountOwnerId )) {
        	errorMessageWhenAccountMatchWithoutOwnerMatch = 'Account match found with Id "' + accountId + '" but owner is Inactive.';
        }
        else {
        	errorMessageWhenAccountMatchWithoutOwnerMatch = 'Account match found with Id "' + accountId + '" but owner did not match.';
        }
        return errorMessageWhenAccountMatchWithoutOwnerMatch;   
	}
	
    /**
    * @description : Method to check if raw sales data is related to unit with People Soft Acct Number 
    */
    private Boolean checkFromPeopleSoftAcctNumber( Raw_Sales_Data__c rsdObj ) {
        	system.debug( ' ***** Billing System ' + rsdObj.Billing_System__c );
            if( rsdObj.Billing_System__c != null ) {
                
                Set<String> unitsWithPeopleSoftAcctNumber = new Set<String> { 'acclaim',
                                                                               'express labels',
                                                                               'dLI',
                                                                               'lancer',
                                                                               'lightning labels' 
                                                                               };
                                                                                                                        
                String unitName = rsdObj.Billing_System__c.trim().toLowerCase();
                system.debug( ' ***** Billing System unitName ' + unitName );
                system.debug( ' ***** selected BU ' + selectedBusinessUnit.toLowerCase().trim() );
                if(  unitsWithPeopleSoftAcctNumber.contains( unitName ) 
                	|| unitsWithPeopleSoftAcctNumber.contains( selectedBusinessUnit.toLowerCase().trim() )) {
                    return true;
                }
            }
            return false;
    }
    
    /**
    * @description : Method to Populate Account using Cenveo Finance Information
    */
    private Raw_Sales_Data__c populateAccountCenveoFinanceInformation( Raw_Sales_Data__c rsd,
                                                                       Map<String, Map<Id, Account>> mapCFIAccountNumberToMapOfAccounts ) {

		Boolean hasError = false;	
        String errorMessage = '';
        if(rsd.Account__c == null && rsd.Billing_Account_Number__c != null && rsd.Billing_Account_Number__c.trim() != '' ) {

            errorMessage += lineBreak;
            errorMessage += ' Account Number CenveoFinanceInformation Match - ';

            String accNumberAsKey = rsd.Billing_Account_Number__c.trim();
            if(mapCFIAccountNumberToMapOfAccounts.containsKey(accNumberAsKey)) {
                
                List<Account> listMatchedAccounts = mapCFIAccountNumberToMapOfAccounts.get(accNumberAsKey).values();
                List<Account> matchedAccountsWithOwnerMatch = new List<Account>();
                for( Account acc : listMatchedAccounts ) {
                    if( ownerMatch( acc.Id, rsd.Sales_Rep__c )) {
                        matchedAccountsWithOwnerMatch.add(acc);
                    }
                }
                
                String successMessage = 'Account Matched From CenveoFinanceInformation Account Number';
                if( matchedAccountsWithOwnerMatch.size() > 0 ) {
                    if( matchedAccountsWithOwnerMatch.size() == 1 ) {
                        
                        Account matchedAccount = matchedAccountsWithOwnerMatch.get(0);
                        Id accountId = matchedAccountsWithOwnerMatch.get(0).Id;
                        if( matchedAccount.Type != null 
                            && ( matchedAccount.Type.equalsIgnoreCase( 'Prospect' )
                                 || matchedAccount.Type.equalsIgnoreCase('Customer') )) {
                                
                                rsd.Account__c = accountId;
                                matchSucceesLog += lineBreak;
                                matchSucceesLog += successMessage;
                                accountMatchErrorLog = '';
                        }
                        else {
                            if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
                    	    	mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
                    	    	accountMatchSucessLog = successMessage;
                    	    }
                            hasError = true;
                            errorMessage += 'Account match found with Id "' + accountId + '" but type not Customer or Prospect.';
                        }
                    }
                    else {
                    	hasError = true;
                        errorMessage += 'Multiple account matched with owner match.';
                    }
                }
                else {
                    if( listMatchedAccounts.size() ==  1 ){
                        Id accountId = listMatchedAccounts.get(0).Id;
                        if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
                	    	mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
                	    	accountMatchSucessLog = successMessage;
                	    }
                        hasError = true;
                        errorMessage += getAccountMatchWhenAccountMatchWithoutOwnerMatch( accountId );    
                    }
                    else {
                    	hasError = true;
                        errorMessage += 'Multiple Account match found but owner ( active user ) did not match in any one.';
                    }
                }
               
            } 
            else {
            	hasError = true;
                errorMessage += System.label.No_Account_Match_Found;
            }
        }

        accountMatchErrorLog += ( hasError ? errorMessage : '' );
        return rsd;
    }

    /**
    * @description : Method to Populate Account using Acount name
    */
    private Raw_Sales_Data__c populateUsingAccountName( Raw_Sales_Data__c rsd, Map<String,
                                                        Map<Id, Account>> mapAccountNameToMapOfAccounts,
                                                        Boolean fromMapping ) {
        Boolean hasError = false;
        String errorMessage = '';
        if( rsd.Account__c == null
            && rsd.Account_Name__c != null && rsd.Account_Name__c .trim() != '' ) {

            errorMessage += lineBreak;
            errorMessage += fromMapping ? ' Account Name Match From Mapping - ' : ' Account Name Match From Database Search - ';
            
            String accNameAsKey = rsd.Account_Name__c.trim().toLowerCase();
            if(mapAccountNameToMapOfAccounts.containsKey(accNameAsKey)) {
                    
                    List<Account> listMatchedAccounts = new List<Account>(); 
                    if( fromMapping ) {
                    	listMatchedAccounts = mapAccountNameToMapOfAccounts.get(accNameAsKey).values();
                    }
                    else {
		                    for( Account accMatched : mapAccountNameToMapOfAccounts.get(accNameAsKey).values() ) {
		                    	// when account not having billing account number
		                    	if( accMatched.Billing_Account_Number__c == null ) {
		                    		listMatchedAccounts.add( accMatched );
		                    	}
		                    }
                    }
                    
                    List<Account> matchedAccountsWithOwnerMatch = new List<Account>();
                    for( Account acc : listMatchedAccounts ) {
                        if( ownerMatch( acc.Id, rsd.Sales_Rep__c )) {
                    		matchedAccountsWithOwnerMatch.add(acc);
                        }
                    }
                    String successMessage = fromMapping ? ' Account matched from Mapping - ' : ' Account matched from Database Search - ';
                    if( matchedAccountsWithOwnerMatch.size() > 0 ) {
                        if( matchedAccountsWithOwnerMatch.size() == 1 ) {
                          Account matchedAccount = matchedAccountsWithOwnerMatch.get(0);
                          Id accountId = matchedAccountsWithOwnerMatch.get(0).Id;
                          if( matchedAccount.Type != null 
                              && ( matchedAccount.Type.equalsIgnoreCase( 'Prospect' )
                                 || matchedAccount.Type.equalsIgnoreCase('Customer') )) {
                        
                                    rsd.Account__c = accountId;
                                    matchSucceesLog += lineBreak;
                                    matchSucceesLog += successMessage;
                                    accountMatchErrorLog = '';
                            }
                            else {
                            	  if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
	                        	       mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
	                        	       accountMatchSucessLog = successMessage;
	                        	  }	
                                  hasError = true;
                                  errorMessage += 'Account match found with Id "' + accountId + '" but type not Customer or Prospect.';
                            }
                        }
                        else {
                        	hasError = true;
                            errorMessage += 'Multiple account matched with owner match.';
                        }
                    }
                    else {
                    	hasError = true;
                    	if( listMatchedAccounts.size() ==  1 ){
                    		Id accountId = listMatchedAccounts.get(0).Id;
                    		if( !mapRSDIdToNearMatchAccountId.containsKey(rsd.Id) ) {
                    	    	mapRSDIdToNearMatchAccountId.put( rsd.Id, accountId );
                    	    	accountMatchSucessLog = successMessage;
                    	    }
	                        errorMessage += getAccountMatchWhenAccountMatchWithoutOwnerMatch( accountId );    
	                    }
	                    else if( listMatchedAccounts.size() >  1 ) {
	                    	errorMessage += 'Multiple Account match found but owner ( active user ) did not match in any one.';
	                    }
	                    else {
	                    		errorMessage += 'No account match found or the matched account has Billing Account Number.';
	                    }
                    }
    
            }
            else {
            	hasError = true;
                errorMessage += System.label.No_Account_Match_Found;
            }
        }

        accountMatchErrorLog += ( hasError ? errorMessage : '' );
        return rsd;
    }

    private String lineBreak = '\r\n\r\n';
    /**
    * @description : Method to Populate Account using Sales_Rep__c name
    */
    private Raw_Sales_Data__c populateSalesRep( Raw_Sales_Data__c rsd, Map<String, Map<Id, User>> mapNameOfUserToListUsers, Boolean fromMapping ) {

        User matchedUser;
        String errorMessage = '';
        //User name
        if(rsd.Rep_Name__c != null && rsd.Rep_Name__c.trim() != '' ){
            String mapKeyRepName = rsd.Rep_Name__c.trim().toLowerCase();
            repMatchErrorLog += lineBreak;
            repMatchErrorLog += fromMapping ? ' Rep Match From Mapping - ' : ' Rep Match From Database Search - ';
			
            if(mapNameOfUserToListUsers.containsKey(mapKeyRepName)
                && mapNameOfUserToListUsers.get(mapKeyRepName).size() == 1) {
                matchedUser = mapNameOfUserToListUsers.get(mapKeyRepName).values().get(0);
                if(matchedUser.IsActive) {
                    rsd.Sales_Rep__c = matchedUser.Id;
                    rsd.Manager__c = matchedUser.ManagerId;
                    matchSucceesLog += lineBreak;
                    matchSucceesLog += fromMapping ? ' Rep Matched From Mapping ' : ' Rep Match From Database Search - ';
                }
                else {
                	inActiveRepMatchIds.add(matchedUser.Id);
                    errorMessage += System.label.Sales_Rep_is_InActive;
                }
            }
            else {
            		
                    if( mapNameOfUserToListUsers.containsKey(mapKeyRepName) ) {
                        
                        possibleRepMatchs = possibleRepMatchs == null ? new Map<Id, User>() : possibleRepMatchs;
                    	Map<Id, User> mapPossibleMatch = mapNameOfUserToListUsers.get(mapKeyRepName);
                    	if( mapPossibleMatch != null && mapPossibleMatch.size() > 0 ) {
                    		possibleRepMatchs.putAll( mapPossibleMatch );
                    	}
                    }
                    errorMessage += (mapNameOfUserToListUsers.containsKey(mapKeyRepName) ? System.label.Multiple_Rep_Match_Found : System.label.No_Rep_Match_Found);
                    system.debug( ' errorMessage : ' + errorMessage );
            }
        }
		
        repMatchErrorLog += errorMessage;
        return rsd;
    }

    /**
    * @description : Method to Populate Plant Product using Plant Product name
    */
    private Raw_Sales_Data__c populatePlantName( Raw_Sales_Data__c rsd,
                                                 Map<String, Map<Id, Plant_Products__c>> plantProductNameToMapOfPlantProductName,
                                                 Boolean fromMapping ) {

        String errorMessage = '';
        //Plant name
        if(rsd.Plant_Product__c == null && rsd.Plant_Name__c != null && rsd.Plant_Name__c.trim() != ''){
            plantProductMatchErrorLog += lineBreak;
            plantProductMatchErrorLog += fromMapping ? ' Plant Product Match From Mapping - ' : ' Plant Product Match From Database Search - ';

            String mapKeyPlantName = rsd.Plant_Name__c.trim().toLowerCase();
            if( plantProductNameToMapOfPlantProductName.containsKey(mapKeyPlantName)
                && plantProductNameToMapOfPlantProductName.get(mapKeyPlantName).size() == 1) {
                rsd.Plant_Product__c = plantProductNameToMapOfPlantProductName.get(mapKeyPlantName).values().get(0).Id;
                matchSucceesLog += lineBreak;
                matchSucceesLog += fromMapping ? ' Plant Product Match From Mapping ' : ' Plant Product Match From Database Search - ';
            }
            else {
                errorMessage += (plantProductNameToMapOfPlantProductName.containsKey(mapKeyPlantName) ? System.label.Multiple_Plant_Name_Match_Found : System.label.No_Plant_Name_Match_Found);
            }
        }

        plantProductMatchErrorLog += errorMessage;
        return rsd;
    }
    
	/**
    * @description : Mthod to set the collection for Billing Account Number match from Cenveo Finance Infomration 
    */
    private Map<String, Map<Id, Account>> getFinanceInfomrationMap( Finance_Information__c fi, String fieldAPINameAccountNumber,
                                                                    Map<String, Map<Id, Account>> mapCFIAccountNumberToMapOfAccounts ) {

         Object fieldValue = fi.get( fieldAPINameAccountNumber );
         if( fieldValue != null ){
            String mapKey = String.valueOf( fieldValue );
            Map<Id, Account> mapAccounts = new Map<Id, Account>();
            if( mapCFIAccountNumberToMapOfAccounts.containsKey(mapKey) ) {
                mapAccounts = mapCFIAccountNumberToMapOfAccounts.get(mapKey);
            }
            Account acc = new Account( Id = fi.Account__c, Name = fi.Account__r.Name,
                                       OwnerId  = fi.Account__r.OwnerId,
                                       Type = fi.Account__r.Type );
             
            mapAccountIdToAccount.put( acc.Id, acc );
            mapAccounts.put( acc.Id , acc );
            mapCFIAccountNumberToMapOfAccounts.put( mapKey, mapAccounts);
         }
         return mapCFIAccountNumberToMapOfAccounts;
    }
    
    /**
    * @description : Method to search Account from Billing Account Number from Cenveo Finance Information
    */
    public void fillMapFinanceInformation(set<string> accountNumbers){

        mapCFIAccountNumberToMapOfAccounts = new Map<String, Map<Id, Account>>();
        mapPeopleSoftCFIAccountNumberToMapOfAccounts = new Map<String, Map<Id, Account>>();
        
        for(Finance_Information__c fi : [Select   Account__c, 
        										  Account__r.PeopleSoft_Acct__c,	
                                                  Account__r.Name, Account__r.OwnerId,
                                                  Account__r.Type
                                                , Account_Number__c /*,Account_Number_2__c
                                                , Account_Number_3__c, Account_Number_4__c
                                                , Account_Number_5__c, Account_Number_6__c
                                                , Account_Number_7__c, Account_Number_8__c
                                                , Account_Number_9__c, Account_Number_10__c
                                                , Account_Number_11__c, Account_Number_12__c, Account_Number_13__c, Account_Number_14__c, Account_Number_15__c, Account_Number_16__c, Account_Number_17__c, Account_Number_18__c, Account_Number_19__c, Account_Number_20__c, Account_Number_21__c, Account_Number_22__c, Account_Number_23__c, Account_Number_24__c, Account_Number_25__c, Account_Number_26__c, Account_Number_27__c, Account_Number_28__c, Account_Number_29__c, Account_Number_30__c, Account_Number_31__c, Account_Number_32__c, Account_Number_33__c, Account_Number_34__c, Account_Number_35__c, Account_Number_36__c, Account_Number_37__c, Account_Number_38__c, Account_Number_39__c, Account_Number_40__c, Account_Number_41__c, Account_Number_42__c, Account_Number_43__c, Account_Number_44__c, Account_Number_45__c, Account_Number_46__c, Account_Number_47__c, Account_Number_48__c, Account_Number_49__c, Account_Number_50__c, Account_Number_51__c, Account_Number_52__c, Account_Number_53__c, Account_Number_54__c, Account_Number_55__c, Account_Number_56__c, Account_Number_57__c, Account_Number_58__c, Account_Number_59__c, Account_Number_60__c, Account_Number_61__c, Account_Number_62__c, Account_Number_63__c, Account_Number_64__c, Account_Number_65__c, Account_Number_66__c, Account_Number_67__c, Account_Number_68__c, Account_Number_69__c, Account_Number_70__c, Account_Number_71__c, Account_Number_72__c, Account_Number_73__c, Account_Number_74__c, Account_Number_75__c, Account_Number_76__c, Account_Number_77__c, Account_Number_78__c, Account_Number_79__c, Account_Number_80__c, Account_Number_81__c, Account_Number_82__c, Account_Number_83__c, Account_Number_84__c, Account_Number_85__c, Account_Number_86__c, Account_Number_87__c, Account_Number_88__c, Account_Number_89__c, Account_Number_90__c, Account_Number_91__c, Account_Number_92__c, Account_Number_93__c, Account_Number_94__c, Account_Number_95__c, Account_Number_96__c, Account_Number_97__c, Account_Number_98__c, Account_Number_99__c, Account_Number_100__c, Account_Number_101__c
                                         */From Finance_Information__c
                                         Where Account__c != null AND (Account_Number__c IN : accountNumbers /*OR Account_Number_2__c IN : accountNumbers OR Account_Number_3__c IN : accountNumbers OR Account_Number_4__c IN : accountNumbers OR Account_Number_5__c IN : accountNumbers OR Account_Number_6__c IN : accountNumbers OR Account_Number_7__c IN : accountNumbers OR Account_Number_8__c IN : accountNumbers OR Account_Number_9__c IN : accountNumbers OR Account_Number_10__c IN : accountNumbers OR Account_Number_11__c IN : accountNumbers OR Account_Number_12__c IN : accountNumbers OR Account_Number_13__c IN : accountNumbers OR Account_Number_14__c IN : accountNumbers OR Account_Number_15__c IN : accountNumbers OR Account_Number_16__c IN : accountNumbers OR Account_Number_17__c IN : accountNumbers OR Account_Number_18__c IN : accountNumbers OR Account_Number_19__c IN : accountNumbers OR Account_Number_20__c IN : accountNumbers OR Account_Number_21__c IN : accountNumbers OR Account_Number_22__c IN : accountNumbers
                                                                                                              *  OR Account_Number_23__c IN : accountNumbers OR Account_Number_24__c IN : accountNumbers OR Account_Number_25__c IN : accountNumbers OR Account_Number_26__c IN : accountNumbers OR Account_Number_27__c IN : accountNumbers OR Account_Number_28__c IN : accountNumbers OR Account_Number_29__c IN : accountNumbers OR Account_Number_30__c IN : accountNumbers OR Account_Number_31__c IN : accountNumbers OR Account_Number_32__c IN : accountNumbers OR Account_Number_33__c IN : accountNumbers OR Account_Number_34__c IN : accountNumbers OR Account_Number_35__c IN : accountNumbers OR Account_Number_36__c IN : accountNumbers OR Account_Number_37__c IN : accountNumbers OR Account_Number_38__c IN : accountNumbers OR Account_Number_39__c IN : accountNumbers OR Account_Number_40__c IN : accountNumbers OR Account_Number_41__c IN : accountNumbers OR Account_Number_42__c IN : accountNumbers OR Account_Number_43__c IN : accountNumbers
                                                                                                              *  OR Account_Number_44__c IN : accountNumbers OR Account_Number_45__c IN : accountNumbers OR Account_Number_46__c IN : accountNumbers OR Account_Number_47__c IN : accountNumbers OR Account_Number_48__c IN : accountNumbers OR Account_Number_49__c IN : accountNumbers OR Account_Number_50__c IN : accountNumbers OR Account_Number_51__c IN : accountNumbers OR Account_Number_52__c IN : accountNumbers OR Account_Number_53__c IN : accountNumbers OR Account_Number_54__c IN : accountNumbers OR Account_Number_55__c IN : accountNumbers OR Account_Number_56__c IN : accountNumbers OR Account_Number_57__c IN : accountNumbers OR Account_Number_58__c IN : accountNumbers OR Account_Number_59__c IN : accountNumbers OR Account_Number_60__c IN : accountNumbers OR Account_Number_61__c IN : accountNumbers OR Account_Number_62__c IN : accountNumbers OR Account_Number_63__c IN : accountNumbers OR Account_Number_64__c IN : accountNumbers
                                                                                                              *  OR Account_Number_65__c IN : accountNumbers OR Account_Number_66__c IN : accountNumbers OR Account_Number_67__c IN : accountNumbers OR Account_Number_68__c IN : accountNumbers OR Account_Number_69__c IN : accountNumbers OR Account_Number_70__c IN : accountNumbers OR Account_Number_71__c IN : accountNumbers OR Account_Number_72__c IN : accountNumbers OR Account_Number_73__c IN : accountNumbers OR Account_Number_74__c IN : accountNumbers OR Account_Number_75__c IN : accountNumbers OR Account_Number_76__c IN : accountNumbers OR Account_Number_77__c IN : accountNumbers OR Account_Number_78__c IN : accountNumbers OR Account_Number_79__c IN : accountNumbers OR Account_Number_80__c IN : accountNumbers OR Account_Number_81__c IN : accountNumbers OR Account_Number_82__c IN : accountNumbers OR Account_Number_83__c IN : accountNumbers OR Account_Number_84__c IN : accountNumbers OR Account_Number_85__c IN : accountNumbers
                                                                                                              *  OR Account_Number_86__c IN : accountNumbers OR Account_Number_87__c IN : accountNumbers OR Account_Number_88__c IN : accountNumbers OR Account_Number_89__c IN : accountNumbers OR Account_Number_90__c IN : accountNumbers OR Account_Number_91__c IN : accountNumbers OR Account_Number_92__c IN : accountNumbers OR Account_Number_93__c IN : accountNumbers OR Account_Number_94__c IN : accountNumbers OR Account_Number_95__c IN : accountNumbers OR Account_Number_96__c IN : accountNumbers OR Account_Number_97__c IN : accountNumbers OR Account_Number_98__c IN : accountNumbers OR Account_Number_99__c IN : accountNumbers OR Account_Number_100__c IN : accountNumbers OR Account_Number_101__c IN : accountNumbers*/)]){
			
			
			if( fi.Account__r.PeopleSoft_Acct__c == null ) {
	            mapCFIAccountNumberToMapOfAccounts = getFinanceInfomrationMap( fi, 'Account_Number__c', mapCFIAccountNumberToMapOfAccounts );
	            for( Integer i = 2; i <= 101; i++ ) {
	                String fieldAPINameAccountNumber = 'Account_Number_' + i.format() + '__c';
	                mapCFIAccountNumberToMapOfAccounts = getFinanceInfomrationMap( fi, fieldAPINameAccountNumber, mapCFIAccountNumberToMapOfAccounts );
	            }
			}
			else {
				mapPeopleSoftCFIAccountNumberToMapOfAccounts = getFinanceInfomrationMap( fi, 'Account_Number__c', mapPeopleSoftCFIAccountNumberToMapOfAccounts );
	            for( Integer i = 2; i <= 101; i++ ) {
	                String fieldAPINameAccountNumber = 'Account_Number_' + i.format() + '__c';
	                mapPeopleSoftCFIAccountNumberToMapOfAccounts = getFinanceInfomrationMap( fi, fieldAPINameAccountNumber, mapPeopleSoftCFIAccountNumberToMapOfAccounts );
	            }
			}
        }
    }

    /**
    * @description : Method to process records and create sales data
    */
    public void moveToSalesData(){

        if( selectedBusinessUnit != null
            && selectedBusinessUnit.trim() != ''
            && selectedBusinessUnit.trim() != '--None--' ){

            isMoveSalesData = true;
            process();

            map<string, Sales_Data__c> mapSalesData = new map<string, Sales_Data__c>();
            list<Raw_Sales_Data__c> listRaw_Sales_Data = new list<Raw_Sales_Data__c>();
            for(Raw_Sales_Data__c rsd : [SELECT Moved_to_Sales_Data__c, Match_Success_Log__c, Billing_System__c, 
                                         Billing_Account_Number__c, Sales_Rep__c , Actual_Unit__c, 
                                         Plant_Product__c, Account__c, Account_Name__c, Plant_Name__c, 
                                         Rep_Name__c, OwnerId, Manager__c, Actual__c, GMDollars__c, GM__c,
                                         Budget__c , Forecast__c,Margin_Sales_Dollars__c, Period__c, 
                                         Period_End_Date__c,  Year__c, Sales_Data__c, 
                                         Buyout_Resale_Budget_Sales__c,
                                         Buyout_Resale_Budget_Units__c,
                                         Manufactured_Budget_Sales__c,
                                         Manufactured_Budget_Units__c,
                                         Buyout_Resale_Actual_Sales__c,
                                         Buyout_Resale_Actual_Units__c,
                                         ENV_1st_Pass_Budget_Amount__c,
                                         ENV_1st_Pass_Budget_Units__c,
                                         Manufactured_Actual_Sales__c,
                                         Manufactured_Actual_Units__c,
                                         Account__r.Name,  
                                         Sales_Rep__r.Name, Plant_Product__r.Name, Manager__r.Name
                            FROM Raw_Sales_Data__c
                            WHERE Processed__c = true
                            AND Error_In_Processing__c =: FALSE
                            AND Billing_System__c =: selectedBusinessUnit
                            AND Year__c =: rawSalesData.Year__c 
                            AND Period__c =: mapMonths.get(selectedMonth) 
                            AND Moved_to_Sales_Data__c = null LIMIT : withoutErrorRecordlimits ]){
                if(rsd.Moved_to_Sales_Data__c == null)
                    if( rsd.Account__c != null ) {
                        listRaw_Sales_Data.add( rsd );
                        mapSalesData.put(rsd.id, new Sales_Data__c( Account__c = rsd.Account__c,
                                                                    Actual_Amount__c = rsd.Actual__c,
                                                                    Actual_Units__c = rsd.Actual_Unit__c != null ? decimal.valueof(rsd.Actual_Unit__c  )  : null,
                                                                    Billing_Account_Number__c = rsd.Billing_Account_Number__c,
                                                                    Budget_Amount__c = rsd.Budget__c,
                                                                    //Actual_Forecast__c = rsd.Forecast__c,
                                                                    GMDollars__c = rsd.GMDollars__c,
                                                                    GM__c = ( rsd.GM__c != null ? ( rsd.GM__c * 100 ) : rsd.GM__c ),
                                                                    Margin_Sales_Dollars__c = rsd.Margin_Sales_Dollars__c !=  null ? rsd.Margin_Sales_Dollars__c : rsd.Actual__c,
                                                                    Manager__c = rsd.Manager__r.Name,
                                                                    Period__c = Integer.valueOf(rsd.Period__c),
                                                                    Period_End_Date__c = rsd.Period_End_Date__c,
                                                                    Plant_Product__c = rsd.Plant_Product__c,
                                                                    Year__c = rsd.Year__c,
                                                                    Historical_Owner__c = rsd.Sales_Rep__c,
                                                                    OwnerId = rsd.Sales_Rep__c,
                                                                    ENV_Buyout_Resale_Budget_Sales__c = rsd.Buyout_Resale_Budget_Sales__c,
                                                                    ENV_Buyout_Resale_Budget_Units__c = rsd.Buyout_Resale_Budget_Units__c,
                                                                    ENV_Manufactured_Budget_Sales__c = rsd.Manufactured_Budget_Sales__c,
                                                                    ENV_Manufactured_Budget_Units__c = rsd.Manufactured_Budget_Units__c,
                                                                    ENV_Buyout_Resale_Actual_Sales__c = rsd.Buyout_Resale_Actual_Sales__c,
                                                                    ENV_Buyout_Resale_Actual_Units__c = rsd.Buyout_Resale_Actual_Units__c,
                                                                    ENV_Manufactured_Actual_Sales__c = rsd.Manufactured_Actual_Sales__c,
                                                                    ENV_Manufactured_Actual_Units__c = rsd.Manufactured_Actual_Units__c,
                                                                    ENV_1st_Pass_Budget_Amount__c = rsd.ENV_1st_Pass_Budget_Amount__c,  
                                                                    ENV_1st_Pass_Budget_Units__c = rsd.ENV_1st_Pass_Budget_Amount__c
                                                                  
                                                                  ));
                }
            }

            if(mapSalesData.size() > 0) {
                // When Result Have Error then Add Error Message To corresponding RSD record
                // Error Message should Start as : ' Error in Move to Sales Data - ' + Then Append Reason for Error
                Map<Id, Sales_Data__c> successfullySaved = new Map<Id, Sales_Data__c>();
                Database.SaveResult[] saveResults = Database.insert( mapSalesData.values(), false );
                Integer i = 0;
                list<Raw_Sales_Data__c> listRawSalesDataToUpdate = new list<Raw_Sales_Data__c>();
                for( Database.SaveResult sr : saveResults ) {
                    Raw_Sales_Data__c rsdToUpdate = listRaw_Sales_Data.get(i);
                    if( sr.isSuccess() ) {
                        rsdToUpdate.Sales_Data__c = sr.getId();
                        rsdToUpdate.Moved_to_Sales_Data__c = Datetime.now();
                    }
                    else {
                            for( Database.Error err : sr.getErrors()) {
                                rsdToUpdate.Error_Log__c = err.getMessage();
                            }
                    }
                    listRawSalesDataToUpdate.add( rsdToUpdate );
                    i++;
                }

                if(listRawSalesDataToUpdate.size() > 0) {
                    update listRawSalesDataToUpdate;
                }
            }

            refresh();
        }
    }

    /**
    * @description : Method to create saveMapping from the UI
    */
    public void saveMapping(){
        insert nmc;
        nmc = new Name_Mapping_Configuration__c();
    }
    
    //Method to Process records Search
    private set<string> rsdSetProcess = new set<string>();
    public Integer processCount{get; set;} 
    
    /**
    * @description : Method to search the records that are not processed 
    */   
    public void searchresultProcess(){
        recordsToProcess = new list<Raw_Sales_Data__c>();
        
        processCount = [SELECT count()
                        FROM Raw_Sales_Data__c
                        WHERE Processed__c = false
                        AND Billing_System__c =: selectedBusinessUnit
                        AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth) 
                        ];
        
        if(mapRecordProcessMoved.containsKey(pagecounterProcess)){
            isNextProcess = true;
            recordsToProcess.addAll(mapRecordProcessMoved.get(pagecounterProcess));
        }else{
            Integer extraRecordLimits = ProcessRecordlimits + 1;
            isNextProcess = false;
            for(Raw_Sales_Data__c r : [SELECT Match_Success_Log__c, Billing_System__c, Billing_Account_Number__c, Actual_Unit__c, Plant_Product__c,
                                              Sales_Rep__c, Account__c, Account_Name__c, Rep_Name__c, Plant_Name__c, OwnerId, Manager__c, Actual__c,
                                              Error_In_Processing__c,
                                              Error_Log__c,
                                              Processed__c, GMDollars__c, GM__c,
                                              Account__r.Name, Sales_Rep__r.Name, Plant_Product__r.Name, Manager__r.Name
                                       FROM Raw_Sales_Data__c
                                       WHERE ID NOT IN : rsdSetProcess 
                                       AND Processed__c = false
                                       AND Billing_System__c =: selectedBusinessUnit
                                       AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth)
                                       Limit : extraRecordLimits]){
                if(recordsToProcess.size() < ProcessRecordlimits){
                    rsdSetProcess.add(r.Id);
                    recordsToProcess.add(r);
                }else{
                    isNextProcess = true;
                }
            }
            mapRecordProcessMoved.put(pagecounterProcess, recordsToProcess);
        }
    }
    
    /**
    * @description : Method to next Process
    */
    public void nextProcess(){
        pagecounterProcess++;
        searchresultProcess();
    }
    
    /**
    * @description : Method to previous Process
    */
    public void previousProcess(){
        pagecounterProcess--;
        searchresultProcess();
    }
    
    private set<string> rsdSetWithoutError = new set<string>();
    public Integer withoutErrorCount{get; set;}
    /**
    * @description : Method to WithoutError records Search
    */
    public void searchresultWithoutError(){
        recordsWithoutError = new list<Raw_Sales_Data__c>();
        
        withoutErrorCount = [SELECT count()
                                FROM Raw_Sales_Data__c
                                WHERE Processed__c = true
                                AND Error_In_Processing__c =: FALSE
                                AND Billing_System__c =: selectedBusinessUnit
                                AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth) AND Moved_to_Sales_Data__c = null 
                                ];
        
        if(mapRecordWithoutErrorMoved.containsKey(pagecounterWithoutError)){
            isNextWithoutError = true;
            recordsWithoutError.addAll(mapRecordWithoutErrorMoved.get(pagecounterWithoutError));
        }else{
            Integer extraRecordLimits = withoutErrorRecordlimits + 1;
            isNextWithoutError = false;
            for(Raw_Sales_Data__c r : [SELECT Match_Success_Log__c, Billing_System__c, Billing_Account_Number__c, Sales_Rep__c , Actual_Unit__c, Plant_Product__c, Account__c, Account_Name__c, Plant_Name__c, Rep_Name__c, OwnerId, Manager__c, Actual__c, GMDollars__c, GM__c,
                                Budget__c , Forecast__c,Margin_Sales_Dollars__c, Period__c, Period_End_Date__c,  Year__c, Sales_Data__c, Account__r.Name, Sales_Rep__r.Name, Plant_Product__r.Name, Manager__r.Name
                                FROM Raw_Sales_Data__c
                                WHERE ID NOT IN : rsdSetWithoutError 
                                AND Processed__c = true
                                AND Error_In_Processing__c =: FALSE
                                AND Billing_System__c =: selectedBusinessUnit
                                AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth) AND Moved_to_Sales_Data__c = null 
                                Limit : extraRecordLimits]){
                if(recordsWithoutError.size() < withoutErrorRecordlimits ){
                    rsdSetWithoutError.add(r.Id);
                    recordsWithoutError.add(r);
                }else{
                    isNextWithoutError = true;
                }
            }
            mapRecordWithoutErrorMoved.put(pagecounterWithoutError, recordsWithoutError);
        }
    }
    
    /**
    * @description : Method to next WithoutError
    */
    public void nextWithoutError(){
        pagecounterWithoutError++;
        searchresultWithoutError();
    }
    
    /**
    * @description : Method to previous WithoutError
    */
    public void previousWithoutError(){
        pagecounterWithoutError--;
        searchresultWithoutError();
    } 
    
    private set<string> rsdSet = new set<string>();
    public Integer successCount{get; set;}
    
    /**
    * @description : Method to successfully records Search
    */
    public void searchresult(){
        recordSuccessfullyMoved = new list<Raw_Sales_Data__c>();
        
        successCount = [SELECT count()
                                FROM Raw_Sales_Data__c
                                WHERE Processed__c = true
                                AND Error_In_Processing__c =: FALSE
                                AND Billing_System__c =: selectedBusinessUnit
                                AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth) 
                                AND Moved_to_Sales_Data__c != null];
        
        if(mapRecordSuccessfullyMoved.containsKey(pagecounter)){
            isNext = true;
            recordSuccessfullyMoved.addAll(mapRecordSuccessfullyMoved.get(pagecounter));
        }else{
            Integer extraRecordLimits = successRecordlimits + 1;
            isNext = false;
            for(Raw_Sales_Data__c r : [SELECT Id, Match_Success_Log__c, Billing_Account_Number__c, Sales_Rep__c , Actual_Unit__c, Plant_Product__c, Account__c, Account_Name__c, Plant_Name__c, Rep_Name__c, OwnerId, Manager__c, Actual__c, GMDollars__c, GM__c,
                                Budget__c , Forecast__c,Margin_Sales_Dollars__c, Period__c, Period_End_Date__c,  Year__c, Sales_Data__c, Account__r.Name, Sales_Rep__r.Name, Plant_Product__r.Name, Manager__r.Name, Sales_Data__r.Name
                                FROM Raw_Sales_Data__c
                                WHERE ID NOT IN : rsdSet 
                                AND Processed__c = true
                                AND Error_In_Processing__c =: FALSE
                                AND Billing_System__c =: selectedBusinessUnit
                                AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth) 
                                AND Moved_to_Sales_Data__c != null limit : extraRecordLimits]){
                if(recordSuccessfullyMoved.size() < successRecordlimits){
                    rsdSet.add(r.Id);
                    recordSuccessfullyMoved.add(r);
                }else{
                    isNext = true;
                }
            }
            mapRecordSuccessfullyMoved.put(pagecounter, recordSuccessfullyMoved);
        }
    }
    
    /**
    * @description : Method to show next
    */
    public void next(){
        pagecounter++;
        searchresult();
    }
    
    /**
    * @description : Method to show previous
    */
    public void previous(){
        pagecounter--;
        searchresult();
    }  
    
    private set<string> rsdSetWithError = new set<string>();
    public Integer withErrorCount{get; set;}
    /**
    * @description : Method to WithError records Search
    */
    public void searchresultWithError(){
        recordsWithError = new list<Raw_Sales_Data__c>();
        
        withErrorCount = [SELECT count()
                                FROM Raw_Sales_Data__c
                                WHERE Processed__c = true
                                AND Error_In_Processing__c =: TRUE
                                And Moved_to_Sales_Data__c =: null
                                AND Billing_System__c =: selectedBusinessUnit
                                AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth)];
        
        if(mapRecordWithErrorMoved.containsKey(pagecounterWithError)){
            isNextWithError = true;
            recordsWithError.addAll(mapRecordWithErrorMoved.get(pagecounterWithError));
        }else{
            Integer extraRecordLimits = withErrorRecordlimits + 1;
            isNextWithError = false;
            for(Raw_Sales_Data__c r : [SELECT Match_Success_Log__c, Billing_Account_Number__c, Actual_Unit__c, Plant_Product__c, Account__c, Sales_Rep__c, Account_Name__c, Plant_Name__c, Rep_Name__c, OwnerId, Manager__c, Actual__c,
                                Error_In_Processing__c,
                                Error_Log__c,
                                GMDollars__c, GM__c,
                                Account__r.Name, Sales_Rep__r.Name, Plant_Product__r.Name, Manager__r.Name
                                FROM Raw_Sales_Data__c
                                WHERE ID NOT IN : rsdSetWithError 
                                AND Processed__c = true
                                AND Error_In_Processing__c =: TRUE
                                And Moved_to_Sales_Data__c =: null
                                AND Billing_System__c =: selectedBusinessUnit
                                AND Year__c =: rawSalesData.Year__c AND Period__c =: mapMonths.get(selectedMonth) 
                                limit : extraRecordLimits]){
                if(recordsWithError.size() < withErrorRecordlimits){
                    rsdSetWithError.add(r.Id);
                    recordsWithError.add(r);
                }else{
                    isNextWithError = true;
                }
            }
            mapRecordWithErrorMoved.put(pagecounterWithError, recordsWithError);
        }
    }
    
    /**
    * @description : Method to show next records for WithError
    */
    public void nextWithError(){
        pagecounterWithError++;
        searchresultWithError();
    }
    
    /**
    * @description : Method to show previous records for WithError
    */
    public void previousWithError(){
        pagecounterWithError--;
        searchresultWithError();
    }   
}