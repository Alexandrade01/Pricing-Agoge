public with sharing class AccountHelper {
    public AccountHelper() {

    }
    public static void checkErrorCNPJ(List<Account> accounts){
        for(Account account:accounts){
            String CNPJRegex = 	'^[0-9]{2}(.[0-9]{3})(.[0-9]{3})(/[0-9]{4})(-[0-9]{2})?$';
            boolean result = Pattern.matches(CNPJRegex,account.CNPJ__c);
           if(!result){
            account.addError(Label.ErrorCNPJ);

        } 
    }
    
            }
}