public with sharing class MarginTriggerHandler {
    List<Margin__c> oldRecords {get;set;}  //Trigger.old
    List<Margin__c> newRecords {get;set;}  //Trigger.new
    Map<Id,Margin__c> oldMap {get;set;}  //Trigger.oldMap
    Map<Id,Margin__c> newMap {get;set;}  //Trigger.newMap

    public MarginTriggerHandler(  List<Margin__c> oldRecords, List<Margin__c> newRecords,
    Map<Id,Margin__c> oldMap,Map<Id,Margin__c> newMap){
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap  = oldMap;
        this.newMap  = newMap;
    }
    public void beforeInsert(){
        MarginHelper.checkCategoriesMargin(this.newRecords);
        MarginHelper.CalcPontuation(this.newRecords);
        MarginHelper.CreateIdMargin(this.newRecords);
       
        
        

    }
    public void beforeUpdate(){
        MarginHelper.checkRecalcCategoriesMargin(this.oldMap, this.newMap);
        MarginHelper.CalcPontuation(this.newRecords);
       
    }
    
}