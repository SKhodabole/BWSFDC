public with sharing class UpdatePeriodEndDateUtil {
	
	private static String runningMode; 
	public UpdatePeriodEndDateUtil(){
		
	}
	public static void setMode(String mode){
		runningMode = mode;
	}
	public static void updatePeriodEndDate(List<Sales_Data__c> sdList){

		Map<String, List<Sales_Data__c>> arrangedMap_SD = new Map<String, List<Sales_Data__c>>();
		Set<String> years = new Set<String>();
		Set<Integer> periods = new Set<Integer>();
		
		for(Sales_Data__c sd : sdList){
			if(sd.Year__c == null || sd.Period__c == null && (sd.Period__c < 1 || sd.Period__c > 12)){
				//do nothing with these SDs
			}
			else{
					String strKey = sd.Year__c + '~' + Integer.valueOf(sd.Period__c);
					if(arrangedMap_SD.containsKey(strKey)){
						arrangedMap_SD.get(strKey).add(sd);
					}
					else{
						List<Sales_Data__c> tempSDList = new List<Sales_Data__c>();
						tempSDList.add(sd);
						arrangedMap_SD.put(strKey,tempSDList);
					}	
					years.add(sd.Year__c);
					periods.add(Integer.valueOf(sd.Period__c));
			}
			
		}
		
		if(arrangedMap_SD.size() <= 0)
			return;
		
			List<Period> periodList = [select Id, 
											  FiscalYearSettingsId, 
											  FiscalYearSettings.StartDate, 
											  FiscalYearSettings.EndDate, 
											  FiscalYearSettings.Name, 
											  FiscalYearSettings.IsStandardYear, 
											  FiscalYearSettings.YearType, 
											  Type, 
											  StartDate, 
											  EndDate, 
											  SystemModstamp, 
											  IsForecastPeriod, 
											  QuarterLabel, 
											  PeriodLabel, 
											  Number 
											  from Period 
											  where FiscalYearSettings.Name IN :years AND
											  FiscalYearSettings.IsStandardYear=true/*false*/ AND  
											  FiscalYearSettings.YearType= 'Standard' /*'Custom'*/ AND 
											  Number IN :periods AND  
											  Type='Month'
										];			
		
		
		Map<String, Period> periodMap = new Map<String, Period>();
		 
		for(Period p : periodList){
			String strKey = p.FiscalYearSettings.Name + '~' + Integer.valueOf(p.Number);
			periodMap.put(strKey, p);
		}
		
		List<Sales_Data__c> updateSDList = new List<Sales_Data__c>();
		
		for(String strTempKey : arrangedMap_SD.keySet()){
			if(periodMap.containsKey(strTempKey)){
				for(Sales_Data__c sd : arrangedMap_SD.get(strTempKey)){
					sd.Period_End_Date__c = periodMap.get(strTempKey).EndDate;
						
					updateSDList.add(sd);
				}
			}
			else{
				//do nothing
			}
		}
		
		if(runningMode == null && updateSDList.size() > 0)
			update updateSDList;
	}
	
	
}