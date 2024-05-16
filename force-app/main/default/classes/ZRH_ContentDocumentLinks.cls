/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 23/10/2023
Description  : Handler Class for ContentDocumentLink
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Josue Alejandro Aguilar     JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      JAA         23/10/2023		    	Initial Version
********************************************************************************/
public class ZRH_ContentDocumentLinks extends fflib_SObjectDomain{
    
    public ZRH_ContentDocumentLinks(List<ContentDocumentLink> sObjectList){
        Super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<Sobject> sObjectList){
            return new ZRH_ContentDocumentLinks(sObjectList);
        }
    }
    
    public override void onAfterInsert() {
        ZRH_ContentDocumentLinksServices.validateUploaFile(records);
        ZRH_ContentDocumentLinksServices.updateFlagPDF(records);
    }
}