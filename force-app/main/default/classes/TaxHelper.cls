public with sharing class TaxHelper {
   
    public static void checkCategoriesTax(List<Tax__c> taxList ){
        
        Set<String> setProduct = new Set<String>();
        Set<String> setState = new Set<String>();
        for(Tax__c tax : taxList ){
            // cadastro por produto
            if(tax.Product2__c != null){setProduct.add(tax.Product2__c);}
            if(tax.State__c != null){setState.add(tax.State__c);}
            if((setProduct.Size() != 1) || (setState.Size() != 1)){
                tax.addError(Label.CategoriesError);
            }
            
            setState.Clear();
            setProduct.Clear();
        }
        
    }
    public static Map<Id,Tax__c> checkRecalcCategoriesTax(Map<Id,Tax__c> oldRecords, Map<Id,Tax__c> newRecords){
        Set<String> alterMarginNames = new Set<String>();
       
            // comparação de novos registros com antigos registros
        
            checkCategoriesTax(newRecords.Values());
     for(Tax__c tax : newRecords.Values()) {
          // novo registro como parametro de visualizacao do antigo
        Tax__c oldRecord = oldRecords.get(tax.Id);
       
        
        if((tax.Product2__c != oldRecord.Product2__c)||(tax.State__c != oldRecord.State__c)){
         
            alterMarginNames.add(tax.Name);
        }
     }

     Map<Id,Tax__c> taxMap = new Map<Id,Tax__c>([
        SELECT Name,Id, Product2__c,State__c
        FROM Tax__c
        WHERE Tax__c.Name IN: alterMarginNames
    ]);
        return taxMap;
    }

    public static void CreateIdTax(List<Tax__c> taxList){
        
        //Carregamento de maps dos parâmetros
        
        Map<Id,Product2> product = new Map<Id,Product2>  ([
            SELECT id,Name
            FROM Product2
            
        ]);
        Map<Id,State__c> state = new Map<Id,State__c>  ([
            SELECT id,Name
            FROM State__c
        ]);
        for(Tax__c tax : taxList){
             String name = '';
             // se o produto estiver cadastrado sera adicionado no Id, senão nome  da hierarquia será adicionada
              if(String.IsNotBlank(tax.Product2__c) && String.IsNotBlank(tax.State__c) )
              {name += ''+product.get(tax.Product2__c).Name +state.get(tax.State__c).Name ;}
              
              else {tax.addError(Label.CategoriesError);}
           
             
               tax.ExternId__c = name.deleteWhiteSpace();
            }
     }
}