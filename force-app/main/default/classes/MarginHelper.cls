public with sharing class MarginHelper {
    public MarginHelper() {

    }
    public static void  checkCategoriesMargin(List<Margin__c> listMargin ){
        Set<String> setLocality = new Set<String>();
        Set<String> setAccount = new Set<String>();
        Set<String> setProduct = new Set<String>();
        
       
        for(Margin__c margin : listMargin ){
            // cadastro todas os registros da categoria localidade
           if(margin.City__c != null) {setLocality.add(margin.City__c);}
           if(margin.State__c != null) {setLocality.add(margin.State__c);}
           if(margin.Country__c != null) {setLocality.add(margin.Country__c);}
           // se o total for diferente de 1 ele retorna um erro
            if(setLocality.Size() != 1){
                margin.addError(Label.CategoriesError);
            }
            

            if(margin.Account__c != null){setAccount.add(margin.Account__c);}
            if(margin.AccountGroup__c != null){setAccount.add(margin.AccountGroup__c);}
            if(setAccount.Size() != 1){
                margin.addError(Label.CategoriesError);
            }

            if(margin.Product2__c != null){setProduct.add(margin.Product2__c);}
            if(margin.HierarchyProduct__c != null){setProduct.add(margin.HierarchyProduct__c);}
            if(setProduct.Size() != 1){
                margin.addError(Label.CategoriesError);
            }
            
            setLocality.Clear();
            setAccount.Clear();
            setProduct.Clear();
           
            
        }
        

        
    }

    public static Map<Id,Margin__c> checkRecalcCategoriesMargin(Map<Id,Margin__c> oldRecords, Map<Id,Margin__c> newRecords){
        Set<String> alterMarginNames = new Set<String>();
       
            // comparação de novos registros com antigos registros
        
       checkCategoriesMargin(newRecords.Values());
     for(Margin__c margin : newRecords.Values()) {
        // novo registro como parametro de visualizacao do antigo
        Margin__c oldRecord = oldRecords.get(margin.Id);
        
     
        if((margin.City__c != oldRecord.City__c)||(margin.State__c != oldRecord.State__c)||
        (margin.Country__c != oldRecord.Country__c)||(margin.Account__c != oldRecord.Account__c)||
        (margin.AccountGroup__c != oldRecord.AccountGroup__c)||(margin.Product2__c != oldRecord.Product2__c)||(margin.HierarchyProduct__c != oldRecord.HierarchyProduct__c)){
         
            alterMarginNames.add(margin.Name);
        }
     }
     Map<Id,Margin__c> marginMap = new Map<Id,Margin__c>([
        SELECT Name,Id, City__c,State__c,Country__c,Account__c,AccountGroup__c,HierarchyProduct__c
        FROM Margin__c
        WHERE Margin__c.Name IN: alterMarginNames
    ]);
        return marginMap;
    }

    public static void CalcPontuation(List<Margin__c> marginList){

        integer score = 0;
        for(Margin__c margin : marginList){

            if(String.isNotEmpty(margin.Product2__c)){
                score += 2000;
            }
            if(String.isNotEmpty(margin.HierarchyProduct__c)){
                score += 1000;
            }
            if(String.isNotEmpty(margin.Account__c)){
                score += 200;
            }
            if(String.isNotEmpty(margin.AccountGroup__c)){
                score += 100;
            }
            if(String.isNotEmpty(margin.City__c)){
                score += 30;
            }
            if(String.isNotEmpty(margin.State__c)){
                score += 20;
            }
            if(String.isNotEmpty(margin.Country__c)){
                score += 10;
            }
            margin.Score__c = score;
            
        }
    }
     public static void CreateIdMargin(List<Margin__c> marginList){
        
        //Carregamento de maps dos parâmetros
        
        Map<Id,Product2> product = new Map<Id,Product2>  ([
            SELECT id,Name
            FROM Product2
            
        ]);
        Map<Id,HierarchyProduct__c> hierarchyProduct = new Map<Id,HierarchyProduct__c>  ([
            SELECT id,Name
            FROM HierarchyProduct__c
            
        ]);
        Map<Id,Account> account = new Map<Id,Account>  ([
            SELECT id,Name
            FROM Account
        ]);
        Map<Id,AccountGroup__c> accountGroup = new Map<Id,AccountGroup__c>  ([
            SELECT id,Name
            FROM AccountGroup__c
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

        for(Margin__c margin : marginList){
             String name = '';
             // se o produto estiver cadastrado sera adicionado no Id, senão nome  da hierarquia será adicionada
              if(String.IsNotBlank(margin.Product2__c)){name += ''+product.get(margin.Product2__c).Name;}
              else if (String.IsNotBlank(margin.HierarchyProduct__c)) {name += ''+hierarchyProduct.get(margin.HierarchyProduct__c).Name;}
              else {margin.addError(Label.CategoriesError);}
                // se a conta não estiver cadastrada o grupo de conta será adicionado
              if(String.IsNotBlank(margin.Account__c)){name += '/'+account.get(margin.Account__c).Name;}
              else if (String.IsNotBlank(margin.AccountGroup__c)) {name += '/'+accountGroup.get(margin.AccountGroup__c).Name;}
              else {margin.addError(Label.CategoriesError);}
                //se a cidade não estiver preenchida, será verificado o estado e depois o país
              if(String.IsNotBlank(margin.City__c)){name += '/'+city.get(margin.City__c).Name;}
              else if(String.IsNotBlank(margin.State__c)){name += '/'+state.get(margin.State__c).Name;}
              else if(String.IsNotBlank(margin.Country__c)){name += '/'+country.get(margin.Country__c).Name;}
              else {margin.addError(Label.CategoriesError);}
             
               margin.ExternId__c = name.deleteWhiteSpace();
            }
        }
   





           
            
           

}