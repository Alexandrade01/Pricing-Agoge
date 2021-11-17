public with sharing class ShippingHelper {
    public ShippingHelper() {

    }
    public static List<Shipping__c> checkCategoriesShipping(List<Shipping__c> listShipping ){
        
        Set<String> setProduct = new Set<String>();
        Set<String> setLocality = new Set<String>();
        List<Shipping__c> returnList = new  List<Shipping__c>();
        
        
       
        for(Shipping__c shipping : listShipping ){
            // cadastro por produto
            if(shipping.Product2__c != null){setProduct.add(shipping.Product2__c);}
            if(shipping.HierarchyProduct__c != null){setProduct.add(shipping.HierarchyProduct__c);}
            if(setProduct.Size() != 1){
                shipping.addError(Label.CategoriesError);
            }
            // cadastro todas os registros da categoria localidade
           if(shipping.City__c != null) {setLocality.add(shipping.City__c);}
           if(shipping.State__c != null) {setLocality.add(shipping.State__c);}
           if(shipping.Country__c != null) {setLocality.add(shipping.Country__c);}
           // se o total for diferente de 1 ele retorna um erro
            if(setLocality.Size() != 1){
                shipping.addError(Label.CategoriesError);
            }
            setLocality.Clear();
           
            setProduct.Clear();
           
            
        }
        return returnList;
    }

    public static Map<Id,Shipping__c> checkRecalcCategoriesShipping(Map<Id,Shipping__c> oldRecords, Map<Id,Shipping__c> newRecords){
        Set<String> alterMarginNames = new Set<String>();
       
            
        // comparação de novos registros com antigos registros
       List<Shipping__c> newRecordsList = checkCategoriesShipping(newRecords.Values());

     for(Shipping__c shipping : newRecordsList) {
          // novo registro com o parametro de visualizacao do antigo
        Shipping__c oldRecord = oldRecords.get(shipping.Id);
       
        
        // fazemos uma limpeza de requisição quando só captamos o que realmente mudou
        if((shipping.City__c != oldRecord.City__c)||(shipping.State__c != oldRecord.State__c)||
        (shipping.Country__c != oldRecord.Country__c)||(shipping.Product2__c != shipping.Product2__c) || (shipping.HierarchyProduct__c != oldRecord.HierarchyProduct__c)){
         
            alterMarginNames.add(shipping.Name);
        }
     }
     Map<Id,Shipping__c> marginMap = new Map<Id,Shipping__c>([
        SELECT Name,Id, City__c,State__c,Country__c,Product2__c,HierarchyProduct__c
        FROM Shipping__c
        WHERE Shipping__c.Name IN: alterMarginNames
    ]);
        return marginMap;
    }

    public static void CalcPontuation(List<Shipping__c> shippingList){

        integer score = 0;
        for(Shipping__c shipping : shippingList){

            if(String.isNotEmpty(shipping.Product2__c)){
                score += 2000;
            }
            if(String.isNotEmpty(shipping.HierarchyProduct__c)){
                score += 1000;
            }
          
            if(String.isNotEmpty(shipping.City__c)){
                score += 30;
            }
            if(String.isNotEmpty(shipping.State__c)){
                score += 20;
            }
            if(String.isNotEmpty(shipping.Country__c)){
                score += 10;
            }
            shipping.Score__c = score;
            
        }
    }

    public static void CreateIdShipping(List<Shipping__c> shippingList){
        
        //Carregamento de maps dos parâmetros
        
        Map<Id,Product2> product = new Map<Id,Product2>  ([
            SELECT id,Name
            FROM Product2
            
        ]);
        Map<Id,HierarchyProduct__c> hierarchyProduct = new Map<Id,HierarchyProduct__c>  ([
            SELECT id,Name
            FROM HierarchyProduct__c
            
        ]);
       
        Map<Id,City__c> city = new Map<Id,City__c>  ([
            SELECT id,Name
            FROM City__c
        ]);
        Map<Id,State__c> state = new Map<Id,State__c>  ([
            SELECT id,Name
            FROM State__c
        ]);
        Map<Id,Country__c> country = new Map<Id,Country__c>  ([
            SELECT id,Name
            FROM Country__c
        ]);

        for(Shipping__c shipping : shippingList){
             String name = '';
             // se o produto estiver cadastrado sera adicionado no Id, senão nome  da hierarquia será adicionada
              if(String.IsNotBlank(shipping.Product2__c)){name += ''+product.get(shipping.Product2__c).Name;}
              else if (String.IsNotBlank(shipping.HierarchyProduct__c)) {name += ''+hierarchyProduct.get(shipping.HierarchyProduct__c).Name;}
              else {shipping.addError(Label.CategoriesError);}
              
                //se a cidade não estiver preenchida, será verificado o estado e depois o país
              if(String.IsNotBlank(shipping.City__c)){name += '/'+city.get(shipping.City__c).Name;}
              else if(String.IsNotBlank(shipping.State__c)){name += '/'+state.get(shipping.State__c).Name;}
              else if(String.IsNotBlank(shipping.Country__c)){name += '/'+country.get(shipping.Country__c).Name;}
              else {shipping.addError(Label.CategoriesError);}
             
               shipping.ExternId__c = name.deleteWhiteSpace();
            }
     }

}