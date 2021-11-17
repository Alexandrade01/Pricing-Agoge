public with sharing class OrderItemHelper {
    public OrderItemHelper() {
        
            }

    public static void CalcParametersOrderItem(List<OrderItem> orderitem){
               
                calcMargin(orderitem);
                calcShipping(orderitem);
                calcTax(orderitem);
                CalcFinalPrice(orderitem);
                
     }
                
                



       
     // verifica se quantidade ou preço estão zerados
     public static void checkErrorQuantity(List<OrderItem> orderitem){
        for(OrderItem orderitemList : orderitem){
            if(orderitemList.Quantity <=0){
                orderitemList.addError(Label.OrderItemQuantityError);
            }
          
        }
    }
        // verifica se parametros esta vazios
    public static void checkParametersIsBlank(List<OrderItem> orderitem){
        for(OrderItem orderitemList : orderitem){
            if(orderItemList.ListPrice==null ||orderItemList.ListPrice== 0 ){
                orderitemList.addError(Label.ParametersIsBlank);
            }
            if (orderItemList.TaxPercent__c==null || orderItemList.TaxPercent__c==0){
                orderitemList.addError(Label.TaxIsBlank);
            }
            if (orderItemList.ValueShipping__c==null || orderItemList.ValueShipping__c==0){
                orderitemList.addError(Label.ShippingIsBlank);
            }
            if(orderItemList.MarginPercent__c==null || orderItemList.MarginPercent__c==0){
                orderitemList.addError(Label.MarginIsBlank);
                
            }
        }
    }



    public static List<OrderItem> calcMargin(List<OrderItem> marginList){

        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        

        for(OrderItem orderItem : marginList){
            productIds.add(orderItem.Product2Id);
            orderIds.add(orderItem.OrderId);
           

        }

        //map dos produtos
        Map<Id,Product2> productMap = new Map<Id,Product2>([
            SELECT Id,HierarchyProduct__c
            FROM Product2
            WHERE Id IN: productIds

        ]); 

        //map dos pedidos
        Map<Id,Order> orderMap = new Map<Id,Order>([
            SELECT Id,AccountId,Account.AccountGroup__c,Address__c,Address__r.City__c,Address__r.City__r.State__c,Address__r.City__r.State__r.Country__c
            FROM Order
            WHERE Id IN: orderIds

        ]);

       

        //aqui eu ja tenho uma lista com os pedidos dos produtos e suas margem caso tenha.
        Map<OrderItem,Margin__c> listMargins = searchMargin(marginList,orderMap,productMap);
        for(OrderItem orderitem : listMargins.keySet()){
            Margin__c margin = listMargins.get(orderitem);
            if(margin != null){
                orderitem.MarginPercent__c = margin.ValueMargin__c;

                
            }

        }
        return new List<OrderItem>(listMargins.keySet());
    }

    public static Map<OrderItem,Margin__c> searchMargin(List<OrderItem> orderItemList,Map<Id,Order> orderMap,Map<Id,Product2> productMap){
      /*  
        // Carregamento de Sets especificos para conseguir captar as margens de uma melhor forma
        Set<Id> productIds = new Set<Id>();
        Set<Id> hierarchyIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> cityIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();

          // dividimos os parametro do calculo de margem por order e product
          for(Product2 product : productMap.Values()){
            productIds.add(product.Id);
            hierarchyIds.add(product.HierarchyProduct__c);
     
        }

        for(Order order : orderMap.Values()){
            accountIds.add(order.AccountId);
            groupIds.add(order.Account.AccountGroup__c);
            
            cityIds.add(order.Address__r.City__c);
            stateIds.add(order.Address__r.City__r.State__c);
            countryIds.add(order.Address__r.City__r.State__r.Country__c);
            
        }

          //faz uma filtragem das margens 
        
          List<Margin__c> priceMarginList = [
            SELECT Id, Product2__c,HierarchyProduct__c,Account__c,AccountGroup__c, City__c,State__c,Country__c
            FROM Margin__c
            WHERE (Product2__c IN:productIds    OR Product2__c = null) AND
            (HierarchyProduct__c IN:hierarchyIds    OR HierarchyProduct__c = null) AND  
            (Account__c IN:accountIds   OR Account__c = null) AND  
            (AccountGroup__c IN:groupIds    OR AccountGroup__c = null) AND         
            (City__c IN:cityIds   OR City__c = null) AND
            (State__c IN:stateIds   OR State__c = null) AND
            (Country__c IN:countryIds   OR Country__c = null)
            ];
*/

         List<Margin__c> priceMarginList = [
            SELECT Id, Product2__c,HierarchyProduct__c,Account__c,AccountGroup__c, City__c,State__c,Country__c,Score__c,ValueMargin__c,Status__c
            FROM Margin__c
            ORDER BY Score__c DESC
            ];

            //associação do orderitem com o margin
        Map<OrderItem,Margin__c> orderItemToMargin = new Map<OrderItem,Margin__c>();

        for(OrderItem orderItem : orderItemList){
            // ou o orderitem leva nulo como margem
            orderItemToMargin.put(orderItem,null);
            for(Margin__c margin : priceMarginList){
                // ou verifica se os dados condizem e leva os dados da margem
                if(matchMargin(margin,orderItem,orderMap,productMap)){
                    orderItemToMargin.put(orderItem,margin);
                     break;
             }

          }
     }


                    
          
        return  orderItemToMargin;
    }

    // verifica se os dados são os mesmos
    public static boolean matchMargin(Margin__c margin, OrderItem orderitem,Map<Id,Order> orderMap, Map<Id,Product2> productMap){
        
        return (String.isBlank(margin.Product2__c) || margin.Product2__c== orderitem.Product2Id) &&
        // no caso para comparar pegamos o devido id do ordemitem e jogamos dentro do objeto procurado, no caso o product2__c e puxamos o campo
       (String.isBlank(margin.HierarchyProduct__c) || margin.HierarchyProduct__c == productMap.get(orderitem.Product2Id).HierarchyProduct__c) &&
       (String.isBlank(margin.Account__c) || margin.Account__c == orderMap.get(orderitem.OrderId).AccountId) &&
        // verificamos se accountgroup é vazio, no segundo caso colocamos a id do orderitem no map de order e pegamos as info da sua account, com isso pegamos o accountgroup 
        (String.isBlank(margin.AccountGroup__c) || margin.AccountGroup__c == orderMap.get(orderitem.OrderId).Account.AccountGroup__c) &&
       
        (String.isBlank(margin.City__c) || margin.City__c == orderMap.get(orderitem.OrderId).Address__r.City__c)&&
        (String.isBlank(margin.State__c) || margin.State__c == orderMap.get(orderitem.OrderId).Address__r.City__r.State__c)&&
        (String.isBlank(margin.Country__c) || margin.Country__c == orderMap.get(orderitem.OrderId).Address__r.City__r.State__r.Country__c) &&
        ( margin.Status__c == 'Aprovado');
        
      
    }


    public static List<OrderItem> calcShipping(List<OrderItem> shippingList){

        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        

        for(OrderItem orderItem : shippingList){
            productIds.add(orderItem.Product2Id);
            orderIds.add(orderItem.OrderId);
           

        }

        //map dos produtos
        Map<Id,Product2> productMap = new Map<Id,Product2>([
            SELECT Id,HierarchyProduct__c
            FROM Product2
            WHERE Id IN: productIds

        ]); 

        //map dos pedidos
        Map<Id,Order> orderMap = new Map<Id,Order>([
            SELECT Id,Address__c,Address__r.City__c,Address__r.City__r.State__c,Address__r.City__r.State__r.Country__c
            FROM Order
            WHERE Id IN: orderIds

        ]);

        //aqui eu ja tenho uma lista com os pedidos dos produtos e seus fretes casos tenha
        Map<OrderItem,Shipping__c> listShipping = searchShipping(shippingList,orderMap,productMap);
        for(OrderItem orderitem : listShipping.keySet()){
            Shipping__c shipping = listShipping.get(orderitem);
            if(shipping != null){
                orderitem.ValueShipping__c = shipping.ValueFrete__c;
            }
            else { orderitem.ValueShipping__c = 0;}

        }

                
        return new List<OrderItem>(listShipping.keySet());


    }


    public static Map<OrderItem,Shipping__c> searchShipping(List<OrderItem> orderItemList,Map<Id,Order> orderMap,Map<Id,Product2> productMap){
        // ordernação de todos os fretes usando o score por ordenação descrescente, garantindo que o maior score esteja em primero 
        List<Shipping__c> shippingList = [
            SELECT Id, Product2__c,HierarchyProduct__c, City__c,State__c,Country__c,Score__c,ValueFrete__c,Status__c
            FROM Shipping__c
            ORDER BY Score__c DESC
            ];
        //associação do orderitem com o margin
         Map<OrderItem,Shipping__c> orderItemToShipping = new Map<OrderItem,Shipping__c>();

             for(OrderItem orderItem : orderItemList){
                 //  o orderitem leva nulo como frete
                 orderItemToShipping.put(orderItem,null);
                 for(Shipping__c shipping : shippingList){
                     // e depois verifica se os dados condizem e leva o correspondete no frete
                     if(matchShipping(shipping,orderItem,orderMap,productMap)){
                        orderItemToShipping.put(orderItem,shipping);
                          break;
                  }
     
                }   
            }
            return orderItemToShipping;
    }

    public static boolean matchShipping(Shipping__c shipping, OrderItem orderitem,Map<Id,Order> orderMap, Map<Id,Product2> productMap){
        
        return (String.isBlank(shipping.Product2__c) || shipping.Product2__c == orderitem.Product2Id) &&
        // no caso para comparar pegamos o devido id do ordemitem e jogamos dentro do objeto procurado, no caso o product2__c e puxamos o campo
       (String.isBlank(shipping.HierarchyProduct__c) || shipping.HierarchyProduct__c == productMap.get(orderitem.Product2Id).HierarchyProduct__c) &&
       (String.isBlank(shipping.City__c) || shipping.City__c == orderMap.get(orderitem.OrderId).Address__r.City__c)&&
       (String.isBlank(shipping.State__c) || shipping.State__c == orderMap.get(orderitem.OrderId).Address__r.City__r.State__c)&&
       (String.isBlank(shipping.Country__c) || shipping.Country__c == orderMap.get(orderitem.OrderId).Address__r.City__r.State__r.Country__c) &&
       ( shipping.Status__c == 'Aprovado');
       
     
   }
    

   public static List<OrderItem> calcTax(List<OrderItem> taxList){

        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
    

        for(OrderItem orderItem : taxList){
        productIds.add(orderItem.Product2Id);
        orderIds.add(orderItem.OrderId);
       

        }

        //map dos produtos
        Map<Id,Product2> productMap = new Map<Id,Product2>([
        SELECT Id
        FROM Product2
        WHERE Id IN: productIds

     ]); 

        //map do estados
        Map<Id,Order> orderMap = new Map<Id,Order>([
        SELECT Id,Address__r.City__r.State__c
        FROM Order
        WHERE Id IN: orderIds ]);

   

        //aqui eu ja tenho uma lista com os pedidos dos produtos e seus impostos casos tenha
        Map<OrderItem,Tax__c> listTax = searchTax(taxList,orderMap,productMap);
     for(OrderItem orderItem : listTax.keySet()){
        Tax__c tax = listTax.get(orderitem);
        if(tax != null){
            orderItem.TaxPercent__c = tax.TaxCost__c;
            
            }
            else {orderItem.TaxPercent__c = 0;}
        }
        return new List<OrderItem>(listTax.keySet());
    }

            




    public static Map<OrderItem,Tax__c> searchTax(List<OrderItem> orderItemList,Map<Id,Order> orderMap,Map<Id,Product2> productMap){
        // ordernação de todos os impostos
        List<Tax__c> taxList = [
            SELECT Id, Product2__c,State__c, Status__c,TaxCost__c
            FROM Tax__c
          
            ];
        //associação do orderitem com o margin
         Map<OrderItem,Tax__c> orderItemToTax = new Map<OrderItem,Tax__c>();

             for(OrderItem orderItem : orderItemList){
                 //  o orderitem leva primeiramente nulo como imposto
                 orderItemToTax.put(orderItem,null);
                 for(Tax__c tax : taxList){
                     // e depois verifica se os dados condizem e leva o correspondente do objeto imposto(tax)
                     if(matchTax(tax,orderItem,orderMap,productMap)){
                        orderItemToTax.put(orderItem,tax);
                          break;
                  }
     
                }   
            }
            return orderItemToTax;
    }

  public static boolean matchTax(Tax__c tax, OrderItem orderitem,Map<Id,Order> orderMap, Map<Id,Product2> productMap){
        
        return (tax.Product2__c == orderitem.Product2Id) &&(tax.State__c == orderMap.get(orderitem.OrderId).Address__r.City__r.State__c)
        &&( tax.Status__c == 'Aprovado');
        
      }
        
   public static void CalcFinalPrice(List<OrderItem> listOrderItem){
         
        for(OrderItem orderItem: listOrderItem){
            
          orderItem.FinalPrice__c =  ((orderItem.ListPrice+orderItem.ValueShipping__c)*(1+(orderItem.TaxPercent__c/100))*(1+(orderItem.MarginPercent__c/100)));
          orderItem.Discount__c = (orderItem.FinalPrice__c-orderItem.UnitPrice)/orderItem.FinalPrice__c;
          orderItem.PriceNoMargin__c = ((orderItem.ListPrice+orderItem.ValueShipping__c)*(1+(orderItem.TaxPercent__c/100)));
          orderItem.TotalPrice__c = orderItem.FinalPrice__c*orderItem.Quantity;
          
         
        }
        
    }

    public static List<OrderItem> recalcPrices(Map<Id,OrderItem> oldRecords, Map<Id,OrderItem> newRecords){
        Set<Id> alterOrderItens = new Set<Id>();
        checkParametersIsBlank(newRecords.Values());
        for(OrderItem orderItem : newRecords.Values()) {
            // novo registro como parametro de visualizacao do antigo
            OrderItem oldRecord = oldRecords.get(orderItem.Id);
            
         
            if(orderItem != oldRecord){
             
                alterOrderItens.add(orderItem.Id);
            }
        }

        List<OrderItem> alterOrderItensId = new List<OrderItem>([
        SELECT Id, OrderId,Product2Id
        FROM OrderItem
        WHERE OrderItem.Id IN: alterOrderItens]);

        checkErrorQuantity(alterOrderItensId);
        CalcParametersOrderItem(alterOrderItensId);
        checkParametersIsBlank(alterOrderItensId);

        return alterOrderItensId;
    }

    public static void blockUpdateAccount(Map<Id,OrderItem> oldMap, Map<Id,OrderItem> newMap){
        Set<Id> newOrderItens = new Set<Id>();
        Set<Id> oldOrderItens = new Set<Id>();

        
        for(OrderItem orderItem : newMap.Values()){
            OrderItem oldOrderItem = oldMap.get(orderItem.Id);
            newOrderItens.add(orderItem.OrderId);
            oldOrderItens.add(oldOrderItem.OrderId);
        }

        Map<Id,Order> newOrders = new Map<Id,Order>  ([
        SELECT Id,Status
        FROM Order
        WHERE Id IN: newOrderItens
        ]);
        Map<Id,Order> oldOrders = new Map<Id,Order>  ([
            SELECT Id,Status
            FROM Order
            WHERE Id IN: oldOrderItens
            ]);

        for(Order order : newOrders.Values()){
                Order oldOrder = oldOrders.get(order.Id);
                    if(oldOrder.Status == 'Activated' && order.Status == 'Activated'){

                        for(OrderItem orderItem : newMap.Values()){
                            if (orderItem.OrderId == oldOrder.Id){
                                orderItem.addError(Label.orderIsActivated);
                            }
                        }
                    }
                   
                }
            }
            
         }
       
                        
                           
                    
                       
