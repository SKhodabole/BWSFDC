public with sharing class AddSalesDataController {
    public Sales_Data__c sd{get; set;}
    public Boolean errorLog{get;set;}	
    private string accid;
    List<RecordType> rtypes = [SELECT DeveloperName,  Name, id FROM RecordType WHERE sObjectType='Sales_Data__c' and isActive=true and DeveloperName = 'Forecast_Sales_Data' ];
    public AddSalesDataController(ApexPages.StandardController controller) {        
	errorLog = true;
        accid = ApexPages.CurrentPage().getParameters().get('accid');
        sd= new Sales_Data__c();
        if(accid != null && accid != '')
            sd.Account__c = accid;
            
            sd.RecordTypeId = rtypes[0].Id;

    }
    public pageReference doSave(){
        //add the period end date from the fiscal calendar year
        if(sd.Year__c == null){
            //throw new My1Exception('Year not defined!');
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, 'Year not defined!');
            ApexPages.addMessage(msg);
	    errorLog = true;
            return null;
        }
        if(sd.Period__c == null){
            //throw new My1Exception('Period not defined!');   
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, 'Period not defined!');
            ApexPages.addMessage(msg);
	    errorLog = true;
            return null;
        }
        if(sd.Period__c < 1 || sd.Period__c > 12){
            //throw new My1Exception('Period not valid!');   
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, 'Period not valid!');
            ApexPages.addMessage(msg);
	    errorLog = true;
            return null;
        }

        system.debug('finding fiscal calendar for year ' + sd.Year__c + ' and month ' + sd.Period__c);
        // READ CUSTOM FISCAL CALENDAR
        FiscalYearSettings fys;
        try{
            fys = [select Id, StartDate, EndDate, Name, IsStandardYear, YearType from FiscalYearSettings where Name=:sd.Year__c and IsStandardYear=true and YearType='Standard'/*IsStandardYear=false and YearType='Custom'*/ LIMIT 1];
        }
        catch(Exception e)
        {
            //throw new My1Exception('Please check if a fiscal calendar is defined for year: ' + sd.Year__c + '!');
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, 'Please check if a fiscal calendar is defined for year: ' + sd.Year__c + '!');
            ApexPages.addMessage(msg);
	    errorLog = true;
            return null;
        }
        
        
        List<Period> p = new List<Period>();
        Integer xPeriod = Integer.valueOf(sd.Period__c);
        if(fys != null){
            p = [select Id, FiscalYearSettingsId, Type, StartDate, EndDate, SystemModstamp, IsForecastPeriod, QuarterLabel, PeriodLabel, Number from Period where FiscalYearSettingsId =:fys.id AND Number=:xPeriod AND Type='Month'];
        }

        if(p == null || p.size() == 0){
            //throw new My1Exception('No valid fiscal calendar entry found for year ' + sd.Year__c + ' and period ' + sd.Period__c);
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, 'No valid fiscal calendar entry found for year ' + sd.Year__c + ' and period ' + sd.Period__c);
            ApexPages.addMessage(msg);
	    errorLog = true;
            return null;
        }
        sd.Period_End_Date__c = p[0].EndDate;
        //
        
        //Check if same Account, Plant Product for same year is being entered.. if so then stop with an error message
        List<Sales_Data__c> duplSD = [Select id, Account__c, Plant_Product__c, Year__c from Sales_Data__c where Account__c =: sd.Account__c AND Plant_Product__c =: sd.Plant_Product__c AND Year__c =: sd.Year__c];
        if(duplSD != null && duplSD.size() > 0){
            //throw new My1Exception('A Sales Data record already exists!');
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, 'A Sales Data Forecast record already exists for the selected Account, Plant Product and Year!');
            ApexPages.addMessage(msg);
	    errorLog = true;
            return null;
        }

        insert sd;
	errorLog = false;
        Pagereference pref = new pagereference('/apex/ForecastVsActual');
        return pref;
    }
    
    public pagereference doCancel(){
        Pagereference pref = new pagereference('/apex/ForecastVsActual');
        return pref;
    }
    public class My1Exception extends Exception {}
}