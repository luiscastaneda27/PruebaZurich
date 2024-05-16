import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin'
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
//import getAccount from '@salesforce/apex/ZRH_MassPolicyDownloadController.getAccounts';

export default class Zrh_MassPolicyDownload extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {

    @api objectApiName;
    @api recordId;
    @track accountsOptions = [];
    @track yearOptions = [];
    @track monthOptions = [];
    @track selectedObject;
    @track selectedYear;
    @track selectedMonth;
    @track recordList;
    @track data;
    @track pageNumber = 1;
    @track recordSize = '10';
    @track totalRecords;
    @track totalPages;
    @track showSpinner = true;
    @track selectedFiles = new Set();
    @api omniJsonData;
    //@track

    @track dataDownload = {};

    connectedCallback() {

        var result = JSON.parse(this.omniJsonData.responseApexClass);
        this.dataDownload.showFolioFilter = true;
        this.dataDownload.showAccountFilter = true;
        this.dataDownload.accountsOptions = result.accountList;
        this.dataDownload.plansOptions = result.plansList;
        this.dataDownload.isHolding = result.isHolding;
        this.dataDownload.selectedAccount = !this.dataDownload.isHolding ? this.omniJsonData.ContextId : null;
        var recordList = [];

        for(let i = 0; i < result.contractList.length; i++) {
            if(result.contractList[i].ContractGroupPlans != null ){
                result.contractList[i].ContractGroupPlans = result.contractList[i].ContractGroupPlans.records;
                for(let j = 0; j < result.contractList[i].ContractGroupPlans.length; j++){
                    if(result.contractList[i].ContractGroupPlans[j].ZRH_Folio__c != null){
                        let folio = result.contractList[i].ContractGroupPlans[j].ZRH_Folio__c;
                        folio = folio.includes('-') ? folio.split('-')[0] : folio;
                        for(let w = 0; w < result.documentList.length; w++){
                            let titleFile = result.documentList[w].ContentDocument.Title;
                            if(titleFile != null && titleFile.includes(folio)){
                                result.documentList[w].folio = result.contractList[i].ContractGroupPlans[j].ZRH_Folio__c;
                                result.documentList[w].accountName = result.contractList[i].Account.Name;
                                result.documentList[w].accountId = result.contractList[i].AccountId;
                                result.documentList[w].peroid = result.contractList[i].ContractGroupPlans[j].ZRH_Periodo__c;
                                result.documentList[w].planCode = result.contractList[i].ContractGroupPlans[j].ZRH_CodigoProducto__c;
                                result.documentList[w].startDate = result.contractList[i].StartDate;
                                result.documentList[w].endDate = result.contractList[i].EndDate;
                                recordList.push(result.documentList[w]);
                            }
                        }
                    }
                }
            }            
        }
        this.dataDownload.documentList = recordList;
        this.showSpinner = false;
        this.fetchDocumentRecords();
    }

    handleChange(event){
        const name = event.target.name;
        const value = event.detail.value != null && event.detail.value.trim() != '' ? event.detail.value.trim() : null;
        if(name == "folio"){
            this.dataDownload.selectedFolio = value;
        }else if(name == "account"){
            this.dataDownload.selectedAccount = value;
        }else if(name == "period"){
            this.dataDownload.selectedPeriod = value;
        }else if(name == "plan"){
            this.dataDownload.selectedPlan= value;
        }else if(name == "dateFrom"){
            this.dataDownload.selectedDateFrom = value;
        }else if(name == "dateExpiry"){
            this.dataDownload.selectedDateExpiry = value;
        }
        this.typeFilter();
        this.fetchDocumentRecords();
    }

    typeFilter(){
        this.dataDownload.showFolioFilter = false;
        this.dataDownload.showAccountFilter = false;
        if(this.dataDownload.selectedFolio != null){
            this.dataDownload.showFolioFilter = true;
        }else {
            this.dataDownload.showAccountFilter = true;
            if((!this.dataDownload.isHolding || this.dataDownload.selectedAccount == null) &&
            this.dataDownload.selectedDateExpiry == null && this.dataDownload.selectedDateFrom == null && 
            this.dataDownload.selectedPlan == null && this.dataDownload.selectedPeriod == null ){
                this.dataDownload.showFolioFilter = true;
            }
        }
    }
    get totalFiles() {
        return this.data.length;
    }

    get recordSizeList() {
        let recordSizeList = [];
        recordSizeList.push({'label':'10', 'value':'10'});
        recordSizeList.push({'label':'25', 'value':'25'});
        recordSizeList.push({'label':'50', 'value':'50'});
        recordSizeList.push({'label':'100', 'value':'100'});
        return recordSizeList;
    }

    get disablePreviousButton() {
        if(!this.data || this.data.length == 0 || this.pageNumber == 1)
            return true;
    }

    get disableNextButton() {
        if(!this.data || this.data.length == 0 || this.pageNumber == this.totalPages)
            return true;
    }

    get disableRecordDropdown() {
        if(!this.data || this.data.length == 0)
            return true;
    }

    downloadFiles() {
        if(this.selectedFiles && this.selectedFiles.size > 0) {
            for(let item of this.selectedFiles) {
                this.download(item);
            }
            this.showNotification('Se han descargado exitosamente'+' '+ this.selectedFiles.size +' '+'Polizas', 'success');    
        } else {
            this.showNotification('Debe seleccionar al menos una Póliza', 'error');
        }
    }

