/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 21/12/2023
Description  : Batch class to enroll members to policies
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Mateo Long.                         ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			21/12/2023		initial version
********************************************************************************/
public class ZRH_EnrollMembersBatch implements Database.Batchable<SObject>, Database.Stateful {

    /**
    *  @Description: Variables
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        21/12/2023  
    */
    private static final String NOTIFICATION_TITLE = 'Administración de Asegurados';
    private static final String NOTIFICATION_TEXT = 'Se ha finalizado exitosamente el proceso de administración de asegurados para el grupo negocio HOLDING_NAME del contrato HOLDING_CONTRACT y sus relacionados.';
    private static final String NOTIFICATION_TITLE_ERROR = 'Error en administración de asegurados';
    private static final String NOTIFICATION_TEXT_ERROR = 'Se ha producido un error en la administración de los asegurados';
    private static final String NAME_CUSTOM_NOTIFICATION = 'ZRH_InscripcionMiembrosFinalizada';
    private static final String POLICY_STATUS = 'Activa';
    private static final String POLICY_NAME_SUBSTR = 'Póliza Titular ';
    private static final String PARTICIPANT_PRIMARY_ROLE = 'Propietario';
    private static final String PARTICIPANT_MEMBER_ROLE = 'Miembro';
    private static final String PARTICIPANT_DEPENDANT_ROLE = 'Beneficiario';
    private static final String PARTICIPANT_LIFE_ROLE = 'Miembro de plan vida';
    private static final String PARTICIPANT_HEALTH_ROLE = 'Miembro del plan de salud';
    private static final String PERSON_ACCOUNT_DEVELOPER_NAME = 'PersonAccount';
    private static final String POLICY_TYPE_HEALTH = 'Salud';
    private static final String RELATIONSHIP_SELF = 'Titular (Self)';
    private static final String CANCELED_STATUS = 'Cancelada';
    private static final String INCLUSION_MOVEMENT = 'Inclusión';
    private static final String EXCLUSION_MOVEMENT = 'Exclusión';
    private static final String MODIFICATION_MOVEMENT = 'Modificación';

