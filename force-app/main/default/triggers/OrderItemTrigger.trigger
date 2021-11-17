trigger OrderItemTrigger on OrderItem (before insert,before update,after insert) {

       // Instancia do handler
       OrderItemTriggerHandler handler = new OrderItemTriggerHandler(
    Trigger.old,Trigger.new,Trigger.oldMap,Trigger.newMap);

    switch on Trigger.operationType {
        when BEFORE_INSERT {
        handler.beforeInsert();
        
    }
        when BEFORE_UPDATE {
        handler.beforeUpdate();
        
    }
        when AFTER_INSERT {
        handler.afterInsert();
        
    }
 
   
    }

}