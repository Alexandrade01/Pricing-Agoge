global with sharing class OrderHelper {
    
    global static void blockUpdateAccount(Map<Id,Order> oldMap, Map<Id,Order> newMap){

        for(Order order : newMap.Values()){
            Order oldOrder = oldMap.get(order.Id);
                if(oldOrder.Status == 'Activated' && order.Status == 'Activated'){
                    order.addError(Label.orderIsActivated);
                }
                if(!(order.AccountId == oldOrder.AccountId) ){
                    order.addError(Label.blockAlterAccount);
                }
        }
    }

   
}


    
    
