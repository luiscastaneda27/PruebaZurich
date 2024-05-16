import { api, track } from 'lwc';
import { dataFormatter } from 'vlocity_ins/insUtility';
import insQuoteCoverageListTemplate from './zrh_insQuoteCoverageList.html';
import insQuoteCoverageList from 'vlocity_ins/insQuoteCoverageList';

export default class zrh_insQuoteCoverageList extends insQuoteCoverageList { 
    @api
    get childProducts() {
        return this._childProducts;
    }

    set childProducts(data) {
        this._childProducts = data;
        if (this.childProducts && this.childProducts.length) {
            this.coverageSpecs = this.childProducts.filter(childProduct => {
                const recordType = dataFormatter.getNamespacedProperty(childProduct, 'RecordTypeName__c');
                return recordType === 'CoverageSpec';
            });
        } else {
            this.coverageSpecs = [];
        }
    }

    @track coverageSpecs = [];

    // deprecated properties
    @api currencySymbol;

    render() {
        return insQuoteCoverageListTemplate;
    }
}