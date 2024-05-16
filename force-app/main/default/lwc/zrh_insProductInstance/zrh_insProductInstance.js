import {api, track, wire } from 'lwc';
import pubsub from 'vlocity_ins/pubsub';
import { LABELS } from './zrh_insProductInstanceLabels.js';
import { communityUtils, dataFormatter } from 'vlocity_ins/insUtility';
import { namespace } from 'vlocity_ins/utility';
import mobileTemplate from './zrh_insProductInstance_mobile.html';
import defaultTemplate from './zrh_insProductInstance.html';
import formFactorPropertyName from '@salesforce/client/formFactor';
import insProductInstance from 'vlocity_ins/insProductInstance'

import { getRecord } from 'lightning/uiRecordApi';
import Id from "@salesforce/user/Id";
import UserRole from '@salesforce/schema/User.UserRole.DeveloperName'

const INSURED_ITEMS = 'Insured Items';
const INSURED_PARTY_SPEC = 'InsuredPartySpec';
const COVERAGE_SPEC = 'CoverageSpec';
const SEPARATOR = ';';
const PRODUCT = 'Product';
const ACCOUNT_FIELDS = [
    'PrimaryParticipantAccount.Phone',
    'PrimaryParticipantAccount.Email__c',
    'PrimaryParticipantAccount.CalculatedAddress__c',
    'PartyAccountPhone__c',
    'PartyAccountEmail__c',
    'PartyAccountCalculatedAddress__c',
];
const LINE_BREAK_TAG = '<br>';

export default class zrh_insProductInstance extends insProductInstance {
    
    @track popRequisitosAsegurabilidad = false;
    @track verRequisitosAsegurabilidad = false;
    @track popBMI = false;
    @track verBMI = false;
    @track popRequisitosMedicos = false;
    @track verRequisitosMedicos = false;
    @track popTarificacion = false;
    @track verTarificacion = false;
    @track popConvenios = false;
    @track verConvenios = false;
    @track popGloss = false;
    @track verGlosas = false;
    @track popClonacion = false;
    @track verClonacion = false;
    @track popTopeCobertura = false;
    @track verTopeCobertura = false;
    @track popTopePoliza = false;
    @track verTopePoliza = false;
    @track popTopeAdicional = false;
    @track verTopeAdicional = false;
    @track perfil;
    @track userRole;

    @api 
    get quoteLineItemLink(){
        return "/" + this._product.quoteLineItemId;
    }

    @api theme = 'slds';
    @api detailsFetched;
    @api isLoaded;
    @api ruleContext;
    @api rootChannel;
    @api isPolicy = false;
    @api enableDelete;
    @api options = {
        isDeletable: true,
        isReadonly: false,
    };
    @api componentName;
    @api displayDetails; //If true, drill down to product details
    @api isMultiRoot;
    @api enableGroupClasses;
    @api enableClone;
    @api hidePrice; // Hides product price
    @api expandCard; // Expands attributes on load
    @api enableCardToggle; // Enables card toggle to dispaly attributes
    @api hideRecordEditor; // Hides edit icon to disable modal
    @api showCoverages = false;
    @api hideAttributePreview;
    @api unsavedRootItems;
    @api unsavedChildItems;

    @api
    get product() {
        return this._product;
    }

    set product(data) {
        this._product = data;
        if (data) {
            const recordTypeName = dataFormatter.getNamespacedProperty(this._product, 'RecordTypeName__c');
            this.isRootProduct = recordTypeName === PRODUCT;
            this.isInsuredParty = recordTypeName === INSURED_PARTY_SPEC;
            this.productName = this.setName(data);
            this.productPrice = this.setPrice(data);
            this.parentItemId = dataFormatter.getNamespacedProperty(this.product, 'ParentItemId__c');

            if (this._product.childProducts && this._product.childProducts.records) {
                this.childProducts = this._product.childProducts.records;
            } else {
                this.childProducts = [];
            }
            const categories = this._product.attributeCategories || this._product.productAttributes;
            this.attributeCategories = categories && categories.records ? categories.records : [];
            this.displayAttributes = this.getSortedAttributes(this.attributeCategories);

            this.unassociatedProducts = this._product.unassociatedProducts || [];
            this.associatedProducts = this._product.associatedProducts || [];
            if (!this.ruleContext || (this.ruleContext && !this.ruleContext.attrMap)) {
                this.setRuleContext();
            }

            if (this.isInsuredParty) {
                this.setPartyFields(data);
            }
            if (this.options && this.isRootProduct) {
                this.expandCardOptions.isReadonly = this.options.isReadonly;
            }
            this.formatLabels();
            this.currency.code = this._product.currencyCode || this.currency.code;
            this.currency.symbol = this._product.currencySymbol || this.currency.symbol;
            this.isLoaded = true;
        }
    }

