public class ZRH_PolicyAssingmentTableController {
    
    @AuraEnabled
    public static List<Object> getContractGroupPlans(Id holdingContractId){
        try {
            List<ContractGroupPlan> contractGroupPlans = [SELECT Id, Name, Contract.Account.Name, ZRH_NumeroDePoliza__c, ZRH_UsuarioAsignado__r.Name FROM ContractGroupPlan WHERE ContractGroupParentPlanId = null AND Contract.ZRH_ContratoHolding__c = :holdingContractId LIMIT 400];
            
            List<Object> listCGP = new List<Object>();

            for (ContractGroupPlan cgp : contractGroupPlans) {
                Map<String,Object> field = new Map<String,Object>();
                field.put('Contratante', cgp.Contract.Account.Name);
                field.put('Plan', cgp.Name);
                field.put('NumeroPoliza', cgp.ZRH_NumeroDePoliza__c);
                field.put('UsuarioAsignado', cgp.ZRH_UsuarioAsignado__r.Name);
                field.put('Id', cgp.Id);
                listCGP.add(field);
            }

            return listCGP;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ContractGroupPlan> assignUserToContractGroupPlans(Id userId, List<ContractGroupPlan> listCGP){
        try {
            System.debug('listCGP:' + listCGP);
            System.debug('userId:' + userId);
            for (ContractGroupPlan cgp : listCGP) {
                cgp.ZRH_UsuarioAsignado__c = userId;
            }
            update listCGP;

            return listCGP;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}