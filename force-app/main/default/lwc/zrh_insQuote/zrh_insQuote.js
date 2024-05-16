import {api, track, wire } from 'lwc';
import pubsub from 'vlocity_ins/pubsub';
import { namespace } from 'vlocity_ins/utility';
import LOCALE from '@salesforce/i18n/locale';
import { LABELS } from './zrh_insQuoteLabels.js';
import { commonUtils, dataFormatter } from 'vlocity_ins/insUtility';
import InsQuoteService from './zrh_insQuoteService.js';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import insQuote from 'vlocity_ins/insQuote';
import { OmniscriptActionCommonUtil } from 'vlocity_ins/omniscriptActionUtils';
import GETUTILITY from '@salesforce/resourceUrl/ZRH_ValidatorUtility';
import { loadScript } from 'lightning/platformResourceLoader';
import getQuoteLineItemGroupClasses from '@salesforce/apex/ZRH_insQuoteController.getQuoteLineItemGroupClasses';
import getRootQuoteLineItems from '@salesforce/apex/ZRH_insQuoteController.getRootQuoteLineItems';
import getRootIdToCoverageCountQuoteLineItems from '@salesforce/apex/ZRH_insQuoteController.getRootIdToCoverageCountQuoteLineItems';
import maxNumberOfPlansLabel from '@salesforce/label/c.ZRH_NumeroPlanesCotizacion';

const ENDORSEMENT = 'Endorsement';
const NEW_BUSINESS = 'New Business';

export default class Zrh_insQuote extends insQuote {
    @api recordId;
    @api enableDebugMode;
    @api priceQuoteAsync;
    @api showActions;
    @api showProductButton;
    @api enableClone;
    @api enableDelete;
    @api editPanelMode;
    @api isMultiRoot;
    @api enableGroupClasses;
    @api useRatingFact;
    @api isBatchMode;
    @api showCoverageDescriptions;

    @track isLoaded = false;
    @track rootLineItem;
    @track disableReprice;
    @track rootLineItems = [];
    @track inDebugMode;
    @track options = {
        // default state options
        isReadonly: false,
        isDeletable: true,
    };

    _actionUtil;
    numberOfPlans;
    maxNumberOfPlans = maxNumberOfPlansLabel;

    //recreation of getAllLines
    rootQlis = [];
    qliGroupClasses = [];