    @api
    get insuredItems() {
        return this._insuredItems;
    }

    set insuredItems(data) {
        this._insuredItems = data;
        if (data) {
            const productId = dataFormatter.getNamespacedProperty(this.product, 'productId');
            const productInsuredItem = data.find((item) => item.productId === productId);
            if (productInsuredItem) {
                this.grandChildSpec = JSON.parse(JSON.stringify(productInsuredItem.grandChildItems)) || [];
            }
        }
    }

    @track productPrice;
    @track childProducts;
    @track grandChildSpec;
    @track associatedProducts;
    @track unassociatedProducts;
    @track attributeCategories;
    @track currency = dataFormatter.currency;

    labels = LABELS;
    roles = [];

    expandCardOptions = {
        colWidth: 2,
        displayCategoryName: true,
        attributeStyle: 'recordEditor',
    };
    accountFields = [];
    isMobile = formFactorPropertyName.toUpperCase() === 'MEDIUM' || formFactorPropertyName.toUpperCase() === 'SMALL';

    // deprecated properties
    @api recordId;
    @api customLabels;
    @api disableReprice;

    render() {
        return this.isMobile ? mobileTemplate : defaultTemplate;
    }

    connectedCallback() {
        this.isInsuredItems = this.componentName === INSURED_ITEMS;
        this.enableCardToggle = this.isRootProduct || this.isInsuredItems || this.enableCardToggle;
        this.expandCard = this.expandCard && this.attributeCategories.length;
        this.expandCardOptions = {
            ...this.options,
            ...this.expandCardOptions,
            isReadonly: this.options.isReadonly || this.isInsuredItems,
        };
        this.setIconDetails();
    }

    getAccountFields(product) {
        return Object.keys(product).reduce((acc, field) => {
            let fieldName = dataFormatter.removeNamespace(field);
            let fieldStr = '';
            if (field.includes('PrimaryParticipantAccount')) {
                const prefix = field.split('.')[0];
                fieldStr = field.split('.')[1];
                fieldName = `${prefix}.${dataFormatter.removeNamespace(fieldStr)}`;
            }
            if (ACCOUNT_FIELDS.includes(fieldName)) {
                let productField = product[field];
                const fscNamespace = dataFormatter.getFscNamespace(fieldStr);
                const fscAddressField = `PrimaryParticipantAccount.${fscNamespace}CalculatedAddress__c`;
                const assetAddressField = `${namespace}PartyAccountCalculatedAddress__c`;
                if (
                    (field === fscAddressField || field === assetAddressField) &&
                    product[field].includes(LINE_BREAK_TAG)
                ) {
                    if (product[field].replace(LINE_BREAK_TAG, '').trim() === '') {
                        return acc; //If only <br> is returned, don't accumulate field
                    }
                    productField = product[field].replace(LINE_BREAK_TAG, ', ');
                }
                acc.push(productField);
            }
            return acc;
        }, []);
    }

    // eslint-disable-next-line consistent-return
    getSortedAttributes(categories) {
        if (categories.length) {
            const attributes = [];
            categories.forEach((category) => {
                category.productAttributes.records.forEach((attr) => {
                    attributes.push(attr);
                });
            });
            const sortedAttributes = attributes.sort(dataFormatter.displaySequenceSort);
            return sortedAttributes
                .filter((attr) => {
                    return !(attr.hidden || attr.inputType === 'equalizer' || attr.hiddenByRule) && attr.userValues;
                })
                .map((attr) => ({
                    ...attr,
                    userValues: dataFormatter.formatDisplayValue(attr),
                }))
                .slice(0, 3);
        }
    }

