/**
 *  Author/Created By       :   Apex controller class for VFP SearchAccounts
 *
 *  Purpose/Description     :   For fetch records from database and show on page.
 *
 *  Where it is used        :   VF Page :- SearchAccounts.
 *
 *  CreatedDate             :   
 *      
 *  Deprecated              :   
 *
 *  Version                 :   V1.0, V_1.1
 *
 *  UpdatedBy               :   Add logic for lead search, for addition opportunity search function.
 **/
 
public without sharing class SearchAccountsController{
    
    //Variables for Account Search
    public String accountName{get;set;}
    public String phone{get;set;}
    public String website{get;set;}
    public String SF_Acct_ID{get;set;}
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public Account account{get; set;}
    public Account manager{get; set;}
    
    //Variables for lead search
    public Integer pageSize{get;set;}
    public Integer pageNumberLead;
    public List<List<Lead>> listOfLeads{get;set;}
    public Integer totalNoOfLeads{get;set;}
    public Lead lead{get;set;}
    public Integer startLead{get;set;}
    public Integer endLead{get;set;}
    
    //Variables for Opportunity Search
    public Opportunity opp{get;set;}
    public List<Opportunity> opportunities{get;set;}
    
    
    //constructor
    public SearchAccountsController(){
    
        // initialize properties
        accountName = '';
        phone = '';
        website = '';
        account = new Account();
        manager = new Account();
        lead = new Lead();   
        listOfLeads = new List<List<Lead>>();
        pageSize = 20;
        pageNumberLead = 0;
        SF_Acct_ID = '';
        size = 200;
        
        opp = new Opportunity();
        opportunities = new List<Opportunity>();
    }

    // standard controller
    public ApexPages.StandardSetController setCon {

        get{
            try {
                
                //Account list is null
                if(setCon == null){
                    
                    //String to hold where clause
                    string whereClause = '';
                    
                    //Account Name in where clause
                    if(accountName.trim() != ''){
                        String queryName = (accountName.contains('*')? String.escapeSingleQuotes(accountName.replace('*','%')) : '%' + String.escapeSingleQuotes(accountName) + '%');
                        whereClause = ' Name LIKE \'' + queryName + '\'';
                    }
                    
                    //Phone add in where clause
                    if(phone.trim() != ''){
                        String queryphone = '%' + String.escapeSingleQuotes(phone) + '%';
                        whereClause += (whereClause =='' ? ' Phone LIKE \'' + queryphone + '\'' : ' AND Phone LIKE \'' + queryphone + '\'');
                    }
                    
                    //Website add in where clause
                    if(website.trim() != ''){
                        String querywebsite = '%' + String.escapeSingleQuotes(website) + '%';
                        whereClause += (whereClause =='' ? ' Website LIKE \'' + querywebsite + '\'' : ' AND Website LIKE \'' + querywebsite + '\'');
                    }
                    
                    //OwnerId add in where clause
                    if(account.OwnerId != null){
                        whereClause += (whereClause =='' ? ' OwnerId = \'' + account.OwnerId + '\'' : ' AND OwnerId = \'' + account.OwnerId + '\'');
                    }

                    //Manager's owner Id add in where clause of query
                    if(manager.OwnerId != null){
                        whereClause += (whereClause =='' ? ' Owner.ManagerId = \'' + manager.OwnerId + '\'' : ' AND Owner.ManagerId = \'' + manager.OwnerId + '\'');
                    }

                    //Billing Street using in dynamoc query
                    if(account.BillingStreet != null && account.BillingStreet.trim() != ''){
                        String queryAddress = '%' + String.escapeSingleQuotes(account.BillingStreet) + '%';
                        whereClause += (whereClause =='' ? ' BillingStreet LIKE \'' + queryAddress + '\'' : ' AND BillingStreet LIKE \'' + queryAddress + '\'');
                    }
                    
                    //Billing city
                    if(account.BillingCity != null && account.BillingCity.trim() != ''){
                        String queryAddress = '%' + String.escapeSingleQuotes(account.BillingCity) + '%';
                        whereClause += (whereClause =='' ? ' BillingCity LIKE \'' + queryAddress + '\'' : ' AND BillingCity LIKE \'' + queryAddress + '\'');
                    }
                    
                    //Billing State
                    if(account.BillingState != null && account.BillingState.trim() != ''){
                        String queryAddress = '%' + String.escapeSingleQuotes(account.BillingState) + '%';
                        whereClause += (whereClause =='' ? ' BillingState LIKE \'' + queryAddress + '\'' : ' AND BillingState LIKE \'' + queryAddress + '\'');
                    }
                    
                    //Billing Country
                    if(account.BillingCountry != null && account.BillingCountry.trim() != ''){
                        String queryAddress = '%' + String.escapeSingleQuotes(account.BillingCountry) + '%';
                        whereClause += (whereClause =='' ? ' BillingCountry LIKE \'' + queryAddress + '\'' : ' AND BillingCountry LIKE \'' + queryAddress + '\'');
                    }
                    
                    //Billing postal code
                    if(account.BillingPostalCode != null && account.BillingPostalCode.trim() != ''){
                        String queryAddress = '%' + String.escapeSingleQuotes(account.BillingPostalCode) + '%';
                        whereClause += (whereClause =='' ? ' BillingPostalCode LIKE \'' + queryAddress + '\'' : ' AND BillingPostalCode LIKE \'' + queryAddress + '\'');
                    }
                    
                    //SF Account Id for where clause
                    if(SF_Acct_ID.trim() != ''){
                        String querySF_Acct_ID = '%' + String.escapeSingleQuotes(SF_Acct_ID) + '%';
                        whereClause += (whereClause =='' ? ' SF_Acct_ID__c LIKE \'' + querySF_Acct_ID + '\'' : ' AND SF_Acct_ID__c LIKE \'' + querySF_Acct_ID + '\'');
                    }
                    
                    //String variable for query hold
                    string queryString = '';
                    
                    // query results if any search field populated
                    if(whereClause != '') {
                        queryString = 'Select Name, ParentId, Parent.Name, SF_Acct_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Website, Type, OwnerId, Owner.ManagerId from Account Where '+ whereClause + 'AND RecordType.DeveloperName = \'Cenveo\' AND Type != \'Parent\' AND Owner.Westrock_User__c != true order by Name limit 1000';
                        System.debug('@##$#%'+queryString);
                        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    }
                    else {
                        setCon = new ApexPages.StandardSetController(new List<Account>() );
                    }
                    System.debug('2436'+setCon);
                    //Set page size into set controller list
                    setCon.setPageSize(size);
                    
                    //Total number of records for Account search result
                    noOfRecords = setCon.getResultSize();
                }
            }
            catch(Exception e) {
                
                String errorMessage = e.getMessage() + ' at line number : ' + e.getLineNumber();
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
                ApexPages.addMessage( errorMsg );
            }
            return setCon;
        }set;
    }
    
     // return true when next page has records
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }

    // return true when previous page has records
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
   
    // get page number
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    // method to show previous page
    public void previous() {
        setCon.previous();
    }
   
    // method to show next page
    public void next() {
        setCon.next();
    }
    
    /**
     * Description      :   Method for get query result from lead based on searching criteria
     *
     * Args             :   void
     *
     * Return           :   List<Lead>
     **/
     
    public List<Lead> setQueryLead() {
        
        //List of lead for hold query result
        List<Lead> leads = new  List<Lead>();
    
        //String to hold whereClause
        String whereClause = '';
        
        //String variable for hold query string
        String queryString = 'Select Id, OwnerId, Status, LeadSource, Email, Street, City, State, Country, PostalCode';
        
        //Loop over fieldset
        for(Schema.FieldSetMember fldSet :SObjectType.Lead.FieldSets.Lead_Search_Set.getFields())
            queryString += ', ' + fldSet.getFieldPath();
        
        //Apppend query string
        queryString += ' from Lead';
        
        //Loop over field set to get field name
        for(Schema.FieldSetMember fldSet :SObjectType.Lead.FieldSets.Lead_Search_Set.getFields()) {
            
            //Check if First Name field is fill for search result...add into where clause
            if(lead.get(fldSet.getFieldPath()) != null && String.valueOf(lead.get(fldSet.getFieldPath())).trim() != '') {
                
                String queryAppend = (String.valueOf(lead.get(fldSet.getFieldPath())).contains('*')? String.escapeSingleQuotes(String.valueOf(lead.get(fldSet.getFieldPath())).replace('*','%')) : '%' + String.escapeSingleQuotes(lead.get(fldSet.getFieldPath()) + '%'));
                whereClause += (whereClause == '' ? fldSet.getFieldPath() +' LIKE \'' + queryAppend +'\'' : 'AND '+ fldSet.getFieldPath() +' LIKE \'' + queryAppend +'\'');  
            }
        }    
        
        //Check if Account name is matching to comapny name of lead
        if(accountName != null && accountName.trim() != '') {
            
            String queryCompanyName = (accountName.contains('*')? String.escapeSingleQuotes(accountName.replace('*','%')) : '%' + String.escapeSingleQuotes(accountName) + '%');
            whereClause += (whereClause =='' ? ' Company LIKE \'' + queryCompanyName + '\'' : 'AND Company LIKE \'' + queryCompanyName + '\'');
        }
            
        //Website add in where clause
        if(website != null && website.trim() != ''){
            
            String querywebsite = '%' + String.escapeSingleQuotes(website) + '%';
            whereClause += (whereClause =='' ? ' Website LIKE \'' + querywebsite + '\'' : ' AND Website LIKE \'' + querywebsite + '\'');
        }

        //Check for where clause added some fields or not
        if(whereClause != '') {
            
            //Append query string
            queryString += ' where '+ whereClause + ' AND (Recordtype.DeveloperName = \'Inside_Sales\' OR Recordtype.DeveloperName = \'Master\') Limit 1000';
            
            System.debug('$#%#^#&'+queryString);
            
            //Execute dynamic query
            leads = database.query(queryString);
            
            //Total 
            totalNoOfLeads = leads.size();
        }    
        return leads;
    }
    
    /**
     * Description      :   Method to populate List<List<Lead>>
     *
     * Args             :   Void
     *
     * Return           :   Void
     **/
    public void populateListOfListLead() {
        
        //Temp variable
        Integer temp = 0;
        
        //Populate list of lead form calling method
        List<Lead> resultLead = setQueryLead();
        
        //Add blank list of lead into List<List<Lead>>
        listOfLeads.add(new List<Lead>());
        
        //Check size of list of lest
        if(resultLead.size() > 0) {
            
            //Loop over list of lead
            for(Lead ld : resultLead) {
                
                //Check for page size for next block of List Of list
                if(temp == pageSize) {
                    listOfLeads.add(new List<Lead>());
                    temp = 0;
                }
                
                //Add List<Lead> into List<List<Lead>>
                listOfLeads[listOfLeads.size()-1].add(ld);
                temp++;
            }
        }
    }
    
    //List of temprary to bind on page for display result
    public List<Lead> tempListOfLead {
        get {
            
            //check for List of lead size
            if(listOfLeads.size() > 0) {
                return listOfLeads[pageNumberLead];
            }
            else
                return new List<Lead>();
        }
        set;
    }
    
    /**
     * Description  :   Method to call when need to display prevoius list of lead
     *
     * Param        :   Void
     *
     * Return       :   Void
     **/
    public void previousLead() {
        
        //Check if Page Number is not belong to start page
        if(pageNumberLead > 0) {
            
            //Decrement PageNumberLead by 1
            pageNumberLead -= 1;
            
            //Set  counter of starting and ending or records
            startLead = pageSize*((pageNumberLead + 1) - 1) + 1;
            endLead = (startLead + tempListOfLead.size()) - 1;
        }
    }
    
    /**
     * Description  :   Method to call when need to display next list of lead
     *
     * Param        :   Void
     *
     * Return       :   Void
     **/
    public void nextLead() {
        
        //Check if page number not at last page of list
        if(pageNumberLead < listOfLeads.size()) {
            
            //Increment page number by 1
            pageNumberLead += 1;
            
            //Set counter of starting and ending of leads records on a page
            startLead = pageSize*((pageNumberLead + 1) - 1) + 1;
            endLead = (startLead + tempListOfLead.size()) - 1;
        }
    }
    
    //Method to disable previous button of Lead, when first page of lead is displaying
    public Boolean getPreviousButtonDisabled() {
        return (pageNumberLead == 0);
    }
    
    //Method to disable Next button of lead, when last page of lead is displaying
    public Boolean getNextButtonDisabled() {
        return (pageNumberLead == listOfLeads.size()-1);
    }
    
    public boolean isSystemAdmin {
        get {
            string profileName = [select Profile.Name from User where Id = :Userinfo.getUserId()].Profile.Name;
            return (profileName == 'System Administrator' ? true : false);
        }
    }
    
    // method to get accounts
    public List<Account> getAccounts(){
        List<Account> accList = new List<Account>();
        for(Account a : (List<Account>)setCon.getRecords())
            accList.add(a);
        return accList;
    }
    
    /**
     * Description      :   Method for get query result from Opportunity based on searching criteria
     *
     * Args             :   void
     *
     * Return           :   List<Lead>
     **/
     public void searchOpportunities () {
        
        //Query String
        String queryString = 'Select Id';
        
        //String where clause
        String whereClause = '';
        
        //Loop over field set of opportunity for fetch fields which fieldset having
        for(Schema.fieldSetMember fldSet : SObjectType.Opportunity.FieldSets.Search_Opportunity.getFields()) 
            queryString += ', '+ fldSet.getFieldPath();
        
        //Append query string with object
        queryString += ',AccountId, Account.Owner.ManagerId From Opportunity ';
        
        //Loop over field set for where clause
        for(Schema.fieldSetMember fldSet : SObjectType.Opportunity.FieldSets.Search_Opportunity.getFields()) {
            
            //Check for field set values
            if(fldSet.getFieldPath() == 'Name' && opp.Name != null && opp.Name.trim() != '') {
                
                //SOSL Injection
                String queryName = (opp.Name.contains('*')? String.escapeSingleQuotes(opp.Name.replace('*','%')) : '%' + String.escapeSingleQuotes(opp.Name) + '%');
                
                //Add into where  clause
                whereClause += (whereClause == '' ? fldSet.getFieldPath() + ' LIKE \'' + queryName +'\'' : 'AND '+ fldSet.getFieldPath() +' LIKE \'' + queryName +'\'');
            }
            
            //Check for field set values
            if(fldSet.getFieldPath() == 'Account.Name' && accountName != null && accountName.trim() != '') {
                
                String queryAccName = (accountName.contains('*')? String.escapeSingleQuotes(accountName.replace('*','%')) : '%' + String.escapeSingleQuotes(accountName) + '%');
                whereClause += (whereClause =='' ? fldSet.getFieldPath() +' LIKE \'' + queryAccName + '\'' : 'AND '+fldSet.getFieldPath() +' LIKE \'' + queryAccName + '\'' );
            }
            
            //Check for field set values
            if(fldSet.getFieldPath() == 'Account.OwnerId' && account.OwnerId != null) {
                whereClause += (whereClause =='' ? fldSet.getFieldPath() +'= \'' + account.OwnerId  + '\'' : 'AND '+fldSet.getFieldPath() +'= \'' + account.OwnerId + '\'' );
             }
        } 
        //Check for where clause added some fields or not
        if(whereClause != '') {
            
            //Append query string
            queryString += ' where '+ whereClause + ' AND (RecordType.DeveloperName = \'Cenveo\' OR RecordType.DeveloperName = \'Custom_Label_Quote_Follow_Up\')  Order by LastModifiedDate desc Limit 5';
            
            System.debug('@$#%#^'+queryString);
            
            //Execute dynamic query
            opportunities = database.query(queryString);
        }    
    }
    
    // method to refresh the results
    public pageReference refresh() {
        try {
            
            setCon = null;
            listOfLeads = new List<List<Lead>>();
            opportunities = new List<Opportunity>();  
            getAccounts();
            populateListOfListLead();
            setCon.setPageNumber(1);
            startLead = pageSize*((pageNumberLead + 1) - 1) + 1;
            endLead = (startLead + tempListOfLead.size()) - 1;
            searchOpportunities();
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

   
    
}