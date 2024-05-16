public inherited sharing class ZRH_GroupCensusMemberSelector extends fflib_SObjectSelector{
    
    public Schema.SObjectType getSObjectType() {
        return GroupCensusMember.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                GroupCensusMember.Id,
                GroupCensusMember.PrimaryGroupCensusMemberId,
                GroupCensusMember.GroupClassId,
                GroupCensusMember.RelationshipToPrimaryMember,
                GroupCensusMember.FirstName,
                GroupCensusMember.LastName,
                GroupCensusMember.Name,
                GroupCensusMember.Email,
                GroupCensusMember.Birthdate,
                GroupCensusMember.Gender,
                GroupCensusMember.PhoneNumber,
                GroupCensusMember.Street,
                GroupCensusMember.State,
                GroupCensusMember.City,
                GroupCensusMember.Country,
                GroupCensusMember.PostalCode,
                GroupCensusMember.PolicyStartDate,
                GroupCensusMember.AnnualEligibleSalary,
                GroupCensusMember.ZRH_Banco__c,
                GroupCensusMember.ZRH_Capital__c,
                GroupCensusMember.ZRH_CapitalVidaVoluntario__c,
                GroupCensusMember.ZRH_CodigoMonedaRenta__c,
                GroupCensusMember.ZRH_ClaveSincronizacion__c,
                GroupCensusMember.ZRH_Estado__c,
                GroupCensusMember.ZRH_FechaConversionCapital__c,
                GroupCensusMember.ZRH_NivelEscolaridad__c,
                GroupCensusMember.ZRH_NumeroCuentaBancaria__c,
                GroupCensusMember.ZRH_NumeroRentas__c,
                GroupCensusMember.ZRH_NumeroTelefonoAlternativo__c,
                GroupCensusMember.ZRH_OmitirRequisitosAsegurabilidad__c,
                GroupCensusMember.ZRH_Rut__c,
                GroupCensusMember.ZRH_TipoCuentaBancaria__c,
                GroupCensusMember.ZRH_TipoMovimiento__c,
                GroupCensusMember.ZRH_ValorMonedaConversion__c,
                GroupCensusMember.ZRH_ValorRentaAsegurado__c,
                GroupCensusMember.ZRH_VigenciaHistorica__c,
                GroupCensusMember.ZRH_FechaExclusion__c,
                GroupCensusMember.ZRH_InclusionRealizada__c,
                GroupCensusMember.ZRH_ExclusionRealizada__c,
                GroupCensusMember.ZRH_Poliza__c,
                GroupCensusMember.ZRH_TipoMovimiento__c
            };
    }

    public Database.QueryLocator selectGroupMembersByCensusIds(Set<Id> groupCensusIds) {      
        return Database.getQueryLocator(
            newQueryFactory(false, false, true)
            .selectField(GroupCensusMember.Id)
            .selectField(GroupCensusMember.PrimaryGroupCensusMemberId)
            .selectField(GroupCensusMember.GroupClassId)
            .selectField(GroupCensusMember.RelationshipToPrimaryMember)
            .selectField(GroupCensusMember.FirstName)
            .selectField(GroupCensusMember.LastName)
            .selectField(GroupCensusMember.Name)
            .selectField(GroupCensusMember.Email)
            .selectField(GroupCensusMember.Birthdate)
            .selectField(GroupCensusMember.Gender)
            .selectField(GroupCensusMember.PhoneNumber)
            .selectField(GroupCensusMember.Street)
            .selectField(GroupCensusMember.State)
            .selectField(GroupCensusMember.City)
            .selectField(GroupCensusMember.Country)
            .selectField(GroupCensusMember.PostalCode)
            .selectField(GroupCensusMember.PolicyStartDate)
            .selectField(GroupCensusMember.AnnualEligibleSalary)
            .selectField(GroupCensusMember.ZRH_Banco__c)
            .selectField(GroupCensusMember.ZRH_Capital__c)
            .selectField(GroupCensusMember.ZRH_CapitalVidaVoluntario__c)
            .selectField(GroupCensusMember.ZRH_CodigoMonedaRenta__c)
            .selectField(GroupCensusMember.ZRH_ClaveSincronizacion__c)
            .selectField(GroupCensusMember.ZRH_Estado__c)
            .selectField(GroupCensusMember.ZRH_FechaConversionCapital__c)
            .selectField(GroupCensusMember.ZRH_NivelEscolaridad__c)
            .selectField(GroupCensusMember.ZRH_NumeroCuentaBancaria__c)
            .selectField(GroupCensusMember.ZRH_NumeroRentas__c)
            .selectField(GroupCensusMember.ZRH_NumeroTelefonoAlternativo__c)
            .selectField(GroupCensusMember.ZRH_OmitirRequisitosAsegurabilidad__c)
            .selectField(GroupCensusMember.ZRH_Rut__c)
            .selectField(GroupCensusMember.ZRH_TipoCuentaBancaria__c)
            .selectField(GroupCensusMember.ZRH_TipoMovimiento__c)
            .selectField(GroupCensusMember.ZRH_ValorMonedaConversion__c)
            .selectField(GroupCensusMember.ZRH_ValorRentaAsegurado__c)
            .selectField(GroupCensusMember.ZRH_VigenciaHistorica__c)
            .setCondition('GroupCensusMember.GroupCensusId IN :groupCensusIds AND PrimaryGroupCensusMemberId = null')
            .toSOQL()
        );
    }

    public List<GroupCensusMember> selectGroupMembersByCensusIdsToInclude(Set<Id> groupCensusIds) {      
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(GroupCensusMember.Id);
        query.selectField(GroupCensusMember.PrimaryGroupCensusMemberId);
        query.selectField(GroupCensusMember.GroupClassId);
        query.selectField(GroupCensusMember.RelationshipToPrimaryMember);
        query.selectField(GroupCensusMember.FirstName);
        query.selectField(GroupCensusMember.LastName);
        query.selectField(GroupCensusMember.Name);
        query.selectField(GroupCensusMember.Email);
        query.selectField(GroupCensusMember.Birthdate);
        query.selectField(GroupCensusMember.Gender);
        query.selectField(GroupCensusMember.PhoneNumber);
        query.selectField(GroupCensusMember.Street);
        query.selectField(GroupCensusMember.State);
        query.selectField(GroupCensusMember.City);
        query.selectField(GroupCensusMember.Country);
        query.selectField(GroupCensusMember.PostalCode);
        query.selectField(GroupCensusMember.PolicyStartDate);
        query.selectField(GroupCensusMember.AnnualEligibleSalary);
        query.selectField(GroupCensusMember.ZRH_Banco__c);
        query.selectField(GroupCensusMember.ZRH_Capital__c);
        query.selectField(GroupCensusMember.ZRH_CapitalVidaVoluntario__c);
        query.selectField(GroupCensusMember.ZRH_CodigoMonedaRenta__c);
        query.selectField(GroupCensusMember.ZRH_ClaveSincronizacion__c);
        query.selectField(GroupCensusMember.ZRH_Estado__c);
        query.selectField(GroupCensusMember.ZRH_FechaConversionCapital__c);
        query.selectField(GroupCensusMember.ZRH_NivelEscolaridad__c);
        query.selectField(GroupCensusMember.ZRH_NumeroCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_NumeroRentas__c);
        query.selectField(GroupCensusMember.ZRH_NumeroTelefonoAlternativo__c);
        query.selectField(GroupCensusMember.ZRH_OmitirRequisitosAsegurabilidad__c);
        query.selectField(GroupCensusMember.ZRH_Rut__c);
        query.selectField(GroupCensusMember.ZRH_TipoCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_TipoMovimiento__c);
        query.selectField(GroupCensusMember.ZRH_ValorMonedaConversion__c);
        query.selectField(GroupCensusMember.ZRH_ValorRentaAsegurado__c);
        query.selectField(GroupCensusMember.ZRH_VigenciaHistorica__c);
        query.selectField(GroupCensusMember.ZRH_FechaExclusion__c);
        query.selectField(GroupCensusMember.ZRH_InclusionRealizada__c);
        query.selectField(GroupCensusMember.ZRH_Poliza__c);
        query.selectField('PrimaryGroupCensusMember.ZRH_Rut__c');
        query.selectField('PrimaryGroupCensusMember.ZRH_Poliza__c');
        query.setCondition(
            'GroupCensusMember.GroupCensusId IN :groupCensusIds ' +
            'AND ZRH_TipoMovimiento__c = \'Inclusión\' ' +
            'AND ZRH_InclusionRealizada__c = false ' +
            'AND (PrimaryGroupCensusMemberId = null OR PrimaryGroupCensusMember.ZRH_InclusionRealizada__c = true)'
        );
        return (List<GroupCensusMember>) Database.query( query.toSOQL() );
    }

    public List<GroupCensusMember> selectGroupMembersByCensusIdsToExclude(Set<Id> groupCensusIds) {      
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(GroupCensusMember.Id);
        query.selectField(GroupCensusMember.PrimaryGroupCensusMemberId);
        query.selectField(GroupCensusMember.GroupClassId);
        query.selectField(GroupCensusMember.RelationshipToPrimaryMember);
        query.selectField(GroupCensusMember.FirstName);
        query.selectField(GroupCensusMember.LastName);
        query.selectField(GroupCensusMember.Name);
        query.selectField(GroupCensusMember.Email);
        query.selectField(GroupCensusMember.Birthdate);
        query.selectField(GroupCensusMember.Gender);
        query.selectField(GroupCensusMember.PhoneNumber);
        query.selectField(GroupCensusMember.Street);
        query.selectField(GroupCensusMember.State);
        query.selectField(GroupCensusMember.City);
        query.selectField(GroupCensusMember.Country);
        query.selectField(GroupCensusMember.PostalCode);
        query.selectField(GroupCensusMember.PolicyStartDate);
        query.selectField(GroupCensusMember.AnnualEligibleSalary);
        query.selectField(GroupCensusMember.ZRH_Banco__c);
        query.selectField(GroupCensusMember.ZRH_Capital__c);
        query.selectField(GroupCensusMember.ZRH_CapitalVidaVoluntario__c);
        query.selectField(GroupCensusMember.ZRH_CodigoMonedaRenta__c);
        query.selectField(GroupCensusMember.ZRH_ClaveSincronizacion__c);
        query.selectField(GroupCensusMember.ZRH_Estado__c);
        query.selectField(GroupCensusMember.ZRH_FechaConversionCapital__c);
        query.selectField(GroupCensusMember.ZRH_NivelEscolaridad__c);
        query.selectField(GroupCensusMember.ZRH_NumeroCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_NumeroRentas__c);
        query.selectField(GroupCensusMember.ZRH_NumeroTelefonoAlternativo__c);
        query.selectField(GroupCensusMember.ZRH_OmitirRequisitosAsegurabilidad__c);
        query.selectField(GroupCensusMember.ZRH_Rut__c);
        query.selectField(GroupCensusMember.ZRH_TipoCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_TipoMovimiento__c);
        query.selectField(GroupCensusMember.ZRH_ValorMonedaConversion__c);
        query.selectField(GroupCensusMember.ZRH_ValorRentaAsegurado__c);
        query.selectField(GroupCensusMember.ZRH_VigenciaHistorica__c);
        query.selectField(GroupCensusMember.ZRH_FechaExclusion__c);
        query.selectField(GroupCensusMember.ZRH_ExclusionRealizada__c);
        query.selectField(GroupCensusMember.ZRH_Poliza__c);
        query.selectField(GroupCensusMember.ZRH_TipoMovimiento__c);
        query.selectField('PrimaryGroupCensusMember.ZRH_Rut__c');
        query.selectField('PrimaryGroupCensusMember.ZRH_Poliza__c');
        query.selectField('PrimaryGroupCensusMember.ZRH_TipoMovimiento__c');
        query.setCondition('GroupCensusMember.GroupCensusId IN :groupCensusIds ' + 
                           'AND ZRH_TipoMovimiento__c = \'Exclusión\'' + 
                           'AND (PrimaryGroupCensusMemberId = null OR PrimaryGroupCensusMember.ZRH_TipoMovimiento__c <> \'Exclusión\')' + 
                           'AND ZRH_ExclusionRealizada__c = false');
        return (List<GroupCensusMember>) Database.query( query.toSOQL() );
    }

    public List<GroupCensusMember> selectGroupMembersByCensusIdsToModify(Set<Id> groupCensusIds) {      
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(GroupCensusMember.Id);
        query.selectField(GroupCensusMember.PrimaryGroupCensusMemberId);
        query.selectField(GroupCensusMember.GroupClassId);
        query.selectField(GroupCensusMember.RelationshipToPrimaryMember);
        query.selectField(GroupCensusMember.FirstName);
        query.selectField(GroupCensusMember.LastName);
        query.selectField(GroupCensusMember.Name);
        query.selectField(GroupCensusMember.Email);
        query.selectField(GroupCensusMember.Birthdate);
        query.selectField(GroupCensusMember.Gender);
        query.selectField(GroupCensusMember.PhoneNumber);
        query.selectField(GroupCensusMember.Street);
        query.selectField(GroupCensusMember.State);
        query.selectField(GroupCensusMember.City);
        query.selectField(GroupCensusMember.Country);
        query.selectField(GroupCensusMember.PostalCode);
        query.selectField(GroupCensusMember.PolicyStartDate);
        query.selectField(GroupCensusMember.AnnualEligibleSalary);
        query.selectField(GroupCensusMember.ZRH_Banco__c);
        query.selectField(GroupCensusMember.ZRH_Capital__c);
        query.selectField(GroupCensusMember.ZRH_CapitalVidaVoluntario__c);
        query.selectField(GroupCensusMember.ZRH_CodigoMonedaRenta__c);
        query.selectField(GroupCensusMember.ZRH_ClaveSincronizacion__c);
        query.selectField(GroupCensusMember.ZRH_Estado__c);
        query.selectField(GroupCensusMember.ZRH_FechaConversionCapital__c);
        query.selectField(GroupCensusMember.ZRH_NivelEscolaridad__c);
        query.selectField(GroupCensusMember.ZRH_NumeroCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_NumeroRentas__c);
        query.selectField(GroupCensusMember.ZRH_NumeroTelefonoAlternativo__c);
        query.selectField(GroupCensusMember.ZRH_OmitirRequisitosAsegurabilidad__c);
        query.selectField(GroupCensusMember.ZRH_Rut__c);
        query.selectField(GroupCensusMember.ZRH_TipoCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_TipoMovimiento__c);
        query.selectField(GroupCensusMember.ZRH_ValorMonedaConversion__c);
        query.selectField(GroupCensusMember.ZRH_ValorRentaAsegurado__c);
        query.selectField(GroupCensusMember.ZRH_VigenciaHistorica__c);
        query.selectField(GroupCensusMember.ZRH_FechaExclusion__c);
        query.selectField(GroupCensusMember.ZRH_Poliza__c);
        query.selectField('PrimaryGroupCensusMember.ZRH_Rut__c');
        query.selectField('PrimaryGroupCensusMember.ZRH_Poliza__c');
        query.setCondition('GroupCensusMember.GroupCensusId IN :groupCensusIds AND ZRH_TipoMovimiento__c = \'Modificación\'');
        return (List<GroupCensusMember>) Database.query( query.toSOQL() );
    }

    public List<GroupCensusMember> selectDependantsFromPrimaryIds(Set<Id> primaryMemberIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(GroupCensusMember.Id);               
        query.selectField(GroupCensusMember.PrimaryGroupCensusMemberId);   
        query.selectField(GroupCensusMember.GroupClassId);  
        query.selectField(GroupCensusMember.RelationshipToPrimaryMember);  
        query.selectField(GroupCensusMember.FirstName);
        query.selectField(GroupCensusMember.LastName);
        query.selectField(GroupCensusMember.Name);
        query.selectField(GroupCensusMember.Email);
        query.selectField(GroupCensusMember.Birthdate);
        query.selectField(GroupCensusMember.Gender);
        query.selectField(GroupCensusMember.PhoneNumber);
        query.selectField(GroupCensusMember.Street);
        query.selectField(GroupCensusMember.State);
        query.selectField(GroupCensusMember.City);
        query.selectField(GroupCensusMember.Country);
        query.selectField(GroupCensusMember.PostalCode);
        query.selectField(GroupCensusMember.PolicyStartDate);
        query.selectField(GroupCensusMember.AnnualEligibleSalary);
        query.selectField(GroupCensusMember.ZRH_Banco__c);
        query.selectField(GroupCensusMember.ZRH_Capital__c);
        query.selectField(GroupCensusMember.ZRH_CapitalVidaVoluntario__c);
        query.selectField(GroupCensusMember.ZRH_CodigoMonedaRenta__c);
        query.selectField(GroupCensusMember.ZRH_ClaveSincronizacion__c);
        query.selectField(GroupCensusMember.ZRH_Estado__c);
        query.selectField(GroupCensusMember.ZRH_FechaConversionCapital__c);
        query.selectField(GroupCensusMember.ZRH_NivelEscolaridad__c);
        query.selectField(GroupCensusMember.ZRH_NumeroCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_NumeroRentas__c);
        query.selectField(GroupCensusMember.ZRH_NumeroTelefonoAlternativo__c);
        query.selectField(GroupCensusMember.ZRH_OmitirRequisitosAsegurabilidad__c);
        query.selectField(GroupCensusMember.ZRH_Rut__c);
        query.selectField(GroupCensusMember.ZRH_TipoCuentaBancaria__c);
        query.selectField(GroupCensusMember.ZRH_TipoMovimiento__c);
        query.selectField(GroupCensusMember.ZRH_ValorMonedaConversion__c);
        query.selectField(GroupCensusMember.ZRH_ValorRentaAsegurado__c);
        query.selectField(GroupCensusMember.ZRH_VigenciaHistorica__c);
        query.selectField('PrimaryGroupCensusMember.GroupClassId');
        query.setCondition('PrimaryGroupCensusMemberId IN :primaryMemberIds');
        return (List<GroupCensusMember>) Database.query( query.toSOQL() );
    }

    public List<GroupCensusMember> selectPrimaryMembersFromRutsAndCensusIds(Set<String> primaryMemberRuts, Set<Id> censusIds) { 
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField(GroupCensusMember.Id);               
        query.selectField(GroupCensusMember.GroupCensusId);               
        query.setCondition('ZRH_Rut__c IN :primaryMemberRuts AND GroupCensusId IN :censusIds');
        return (List<GroupCensusMember>) Database.query( query.toSOQL() );
    }

}