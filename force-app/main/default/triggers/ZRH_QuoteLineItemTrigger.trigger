/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 18/03/2024
Description  : Trigger for object QuoteLineItem
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Josue Alejandro Aguilar      JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      JAA         18/03/2024		    	Initial Version
********************************************************************************/
trigger ZRH_QuoteLineItemTrigger on QuoteLineItem (before insert, after insert, before update, after update, before delete, after delete) {
	fflib_SObjectDomain.triggerHandler(ZRH_QuoteLineItems.class);
}