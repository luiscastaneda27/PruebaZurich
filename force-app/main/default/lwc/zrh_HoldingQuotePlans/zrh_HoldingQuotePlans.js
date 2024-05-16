// wireGetRelatedListRecords.js
import { LightningElement, wire, api} from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Quote.Id','Quote.ZRH_AprobacionPendiente__c'];
export default class zrh_HoldingQuotePlans extends LightningElement {
    @api recordId;
    error;
    records;
    popTarificacion = false;
    seeRate = false;
    pendingApproval
    quoteId;
    perfill;

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'QuoteLineItems',
        fields: ['QuoteLineItem.Id','QuoteLineItem.ZRH_CodigoProducto__c','QuoteLineItem.vlocity_ins__ProductName__c','QuoteLineItem.ZRH_TipoTarifa__c']
    })listInfo({ error, data }) {
        if (data) {
            this.records = data.records;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredQuote({ error, data }) {
        if (error) {
        } else if (data) {
            this.quoteId = data.fields.Id.value;
            this.pendingApproval = data.fields.ZRH_AprobacionPendiente__c.value;
            if(this.pendingApproval)
            { 
               
                this.seeRate=false;
            }
            else { 
               
                this.seeRate=true;
            }
        }
    }

    onClickTarificacion(event){
        const idValue = event.target.dataset.rec;
        this.perfill = '\{"ContextId":"' + idValue + '"}';
        this.popTarificacion = true;
    }

    cancel(){
        this.popTarificacion = false;
    }
}