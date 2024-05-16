/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 23/10/2023
Description  : Service Class for ContentDocumentLink
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Josue Alejandro Aguilar     JAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      JAA         23/10/2023		    	Initial Version
********************************************************************************/

public class ZRH_ContentDocumentLinksServices {
    
    /**
*  @Description: Static variables
*  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
*  @Date:        1/12/2023  
*/
    private static final String PDF_FILE_TYPE = 'PDF';
    private static final String PS_PROPOSITION = 'ZRH_PermisosProposition';
    private static final String PS_OPERATIONS = 'ZRH_PermisosOperaciones';
    private static final String PF_ADMINISTRATOR = 'System Administrator';
    private static final String PF_ADMINISTRATOR_ES = 'Administrador del sistema';
    
    
    
    /**
*  @Description: Method to update flag for PDF file in Quote
*  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
*  @Date:        23/10/2023  
*/
    public static void updateFlagPDF(List<ContentDocumentLink> documentList){
        List<Id> quoteIds = new List<Id>();
        Map<Id, String> mapQuotes = new Map<Id, String>();
        for (ContentDocumentLink cdl : documentList) {
            if (cdl.LinkedEntityId.getSObjectType() == Quote.sObjectType) {
                ContentDocument cd = [SELECT Id, FileType, Title FROM ContentDocument WHERE Id = :cdl.ContentDocumentId];
                if (cd.FileType == PDF_FILE_TYPE) {
                    quoteIds.add(cdl.LinkedEntityId);
                    mapQuotes.put(cdl.LinkedEntityId, cd.Title);
                }
            }
        }
        
        if(!quoteIds.isEmpty()){
            String replaceText = '.' + PDF_FILE_TYPE.toLowerCase();
            List<Quote> quotesToUpdate = new List<Quote>();
            for(Quote item: DataBase.query(new ZRH_QuotesSelector().selectQuotesByIds(quoteIds).getQuery())){
                String nameQuote = item.Name.subString(2, item.Name.length());
                String nameFile = mapQuotes.get(item.Id).replace(replaceText,'');
                if(nameQuote == nameFile){
                    quotesToUpdate.add(new Quote(Id = item.Id, ZRH_PDFCreado__c = true));
                }
            }
            update quotesToUpdate;
        }
    }
    
    /**
*  @Description: Method to validate upload file for permission set
*  @Autor:       JN, Deloitte, jnietom@deloitte.com
*  @Date:        12/01/2024  
*/
    public static void validateUploaFile(List<ContentDocumentLink> documentList){
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if(profileName != PF_ADMINISTRATOR && profileName != PF_ADMINISTRATOR_ES){
            PermissionSetAssignment[]  listPermisionId= [SELECT PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() and (PermissionSet.Name= :PS_PROPOSITION or PermissionSet.Name= :PS_OPERATIONS)];
            for (ContentDocumentLink cdl : documentList) {
                if (cdl.LinkedEntityId.getSObjectType() == Quote.sObjectType) {
                    if(listPermisionId.size() > 0){
                        cdl.addError('');  
                        
                    }
                }
                
            }
        }
        return;
    }
    
}