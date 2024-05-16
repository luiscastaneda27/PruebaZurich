import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin';
import getBatchJobStatus from '@salesforce/apex/ZRH_BatchProgressIndicator.getBatchJobStatus';

export default class zrh_batchProgressIndicator extends OmniscriptBaseMixin(LightningElement) {
    
    @api omniJsonData;
    @api batchJobId;
    totalJobItems;
    jobItemsProcessed;
    numberOfErrors;

    renderedCallback() {
        console.log('batchJobId: ', this.batchJobId);
        //Call async apex job record in a time interval to see progress
        var intervalId = setInterval(() => {
            getBatchJobStatus({jobID: this.batchJobId})
                .then((result) => {
                    console.log('job result: ', JSON.stringify(result));
                    
                    this.totalJobItems = result.TotalJobItems;
                    this.jobItemsProcessed = result.JobItemsProcessed;
                    this.numberOfErrors = result.NumberOfErrors;

                    if (this.jobItemsProcessed == this.totalJobItems || this.numberOfErrors > 0 ) {
                        clearInterval(intervalId);
                    }

                })
                .catch((error) => {
                    console.log('error: ', JSON.stringify(error));
                    
                })
        }, 2000);
    }

    get jobProgress() {
        return Math.round((this.jobItemsProcessed / this.totalJobItems) * 100);
    }

    get errorsFound() {
        return this.numberOfErrors > 0;
    }

}