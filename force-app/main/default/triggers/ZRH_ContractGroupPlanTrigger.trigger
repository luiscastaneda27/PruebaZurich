/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/03/2024
Description  : Trigger for object ContractGroupPlan
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.			      ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      ATO         27/03/2024	    	Initial Version
********************************************************************************/
trigger ZRH_ContractGroupPlanTrigger on ContractGroupPlan (before insert, after insert, before update, after update, before delete, after delete) {
	fflib_SObjectDomain.triggerHandler(ZRH_ContractGroupPlan.class);
}