    setName(data) {
        const fscAssetName = dataFormatter.getNamespacedProperty(data, 'AssetName__c') || data.AssetName;
        const fscPartyName = dataFormatter.getNamespacedProperty(data, 'ParticipantName__c');
        const productName = dataFormatter.getNamespacedProperty(data, 'ProductName__c') || data.productName;
        return data.instanceKey || fscAssetName || fscPartyName || data.Name || productName || data.name;
    }

    formatLabels() {
        this.labels.Includes = this.labels.Includes.charAt(0).toUpperCase() + this.labels.Includes.substring(1);
        this.labels.attributeDetails =
            this.isPolicy || this.options.isReadonly ? this.labels.InsViewAttributes : this.labels.InsEditDetails;
        this.labels.removeGrandChild = this.labels.InsRemoveFrom.replace('{0}', this.productName);
        this.labels.removeGrandChildRecord = { label: this.labels.removeGrandChild };
        this.labels.InsEditDetailsRecord = !this.options.isReadonly
            ? { label: this.labels.InsEditDetails }
            : { label: this.labels.InsViewAttributes };
        this.labels.InsSetAsPrimaryRecord = { label: this.labels.InsSetAsPrimary };
    }

    /**
     * Deprecated - only used in insPolicyItem now
     */
    setIconDetails() {
        if (this.product && this.product.ImageId) {
            return;
        }
        this.iconSize = 'large';
        this.iconClasses = `${this.theme}-icon_container ${
            this.isRootProduct ? 'vloc-ins-icon-root' : 'vloc-ins-icon-item'
        }`;
        const prodRecordType = dataFormatter.getNamespacedProperty(this.product, 'RecordTypeName__c');
        if (this.isInsuredItems) {
            this.iconName = prodRecordType === INSURED_PARTY_SPEC ? 'utility:user' : 'utility:ribbon';
        } else {
            this.iconName = dataFormatter.getNamespacedProperty(this.product, 'ImageId__c') || 'utility:ribbon';
        }
        if (this.iconName.startsWith('utility')) {
            // utility icons are sized differently from standard and custom icons
            this.iconSize = 'medium';
            this.iconClasses += ` ${this.theme}-p-around_x-small`;
        }
    }

    setPartyFields(data) {
        this.roles = this.setPartyRoles(data);
        this.accountFields = this.getAccountFields(data);
    }

    setPartyRoles(product) {
        let roles = [];
        const assetRole = dataFormatter.getNamespacedProperty(product, 'PartyRelationshipTypeName__c');
        const partyRoles = dataFormatter.getNamespacedProperty(product, 'Role') || assetRole;
        this.isPolicyholder =
            dataFormatter.getNamespacedProperty(this._product, 'IsPolicyholder__c') || this._product.IsPolicyholder;
        if (this.isPolicyholder) {
            roles.push(this.labels.InsPolicyholder);
        }
        if (partyRoles) {
            if (partyRoles.includes(SEPARATOR)) {
                roles = roles.concat(partyRoles.split(SEPARATOR));
            } else {
                roles.push(partyRoles);
            }
        }
        return roles;
    }

    setPrice() {
        const totalAmount = dataFormatter.getNamespacedProperty(this._product, 'TotalAmount__c');
        return totalAmount || this._product.Price || this._product.TotalPrice || this._product.TotalStandardAmount || 0;
    }

    setRuleContext() {
        this.ruleContext = !this.ruleContext ? {} : JSON.parse(JSON.stringify(this.ruleContext));
        this.ruleContext.instanceLineId = this.product.Id;
        this.ruleContext.quoteId = this.product.QuoteId;
        this.ruleContext.instanceProductCode = this.product.ProductCode;
        this.ruleContext.coverageCodes = this.getCoverageCodes();
        if (this.product.attributeCategories && this.product.attributeCategories.records) {
            this.createAttributeMap();
        }
    }

