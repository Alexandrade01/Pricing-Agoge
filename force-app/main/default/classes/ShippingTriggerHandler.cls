public with sharing class ShippingTriggerHandler {
    List<Shipping__c> oldRecords {get;set;}  //Trigger.old
    List<Shipping__c> newRecords {get;set;}  //Trigger.new
    Map<Id,Shipping__c> oldMap {get;set;}  //Trigger.oldMap
    Map<Id,Shipping__c> newMap {get;set;}  //Trigger.newMap

    public ShippingTriggerHandler(  List<Shipping__c> oldRecords, List<Shipping__c> newRecords,
    Map<Id,Shipping__c> oldMap,Map<Id,Shipping__c> newMap){
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap  = oldMap;
        this.newMap  = newMap;
    }
    public void beforeInsert(){
        ShippingHelper.checkCategoriesShipping(this.newRecords);
        ShippingHelper.CalcPontuation(this.newRecords);
        ShippingHelper.CreateIdShipping(this.newRecords);

    }
    public void beforeUpdate(){
        ShippingHelper.checkRecalcCategoriesShipping(this.oldMap, this.newMap);
        ShippingHelper.CalcPontuation(this.newRecords);
    }
    
    public void afterInsert(){
       
    }
}