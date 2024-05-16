public abstract class ZRH_AbstractBatch implements Database.Batchable<SObject>, Database.Stateful {

    String query;
    
    public void setQuery(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }

    public abstract void execute(Database.BatchableContext context, SObject[] scope);

    public abstract void finish(Database.BatchableContext context);

}