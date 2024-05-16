public with sharing class ZRH_AsyncApexJobsSelector extends fflib_SObjectSelector {

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        28/08/2023
    */
    public Schema.SObjectType getSObjectType() {
        return AsyncApexJob.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        28/08/2023
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AsyncApexJob.Id,
            AsyncApexJob.Status,
            AsyncApexJob.NumberOfErrors,
            AsyncApexJob.JobItemsProcessed,
            AsyncApexJob.TotalJobItems,
            AsyncApexJob.ExtendedStatus
        };
    }

    /**
    *  @Description: Performs a query with fields defined in the method with the id as a condition
    *  @Autor:       Mateo Long, Deloitte, mlongg@deloitte.com
    *  @Date:        28/08/2023
    */
    public List<AsyncApexJob> selectById(Id id) {
        return (List<AsyncApexJob>) Database.query(
            newQueryFactory(false, false, true)
            .selectField(AsyncApexJob.Status)
            .selectField(AsyncApexJob.NumberOfErrors)
            .selectField(AsyncApexJob.JobItemsProcessed)
            .selectField(AsyncApexJob.TotalJobItems)
            .selectField(AsyncApexJob.ExtendedStatus)
            .selectField('CreatedBy.Email')
            .setCondition('Id = :id')
            .toSOQL()
      );
    }
}