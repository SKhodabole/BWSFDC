trigger NameMappingConfigurationTrigger on Name_Mapping_Configuration__c (before insert, before update) {

    NameMappingConfigurationTriggerHelper.newNameMappingConfigurations = trigger.new;
    NameMappingConfigurationTriggerHelper.oldNameMappingConfigurations = trigger.old;
    NameMappingConfigurationTriggerHelper.newNameMappingConfigurationsMap = trigger.newMap;
    NameMappingConfigurationTriggerHelper.oldNameMappingConfigurationsMap = trigger.oldMap;
    
    //Is Before Context of Initation Context
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            NameMappingConfigurationTriggerHelper.onBeforeInsert();
        }
        
        if (trigger.isUpdate) {
            NameMappingConfigurationTriggerHelper.onBeforeUpdate();
        }
    }
}