    error;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [PROFILE_NAME_FIELD],
    })
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userProfile = data.fields.Profile.displayValue;
        }
    }

    theme = 'slds';
    rootDetails;
    labels = LABELS;
    currency = dataFormatter.currency;
    userProfile;
    pubsubPayload = {
        addRootProduct: this.addRootProduct.bind(this),
        refreshQuote: this.refreshQuote.bind(this),
        toggleRootLine: this.toggleRootLine.bind(this),
        updateReprice: this.updateReprice.bind(this),
        openProductList: this.openProductList.bind(this),
        debugMode: this.debugMode.bind(this),
        removeRootProduct: this.removeRootProduct.bind(this),
        updateGroupClasses: this.updateGroupClasses.bind(this),
    };
    insQuoteService = new InsQuoteService();
    // OS form integration
    omniscriptAction = {
        data: this.handleOmniAction.bind(this),
    };

    // State transition channel
    stateChange = {
        stateChange: this.handleStateTransition.bind(this),
    };

    // Action channel
    issuePolicy = {
        issuePolicy: this.handleIssuePolicy.bind(this),
    };

    repriceQuote = {
        repriceQuote: this.getAllLines.bind(this),
    };


    connectedCallback() {
        if (!this.rootQuoteChannel) {
            this.rootQuoteChannel = `insuranceQuote-${this.recordId}-
            ${Date.now()}`;
        }
        pubsub.register(this.rootQuoteChannel, this.pubsubPayload);
        pubsub.register(`stateTransitionChannel-${this.recordId}`, this.stateChange);
        pubsub.register(`repriceQuote-${this.recordId}`, this.repriceQuote);

        // Listens to `refreshProductList` from omniscript
        pubsub.register('omniscript_action', this.omniscriptAction);

        // Listens to `policy_action` from Action component
        pubsub.register('policy_action', this.issuePolicy);

        this._actionUtil = new OmniscriptActionCommonUtil();
        
        // get root qlis
        getRootQuoteLineItems({quoteId: this.recordId})
            .then((response) => {
                this.rootQlis = response;
                this.numberOfPlans = response.length;      
                this.loadPlans();
            })
            .catch((message) => {
                console.log('getRootQuoteLineItems error: ' + message);
            }) 
    }

    //Loads plans by quote id or quote line items depending on amount of plans
    loadPlans() {          
        console.log('numberOfPlans: ' + this.numberOfPlans);
        console.log('maxNumberOfPlans: ' + this.maxNumberOfPlans);
        
        if (this.numberOfPlans > this.maxNumberOfPlans) {
            commonUtils.showSuccessToast.call(this, 'Debido al gran número de planes, el proceso de carga puede tardar');
            console.log('FETCH DATA BY QUOTE LINE ITEM');
            // FETCH DATA BY QUOTE LINE ITEM
            this.getAllLinesByQuoteLineItem();
        
        } else {

            console.log('FETCH DATA BY QUOTE ID');
            // FETCH DATA BY QUOTE ID
            this.getAllLinesByQuoteId();
        }   
    }

    // BY QUOTE LINE ITEM
    async getAllLinesByQuoteLineItem() {
        return  this.fetchDataByQuoteLineItem()
        .then((response) => {
            return this.formatLineItems(response);  
        })
        .catch((message) => {
            commonUtils.showErrorToast.call(this, 'Ocurrió un error al cargar los planes, contacte a su administrador');
            commonUtils.showErrorToast.call(this, message);
            this.isLoaded = false;
        })
    }

    async fetchDataByQuoteLineItem() {
        try {
            
            //get qli group classes
            const qliGroupClassesData = await getQuoteLineItemGroupClasses({quoteId: this.recordId});
            this.qliGroupClasses = qliGroupClassesData;

            //get root qlis
            const rootQlis = await getRootQuoteLineItems({quoteId: this.recordId});
            this.rootQlis = rootQlis;

            //get root qli coverage count
            const qliRootToCoverageCount = await getRootIdToCoverageCountQuoteLineItems({quoteId: this.recordId});
    
            this._actionUtilClass = new OmniscriptActionCommonUtil();
            const records = [];
            let quoteDetails;

            for (const qli of this.rootQlis) {
                let groupClasses = [];
                
                // get line details
                const response = await this.getLineDetailsByQuoteLineItem(this.recordId, qli);
                let record = response.result.productConfigurationDetail.records[0];
                
                if (this.qliGroupClasses.length > 0) {
                    groupClasses = this.qliGroupClasses.filter(gc => gc.vlocity_ins__QuoteLineItemId__c === record.quoteLineItemId);
                    const simplifiedGroupClasses = groupClasses.map(gc => ({
                        Id: gc.Id,
                        Name: gc.vlocity_ins__GroupClassId__r.Name
                    }));
                    record.groupClasses = simplifiedGroupClasses;
                }

                record.childProducts = {totalSize: 0};
                record.hasCoverages = true;
                record.coverageCount = qliRootToCoverageCount[qli];
                records.push(record);

                // quoteDetails just once
                if (!quoteDetails) {
                    quoteDetails = response.result.quoteDetail;
                }
            }

            const lines = {
                allLines: {records: records},
                quoteDetail: quoteDetails
            }
            return lines;

        } catch (error) {
            console.log('Error fetchDataByQuoteLineItem: ' + JSON.stringify(error));
        }
    }

    async getLineDetailsByQuoteLineItem(quoteId, quoteLineItemId) {
        const params = {
            input: '{}',
            sClassName: 'InsQuoteService',
            sMethodName: 'getQuoteDetail',
            options: {quoteId: quoteId, quoteLineItemId: quoteLineItemId, disableChildProducts: true},
        };
    
        try {
            const response = await this._actionUtilClass.executeAction(params, null, this, null, null);
            return response;
        } catch (error) {
            console.log('Error getLineDetailsByQuoteLineItem : ' + error);
        }
    }   

    // BY QUOTE ID
    async getAllLinesByQuoteId() {
        // return  this.fetchDataByQuoteId()
        //     .then((response) => {
        //         return this.formatLineItems(response);
        //     });
        return this.fetchDataByQuoteId()
            .then((response) => {
               return this.formatLineItems(response); 
            })
            .catch((message) => {
                commonUtils.showErrorToast.call(this, 'Ocurrió un error al cargar los planes, contacte a su administrador');
                commonUtils.showErrorToast.call(this, message);
                this.isLoaded = false;
            })
    }

    async fetchDataByQuoteId() {
        try {
            //get qli group classes
            const qliGroupClassesData = await getQuoteLineItemGroupClasses({quoteId: this.recordId});
            this.qliGroupClasses = qliGroupClassesData;

            //get root qli coverage count
            const qliRootToCoverageCount = await getRootIdToCoverageCountQuoteLineItems({quoteId: this.recordId});

            //get qlis
            const response = await this.getLineDetailsByQuoteId();
            let quoteDetails = response.result.IPResult.getQuoteDetail.quoteDetail;
            let qlis;
            if ('records' in response.result.IPResult.getQuoteDetail.productConfigurationDetail) {
                qlis = response.result.IPResult.getQuoteDetail.productConfigurationDetail.records;
            } else {
                const lines = {
                    allLines: {},
                    quoteDetail: quoteDetails
                }
                return lines;    
            }

            
            for (let qli of qlis) {
                let groupClasses = [];
                if (this.qliGroupClasses.length > 0) {
                    groupClasses = this.qliGroupClasses.filter(gc => gc.vlocity_ins__QuoteLineItemId__c === qli.quoteLineItemId);
                    const simplifiedGroupClasses = groupClasses.map(gc => ({
                        Id: gc.Id,
                        Name: gc.vlocity_ins__GroupClassId__r.Name
                    }));
                    qli.groupClasses = simplifiedGroupClasses;
                }
                qli.childProducts = {totalSize: 0};
                qli.hasCoverages = true;
                qli.coverageCount = qliRootToCoverageCount[qli.Id];
            }

            const lines = {
                allLines: {records: qlis},
                quoteDetail: quoteDetails
            }
            return lines;    
        } catch (error) {
            console.log('Error fetchDataByQuoteId: ' + JSON.stringify(error));
        }
        
    }
    
    async getLineDetailsByQuoteId() {
        const params = {
            input: {
                quoteId: this.recordId
            },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhConsultaPlanesCotizacion_SegurosColectivos",
            options: {
                queueableChainable: true
            }
        }
        try {
            const response = await this._actionUtil.executeAction(params, null, this, null, null);
            return response;
        } catch (error) {
            console.log('Error getLineDetailsByQuoteId: ' + JSON.stringify(error));
        }
    }

    renderedCallback() {
        loadScript(this, GETUTILITY)
        .then(() => console.log('Loaded GETUTILITY'))
        .catch(error => console.log('error: ' + JSON.stringify(error)));
    }

    /**
     * Fetches root product and child instances
     */
    getAllLines(needQuoteHeader = false, needState = false) {
        return this.insQuoteService
            .getAllLines(this.recordId, needQuoteHeader, needState, this.enableGroupClasses)
            .then((response) => {
                return this.formatLineItems(response);
            });
    }

    refreshQuote(isLoaded = false) {
        this.isLoaded = isLoaded;
        this.refreshGetAllLine = false;
        // return this.getAllLines(true, false);
        return this.loadPlans();
    }

    updateReprice(payload) {
        const index = this.rootLineItems.findIndex((item) => item.Id === payload.Id);
        this.rootLineItems[index].needReprice = payload.needReprice;
        this.refreshGetAllLine = true;
    }

    removeRootProduct(payload) {
        this.numberOfPlans = this.numberOfPlans - 1;
        console.log('removeRootProduct numberOfPlans:' + this.numberOfPlans);
        const index = this.rootLineItems.findIndex((item) => item.Id === payload.Id);
        this.rootLineItems.splice(index, 1);
    }

    /**
     * Formats line items (does not include coverage and attributes)
     * @param {string} data stringified response from getAllLines
     */
    formatLineItems(data) {
        let hasRenderedLargeGroup = {};
        if (this.rootLineItems.length) {
            hasRenderedLargeGroup = this.rootLineItems.reduce((obj, item) => {
                obj[item.Id] = item.renderDetails;
                return obj;
            }, {});
        }
        this.rootLineItems = [];
        // DONT PARSE DATA, IT IS ALREADY PARSED
        // const result = JSON.parse(data);
        const result = data;
        // On initial load we get allLines for records and quoteDetail for quote fields
        if (result.quoteDetail) {
            const quoteType = dataFormatter.getNamespacedProperty(result.quoteDetail, 'Type__c');
            this.quoteType = quoteType || NEW_BUSINESS;
            const quoteDetail = result.quoteDetail;
            this.handleNetChange(quoteDetail);
        }

        if (result.stateDetail) {
            const { noDelete, noUpdate, stateName } = result.stateDetail;
            this.options.isDeletable = !noDelete; // if is true, allow items to be removed
            this.options.isReadonly = noUpdate; // if true, do not allow items to be edited
            this.options.stateName = stateName;
        }

        this.options.showCovDescriptions = this.showCoverageDescriptions;

        this.setRootLineItems(result, hasRenderedLargeGroup);
        this.isLoaded = true;
    }

    setRootLineItems(result, hasRenderedLargeGroup) {
        const response = result.allLines || result;
        if (response && response.records) {
            response.records.sort(dataFormatter.displaySequenceSort);
            this.rootLineItems = response.records.map((rootLine) => {
                rootLine.userProfile = this.userProfile; // Evaluate profile rules in top-down rule design (insClientRules)
                rootLine.renderDetails = hasRenderedLargeGroup[rootLine.Id];
                return rootLine;
            });
        }
    }

    /**
     * Handles debug panel for rules
     */
    debugMode() {
        this.inDebugMode = !this.inDebugMode ? true : false;
    }

    /**
     * Refresh data when omniscript sends `refreshProductList`
     */
    handleOmniAction(data) {
        if (data.refreshProductList) {
            console.log('handleOmniAction');
            // this.getAllLines();
            this.loadPlans();
            this.closeRecordEditor();
        }
    }

    /**
     * Updates quote readonly and is deletable status when state is changed
     */
    handleStateTransition() {
        console.log('handleStateTransition');
        this.rootDetails = false;
        // this.getAllLines(true, true);
        this.loadPlans();
    }

    /**
     * Launches issue policy and FSC modal
     */
    handleIssuePolicy(payload) {
        const isFsc = payload && payload.isFsc;
        const modal = this.template.querySelector('.vloc-ins-policy-management');
        if (payload.recordId === this.recordId) {
            if (isFsc !== modal.isFsc) {
                modal.isFsc = isFsc;
                modal.hasRendered = false;
            }
            modal.openEditor();
        }
    }

    handleNetChange(data) {
        this.netChange = {
            daysRemaining: this.labels.InsQuoteDaysRemaining.replace('{0}', data[`${namespace}DaysRemaining__c`]),
            effectiveDate: this.formatDate(data[`${namespace}EffectiveDate__c`]),
            endDate: this.formatDate(data[`${namespace}EndDate__c`]),
            priceNetDifference: data[`${namespace}TotalAmountTermDifference__c`],
            isNetPositive: Math.sign(this.priceNetDifference) === 1,
            totalPremiumForTerm: data[`${namespace}TotalPremiumforTerm__c`],
            totalPremiumTermDifference: data[`${namespace}TotalPremiumTermDifference__c`] || 0,
            totalTaxTermDifference: data[`${namespace}TotalTaxTermDifference__c`],
            totalFeeTermDifference: data[`${namespace}TotalFeeTermDifference__c`],
        };
    }

    addRootProduct(payload) {
        this.isLoaded = false;
        this.numberOfPlans = this.numberOfPlans + payload.productIds.length;
        this.insQuoteService
            .addRootItems(payload.productIds, this.recordId)
            .then((response) => {
                const res = JSON.parse(response);
                // this.getAllLines();
                console.log('addRootProduct numberOfPlans:' + this.numberOfPlans);
                this.loadPlans();
                if (res.result && res.result.errors) {
                    const errorObj = res.result.errors;
                    Object.keys(errorObj).forEach((key) => {
                        if (errorObj[key]) {
                            commonUtils.showErrorToast.call(this, errorObj[key]);
                        }
                    });
                }
            })
            .catch((message) => {
                commonUtils.showErrorToast.call(this, message);
                this.isLoaded = true;
            });
    }

    openProductList() {
        this.template.querySelector('.vloc-ins-product-list').openProductModal();
    }

    /**
     * Toggles between root line items and product details
     */
    toggleRootLine(payload) {
        const els = this.template.querySelectorAll('.vloc-ins-large-group');
        if (!this.rootDetails) {
            const index = this.rootLineItems.findIndex((r) => r.Id === payload.Id);
            this.rootLineItems[index].renderDetails = true;
            this.rootProdId = this.rootLineItems[index].Product2Id;
            this.lineId = payload.Id;
            els.forEach((elm) => {
                if (elm.dataset.index === index.toString()) {
                    elm.classList.remove(`${this.theme}-hide`);
                } else {
                    elm.classList.add(`${this.theme}-hide`);
                }
            });
        } else {
            els.forEach((elm) => {
                elm.classList.add(`${this.theme}-hide`);
            });
            if (this.refreshGetAllLine || payload.refreshGetAllLine) {
                this.refreshGetAllLine = false;
                this.refreshQuote();
            }
        }
        this.rootDetails = !this.rootDetails;
    }

    /**
     * Formats date returned in net change
     */
    formatDate(val) {
        if (val) {
            const dateFormat = new Intl.DateTimeFormat(LOCALE, { timeZone: 'UTC' });
            return dateFormat.format(new Date(val));
        }
        return val;
    }

    closeRecordEditor() {
        pubsub.fire(this.rootQuoteChannel, 'closeRecordEditor');
    }

    updateGroupClasses(payload) {
        const { productId, groupClasses } = payload;
        const index = this.rootLineItems.findIndex((item) => item.Id === productId);
        this.rootLineItems[index].groupClasses = groupClasses;
        this.rootLineItems[index] = { ...this.rootLineItems[index] };
    }

    get headerActions() {
        return this.isMultiRoot || !this.rootLineItems.length;
    }

    get buildQuote() {
        return this.isLoaded && !this.rootLineItems.length;
    }

    get displayNetPrice() {
        return this.quoteType === ENDORSEMENT && this.netChange.totalPremiumTermDifference !== 0;
    }

    get displayTooltip() {
        return (
            this.netChange.totalPremiumTermDifference ||
            this.netChange.totalTaxTermDifference ||
            this.netChange.totalFeeTermDifference
        );
    }

    get rootLineItemsClass() {
        return this.rootDetails ? `${this.theme}-hide` : `${this.theme}-show`;
    }

    get netPriceClasses() {
        const classes = `${this.theme}-box vloc-ins-price-change-container ${this.theme}-grid ${this.theme}-wrap`;
        return `${this.isMultiRoot ? `${this.theme}-m-bottom_medium` : `${this.theme}-m-top_medium`} ${classes}`;
    }

    get labelDebugButton() {
        return `${this.inDebugMode ? this.labels.InsQuoteProduction : this.labels.InsQuoteDebug}
            ${this.labels.InsQuoteMode}
        `;
    }

    get isDeviceSizeSupported() {
        return formFactorPropertyName.toUpperCase() !== 'SMALL';
    }

    get showDebugMode() {
        return this.isDeviceSizeSupported && this.enableDebugMode;
    }

    get showVersionHistory() {
        return this.isDeviceSizeSupported;
    }

    disconnectedCallback() {
        pubsub.unregister(this.rootQuoteChannel, this.pubsubPayload);
        pubsub.unregister(this.stateTransitionChannel, this.stateChange);
        pubsub.unregister('omniscript_action', this.omniscriptAction);
        pubsub.unregister('policy_action', this.issuePolicy);
        pubsub.unregister(`repriceQuote-${this.recordId}`, this.repriceQuote);
    }
}