    getCoverageCodes() {
        //make a list of coverage codes to know which attributes do not need backend support
        let coverageCodes = [];
        if (this.product.childProducts && this.product.childProducts.records) {
            const coverages = this.product.childProducts.records.filter((coverage) => {
                const recordType = dataFormatter.getNamespacedProperty(coverage, 'RecordTypeName__c');
                return recordType === COVERAGE_SPEC;
            });
            coverages.forEach((coverage) => {
                coverageCodes.push(coverage.ProductCode);
            });
        }
        return JSON.stringify(coverageCodes);
    }

    createAttributeMap() {
        this.ruleContext.attrMap = {};
        this.product.attributeCategories.records.forEach((category) => {
            if (category.productAttributes && category.productAttributes.records) {
                category.productAttributes.records.forEach((attribute) => {
                    // eslint-disable-next-line no-useless-concat
                    const token = `${this.product.ProductCode || this.product.productCode}` + '.' + attribute.code;
                    const attr = JSON.parse(JSON.stringify(attribute));
                    this.ruleContext.attrMap[token] = {
                        newValue: attr.userValues,
                        uniqueCode: token,
                        valueDecoder: attr.valueDecoder,
                    };
                });
            }
        });
        this.ruleContext.attrMap = JSON.stringify(this.ruleContext.attrMap);
    }

    /**
     * Toggles coverages list and fetches product coverages and attributes on first click
     */
    toggleCoverages() {
        if (!this.detailsFetched) {
            this.fetchProductDetails();
        }
        this.showCoverages = !this.showCoverages;
    }

    handleDetails() {
        if (this.displayDetails) {
            pubsub.fire(this.rootChannel, 'toggleRootLine', this.product.Id); // Navigates user to detailed product view
            return;
        }

        if (this.enableCardToggle && this.attributeCategories.length) {
            this.expandCard = !this.expandCard;
        }
    }

    fetchProductDetails() {
        this.isLoaded = false;
        pubsub.fire(this.rootChannel, 'fetchProductDetails', this.product.Id);
    }

    getInsuredItemSpec(e) {
        pubsub.fire(this.rootChannel, 'getPrimarySpec', e.currentTarget.dataset.childProductId);
    }

    addGrandchild(e) {
        const { grandChildId } = e.currentTarget.dataset;
        const payload = {
            grandChildSpec: this.grandChildSpec.find((item) => item.productId === grandChildId),
            parentQuoteLineId: this.product.quoteLineItemId,
        };
        pubsub.fire(this.rootChannel, 'getGrandChildSpec', payload);
    }

    associateProduct(e) {
        const payload = {
            parentLineId: this.product.quoteLineItemId,
            childLineId: e.currentTarget.dataset.grandChildId,
        };
        pubsub.fire(this.rootChannel, 'associateProduct', payload);
    }

    unassociateProduct(e) {
        const payload = {
            parentLineId: this.product.quoteLineItemId,
            childLineId: e.currentTarget.dataset.grandChildId,
        };
        pubsub.fire(this.rootChannel, 'unassociateProduct', payload);
    }

    setPrimary(e) {
        const payload = {
            parentLineId: this.product.quoteLineItemId,
            childLineId: e.currentTarget.dataset.grandChildId,
        };
        pubsub.fire(this.rootChannel, 'setPrimary', payload);
    }

    editGrandchild(e) {
        const selectedGrandChildId = e.currentTarget.dataset.grandChildId;
        const grandChildItem = this.associatedProducts.find(
            (grandChildren) => grandChildren.Id === selectedGrandChildId
        );
        this.editAttributes(grandChildItem, true);
    }

    editPrimary(e) {
        this.stopPropagation(e);
        this.editAttributes(this.product);
    }

    editAttributes(product, isGrandChild) {
        const payload = {
            product,
            isGrandChild,
            parentLineId: this.product.quoteLineItemId,
            isRootProduct: this.isRootProduct,
        };
        if (this.isPolicy) {
            pubsub.fire(this.rootChannel, 'viewAttributes', payload);
        } else {
            pubsub.fire(this.rootChannel, 'editAttributes', payload);
        }
    }

    deleteProduct() {
        this.template.querySelector('vlocity_ins-modal').closeModal();
        const payload = {
            quoteLineItemId: this.product.quoteLineItemId,
            isRootProduct: this.isRootProduct,
        };
        pubsub.fire(this.rootChannel, 'deleteProduct', payload);
    }

