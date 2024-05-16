import { api, track } from 'lwc';
import pubsub from 'vlocity_ins/pubsub';
import { commonUtils, dataFormatter } from 'vlocity_ins/insUtility';
import LABELS from './zrh_insQuoteGroupClassesLabels.js';
import InsQuoteGroupClassesService from './zrh_insQuoteGroupClassesService.js';
import insQuoteGroupClasses from 'vlocity_ins/insQuoteGroupClasses'

export default class zrh_insQuoteGroupClasses extends insQuoteGroupClasses {
    @api theme = 'slds';
    @api isReadonly;
    @api rootChannel;
    @api unsavedRootItems;
    @api unsavedChildItems;
    @api
    get product() {
        return this._product;
    }
    set product(data) {
        this._product = data;
        this.groupClasses = JSON.parse(JSON.stringify(data.groupClasses || []));
        dataFormatter.sortByKey(this.groupClasses, 'Name');
    }

    @track groupClasses = [];

    isLoaded = true;
    labels = {...LABELS};
    insQuoteGroupClassesService = new InsQuoteGroupClassesService();

    connectedCallback() {
        this.labels.removeGroupClass = this.labels.InsRemoveFrom.replace('{0}', this.product.Name);
    }

    openModal() {
        this.isLoaded = false;
        this.insQuoteGroupClassesService.getGroupClasses(this.product.QuoteId, this.product.quoteLineItemId)
        .then(response => {
            const { groupClassFields, groupClasses } = JSON.parse(response);
            this.template.querySelector('.vloc-ins-group-classes-modal').openModal(groupClassFields, groupClasses);
        })
        .catch(error => commonUtils.showErrorToast.call(this, error))
        .finally(() => this.isLoaded = true);
    }

    removeQliGroupClass(e) {
        if (this.unsavedRootItems || this.unsavedChildItems) {
            commonUtils.showErrorToast.call(this, "Guardar los cambios pendientes antes de agregar o quitar roles.");
            return;
        }
        this.isLoaded = false;
        const qliGroupClassId = e.currentTarget.dataset.groupClassId;
        this.insQuoteGroupClassesService.removeQliGroupClass(qliGroupClassId)
        .then(() => {
            const index = this.groupClasses.findIndex(groupClass => groupClass.Id === qliGroupClassId);
            this.groupClasses.splice(index, 1);
            this.updateGroupClasses();
        })
        .catch(error => commonUtils.showErrorToast.call(this, error))
        .finally(() => this.isLoaded = true);
    }

    associateGroupClassesToLine(e) {
        if (this.unsavedRootItems || this.unsavedChildItems) {
            commonUtils.showErrorToast.call(this, "Guardar los cambios pendientes antes de agregar o quitar roles.");
            return;
        }
        this.isLoaded = false;
        const selectedRows = e.detail;
        const groupClassIds = selectedRows.map(row => row.Id);
        this.insQuoteGroupClassesService.associateGroupClassesToLine(this.product.QuoteId, this.product.quoteLineItemId, groupClassIds)
        .then(response => {
            const lineGroupClassIds = JSON.parse(response).lineGroupClassIds;
            // manually update ids and rows instead of making a new backend call
            lineGroupClassIds.forEach((qliGroupClassId, i) => {
                selectedRows[i].Id = qliGroupClassId;
            });
            this.groupClasses = this.groupClasses.concat(selectedRows);
            dataFormatter.sortByKey(this.groupClasses, 'Name');
            this.updateGroupClasses();
        })
        .catch(error => commonUtils.showErrorToast(this, error))
        .finally(() => this.isLoaded = true);
    }

    updateGroupClasses() {
        const payload = {
            productId: this.product.Id,
            groupClasses: this.groupClasses
        };
        pubsub.fire(this.rootChannel, 'updateGroupClasses', payload);
        commonUtils.showSuccessToast.call(this, this.labels.InsProductSuccessfullyUpdatedQuoteLineItems);
    }
}