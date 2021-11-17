public with sharing class TaxTriggerHelper {
    List<Tax__c> oldRecords {get;set;}  //Trigger.old
    List<Tax__c> newRecords {get;set;}  //Trigger.new
    Map<Id,Tax__c> oldMap {get;set;}  //Trigger.oldMap
    Map<Id,Tax__c> newMap {get;set;}  //Trigger.newMap

    public TaxTriggerHelper(  List<Tax__c> oldRecords, List<Tax__c> newRecords,
    Map<Id,Tax__c> oldMap,Map<Id,Tax__c> newMap){
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap  = oldMap;
        this.newMap  = newMap;
    }
    public void beforeInsert(){
        TaxHelper.checkCategoriesTax(this.newRecords);
       
    }
    public void beforeUpdate(){
        TaxHelper.checkRecalcCategoriesTax(this.oldMap, this.newMap);
        
    }
    
    public void afterInsert(){
       
    }
}