    confirmDelete(e) {
        this.stopPropagation(e);
        this.template.querySelector('vlocity_ins-modal').openModal();
    }

    closeDeleteModal() {
        this.template.querySelector('vlocity_ins-modal').closeModal();
    }

    priceRootItem(e) {
        e.stopPropagation();
        pubsub.fire(this.rootChannel, 'priceRootItem');
    }

    cloneRootLine() {
        pubsub.fire(this.rootChannel, 'cloneRootLine', this.product.quoteLineItemId);
    }

    onClickRequisitosAsegurabilidad(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '","otherParam":"FAQ"}';
        this.popRequisitosAsegurabilidad = true;
    }
    onClickBMI(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '","otherParam":"FAQ"}';
        this.popBMI = true;
    }

    onClickRequisitosMedicos(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '","otherParam":"FAQ"}';
        this.popRequisitosMedicos = true;
    }
    
    onClickTarificacion(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '"}';
        this.popTarificacion = true;
    }
    
    onClickConvenios(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '"}';
        this.popConvenios = true;
    }

    /**
    *  @Description: Method that activates gloss modal
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        2/10/2023
    */
    onClickGloss(){
        this.popGloss = true;
    }

    /**
    *  @Description: Method that activates clone modal
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        7/12/2023
    */
    onClickClonacion(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '"}';
        this.popClonacion = true;
    }

    /**
    *  @Description: Method that activates coverage limits modal
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        7/2/2024
    */
    onClickTopeCobertura(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '","TipoTope":"G"}';
        this.popTopeCobertura = true;
    }

    /**
    *  @Description: Method that activates policy limits modal
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        7/2/2024
    */
    onClickTopePoliza(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '","TipoTope":"P"}';
        this.popTopePoliza = true;
    }

    /**
    *  @Description: Method that activates aditional limits modal
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        7/2/2024
    */
    onClickTopeAdicional(){
        this.perfil = '\{"ContextId":"' + this._product.quoteLineItemId + '","TipoTope":"A"}';
        this.popTopeAdicional = true;
    }

    cancelar(){
        this.popRequisitosAsegurabilidad = false;
        this.popRequisitosMedicos = false;
        this.popBMI = false;
        this.popTarificacion = false;
        this.popConvenios = false;
        this.popGloss = false;
        this.popClonacion = false;
        this.popTopeCobertura = false;
        this.popTopePoliza = false;
        this.popTopeAdicional = false;
    }

