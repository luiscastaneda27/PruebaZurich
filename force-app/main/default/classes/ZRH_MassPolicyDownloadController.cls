/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 20/12/2023
Description  : Class to Download policy PDF
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO		20/12/2023		initial version
********************************************************************************/
global class ZRH_MassPolicyDownloadController implements vlocity_ins.VlocityOpenInterface2, System.Callable{
    
    
    /**
    *  @Description: Static variables
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        20/12/2023  
    */
    private static final String MAP_INPUT = 'input';
    private static final String MAP_OUTPUT = 'output';
    private static final String MAP_OPTIONS = 'options';
    private static final String METHOD_NAME = 'getAccounts';
    private static final String NAME_RESPONSE = 'responseApexClass';
    private static final String NAME_ACCOUNT = 'accountId';
    private static final String NAME_QUERY = 'query';
    
    // Implementation of invokeMethod for vlocity_ins.VlocityOpenInterface2
    global Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        if (methodName == METHOD_NAME) {
            getAccounts(input, output);
        }
        return output;
    }

    // Implementation of call method for System.Callable
    global Object call(String methodName, Map<String, Object> params) {
        Map<String, Object> input = (Map<String, Object>) params.get(MAP_INPUT);
        Map<String, Object> output = (Map<String, Object>) params.get(MAP_OUTPUT);
        Map<String, Object> options = (Map<String, Object>) params.get(MAP_OPTIONS);
        return invokeMethod(methodName, input, output, options);
    }
    
    /**
    *  @Description: Get Account y plan for contract
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        20/12/2023	  
    */
    public static PolicyDownloadWrapper getAccounts( Map<String, Object> input, Map<String, Object> output) {
        String valueDefaul = '';
        String labelDefaul = '--Ninguno--';
        String accountId = (String) input.get(NAME_ACCOUNT);
        String query = (String) input.get(NAME_QUERY);
        PolicyDownloadWrapper response = new PolicyDownloadWrapper();
        response.accountList = new List<PicklistOptions>();
        response.plansList = new List<PicklistOptions>();
        response.plansList.add(new PicklistOptions(labelDefaul, valueDefaul));
        List<String> listField = ZRH_ClonePlanController.getFieldsObj('Account');
        List<String> plansList = new List<String>();
        List<String> accountsList = new List<String>();
        List<String> contractList = new List<String>();
        Account acc = new ZRH_AccountsSelector().selectById(accountId, listField);
        response.isHolding = acc.ZRH_EsHolding__c;
        if(acc.ZRH_EsHolding__c){
            response.accountList.add(new PicklistOptions(labelDefaul, valueDefaul));
            for(Account item: new ZRH_AccountsSelector().selectByHoldingId(accountId)){
                response.accountList.add(addAccountPick(item));
                accountsList.add(item.Id);
            }
        }else{
            response.accountList.add(addAccountPick(acc));
            accountsList.add(acc.Id);
        }
        response.accountList.sort();
        response.contractList = new ZRH_ContractsSelector().selectByAccountIds(accountsList);
        for(Contract item: response.contractList){
            contractList.add(item.Id);
            for(ContractgroupPlan ele: item.ContractGroupPlans){
                if(!plansList.contains(ele.ZRH_CodigoProducto__c)){
                    response.plansList.add(new PicklistOptions(ele.ZRH_CodigoProducto__c, ele.ZRH_CodigoProducto__c));
                    plansList.add(ele.ZRH_CodigoProducto__c);   
                }
            }
        }
        response.plansList.sort();
        response.documentList = contractList.size() > 0 ?  Database.query(query) : new List<ContentDocumentLink>(); 
        output.put(NAME_RESPONSE, JSON.serialize(response));
        return response;
    }
    
    
    /**
    *  @Description: Added Account to picklist 
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        20/12/2023	  
    */
    public static PicklistOptions addAccountPick(Account acc){
        return new PicklistOptions(acc.Name, acc.Id);
    }
    
    
    public class PolicyDownloadWrapper{
        @AuraEnabled public List<PicklistOptions> accountList;
        @AuraEnabled public List<PicklistOptions> plansList;
        @AuraEnabled public List<ContentDocumentLink> documentList;
        @AuraEnabled public List<Contract> contractList;
        @AuraEnabled public Boolean isHolding;
    }
    
    
    public class PicklistOptions implements Comparable {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public Integer compareTo(Object ObjToCompare) {
            return label.CompareTo(((PicklistOptions)ObjToCompare).label);
        }
    }
}