/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 14/03/2024
Description  : Query factory for CronTrigger using "FFLIB – Selector layer"
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Andrés Deus                       AD
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      AD            14/03/2024       initial version
********************************************************************************/
public class ZRH_CronTriggerSelector extends fflib_SObjectSelector {

    /**
    *  @Description: Defines the type of object handled in the selector
    *  @Author:       Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        14/03/2024
    */
    public Schema.SObjectType getSObjectType(){
        return CronTrigger.sObjectType;
    }

    /**
    *  @Description: Defines the fields that will be queried in a default query
    *  @Author:       Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        14/03/2024
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            CronTrigger.Id,
            CronTrigger.CronExpression,
            CronTrigger.TimesTriggered,
            CronTrigger.NextFireTime,
            CronTrigger.PreviousFireTime,
            CronTrigger.State,
            CronTrigger.CronJobDetailId
        };
    }

    /**
    *  @Description: Select CronTrigger records by job name
    *  @Author:       Andrés Deus, Deloitte, adeusme@deloitte.com
    *  @Date:        14/03/2024
    */
    public List<CronTrigger> selectByJobName(String jobName) {
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectFields(getSObjectFieldList());
        query.setCondition('CronJobDetail.Name = :jobName');
        return (List<CronTrigger>) Database.query( query.toSOQL() );
    }
}