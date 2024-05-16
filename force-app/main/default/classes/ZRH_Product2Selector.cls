/*********************************************************************************
Project      : Zurich Salesforce - Seguros colectivos
Created By   : Deloitte
Created Date : 26/03/2023
Description  : Query factory for Product2 using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			26/03/2023		initial version
********************************************************************************/
public without sharing class ZRH_Product2Selector extends fflib_SObjectSelector{

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/03/2023
    */
    public Schema.SObjectType getSObjectType() {
        return Product2.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/03/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product2.Id,
            Product2.Description,
            Product2.Name,
            Product2.ProductCode,
            Product2.RecordTypeId
        };
    }

    /**
    *  @Description: Performs a query with fields defined in the method with the Product Code as a condition
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/03/2023
    */
    public List<Product2> selectByProductCode(String str) {
        return (List<Product2>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(Product2.Id)
            .selectField(Product2.Description)
            .selectField(Product2.Name)
            .selectField(Product2.ProductCode)
            .selectField(Product2.RecordTypeId)
            .setCondition('ProductCode = :str')
            .toSOQL()
      );
    }
}