import { LightningElement, wire, track,api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_OBJECT from '@salesforce/schema/Quote'; 
import PREEXISTENCIA_FIELD from '@salesforce/schema/Quote.ZRH_CualesPreexistencias__c';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin';

export default class MultiSelectPicklist extends OmniscriptBaseMixin(LightningElement) {
    @track lstSelected = [];
    @track lstOptions = [];
    @api outputNode;
    @api outputNodePrueba;
    @track  employee = {};  
      
    result = [];

    connectedCallback() {
  
    }

    // Get Object Info.
    @wire (getObjectInfo, {objectApiName: QUOTE_OBJECT})
    quoteObjectInfo;

    // Get Picklist values.
    @wire(getPicklistValues, {recordTypeId: '$quoteObjectInfo.data.defaultRecordTypeId', fieldApiName: PREEXISTENCIA_FIELD })
    preexistencias(data, error){
        if(data && data.data && data.data.values){
            
            data.data.values.forEach( objPicklist => {
                this.employee = {};  
               this.lstSelected.push( objPicklist.value);
                this.employee["Name"] = objPicklist.value;
                this.result.push(this.employee);

                this.lstOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                
                });
            });
            //this.omniApplyCallResp({[this.outputNode]:this.lstSelected});
           this.omniApplyCallResp({[this.outputNode]:this.lstSelected.sort()});
          this.omniApplyCallResp({[this.outputNodePrueba]:this.result});   
        } else if(error){
            console.log(error);
        }
    };

    handleChange(event) {
        this.result = [];
        this.employee = {};  
        this.lstSelected = event.detail.value;
        this.lstSelected.forEach( objPicklist2 => {
            this.employee = {};  
            this.employee["Name"] = objPicklist2;
            this.result.push(this.employee);
        }); 
        this.omniApplyCallResp({[this.outputNode]:this.lstSelected});
        this.omniApplyCallResp({[this.outputNodePrueba]:this.result});
    }
}