    handleCheckbox(event) {
        let checkbox = this.template.querySelectorAll('[data-id="headerCheckbox"]');
        if(this.selectedFiles.has(event.target.name) && !event.target.checked) {
            checkbox[0].checked = false;
            this.selectedFiles.delete(event.target.name);
        } else {
            this.selectedFiles.add(event.target.name);
            if(this.selectedFiles.size == this.recordList.length) {
                checkbox[0].checked = true;
            }
        }
    }

    handleHeaderCheckbox(event) {
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for(let i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
        }
        
        for(let i = 0; i < this.recordList.length; i++) {
            if(event.target.checked) {
                this.selectedFiles.add(this.recordList[i].ContentDocumentId);
            } else {
                this.selectedFiles.delete(this.recordList[i].ContentDocumentId);
            }
        }
        this.headerCheckbox = true;
    }

    resetCheckboxes() {
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for(let i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = false;
        }
        let headerCheckbox = this.template.querySelectorAll('[data-id="headerCheckbox"]');
        if(headerCheckbox && headerCheckbox.length > 0)
            headerCheckbox[0].checked = false;
    }

    handleRecordSizeChange(event) {
        this.recordSize = event.detail.value;
        this.pageNumber = 1;
        this.totalPages = Math.ceil(this.totalRecords / Number(this.recordSize));
        this.processRecords();
    }

    handleNavigation(event){
        let buttonName = event.target.name;
        if(buttonName == 'Next') {
            this.pageNumber = this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        } else if(buttonName == 'Previous') {
            this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;
        }
        this.processRecords();
    }

    processRecords() {
        this.selectedFiles = new Set();
        this.resetCheckboxes();
        this.showSpinner = true;
        var uiRecords = [];
        var startLoop = ((this.pageNumber - 1) *  Number(this.recordSize));
        var endLoop =  (this.pageNumber *  Number(this.recordSize) >= this.totalRecords) ? this.totalRecords : this.pageNumber *  Number(this.recordSize);
        for(var i = startLoop; i < endLoop; i++) {
            uiRecords.push(JSON.parse(JSON.stringify(this.data[i])));
        }
        this.recordList = JSON.parse(JSON.stringify(uiRecords));
        this.showSpinner = false;
    }

    fetchDocumentRecords() {
        this.showSpinner = true;
        this.pageNumber = 1;
        this.recordList = [];
        this.data = [];
        this.selectedFiles = new Set();
        this.resetCheckboxes();
        var result = [];
        for(let w = 0; w < this.dataDownload.documentList.length; w++){
            let flogAdd = true;
            let file = this.dataDownload.documentList[w];
            if((this.dataDownload.selectedFolio != null && !file.folio.includes(this.dataDownload.selectedFolio)) ||
               (this.dataDownload.selectedAccount != null && file.accountId != this.dataDownload.selectedAccount) ||
               (this.dataDownload.selectedPeriod != null && file.peroid != this.dataDownload.selectedPeriod) ||
               (this.dataDownload.selectedPlan != null && file.planCode != this.dataDownload.selectedPlan) ||
               (this.dataDownload.selectedDateFrom != null && !this.dateCompareFrom(this.dataDownload.selectedDateFrom, file.startDate)) ||
               (this.dataDownload.selectedDateExpiry != null && !this.dateCompareExpiry(this.dataDownload.selectedDateExpiry, file.endDate))){
                flogAdd = false
            }
            if(flogAdd == true){
                result.push(file);
            }
        }
        
        if(result && result.length > 0) {
            for(var i = 0; i < result.length; i++) {
                var contentSize = result[i].ContentDocument.ContentSize;
                var size = (contentSize >= 1024) ? ((contentSize/1024 >= 1024) ? (Number(contentSize/1048576).toFixed(2) + ' MB') : (Number(contentSize/1024).toFixed(2) + ' KB')) : (Number(contentSize).toFixed(2) + ' Bytes');
                result[i].size = size;
                result[i].count = i+1;
                result[i].check = false;
            }
            this.totalRecords = result.length;
            this.totalPages = Math.ceil(Number(result.length)/Number(this.recordSize));
            this.data = JSON.parse(JSON.stringify(result));
            
            var uiRecords = [];
            var recordDisplaySize = result.length < Number(this.recordSize) ? result.length : Number(this.recordSize);
            for(var i = 0; i < recordDisplaySize; i++) {
                uiRecords.push(JSON.parse(JSON.stringify(result[i])));
            }
            this.recordList = JSON.parse(JSON.stringify(uiRecords));
        }else{
            this.recordList = null;
        }
        this.showSpinner = false;
    }

    showNotification(message, variant) {
        const evt = new ShowToastEvent({
            'message': message,
            'variant': variant
        });
        this.dispatchEvent(evt);
    }

    navigateToRecordViewPage(event) {
        if(event.currentTarget.dataset.key) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.currentTarget.dataset.key,
                    objectApiName: 'ContentDocument',
                    actionName: 'view'
                }
            });
        }
    }

    downloadFile(event) {
        if(event.target.name) {
            this.download(event.target.name);
        }
    }

    download(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin + '/sfc/servlet.shepherd/document/download/' + recordId
            }
        }, false);
    }

    dateCompareFrom(date1, date2){
        if(date1 <= date2){
            return true
        }else{
            return false;
        }
    }

    dateCompareExpiry(date1, date2){
        if(date1 >= date2){
            return true
        }else{
            return false;
        }
    }
}