    public String holdingQuoteId;
    public Integer autoNumberAugmentor = 1;
    public Id recordTypePersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PERSON_ACCOUNT_DEVELOPER_NAME).getRecordTypeId();

    /**
    *  @Description: Start Batch method of the batch
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        21/12/2023  
    */
    public List<GroupCensusMember> start(Database.BatchableContext BC) {
        
        Set<Id> groupCensusIds = new Set<Id>();
        List<GroupCensusMember> groupCensusMembers = new List<GroupCensusMember>();

        List<Quote> allQuotes = new ZRH_QuotesSelector().selectQuotesForGroup(holdingQuoteId);

        for (Quote quote : allQuotes) {
            groupCensusIds.add(quote.vlocity_ins_fsc__GroupCensusStdId__c);
        }
        // select all members that are to be included and have not been included yet
        List<GroupCensusMember> groupCensusMembersToInclude = new ZRH_GroupCensusMemberSelector().selectGroupMembersByCensusIdsToInclude(groupCensusIds);
        // select all members that are to be excluded and have not been excluded yet
        List<GroupCensusMember> groupCensusMembersToExclude = new ZRH_GroupCensusMemberSelector().selectGroupMembersByCensusIdsToExclude(groupCensusIds);
        // select all members that are to be modified
        List<GroupCensusMember> groupCensusMembersToModify = new ZRH_GroupCensusMemberSelector().selectGroupMembersByCensusIdsToModify(groupCensusIds);

        groupCensusMembers.addAll(groupCensusMembersToInclude);
        groupCensusMembers.addAll(groupCensusMembersToExclude);
        groupCensusMembers.addAll(groupCensusMembersToModify);

        Map<String, String> gcmToInclude = new Map<String,String>();
        for (GroupCensusMember gcm : groupCensusMembersToInclude) {
            gcmToInclude.put(gcm.Name, gcm.ZRH_TipoMovimiento__c + ' ' + gcm.ZRH_InclusionRealizada__c);
        }
        Map<String, String> gcmToExclude = new Map<String,String>();
        for (GroupCensusMember gcm : groupCensusMembersToExclude) {
            gcmToExclude.put(gcm.Name, gcm.ZRH_TipoMovimiento__c + ' ' + gcm.ZRH_ExclusionRealizada__c);
        }
        Map<String, String> gcmToModify = new Map<String,String>();
        for (GroupCensusMember gcm : groupCensusMembersToModify) {
            gcmToModify.put(gcm.Name, gcm.ZRH_TipoMovimiento__c);
        }

        System.debug('gcmToInclude: ' + gcmToInclude);
        System.debug('gcmToExclude: ' + gcmToExclude);
        System.debug('gcmToModify: ' + gcmToModify);

        return groupCensusMembers;

    }

    /**
    *  @Description: Execute Batch method of the batch
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        21/12/2023  
    */
    public void execute(Database.BatchableContext BC, List<GroupCensusMember> censusMembers) {
        
        // select all quotes related to the holding quote
        List<Quote> allQuotes = new ZRH_QuotesSelector().selectQuotesFromGroupHolding(holdingQuoteId);
        Set<Id> quoteIds = extractIdsFromSObject((List<SObject>)allQuotes);

        // collections for members to be enrolled
        Set<Id> toEnrollPrimaryMemberIds = new Set<Id>();
        List<GroupCensusMember> toEnrollPrimaryMembers = new List<GroupCensusMember>();
        Set<String> toEnrollPrimaryMemberPolicies = new Set<String>();
        Set<String> toEnrollAloneDependantMemberPrimaryRuts = new Set<String>();
        List<GroupCensusMember> toEnrollAloneDependantMembers = new List<GroupCensusMember>();
        Map<String, GroupCensusMember> toEnrollPrimaryRutPolicyNumberToMember = new Map<String, GroupCensusMember>();

        // collections for members to be excluded
        List<GroupCensusMember> toExcludePrimaryMembers = new List<GroupCensusMember>();
        Map<String, GroupCensusMember> toExcludePrimaryRutPolicyNumberToMember = new Map<String, GroupCensusMember>();
        Set<String> toExcludePrimaryMemberRuts = new Set<String>();
        Set<Id> toExcludePrimaryMemberIds = new Set<Id>();
        Set<String> toExcludePrimaryMemberPolicies = new Set<String>();
        List<GroupCensusMember> toExcludeAloneDependantMembers = new List<GroupCensusMember>();
        Map<String, GroupCensusMember> toExcludeDependantRutPolicyNumberPrimaryRutToMember = new Map<String, GroupCensusMember>();
        Set<String> toExcludeAloneDependantMemberRuts = new Set<String>();
        Set<String> toExcludeAloneDependantMemberPolicies = new Set<String>();
        
        // collections for members to be modified
        Map<String, GroupCensusMember> toModifyMemberRutToCensusMember = new Map<String, GroupCensusMember>();
        Set<String> toModifyMemberPolicies = new Set<String>();
        Map<String, GroupCensusMember> toModifyMemberRutPolicyNumberToCensusMember = new Map<String, GroupCensusMember>();
        Map<String, GroupCensusMember> toModifyMemberRutPolicyNumberPrimaryRutToCensusMember = new Map<String, GroupCensusMember>();
        Set<String> toModifyMemberRuts = new Set<String>();

        // fill collections based on conditions
        for (GroupCensusMember cm : censusMembers) {
            String policyNum = transformPolicyNumber(cm.ZRH_Poliza__c);
            // primary members to be enrolled
            if (cm.ZRH_TipoMovimiento__c == INCLUSION_MOVEMENT && cm.PrimaryGroupCensusMemberId == null) {
                toEnrollPrimaryMemberIds.add(cm.Id);
                toEnrollPrimaryMembers.add(cm);
                toEnrollPrimaryMemberPolicies.add(policyNum);
                toEnrollPrimaryRutPolicyNumberToMember.put(cm.ZRH_Rut__c + '-' + policyNum, cm);
            // dependants to be enrolled with their primaries already enrolled 
            } else if (cm.ZRH_TipoMovimiento__c == INCLUSION_MOVEMENT && cm.PrimaryGroupCensusMemberId != null) {
                toEnrollAloneDependantMemberPrimaryRuts.add(cm.PrimaryGroupCensusMember.ZRH_Rut__c);
                toEnrollAloneDependantMembers.add(cm);
            // primary members to be excluded
            } else if (cm.ZRH_TipoMovimiento__c == EXCLUSION_MOVEMENT && cm.PrimaryGroupCensusMemberId == null) {
                toExcludePrimaryMemberRuts.add(cm.ZRH_Rut__c);
                toExcludePrimaryMemberIds.add(cm.Id);
                toExcludePrimaryMemberPolicies.add(policyNum);
                toExcludePrimaryRutPolicyNumberToMember.put(cm.ZRH_Rut__c + '-' + policyNum, cm);
                toExcludePrimaryMembers.add(cm);
            // dependants to be excluded with their primaries not being excluded
            } else if (cm.ZRH_TipoMovimiento__c == EXCLUSION_MOVEMENT && cm.PrimaryGroupCensusMember.ZRH_TipoMovimiento__c <> EXCLUSION_MOVEMENT) {
                toExcludeAloneDependantMemberRuts.add(cm.ZRH_Rut__c);
                toExcludeAloneDependantMemberPolicies.add(policyNum);
                toExcludeDependantRutPolicyNumberPrimaryRutToMember.put(cm.ZRH_Rut__c + '-' + policyNum + '-' + cm.PrimaryGroupCensusMember.ZRH_Rut__c, cm);
                toExcludeAloneDependantMembers.add(cm);
            // members to be modified
            } else if (cm.ZRH_TipoMovimiento__c == MODIFICATION_MOVEMENT) {
                toModifyMemberPolicies.add(policyNum);
                toModifyMemberRutToCensusMember.put(cm.ZRH_Rut__c, cm);
                toModifyMemberRutPolicyNumberToCensusMember.put(cm.ZRH_Rut__c + '-' + policyNum, cm);
                toModifyMemberRutPolicyNumberPrimaryRutToCensusMember.put(cm.ZRH_Rut__c + '-' + policyNum + '-' + cm.PrimaryGroupCensusMember.ZRH_Rut__c, cm);
            }
        }

        // -------- ---------- ---------
        // -------- ENROLLMENTS --------
        // -------- ---------- ---------

        // query contract group plans by related quotes
        Map<Id, ContractGroupPlan> cgpIdToCgp = new Map<Id, ContractGroupPlan>();
        Map<String, ContractGroupPlan> policyNumberToCgp = new Map<String, ContractGroupPlan>();
        Set<Id> contractGroupPlanIds = new Set<Id>();
        List<ContractGroupPlan> contractGroupPlans = new ZRH_ContractGroupPlansSelector().selectByRelatedQuotes(quoteIds);
        
        List<ContractGroupPlan> plans = new List<ContractGroupPlan>();
        List<ContractGroupPlan> coverages = new List<ContractGroupPlan>();
        
        for (ContractGroupPlan cgp : contractGroupPlans) {
            cgpIdToCgp.put(cgp.Id, cgp);
            contractGroupPlanIds.add(cgp.Id);
            
            if (cgp.ContractGroupParentPlanId == null ) {
                plans.add(cgp);
                policyNumberToCgp.put(transformPolicyNumber(cgp.ZRH_NumeroDePoliza__c), cgp);
            } else {
                coverages.add(cgp);   
            }
        }
        
        // --- PERSON ACCOUNT UPSERT ---
        // get dependants to be enrolled from primaries to be enrolled
        List<GroupCensusMember> dependantMembers = new ZRH_GroupCensusMemberSelector().selectDependantsFromPrimaryIds(toEnrollPrimaryMemberIds);
        List<GroupCensusMember> dependantMembersToExclude = new ZRH_GroupCensusMemberSelector().selectDependantsFromPrimaryIds(toExcludePrimaryMemberIds);
        
        // all the members in the batch plus the dependants of the primaries to be enrolled will be upserted as person accounts
        List<GroupCensusMember> groupCensusMembersForAccountsWithDupes = new List<GroupCensusMember>();
        List<GroupCensusMember> groupCensusMembersForAccounts = new List<GroupCensusMember>();
        Map<String, GroupCensusMember> uniqueMembersMap = new Map<String, GroupCensusMember>();

        groupCensusMembersForAccountsWithDupes.addAll(censusMembers);
        groupCensusMembersForAccountsWithDupes.addAll(dependantMembers);        
        groupCensusMembersForAccountsWithDupes.addAll(dependantMembersToExclude);        
        
        for (GroupCensusMember gcm : groupCensusMembersForAccountsWithDupes) {
            if (!uniqueMembersMap.containsKey(gcm.ZRH_Rut__c)) {
                uniqueMembersMap.put(gcm.ZRH_Rut__c, gcm);
            }
        }
        groupCensusMembersForAccounts.addAll(uniqueMembersMap.values());
        
        //query person accounts
        List<Account> personAccounts = new ZRH_AccountsSelector().selectByRutsSet(uniqueMembersMap.keySet());
        Map<String,Id> mapRutToAccountId = new Map<String,Id>();
        for (Account acc : personAccounts) {
            mapRutToAccountId.put(acc.ZRH_Rut__c, acc.Id);
        }

        // collections to use with person account
        List<Account> accountsToUpsert = new List<Account>();
        Map<String,Account> censusMemberRutToPersonAccount = new Map<String,Account>();
        
        // for each census member map information to person account 
        for (GroupCensusMember member : groupCensusMembersForAccounts) {
            
            Account acc = mapCensusMemberToPersonAccount(member, recordTypePersonAccount);
            if (mapRutToAccountId.containsKey(member.ZRH_Rut__c)) {
                acc.Id = mapRutToAccountId.get(member.ZRH_Rut__c);
            }
            accountsToUpsert.add(acc);
            censusMemberRutToPersonAccount.put(member.ZRH_Rut__c, acc);
        }
        
        // upsert person accounts
        if (accountsToUpsert.size() > 0) {
            List<Database.UpsertResult> result = Database.upsert(accountsToUpsert, true);
        }

        // map account id to rut
        Map<Id,String> accountIdToMemberRut = new Map<Id,String>();
        for (Account acc : accountsToUpsert) {
            accountIdToMemberRut.put(acc.Id, acc.ZRH_Rut__c);
        }

        // --- INSURANCE POLICY CREATION ---
        List<InsurancePolicy> insurancePoliciesToCreate = new List<InsurancePolicy>();
        insurancePoliciesToCreate = createInsurancePolicies(toEnrollPrimaryMembers, policyNumberToCgp, censusMemberRutToPersonAccount, autoNumberAugmentor);
        if (insurancePoliciesToCreate.size() > 0) {
            List<Database.SaveResult> resultIPs = Database.insert(insurancePoliciesToCreate, true);
        }
        
        // --- INSURANCE POLICY COVERAGE CREATION ---
        List<InsurancePolicyCoverage> insurancePolicyCoveragesToCreate = createInsurancePolicyCoverages(plans, coverages, insurancePoliciesToCreate);
        if (insurancePolicyCoveragesToCreate.size() > 0) {
            List<Database.SaveResult> resultIPCs = Database.insert(insurancePolicyCoveragesToCreate, true);
        }
        
        // --- INSURANCE POLICY PARTICIPANT CREATION ---
        List<InsurancePolicyParticipant> insurancePolicyParticipantsToCreate = new List<InsurancePolicyParticipant>();
        Map<Id, List<GroupCensusMember>> primaryToDependants = mapPrimaryMembersToDependants(dependantMembers);
        
        // create ipp for primaries and their dependants
        System.Formula.recalculateFormulas(insurancePoliciesToCreate);
        for (InsurancePolicy policy : insurancePoliciesToCreate) {
            
            // primary ipp creation
            String primaryPolicy = transformPolicyNumber(policy.ZRH_NumeroDePoliza__c);
            String memberRut = accountIdToMemberRut.get(policy.NameInsuredId);
            String rutPolicyNum = memberRut + '-' + primaryPolicy;
            GroupCensusMember censusMember = toEnrollPrimaryRutPolicyNumberToMember.get(rutPolicyNum);
            
            InsurancePolicyParticipant primaryParticipant = mapGroupCensusMemberAndPolicyToPolicyParticipant(true, censusMember, policy);
            insurancePolicyParticipantsToCreate.add(primaryParticipant);
            
            if (!primaryToDependants.containsKey(censusMember.Id) || primaryToDependants.get(censusMember.Id).size() == 0) {
                continue;
            }
            // primary deps ipp creation
            for (GroupCensusMember dependant : primaryToDependants.get(censusMember.Id)) {
                InsurancePolicyParticipant dependantParticipant = mapGroupCensusMemberAndPolicyToPolicyParticipant(false, dependant, policy);
                dependantParticipant.RelatedParticipantAccountId = censusMemberRutToPersonAccount.get(dependant.ZRH_Rut__c).Id;
                insurancePolicyParticipantsToCreate.add(dependantParticipant);
            }
        }

        // dependants ipp to be created with their primaries already enrolled 
        Map<String, InsurancePolicy> mapPrimaryRutPolicyNumberToInsurancePolicies = new Map<String, InsurancePolicy>();
        List<InsurancePolicy> exisitingPrimaryPolicies = new ZRH_InsurancePolicySelector().selectByPrimaryMembers(toEnrollAloneDependantMemberPrimaryRuts, quoteIds);
        for (InsurancePolicy ip : exisitingPrimaryPolicies) {
            String rutPolicyNum = ip.NameInsured.ZRH_Rut__c + '-' + transformPolicyNumber(ip.ContractGroupPlan.ZRH_NumeroDePoliza__c);
            mapPrimaryRutPolicyNumberToInsurancePolicies.put(rutPolicyNum, ip);
        }
        for (GroupCensusMember gcm : toEnrollAloneDependantMembers) {
            String rutPolicyNum = gcm.PrimaryGroupCensusMember.ZRH_Rut__c + '-' + transformPolicyNumber(gcm.PrimaryGroupCensusMember.ZRH_Poliza__c);
            InsurancePolicy ip = mapPrimaryRutPolicyNumberToInsurancePolicies.get(rutPolicyNum);
            InsurancePolicyParticipant dependantParticipant = mapGroupCensusMemberAndPolicyToPolicyParticipant(false, gcm, ip);
            dependantParticipant.EffectiveDate = dateToDateTime(gcm.PolicyStartDate);
            dependantParticipant.RelatedParticipantAccountId = censusMemberRutToPersonAccount.get(gcm.ZRH_Rut__c).Id;                    
            insurancePolicyParticipantsToCreate.add(dependantParticipant);
        }
        if (insurancePolicyParticipantsToCreate.size() > 0) {
            List<Database.SaveResult> resultIPPs = Database.insert(insurancePolicyParticipantsToCreate, true);
        }
        
        // -------- ---------- --------
        // -------- EXCLUSIONS --------
        // -------- ---------- --------

        // --- INSURANCE POLICY CANCEL ---
        Set<Id> terminatedPolicies = new Set<Id>();
        List<InsurancePolicy> policiesToTerminate = new ZRH_InsurancePolicySelector().selectByPrimaryMemberRutPolicyNumberAndQuoteIds(toExcludePrimaryMemberRuts, toExcludePrimaryMemberPolicies, quoteIds);
        
        for (InsurancePolicy ip : policiesToTerminate) {
            String rutPolicyNum = ip.NameInsured.ZRH_Rut__c + '-' + transformPolicyNumber(ip.ContractGroupPlan.ZRH_NumeroDePoliza__c);

            if (!toExcludePrimaryRutPolicyNumberToMember.containsKey(rutPolicyNum)) {
                continue;
            }
            GroupCensusMember gcm = toExcludePrimaryRutPolicyNumberToMember.get(rutPolicyNum);
            
            ip.OriginalExpirationDate = ip.ExpirationDate;
            ip.ExpirationDate = expirationDate(gcm.ZRH_FechaExclusion__c);
            ip.CancellationDate = cancellationDate(gcm.ZRH_FechaExclusion__c);
            
            ip.Status = CANCELED_STATUS;
            terminatedPolicies.add(ip.Id);
        }
        if (policiesToTerminate.size() > 0) {
            List<Database.SaveResult> resultIPs = Database.update(policiesToTerminate, true);
        }

        // --- INSURANCE POLICY COVERAGE CANCEL ---
        List<InsurancePolicyCoverage> policyCoveragesToTerminate = new ZRH_InsurancePolicyCoverageSelector().selectByInsurancePolicies(terminatedPolicies);
        for (InsurancePolicyCoverage cov : policyCoveragesToTerminate) {
            cov.ExpirationDate = cov.InsurancePolicy.ExpirationDate;
        }
        if (policyCoveragesToTerminate.size() > 0) {
            List<Database.SaveResult> resultIPs = Database.update(policyCoveragesToTerminate, true);
        }

        // --- INSURANCE POLICY PARTICIPANT CANCEL ---
        // from primaries
        List<InsurancePolicyParticipant> policyParticipantsToTerminate = new ZRH_InsurancePolicyParticipantSelector().selectByInsurancePolicies(terminatedPolicies);
        for (InsurancePolicyParticipant ipp : policyParticipantsToTerminate) {
            ipp.ExpirationDate = ipp.InsurancePolicy.ExpirationDate;
            ipp.IsActiveParticipant = false;
        }
        if (policyParticipantsToTerminate.size() > 0) {
            List<Database.SaveResult> resultIPs = Database.update(policyParticipantsToTerminate, true);
        }
        //just dependants
        List<InsurancePolicyParticipant> depPolicyParticipantsToTerminate = new ZRH_InsurancePolicyParticipantSelector().selectByActiveRelatedAccPartsRutsPolicyNumAndSourceQuotes(toExcludeAloneDependantMemberRuts, toExcludeAloneDependantMemberPolicies, quoteIds);
        for (InsurancePolicyParticipant ipp : depPolicyParticipantsToTerminate) {
            String rutPolicyNumPrimaryRut = ipp.RelatedParticipantAccount.ZRH_Rut__c + '-' + transformPolicyNumber(ipp.InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c) + '-' + ipp.PrimaryParticipantAccount.ZRH_Rut__c;
            if (!toExcludeDependantRutPolicyNumberPrimaryRutToMember.containsKey(rutPolicyNumPrimaryRut)) {
                continue;
            }
            ipp.ExpirationDate = toExcludeDependantRutPolicyNumberPrimaryRutToMember.get(rutPolicyNumPrimaryRut).ZRH_FechaExclusion__c;
            ipp.IsActiveParticipant = false;
        }

        if (depPolicyParticipantsToTerminate.size() > 0) {
            List<Database.SaveResult> resultIPs = Database.update(depPolicyParticipantsToTerminate, true);
        }

        // -------- -------------------------------------------- --------
        // -------- MODIFICATION OF INSURANCE POLICY PARTICIPANT --------
        // -------- -------------------------------------------- --------
        // get from this members accs and the insurance policies of this quotes the insurance policy participants to update, and do the match with the members and update
        List<InsurancePolicyParticipant> policyParticipantsToModify = new ZRH_InsurancePolicyParticipantSelector().selectByActivePrimOrRelatedAccPartRutsPolicyNumAndSourceQuotes(toModifyMemberRutToCensusMember.keySet(), toModifyMemberPolicies, quoteIds);
        list<InsurancePolicyParticipant> ippToUpdate = new list<InsurancePolicyParticipant>();

        for (InsurancePolicyParticipant ipp : policyParticipantsToModify) {
            if (ipp.RelatedParticipantAccountId == null) {
                String rutPolicyNum = ipp.PrimaryParticipantAccount.ZRH_Rut__c + '-' + transformPolicyNumber(ipp.InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c);
                if (!toModifyMemberRutPolicyNumberToCensusMember.containsKey(rutPolicyNum)) {
                    continue;
                }
                GroupCensusMember gcm = toModifyMemberRutPolicyNumberToCensusMember.get(rutPolicyNum);
                InsurancePolicyParticipant participantUpdate = mapGroupCensusMemberToPolicyParticipant(ipp.Id, gcm);
                ippToUpdate.add(participantUpdate);
            } else {
                String rutPolicyNumPrimaryRut = ipp.RelatedParticipantAccount.ZRH_Rut__c + '-' + 
                                                transformPolicyNumber(ipp.InsurancePolicy.ContractGroupPlan.ZRH_NumeroDePoliza__c) + '-' + 
                                                ipp.PrimaryParticipantAccount.ZRH_Rut__c;
                if (!toModifyMemberRutPolicyNumberPrimaryRutToCensusMember.containsKey(rutPolicyNumPrimaryRut)) {
                    continue;
                }
                GroupCensusMember gcm = toModifyMemberRutPolicyNumberPrimaryRutToCensusMember.get(rutPolicyNumPrimaryRut);
                InsurancePolicyParticipant participantUpdate = mapGroupCensusMemberToPolicyParticipant(ipp.Id, gcm);
                ippToUpdate.add(participantUpdate);
            }
        }
        if (ippToUpdate.size() > 0) {
            List<Database.SaveResult> resultIPs = Database.update(ippToUpdate, true);
        }

        // -------- UPDATE OF CENSUS MEMBERS WITH CHECKS --------
        // list of members to be updated after inclusions/exclusions
        List<GroupCensusMember> updateMembers = new List<GroupCensusMember>();
        
        // list of members enrolled to be updated as included
        List<GroupCensusMember> toEnrollMembers = new List<GroupCensusMember>();
        toEnrollMembers.addAll(toEnrollPrimaryMembers);
        toEnrollMembers.addAll(dependantMembers);
        toEnrollMembers.addAll(toEnrollAloneDependantMembers);
        
        for (GroupCensusMember gcm : toEnrollMembers) {
            gcm.ZRH_InclusionRealizada__c = true;
            updateMembers.add(gcm);
        }

        // list of members excluded to be updated as excluded
        List<GroupCensusMember> toExcludeMembers = new List<GroupCensusMember>();
        toExcludeMembers.addAll(toExcludePrimaryMembers);
        toExcludeMembers.addAll(dependantMembersToExclude);
        toExcludeMembers.addAll(toExcludeAloneDependantMembers);

        for (GroupCensusMember gcm : toExcludeMembers) {
            gcm.ZRH_ExclusionRealizada__c = true;
            updateMembers.add(gcm);
        }

        // update census members
        List<Database.SaveResult> resultUpdateMembers = Database.update(updateMembers, true);
    }

    /**
    *  @Description: Finish Batch method of the batch
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        21/12/2023  
    */
    public void finish(Database.BatchableContext BC) {

        AsyncApexJob a = new ZRH_AsyncApexJobsSelector().selectById(BC.getJobId())[0];
        List<Quote> quotes = new ZRH_QuotesSelector().selectQuotesForGroup(holdingQuoteId);
        List<Id> quoteIds = new List<Id>();
        for (Quote quote : quotes) {
            quoteIds.add(quote.Id);
        }
        List<Contract> contracts = new ZRH_ContractsSelector().selectContractsBySourceQuoteIds(quoteIds);
        Id holdingContractId;
        String holdingContractNumber;
        String holdingName;
        String holdingCode;
        Set<Id> contractIds = new Set<Id>();
        for (Contract contract : contracts) {
            contractIds.add(contract.Id);
            if (contract.ZRH_ContratoHolding__c == null) {
                holdingContractId = contract.Id;
                holdingContractNumber = contract.ContractNumber;
                holdingName = contract.Account.Name;
                holdingCode = contract.Account.ZRH_CodigoGrupoNegocio__c;
            }
        }
        Id ownerId = UserInfo.getUserId();
        if (a.NumberOfErrors <= 0) {

            String description = NOTIFICATION_TEXT;
            description = description.replace('HOLDING_NAME', holdingCode + ' - ' + holdingName);
            description = description.replace('HOLDING_CONTRACT', holdingContractNumber);
            sendNotification(NOTIFICATION_TITLE, description, holdingContractId, ownerId);

        } else if (a.NumberOfErrors > 0) {
            sendNotification(NOTIFICATION_TITLE_ERROR, NOTIFICATION_TEXT_ERROR, holdingContractId, ownerId);
        }
    }

    /**
    *  @Description: Maps group census member and policy fields to policy participant fields
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        21/12/2023  
    */
    public static InsurancePolicyParticipant mapGroupCensusMemberAndPolicyToPolicyParticipant(Boolean isPrimaryParticipant, GroupCensusMember gcm, InsurancePolicy policy) {
        
        String policyTypeRole = policy.PolicyType == POLICY_TYPE_HEALTH ? PARTICIPANT_HEALTH_ROLE : PARTICIPANT_LIFE_ROLE;
        String primaryRoles = PARTICIPANT_PRIMARY_ROLE + ';' + PARTICIPANT_MEMBER_ROLE + ';' + policyTypeRole;
        String dependantRoles = PARTICIPANT_DEPENDANT_ROLE + ';' + PARTICIPANT_MEMBER_ROLE + ';' + policyTypeRole;
        System.debug('gcm: ' + gcm);
        InsurancePolicyParticipant participant = new InsurancePolicyParticipant();
        participant.RelationshipToInsured = gcm.RelationshipToPrimaryMember;
        participant.vlocity_ins_fsc__ParticipantName__c = gcm.Name; 
        participant.ZRH_Banco__c = gcm.ZRH_Banco__c; 
        participant.ZRH_Capital__c = gcm.ZRH_Capital__c;
        participant.ZRH_CapitalVidaVoluntario__c = gcm.ZRH_CapitalVidaVoluntario__c;
        participant.ZRH_CodigoMonedaRenta__c = gcm.ZRH_CodigoMonedaRenta__c;
        participant.ZRH_FechaConversionCapital__c = gcm.ZRH_FechaConversionCapital__c;
        participant.ZRH_NumeroCuentaBancaria__c = gcm.ZRH_NumeroCuentaBancaria__c;
        participant.ZRH_NumeroRentas__c = gcm.ZRH_NumeroRentas__c;
        participant.ZRH_OmitirRequisitosAsegurabilidad__c = gcm.ZRH_OmitirRequisitosAsegurabilidad__c;
        participant.ZRH_Renta__c = gcm.AnnualEligibleSalary;
        participant.ZRH_TipoCuentaBancaria__c = gcm.ZRH_TipoCuentaBancaria__c;
        participant.ZRH_ValorMonedaConversion__c = gcm.ZRH_ValorMonedaConversion__c;
        participant.ZRH_ValorRentaAsegurado__c = gcm.ZRH_ValorRentaAsegurado__c;
        participant.ZRH_VigenciaHistorica__c = gcm.ZRH_VigenciaHistorica__c;
        participant.InsurancePolicyId = policy.Id;
        participant.PrimaryParticipantAccountId = policy.NameInsuredId;
        participant.EffectiveDate = policy.EffectiveDate;
        participant.ExpirationDate = policy.ExpirationDate;
        participant.IsActiveParticipant = true;
        if (isPrimaryParticipant) {
            participant.Role = primaryRoles;
            participant.RelationshipToInsured = RELATIONSHIP_SELF;
        } else {
            participant.Role = dependantRoles;

        }
        return participant;
    }

    /**
    *  @Description: Maps group census member to policy participant fields
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        15/02/2024
    */
    public static InsurancePolicyParticipant mapGroupCensusMemberToPolicyParticipant(Id ippId , GroupCensusMember gcm) {
        
        InsurancePolicyParticipant participant = new InsurancePolicyParticipant();
        participant.Id = ippId;
        participant.RelationshipToInsured = gcm.RelationshipToPrimaryMember;
        participant.vlocity_ins_fsc__ParticipantName__c = gcm.Name; 
        participant.ZRH_Banco__c = gcm.ZRH_Banco__c; 
        participant.ZRH_Capital__c = gcm.ZRH_Capital__c;
        participant.ZRH_CapitalVidaVoluntario__c = gcm.ZRH_CapitalVidaVoluntario__c;
        participant.ZRH_CodigoMonedaRenta__c = gcm.ZRH_CodigoMonedaRenta__c;
        participant.ZRH_FechaConversionCapital__c = gcm.ZRH_FechaConversionCapital__c;
        participant.ZRH_NumeroCuentaBancaria__c = gcm.ZRH_NumeroCuentaBancaria__c;
        participant.ZRH_NumeroRentas__c = gcm.ZRH_NumeroRentas__c;
        participant.ZRH_OmitirRequisitosAsegurabilidad__c = gcm.ZRH_OmitirRequisitosAsegurabilidad__c;
        participant.ZRH_Renta__c = gcm.AnnualEligibleSalary;
        participant.ZRH_TipoCuentaBancaria__c = gcm.ZRH_TipoCuentaBancaria__c;
        participant.ZRH_ValorMonedaConversion__c = gcm.ZRH_ValorMonedaConversion__c;
        participant.ZRH_ValorRentaAsegurado__c = gcm.ZRH_ValorRentaAsegurado__c;
        participant.ZRH_VigenciaHistorica__c = gcm.ZRH_VigenciaHistorica__c;
        
        return participant;
    }

    /**
    *  @Description: Maps census member fields to person account fields
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        21/12/2023  
    */
    public static Account mapCensusMemberToPersonAccount(GroupCensusMember member, Id accRecordType) {
        Account acc = new Account();
        acc.FirstName = member.FirstName;
        acc.LastName = member.LastName;
        acc.PersonEmail = member.Email;
        acc.BillingStreet = member.Street;
        acc.BillingState = member.State;
        acc.BillingCity = member.City;
        acc.BillingCountry = member.Country;
        acc.BillingPostalCode = member.PostalCode;
        acc.PersonBirthdate = member.Birthdate;
        acc.FinServ__Gender__pc = member.Gender;
        acc.ZRH_NivelEscolaridad__pc = member.ZRH_NivelEscolaridad__c;
        acc.PersonMobilePhone = transformMobileNumber(member.PhoneNumber);
        acc.PersonOtherPhone = member.ZRH_NumeroTelefonoAlternativo__c;
        acc.ZRH_Rut__c = member.ZRH_Rut__c;
        acc.RecordTypeId = accRecordType;

        return acc;
    }

    /**
    *  @Description: Send notification
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        12/21/2023  
    */
    public static void sendNotification(String title, String description, String recordId, String userId){
        CustomNotificationType notificacion = [Select Id from CustomNotificationType where DeveloperName = :NAME_CUSTOM_NOTIFICATION]; 
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(description);
        notification.setNotificationTypeId(notificacion.Id);
        notification.setTargetId( recordId ); 
        notification.send(new Set<String> { userId }); 
    }

    /**
    *  @Description: Maps primary census members to its dependants
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        12/21/2023  
    */
    public static Map<Id, List<GroupCensusMember>> mapPrimaryMembersToDependants(List<GroupCensusMember> dependantMembers) {
        Map<Id, List<GroupCensusMember>> primaryToDependants = new Map<Id, List<GroupCensusMember>>();
        for (GroupCensusMember gcm : dependantMembers) {
            if (!primaryToDependants.containsKey(gcm.PrimaryGroupCensusMemberId)) {
                primaryToDependants.put(gcm.PrimaryGroupCensusMemberId, new List<GroupCensusMember>());
            }
            primaryToDependants.get(gcm.PrimaryGroupCensusMemberId).add(gcm);
        }   

        return primaryToDependants;
    }

    /**
    *  @Description: Gets set of ids from a list of SObjects
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        12/21/2023  
    */
    public static Set<Id> extractIdsFromSObject(List<SObject> records) {
        Set<Id> ids = new Set<Id>();
        for (SObject record : records) {
            ids.add(record.Id);
        }
        return ids;
    }

    /**
    *  @Description: Creates insurance policies for primary members given their group census member plans
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        12/21/2023  
    */
    public static List<InsurancePolicy> createInsurancePolicies(List<GroupCensusMember> primaryMembers, Map<String, ContractGroupPlan> policyNumberToCgp, Map<String, Account> memberRutToAccount, Integer autoNumberAugmentor) {
        List<InsurancePolicy> insurancePoliciesToCreate = new List<InsurancePolicy>();
        for (GroupCensusMember primaryMember : primaryMembers) {
            
            if (!policyNumberToCgp.containsKey(transformPolicyNumber(primaryMember.ZRH_Poliza__c))) {
                continue;
            }
            ContractGroupPlan cgp = policyNumberToCgp.get(transformPolicyNumber(primaryMember.ZRH_Poliza__c));


            InsurancePolicy policy = new InsurancePolicy();
            policy.NameInsuredId = memberRutToAccount.get(primaryMember.ZRH_Rut__c).Id;
            policy.ContractGroupPlanId = cgp.Id;
            policy.ProductId = cgp.vlocity_ins_fsc__Product2Id__c;
            policy.Name = cgp.ZRH_Folio__c + ' ' + autoNumberAugmentor;
            policy.Status = POLICY_STATUS;
            policy.EffectiveDate = dateToDateTime(primaryMember.PolicyStartDate);
            policy.ExpirationDate = dateToDateTime(cgp.Contract.EndDate);
            policy.PolicyName = POLICY_NAME_SUBSTR + primaryMember.Name;
            policy.PolicyType = cgp.vlocity_ins_fsc__Product2Id__r.vlocity_ins__Type__c;
            policy.SourceQuoteId = cgp.Contract.SourceQuoteId;
            policy.vlocity_ins_fsc__AttributesSelectedValues__c = cgp.vlocity_ins_fsc__AttributeSelectedValues__c;

            insurancePoliciesToCreate.add(policy);
            autoNumberAugmentor += 1;
        }

        return insurancePoliciesToCreate;
    }

    /**
    *  @Description: creates insurance policy coverages for the policies given the coverages related
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        12/21/2023  
    */
    public static List<InsurancePolicyCoverage> createInsurancePolicyCoverages(List<ContractGroupPlan> plans, List<ContractGroupPlan> coverages, List<InsurancePolicy> insurancePolicies) {
                
        Map<Id,List<ContractGroupPlan>> cgpToCgpCoverages = new Map<Id,List<ContractGroupPlan>>();
        for (ContractGroupPlan plan : plans) {
            if (!cgpToCgpCoverages.containsKey(plan.Id)) {
                cgpToCgpCoverages.put(plan.Id, new List<ContractGroupPlan>());
            }
        }
        for (ContractGroupPlan coverage : coverages) {
            cgpToCgpCoverages.get(coverage.ContractGroupParentPlanId).add(coverage);
        }
        
        List<InsurancePolicyCoverage> insurancePolicyCoveragesToCreate = new List<InsurancePolicyCoverage>();
        for (InsurancePolicy policy : insurancePolicies) {
            Id relatedCgp = policy.ContractGroupPlanId;
            if (!cgpToCgpCoverages.containsKey(relatedCgp) || cgpToCgpCoverages.get(relatedCgp).size() == 0) {
                continue;
            }
            for (ContractGroupPlan coverage : cgpToCgpCoverages.get(relatedCgp)) {
                InsurancePolicyCoverage policyCov = new InsurancePolicyCoverage();
                policyCov.InsurancePolicyId = policy.Id;
                policyCov.ContractGroupPlanId = coverage.Id;
                policyCov.EffectiveDate = policy.EffectiveDate;
                policyCov.ExpirationDate = policy.ExpirationDate;
                policyCov.CoverageName = coverage.Name;
                policyCov.vlocity_ins_fsc__AttributesSelectedValues__c = coverage.vlocity_ins_fsc__AttributeSelectedValues__c;
                policyCov.vlocity_ins_fsc__Product2Id__c = coverage.vlocity_ins_fsc__Product2Id__c;

                insurancePolicyCoveragesToCreate.add(policyCov);

            }
        }

        return insurancePolicyCoveragesToCreate;
    }

    /**
    *  @Description: Create local date time from date
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        21/12/2023  
    */
    public static DateTime dateToDateTime(Date selectedDate) {
        DateTime outDateTime;
        if (selectedDate == null) {
            return outDateTime;
        }

        Integer d = selectedDate.day();
        Integer mo = selectedDate.month();
        Integer yr = selectedDate.year();
        outDateTime = DateTime.newInstance(yr, mo, d);

        return outDateTime;
    }    

    /**
    *  @Description: Create cancellation date time
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        13/02/2024  
    */
    public static DateTime cancellationDate(Date fechaTerminacion) {
        Integer d = fechaTerminacion.day();
        Integer mo = fechaTerminacion.month();
        Integer yr = fechaTerminacion.year();
        DateTime cancellationDate = DateTime.newInstance(yr, mo, d);

        return cancellationDate;
    }

    /**
    *  @Description: Create expiration date time
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        13/02/2024  
    */
    public static DateTime expirationDate(Date fechaTerminacion) {  
        Date previousDayDate = fechaTerminacion.addDays(-1);

        Integer prevDay = previousDayDate.day();
        Integer prevMonth = previousDayDate.month();
        Integer prevYear = previousDayDate.year();
        DateTime expirationDate = DateTime.newInstance(prevYear, prevMonth, prevDay, 23, 59, 59);
        return expirationDate;
    }

    /**
    *  @Description: Transform policy number (folio + dv + period) into folio + period
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        13/02/2024  
    */
    public static String transformPolicyNumber(String policyNumber) {  
        // Split the string by "-"
        String[] parts = String.isNotBlank(policyNumber) ? policyNumber.split('-') : new String[3];
        
        // Check if the string is in folio + dv + period
        if(parts.size() == 3) {
            // If there are three parts, assume format is folio-dv-period and reconstruct without dv
            return parts[0] + '-' + parts[2];
        } else {
            // If not in expected format (no dv), return the policyNumber string unchanged
            return policyNumber;
        }
    }

    /**
    *  @Description: Transform phone number 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        18/04/2024  
    */
    public static String transformMobileNumber(String mobileNumber) {  
        if (mobileNumber == null) {
            return null;
        }
        String newMobileNumber;
        switch on mobileNumber.length() {
            when 8 {		
                newMobileNumber = '+569' + mobileNumber;
            }	
            when 9 {
                newMobileNumber = '+56' + mobileNumber;
            }
            when 11 {		
                newMobileNumber = '+' + mobileNumber;
            }
            when 12 {
                newMobileNumber = mobileNumber;
            }
            when else {		  
                newMobileNumber = null;
            }
        }
        return newMobileNumber;
    }   
}