    @wire(getRecord, { recordId: Id, fields: [UserRole]}) 
    userDetails({error, data}) {
        if (data) {
            let codigoProd = this._product.ProductCode;
            this.userRole = data.fields.UserRole.value != null ? data.fields.UserRole.value.fields.DeveloperName.value : "";
            
            this.verRequisitosAsegurabilidad =  codigoProd === "500" || codigoProd === "501" || codigoProd === "502" || codigoProd === "700";
            this.verRequisitosAsegurabilidad =  this.verRequisitosAsegurabilidad || codigoProd === "600" || codigoProd === "601" || codigoProd === "602" || codigoProd === "603";
            this.verRequisitosAsegurabilidad =  this.verRequisitosAsegurabilidad || codigoProd === "604" || codigoProd === "605" || codigoProd === "606";
            this.verRequisitosAsegurabilidad = this.verRequisitosAsegurabilidad && (this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion");

            this.verRequisitosMedicos = codigoProd === "500" || codigoProd === "501" || codigoProd === "502";
            this.verRequisitosMedicos = this.verRequisitosMedicos && (this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion");

            this.verBMI =  codigoProd === "600" || codigoProd === "601" || codigoProd === "602" || codigoProd === "603";
            this.verBMI =  this.verBMI || codigoProd === "604" || codigoProd === "605" || codigoProd === "606";
            this.verBMI = this.verBMI && (this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion");

            this.verConvenios =  codigoProd === "600" || codigoProd === "601" || codigoProd === "602" || codigoProd === "603";
            this.verConvenios =  this.verConvenios || codigoProd === "604" || codigoProd === "605" || codigoProd === "606";
            this.verConvenios = this.verConvenios && (this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion");

            this.verTarificacion = this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion";

            this.verGlosas = this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion";

            this.verClonacion = this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion";

            this.verTopeCobertura =  codigoProd === "600" || codigoProd === "601" || codigoProd === "602" || codigoProd === "603";
            this.verTopeCobertura =  this.verTopeCobertura || codigoProd === "604" || codigoProd === "605" || codigoProd === "606";
            this.verTopeCobertura = this.verTopeCobertura && (this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion");

            this.verTopePoliza =  codigoProd === "600" || codigoProd === "601" || codigoProd === "602" || codigoProd === "603";
            this.verTopePoliza =  this.verTopePoliza || codigoProd === "604" || codigoProd === "605" || codigoProd === "606";
            this.verTopePoliza = this.verTopePoliza && (this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion");

            this.verTopeAdicional =  codigoProd === "600" || codigoProd === "601" || codigoProd === "602" || codigoProd === "603";
            this.verTopeAdicional =  this.verTopeAdicional || codigoProd === "604" || codigoProd === "605" || codigoProd === "606";
            this.verTopeAdicional = this.verTopeAdicional && (this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion");

        }else if(error){
            this.verRequisitosAsegurabilidad = false;
            this.verBMI = false;
            this.verTarificacion = false;
            this.verConvenios = false;
            this.verTopeCobertura = false;
            this.verTopePoliza = false;
            this.verTopeAdicional = false;
        }
    }

    get customIconSrc() {
        return `${communityUtils.communityPath}${this.product.ImageId}`;
    }

    get coverageDetailsClasses() {
        return this.showCoverages
            ? `vloc-ins-section ${this.theme}-p-horizontal_x-large ${this.theme}-p-bottom_x-large`
            : `vloc-ins-section ${this.theme}-is-collapsed`;
    }

    get attributeClasses() {
        if (this.expandCard) {
            return `vloc-ins-section ${this.theme}-p-horizontal_x-large ${this.theme}-p-bottom_x-large`;
        }
        return `vloc-ins-section ${this.theme}-is-collapsed`;
    }

    get isEditGrandchildren() {
        const hasGrandchildSpec = this.grandChildSpec && this.grandChildSpec.length;
        return !this.isPolicy && hasGrandchildSpec && !this.options.isReadonly;
    }

    get priceClasses() {
        let classes = `${this.theme}-text-heading_medium vloc-ins-bold`;
        if (this.product.needReprice) {
            classes += ` ${this.theme}-text-color_error`;
        }
        return classes;
    }

    get mainHeaderClasses() {
        const mobileClasses = this.isMobile ? `${this.theme}-size_1-of-1` : `${this.theme}-size_11-of-12`;
        const classes = this.isInsuredItems
            ? mobileClasses
            : `${this.theme}-size_1-of-2 ${this.theme}-small-size_2-of-3`;
        return ` ${this.theme}-grid ${this.theme}-grid_align-start ${classes}`;
    }

    get leftHeaderClasses() {
        const classes = this.isInsuredItems
            ? `${this.theme}-size_1-of-12`
            : `${this.theme}-size_1-of-2 ${this.theme}-small-size_1-of-3`;
        return ` ${this.theme}-grid ${this.theme}-grid_align-end ${classes}`;
    }

    get headingClasses() {
        const classes = `${this.theme}-text-heading_medium vloc-ins-product-name ${this.theme}-p-top_small vloc-ins-bold`;
        return this.isInsuredParty && this.isPolicy ? `${classes} vloc-ins-inline` : classes;
    }

    get titleContainerClasses() {
        if (this.isInsuredItems && !this.isPolicy) {
            return !this.isMobile ? `${this.theme}-size_1-of-3` : `${this.theme}-size_1-of-1`;
        }
        return `${this.theme}-size_3-of-3 ${this.theme}-small-size_2-of-3`;
    }

    get totalTaxFeeAmount() {
        let taxFeeAmt = this.product.totalTaxFeeAmount || 0;
        const taxAmount =
            dataFormatter.getNamespacedProperty(this.product, 'TotalTaxAmount__c') || this.product.taxAmount || 0;
        const feeAmount =
            dataFormatter.getNamespacedProperty(this.product, 'TotalFeeAmount__c') || this.product.feeAmount || 0;
        if (!taxFeeAmt && (taxAmount || feeAmount)) {
            taxFeeAmt = taxAmount + feeAmount;
        }
        return taxFeeAmt;
    }

    get priceIconVariant() {
        return this.product.needReprice ? 'error' : 'default';
    }

    get rootLevelCoverages() {
        return this.isRootProduct && (this.product.coverageCount > 0 || this.product.hasCoverages);
    }

    get showRateButton() {
        return this.isRootProduct && this.product.needReprice;
    }

    get menuDisabled() {
        return !this.product.hasAttributes && this.isPolicy;
    }

    get isDeletable() {
        return !this.isPolicy && this.options.isDeletable;
    }

    get editLabel() {
        return this.product.hasAttributes && !this.options.isReadonly
            ? this.labels.attributeDetails
            : this.labels.InsViewAttributes;
    }

    get allowDelete() {
        return !this.options.isReadonly && this.options.isDeletable && this.enableDelete;
    }

    get repriceMessage() {
        return this.product.needReprice && this.isInsuredItems;
    }

    /**
     * Loops through all parent associated/unassociated insured items and associates them to the correct grandchild spec based on product type (productId)
     */
    get grandChildItems() {
        if (this.grandChildSpec && this.grandChildSpec.length) {
            this.grandChildSpec.forEach((item) => {
                item.label = `${this.labels.Add} ${item.name}`;
                item.associatedProducts = this.associatedProducts.filter(
                    (assocProduct) => item.productId === assocProduct.productId
                );
                item.unassociatedProducts = this.unassociatedProducts.filter(
                    (unassocProduct) => item.productId === unassocProduct.productId
                );
            });
        }
        return this.grandChildSpec;
    }

    get displayCoverages() {
        const hasCoverages = this.product.hasCoverages || this.product.coverageCount > 0;
        return !this.isInsuredItems && hasCoverages && !this.displayDetails;
    }

    get displayPrice() {
        this.hidePrice = true;
        return this.productPrice != null && !this.hidePrice;
    }

    get sectionClasses() {
        let classes;
        if (!this.isMobile) {
            classes = `${this.theme}-grid ${this.theme}-grid_align-spread ${this.theme}-p-around_x-large`;
        } else {
            classes = `${this.theme}-p-around_medium`;
        }
        const isCardSelectable = this.isInsuredItems || this.isRootProduct || this.enableCardToggle;
        if (isCardSelectable && this.attributeCategories.length) {
            classes += ' vloc-ins-product-summary';
        }
        return classes;
    }

    get chevronName() {
        return this.showCoverages ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get showCoveragesLabel() {
        const hideCoverages = `${this.labels.InsButtonHide} ${this.labels.InsCoverages}`;
        const showCoverages = `${this.labels.InsButtonShow} ${this.labels.InsCoverages}`;
        return this.showCoverages ? hideCoverages : showCoverages;
    }

    get contactFields() {
        return this.isPolicyholder && this.isInsuredItems && this.accountFields.length;
    }

    get previewAttrs() {
        const hasPreviewAttrs = !this.isPolicyholder || (this.isPolicyholder && !this.accountFields.length);
        return this.isInsuredItems && hasPreviewAttrs;
    }

    get displayProductPrice() {
        return this.isRootProduct || this.productPrice;
    }

    get showModal() {
        return !this.isRootProduct && !this.hideRecordEditor;
    }

    get editCardAttrs() {
        return this.options.isReadonly || this.isInsuredItems;
    }

    get disableRate() {
        return this.options.isReadonly || this.product.disableReprice;
    }

    get displayMultiRootMenu() {
        return this.isMultiRoot && this.isRootProduct;
    }

    get isPolicyRootProduct() {
        return this.isPolicy && this.isRootProduct;
    }

    get showMenu() {
        return (
            this.enableClone || this.enableDelete || this.verBMI || this.verConvenios || this.verTopeCobertura || this.verTopePoliza ||
            this.verTopeAdicional || this.verRequisitosAsegurabilidad || this.verRequisitosMedicos || this.verTarificacion || this.insuredItems
        );
    }

    stopPropagation(e) {
        e.stopPropagation();
    }
}