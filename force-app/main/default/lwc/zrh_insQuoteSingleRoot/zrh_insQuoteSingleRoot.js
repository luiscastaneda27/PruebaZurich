import {wire, api, track } from 'lwc';
import { get } from 'vlocity_ins/lodash';
import pubsub from 'vlocity_ins/pubsub';
import { LABELS } from './zrh_insQuoteSingleRootLabels.js';
import { commonUtils, dataFormatter } from 'vlocity_ins/insUtility';
import formFactorPropertyName from '@salesforce/client/formFactor';
import InsQuoteSingleRootService from './zrh_insQuoteSingleRootService.js';
import insQuoteSingleRoot from 'vlocity_ins/insQuoteSingleRoot';
import { getNamespaceDotNotation } from "vlocity_ins/omniscriptInternalUtils";
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";

import { getRecord } from 'lightning/uiRecordApi';
import Id from "@salesforce/user/Id";
import UserRole from '@salesforce/schema/User.UserRole.DeveloperName'

export default class zrh_insQuoteSingleRoot extends insQuoteSingleRoot {
    @api recordId;
    @api isMultiRoot;
    @api enableClone;
    @api enableDelete;
    @api enableGroupClasses;
    @api rootQuoteChannel;
    @api rootChannel;
    @api editPanelMode;
    @api priceQuoteAsync;
    @api showActions;
    @api enableDebugMode;
    @api useRatingFact;
    @api isBatchMode;
    attributeChanges = {};
    attributeActualValues = new Map();
    attributeChangesValidity = {};
    invalidAttributeValues = true;
    invalidAttributeClasses = 'has-error';
    saveChangesButton = false;
    hasUnsavedRootItems = false;
    hasUnsavedChildItems = false;

    @api get userProfile() {
        return this._userProfile;
    }
    set userProfile(data) {
        if (data) {
            this._userProfile = data;
            // Rule context is used in bottom-up rules approach.
            this.ruleContext.userProfile = this._userProfile;
        }
    }

    @api get product() {
        return this._product;
    }
    set product(data) {
        if (data) {
            this._product = JSON.parse(JSON.stringify(data));

            this.rootProductId = this._product.productId;
            this.rootLineId = this._product.quoteLineItemId;
            this.rootProductType = dataFormatter.getNamespacedProperty(this._product, 'Type__c');
            const productData = dataFormatter.formatQuoteProductCoverages(this._product, {
                rootGrandchildInsuredItems: [],
            });
            this._product = productData.product || productData;
            if (productData.options) {
                this.rootGrandchildInsuredItems = productData.options.rootGrandchildInsuredItems || [];
            }

            if (this._product.childProducts) {
                this.initInsuredItems();
            } else {
                this.rootLineItem = this._product;
                this.handleDisableReprice();
            }
            if (!this.hasRendered) {
                this.ruleContext = {
                    rootId: this.rootLineId,
                    rootProductCode: this._product.ProductCode,
                };
                this.hasRendered = true;
            }
            this.isLoaded = true;
            this.clearFetchedLines(true, true);
        }
    }

    _inDebugMode;
    @api //keep track of debug mode
    get inDebugMode() {
        return this._inDebugMode;
    }
    set inDebugMode(data) {
        this._inDebugMode = data;
        if (this.ruleContext) {
            this.ruleContext = JSON.parse(JSON.stringify(this.ruleContext));
            this.ruleContext.debugMode = data;
            pubsub.fire(this.rootChannel, 'setDebugMode', data);
        }
    }
    _actionUtil;
    _ns = getNamespaceDotNotation();
    @api theme = 'slds';
    @api options = {
        // default state options
        isReadonly: false,
        isDeletable: true,
    };

    @track isLoaded = false;
    @track insuredItemSpec;
    @track editorConfig = {
        isEditMode: false,
        isPrimary: false,
        product: null,
    };
    @track rootLineItem;
    isInsuredItemsFetched = false;
    isEditorOpen = false;
    labels = LABELS;
    clearRoot = false;
    clearChildProducts = false;
    _userProfile;
    rootGrandchildInsuredItems = []; // All grandchild insured item products that can be associated to a parent product
    pubsubPayload = {
        fetchProductDetails: this.getCoverages.bind(this),
        attributeMapChange: this.attributeMapChange.bind(this),
        editAttributes: this.editAttributes.bind(this),
        getGrandChildSpec: this.getGrandChildSpec.bind(this),
        deleteProduct: this.deleteProduct.bind(this),
        associateProduct: this.associateProduct.bind(this),
        unassociateProduct: this.unassociateProduct.bind(this),
        getPrimarySpec: this.getPrimarySpec.bind(this),
        cloneRootLine: this.cloneRootLine.bind(this),
        toggleOptionalCoverage: this.toggleOptionalCoverage.bind(this),
        changeAttributeValue: this.changeAttributeValue.bind(this),
        priceRootItem: this.priceRootItem.bind(this),
        setPrimary: this.setPrimary.bind(this),
        toggleRootLine: this.toggleRootLine.bind(this),
        updateGroupClasses: this.updateGroupClasses.bind(this),
    };

    recordEditor = {
        closeRecordEditor: this.closeRecordEditor.bind(this),
    };

    insQuoteSingleRootService = new InsQuoteSingleRootService();

    @wire(getRecord, { recordId: Id, fields: [UserRole]}) 
    userDetails({error, data}) {
        if (data) {
            this.userRole = data.fields.UserRole.value != null ? data.fields.UserRole.value.fields.DeveloperName.value : "";            
            this.saveChangesButton = this.userRole === "ZRH_Suscriptor" || this.userRole === "ZRH_JefeSuscripcion" || this.userRole === "ZRH_SubgerenteSuscripcion";
        }else if(error){
            console.log('error', error);
        }
    }

    connectedCallback() {
        if (!this.rootChannel) {
            this.rootChannel = `insQuoteSingleRoot-${this.recordId}-${Date.now()}`;
        }
        pubsub.register(this.rootChannel, this.pubsubPayload);

        pubsub.register(this.rootQuoteChannel, this.recordEditor);
        this.successMessages = {
            create: this.labels.InsQuoteCreatedQuoteLineItem,
            update: this.labels.InsProductSuccessfullyUpdatedQuoteLineItems,
            delete: this.labels.InsQuoteDeletedQuoteLineItem,
        };
        this.template.addEventListener('reseteditorflag', this.updateEditorFlag.bind(this));
        this._actionUtil = new OmniscriptActionCommonUtil();
        
    }

    /**
     * Fetches line item details without insured items
     * @param {object} inputMap
     * @param {object} optionsMap
     */
    getLineDetails(inputMap) {
        this.insQuoteSingleRootService.getLineDetails(inputMap).then((response) => {
            this.formatLineDetails(response);
            this.isLoaded = true;
            return response;
        });
    }

    getCoverages(lineId) {
        const inputMap = { lineId };
        return this.getLineDetails(inputMap);
    }

    /**
     * Formats line item details and adds it to `this.rootLineItem`
     * @param {string} data stringified response from getLineDetails
     */
    formatLineDetails(data) {
        let result = JSON.parse(data);
        if (result && result.records && result.records[0]) {
            result = result.records[0];
            result.userProfile = this._userProfile;
            if (this.rootLineItem && !this.rootLineItem.userProfile) {
                this.rootLineItem.userProfile = this._userProfile;
            }
            if (this.rootLineItem.Id === result.Id) {
                this.formatRootLineDetails(result); // Format root product
            } else {
                this.formatChildLineDetails(result);
            }
        }
    }

    /**
     * Formats response from `getLineDetails` if it's the root line item.
     * Since child instances are nested under the root line item,
     * we don't want to reset them with this response so this function selectively updates the root product.
     * @param {Object} response response from getLineDetails
     */
    formatRootLineDetails(response) {
        this.rootLineItem.attributeCategories = response.attributeCategories;
        if (!this.rootLineItem.childProducts || !this.rootLineItem.childProducts.records) {
            this.rootLineItem.childProducts = { records: [] };
        }
        if (response.childProducts && response.childProducts.records) {
            const childProducts = this.rootLineItem.childProducts.records.filter(
                (record) => !this.isCoverageSpec(record)
            );

            const coverages = response.childProducts.records.filter((record) => this.isCoverageSpec(record));

            this.rootLineItem.childProducts.records = [...childProducts, ...coverages];
        }

        // Formats root line with updated response
        this.rootLineItem = dataFormatter.formatQuoteProductCoverages(this.rootLineItem);
        this.rootLineItem.needReprice = response.needReprice;
        this.rootLineItem.disableReprice = response.disableReprice;
        // Use spread operator to trigger reactive child components
        this.rootLineItem = { ...this.rootLineItem };
        this.manageFetched(response);
    }

    /**
     * Formats response from `getLineDetails` if it's a child line item (i.e. instance item)
     * @param {Object} data response from getLineDetails
     */
    formatChildLineDetails(data) {
        this.rootLineItem.childProducts.records = this.rootLineItem.childProducts.records || [];
        const childLineItems = this.rootLineItem.childProducts.records;
        const idx = childLineItems.findIndex((childProduct) => childProduct.Id === data.Id);
        if (idx > -1) {
            // Format existing line item
            data.path = childLineItems[idx].path;
            data.associatedProducts = childLineItems[idx].associatedProducts;
            data.unassociatedProducts = childLineItems[idx].unassociatedProducts;
            childLineItems[idx] = dataFormatter.formatQuoteProductCoverages(data);
            childLineItems[idx] = { ...childLineItems[idx] };
        } else {
            // Format product with newly added insured item
            data.unassociatedProducts = this.getUnassociatedItems(data);
            childLineItems.push(data);
            this.rootLineItem = dataFormatter.formatQuoteProductCoverages(this.rootLineItem);
        }
        // Clears disableReprice on child line changes
        this.rootLineItem.disableReprice = false;
        this.handleDisableReprice();
        this.manageFetched(data);
    }

    /**
     * Helper methods to clear fetched coverages or set coverages fetched
     */
    manageFetched(data) {
        if (this.clearRoot || this.clearChildProducts) {
            this.clearFetchedLines();
        } else {
            this.setDetailsFetched(data.quoteLineItemId);
        }
    }

    /**
     * Initializes child and grandchild items
     */
    initInsuredItems() {
        if (!this.isInsuredItemsFetched) {
            this.getInsuredItems();
        } else {
            this.handleGrandchildAssociations();
        }
    }

    /**
     * Sets unassociated grandchildren for each child product instance
     */
    handleGrandchildAssociations() {
        const childProducts = this.product.childProducts && this.product.childProducts.records;
        if (childProducts) {
            childProducts.forEach((prod) => {
                if (!this.isCoverageSpec(prod)) {
                    prod.unassociatedProducts = this.getUnassociatedItems(prod);
                }
            });
        }
        this.rootLineItem = this.product;
        this.handleDisableReprice();
    }

    /**
     * Helper method to determine if record is a Coverage Spec
     * @param {array} record product records
     */
    isCoverageSpec(record) {
        return dataFormatter.getNamespacedProperty(record, 'RecordTypeName__c') === 'CoverageSpec';
    }

    /**
     * Helper method filters associated product grandchildren from root grandchildren and returns unassociated product list
     * @param {array} parentProduct parent insured item instance
     */
    getUnassociatedItems(parentProduct) {
        const itemsGroupedByParent = this.getGrandchildAssociations(parentProduct);
        // Filter the associated from unassociated grandchild insured items
        if (parentProduct.associatedProducts && parentProduct.associatedProducts.length) {
            return this.filterUnassociatedItems(itemsGroupedByParent, parentProduct); // If a product already has associated grandchild items, it filters these from the unassociated items
        }
        return itemsGroupedByParent;
    }

    /**
     * Helper method to filter grandchildren for each insured item spec
     * @param {array} product parent insured item instance
     */
    getGrandchildAssociations(product) {
        const parentProductSpec = this.insuredItemSpec.find((item) => item.productId === product.Product2Id); // Get insured item spec for parent product
        const hasGrandchildSpec = parentProductSpec && parentProductSpec.grandChildItems.length;
        if (hasGrandchildSpec) {
            return parentProductSpec.grandChildItems
                .filter((i) => i.recordType !== 'InsuredItemSpec')
                .reduce((arr, spec) => {
                    return arr.concat(
                        this.rootGrandchildInsuredItems.filter((rec) => rec.productId === spec.productId)
                    );
                }, []);
        }
        return null;
    }

    filterByInsuredType(product) {
        const productSpec = (this.insuredItemSpec || []).find((item) => item.productId === product.Product2Id);
        if (productSpec && productSpec.grandChildItems.length) {
            const id = productSpec.grandChildItems[0].productId;
            return this.rootGrandchildren.filter((child) => id === child.productId);
        }
        return null;
    }

    /**
     * Helper method that filters the unassociated grandchild insured items from the associated
     * @param {array} items insured items groups by parent
     * @param {array} parent parent insured item instance
     */
    filterUnassociatedItems(items, parent) {
        return items.filter((product) => !parent.associatedProducts.some((record) => record.Id === product.Id));
    }

    /**
     * Fetches insured items for a given root product
     */
    getInsuredItems() {
        this.insQuoteSingleRootService.getInsuredItems(this.product.productId).then((result) => {
            this.isInsuredItemsFetched = true;
            const res = JSON.parse(result);
            if (res.primaryInsuredItems) {
                this.insuredItemSpec = res.primaryInsuredItems.map((item) => {
                    return {
                        ...item,
                        label: `${this.labels.Add} ${item.name}`,
                    };
                });
                this.handleGrandchildAssociations();
                this.handleMoreOptions();
            } else {
                this.rootLineItem = this.product;
                this.handleDisableReprice();
            }
        });
    }

    /**
     * Helper to display insured items in a dropdown
     */
    handleMoreOptions() {
        if (this.insuredItemSpec.length > 3) {
            this.insuredItemSpecOptions = this.insuredItemSpec.map((item) => {
                return {
                    label: item.name,
                    value: dataFormatter.getNamespacedProperty(item, 'productId'),
                };
            });
        }
    }

    /**
     * Configure grandchild insured item spec to add grandchild
     */
    getGrandChildSpec(payload) {
        this.parentLineId = payload.parentQuoteLineId;
        this.setEditorConfig({
            isPrimary: false,
            isEditMode: false,
            productName: payload.grandChildSpec.name,
            product: payload.grandChildSpec,
            parentLineId: this.parentLineId, // Props to create grandchild in OS
            rootLineId: this.rootLineId,
            rootProductType: this.rootProductType,
            isRootProduct: false,
        });
        this.getInsuredItemSpec(payload.grandChildSpec.productId);
    }

    /**
     * Configure primary insured item spec to add insured item
     */
    getPrimarySpec(value) {
        const childProductId =
            value.currentTarget || value.target
                ? value.currentTarget.dataset.childProductId || value.target.value
                : value;
        const primaryItem = this.insuredItemSpec.find((item) => item.productId === childProductId);

        if (this.editorConfig.parentLineId) {
            delete this.editorConfig.parentLineId;
        }

        this.setEditorConfig({
            isPrimary: true,
            isEditMode: false,
            productName: primaryItem.name,
            product: primaryItem,
            rootLineId: this.rootLineId, // Props to create primary item in OS
            rootProductId: this.rootProductId,
            rootProductType: this.rootProductType,
            isRootProduct: false,
        });
        this.getInsuredItemSpec(childProductId, primaryItem);
    }

    /**
     * Fetch insured item attribute metadata to display in record editor
     */
    getInsuredItemSpec(childProductId) {
        this.isLoaded = false;
        this.insQuoteSingleRootService
            .getInsuredItemAttrs(childProductId, this.rootProductId)
            .then((result) => {
                const response = dataFormatter.parseResponse(result);
                if (response && response.attributeCategories) {
                    this.setEditorConfig({ product: response });
                    this.openRecordEditor();
                }
            })
            .catch((message) => {
                commonUtils.showErrorToast.call(this, message);
            })
            .finally(() => {
                this.isLoaded = true;
            });
    }

    /**
     * Sends method to get grandchild or primary insured item attributes
     */
    editAttributes(payload) {
        this.editorConfig.isEditMode = true;
        if (payload.isGrandChild) {
            this.getGrandChildAttributes(false, payload);
        } else {
            this.getProductAttributes(payload.isRootProduct, payload.product.Id);
        }
    }

    /**
     * Fetches insured item attributes to view or edit existing insured items in modal
     */
    getProductAttributes(isRootProduct, lineId) {
        this.isLoaded = false;
        const inputMap = { lineId };
        const optionsMap = {
            disableCoverages: true,
            disableAttributeCategories: false,
        };
        this.insQuoteSingleRootService.getLineDetails(inputMap, optionsMap).then((response) => {
            this.isLoaded = true;
            const product = dataFormatter.parseResponse(response);
            this.setEditorConfig({
                product,
                isPrimary: true,
                quoteId: this.recordId, // Props to edit primary item in OS
                isRootProduct,
                rootLineId: this.rootLineId,
                rootProductId: this.rootLineItem.productId,
                rootProductType: this.rootProductType,
            });
            this.openRecordEditor();
        });
    }

    /**
     * Fetches grandchild attributes to view or edit existing insured items in modal
     */
    getGrandChildAttributes(isRootProduct, payload) {
        this.isLoaded = false;
        this.insQuoteSingleRootService
            .getInstanceGrandchildren(payload.parentLineId)
            .then(
                (response) => {
                    this.isLoaded = true;
                    const result = JSON.parse(response);
                    if (result && result.records) {
                        const product = result.records.find((prod) => prod.Id === payload.product.Id);
                        this.setEditorConfig({
                            product,
                            isPrimary: false,
                            quoteId: this.recordId, // Props to edit grandChild in OS
                            rootProductId: this.rootProductId,
                            rootLineId: this.rootLineId,
                            rootProductType: this.rootProductType,
                            isRootProduct,
                        });
                        this.openRecordEditor();
                    }
                },
                (error) => {
                    console.error(error);
                }
            )
            .finally(() => {
                this.isLoaded = true;
            });
    }

    /**
     * Configures record editor data to display attributes in omniscript or modal
     * @param {Object} attrs
     */
    setEditorConfig(attrs) {
        this.editorConfig = {
            ...this.editorConfig,
            ...attrs,
        };
        const productName =
            this.editorConfig.product.Name || this.editorConfig.productName || this.editorConfig.product.name;

        this.recordEditorTitle = this.options.isReadonly
            ? productName
            : `${this.editorConfig.isEditMode ? this.labels.Edit : this.labels.Add} ${productName}`;
    }

    /**
     * Sends attribute map change to add or edit insured items
     */
    attributeMapChange(payload) {
        if (this.editorConfig.isEditMode) {
            this.editInsuredItem(payload);
        } else {
            if (!this.editorConfig.isPrimary) {
                this.addGrandchild(payload);
            } else {
                this.addInsuredItem(payload);
            }
        }
    }

    /**
     * Adds insured item
     * @param {Object} payload
     */
    addInsuredItem(payload) {
        this.isLoaded = false;
        const inputMap = {
            rootLineId: this.rootLineItem.quoteLineItemId,
            productId: this.editorConfig.product.productId,
            attributeValues: payload.attributeMap,
        };
        const optionsMap = {
            includeLineDetail: true,
            disableChildProducts: false,
            disableCoverages: true,
        };

        this.insQuoteSingleRootService
            .addInsuredItem(inputMap, optionsMap)
            .then((result) => {
                this.isEditorOpen = false;
                this.isLoaded = true;
                this.rootLineItem.needReprice = true;
                const res = JSON.parse(result).result;
                if (res && res.result && res.result.records.length) {
                    this.clearRoot = true;
                    this.clearChildProducts = true;
                    this.formatChildLineDetails(res.result.records[0]);
                }
            })
            .catch((message) => {
                this.isLoaded = true;
                commonUtils.showErrorToast.call(this, message);
            });
    }

    /**
     * Adds grandchild insured item
     * @param {Object} payload
     */
    addGrandchild(payload) {
        this.isLoaded = false;
        const rootLineId = this.rootLineItem.quoteLineItemId;
        const productId = this.editorConfig.product.productId;
        this.insQuoteSingleRootService
            .addGrandchild(payload.attributeMap, rootLineId, productId, this.parentLineId, this.isPrimaryGrandChild)
            .then(() => {
                this.isPrimaryGrandChild = false;
                this.isLoaded = true;
                this.handleUpdate(this.successMessages.create, true);
            })
            .catch((message) => {
                this.isLoaded = true;
                commonUtils.showErrorToast.call(this, message);
            });
    }

    /**
     * Saves changes to insured items
     * @param {Object} payload
     */
    editInsuredItem(payload) {
        this.isLoaded = false;
        const attrMap = payload.attributeMap;
        const quoteLineItemId = this.editorConfig.product.quoteLineItemId;
        const isPrimary = this.editorConfig.isPrimary;
        const inputMap = {
            quoteId: this.recordId,
            attributeValues: attrMap,
            quoteLineId: quoteLineItemId,
            rootItemId: this.rootLineId,
            rootProductId: this.rootProductId,
            reprice: false,
            recalculateTaxesAndFees: false,
        };

        const optionsMap = {
            includeLineDetail: isPrimary,
            disableChildProducts: false,
            disableCoverages: true,
            disableAttributeCategories: true,
        };

        this.insQuoteSingleRootService
            .editInsuredItem(inputMap, optionsMap)
            .then((result) => {
                this.isLoaded = true;
                this.isEditorOpen = false;
                this.rootLineItem.needReprice = true;
                const res = JSON.parse(result).result;
                if (res && res.result && res.result.records[0]) {
                    commonUtils.showSuccessToast.call(this, this.successMessages.update);
                    this.clearRoot = true;
                    this.clearChildProducts = true;
                    this.formatChildLineDetails(res.result.records[0]);
                } else {
                    this.handleUpdate(this.successMessages.update, true);
                }
            })
            .catch((message) => {
                commonUtils.showErrorToast.call(this, message);
            })
            .finally(() => {
                this.isLoaded = true;
            });
    }

    /**
     * Deletes products
     */
    deleteProduct(payload) {
        this.isLoaded = false;
        if (payload.isRootProduct) {
            this.rootLineItem = null;
            this.insuredItemSpec = [];
        }
        this.insQuoteSingleRootService
            .deleteProduct(payload)
            .then(() => {
                this.isLoaded = true;
                commonUtils.showSuccessToast.call(this, this.successMessages.delete);
                if (payload.isRootProduct) {
                    pubsub.fire(this.rootQuoteChannel, 'removeRootProduct', {
                        Id: payload.quoteLineItemId,
                    });
                } else {
                    pubsub.fire(this.rootQuoteChannel, 'refreshQuote', this.isLoaded);
                }
            })
            .catch((message) => {
                commonUtils.showErrorToast.call(this, message);
                this.isLoaded = true;
            });
    }

    /**
     * Clears fetched coverages after update to call getLineDetails and retrieve coverage rule evalutions
     */
    clearFetchedLines(clearRoot = this.clearRoot, clearChild = this.clearChildProducts) {
        if (this.rootLineItem && clearRoot) {
            this.setDetailsFetched(this.rootLineItem.quoteLineItemId, false);
        }
        if (this.rootLineItem && this.rootLineItem.childProducts.records && clearChild) {
            this.rootLineItem.childProducts.records.forEach((product) => {
                this.setDetailsFetched(product.quoteLineItemId, false);
            });
        }
        this.clearChildProducts = false;
        this.clearRoot = false;
    }

    /**
     * Add grandchild item to an insured item
     */
    associateProduct(payload) {
        this.isLoaded = false;
        const { parentLineId, childLineId, isPrimary } = payload;
        this.insQuoteSingleRootService
            .associateProduct(parentLineId, childLineId, isPrimary)
            .then(() => {
                this.isLoaded = true;
                this.handleUpdate(this.successMessages.update, true);
            })
            .catch((message) => {
                this.isLoaded = true;
                commonUtils.showErrorToast.call(this, message);
            });
    }

    /**
     * Remove grandchild item from an insured item
     */
    unassociateProduct(payload) {
        this.isLoaded = false;
        const { parentLineId, childLineId } = payload;
        this.insQuoteSingleRootService
            .unassociateProduct(parentLineId, childLineId)
            .then(() => {
                this.isLoaded = true;
                this.handleUpdate(this.successMessages.update, true);
            })
            .catch((message) => {
                this.isLoaded = true;
                commonUtils.showErrorToast.call(this, message);
            });
    }

    /**
     * Sets primary grandchild item
     */
    setPrimary(payload) {
        this.isLoaded = false;
        const { parentLineId, childLineId } = payload;
        this.insQuoteSingleRootService
            .setPrimary(parentLineId, childLineId)
            .then(() => {
                this.isLoaded = true;
                this.handleUpdate(this.successMessages.update, true);
            })
            .catch((message) => {
                this.isLoaded = true;
                commonUtils.showErrorToast.call(this, message);
            });
    }

    /**
     * Adds or removes child line item when optional coverage is selected/unselected
     * @param {string} selectedCoveragePath
     */
    toggleOptionalCoverage(selectedCoveragePath) {
        const rootItems = Object.values(this.attributeChanges).filter(item => item.isRootItem);
        const childItems = Object.values(this.attributeChanges).filter(item => !item.isRootItem);

        if (rootItems.length > 0 || childItems.length > 0) {
            commonUtils.showErrorToast.call(this, "Guardar los cambios pendientes antes de agregar o quitar coberturas.");
            return;
        }

        this.isLoaded = false;
        const coverage = get(this.rootLineItem, selectedCoveragePath);
        if (coverage.isSelected) {
            this.insQuoteSingleRootService
                .deleteChildLine(coverage.quoteLineItemId)
                .then(() => {
                    this.rootLineItem.needReprice = true;
                    commonUtils.showSuccessToast.call(this, this.successMessages.update);
                    const inputMap = { lineId: coverage.parentQuoteLineItemId };
                    this.getLineDetails(inputMap);
                })
                .catch((message) => {
                    this.isLoaded = true;
                    commonUtils.showErrorToast.call(this, message);
                });
        } else {
            const inputs = {
                quoteId: this.recordId,
                productId: coverage.productId,
                subParentId: coverage.parentQuoteLineItemId,
                rootLineId: this.rootLineItem.quoteLineItemId,
            };
            this.insQuoteSingleRootService
                .addChildLine(inputs)
                .then(() => {
                    commonUtils.showSuccessToast.call(this, this.successMessages.update);
                    this.rootLineItem.needReprice = true;
                    const inputMap = { lineId: coverage.parentQuoteLineItemId };
                    this.getLineDetails(inputMap);
                })
                .catch((message) => {
                    this.isLoaded = true;
                    commonUtils.showErrorToast.call(this, message);
                });
        }
    }

    /**
     * Updates attribute value when user changes it
     * @param {Object} changedAttribute
     */
    changeAttributeValue(changedAttribute) {
        const attribute = get(this.rootLineItem, changedAttribute.path);
        if (attribute && !this.isEditorOpen) {
            //saves attribute changes from coverages and root product
            // this.isLoaded = false;
            const attributeValues = {
                [attribute.code]: changedAttribute.userValues,
            };
            let attributeValueDecoder;
            if (attribute.valueDecoder) {
                attributeValueDecoder = {
                    [attribute.code]: attribute.valueDecoder,
                };
            }
            const quoteLineId = attribute.parentQuoteLineItemId || this.rootLineItem.quoteLineItemId;
            const isRootCoverage = attribute.instanceLevelItemId === this.rootLineId;
            this.clearChildProducts = !attribute.instanceLevelItemId || isRootCoverage;
            this.clearRoot = !isRootCoverage;
            
            //Validate if there are invalid attribute values
            const attId = attribute.attributeId;
            const attValidity = changedAttribute.validValue;
            this.attributeChangesValidity[attId] = {
                attId: attValidity
            };
            this.invalidAttributeValues = Object.values(this.attributeChangesValidity).filter(att => att.attId == false).length != 0;
            if (this.invalidAttributeValues) {
                this.invalidAttributeClasses = 'has-error has-error-on';
            } else {
                this.invalidAttributeClasses = 'has-error';
            }

            // Check if the quoteLineId exists
            if (!this.attributeChanges[quoteLineId]) {
                let attributeIntialValues;
                let isRootItem;
                if (this.rootLineItem.quoteLineItemId == quoteLineId) {
                    isRootItem = true;
                    attributeIntialValues = JSON.parse(this.rootLineItem.vlocity_ins__AttributeSelectedValues__c) || {};
                    this.attributeActualValues.set(quoteLineId, this.attributeActualValues.has(quoteLineId) ? this.attributeActualValues.get(quoteLineId) : attributeIntialValues);
                } else {
                    isRootItem = false;
                    const result = this.rootLineItem.childProducts.records.filter(item => item.Id == quoteLineId);
                    attributeIntialValues = result[0].hasOwnProperty("vlocity_ins__AttributeSelectedValues__c") ? JSON.parse(result[0].vlocity_ins__AttributeSelectedValues__c) : {};
                    this.attributeActualValues.set(quoteLineId, this.attributeActualValues.has(quoteLineId) ? this.attributeActualValues.get(quoteLineId) : attributeIntialValues);
                }
                // If not, create a new entry with the attributeValues that are already there
                this.attributeChanges[quoteLineId] = {
                    quoteLineId: quoteLineId,
                    // attributeValues: attributeIntialValues,
                    attributeValues: this.attributeActualValues.get(quoteLineId),
                    isRootItem: isRootItem
                };
            }

            // Update the attributeValues with the new input data
            this.attributeChanges[quoteLineId].attributeValues[attribute.code] = changedAttribute.userValues;

            this.hasUnsavedRootItems = Object.values(this.attributeChanges).some(item => item.isRootItem);
            this.hasUnsavedChildItems = Object.values(this.attributeChanges).some(item => !item.isRootItem);

        }
    }

    saveAttributeChanges() {
        this.isLoaded = false;
        const rootItems = Object.values(this.attributeChanges).filter(item => item.isRootItem);
        const childItems = Object.values(this.attributeChanges).filter(item => !item.isRootItem);
        const options = {};
        const attributeChangesList = Object.values(this.attributeChanges);

        const params = {
            input: { attributeChangesList: attributeChangesList },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhActualizarPlanInsQuote_SegurosColectivos",
            options: JSON.stringify(options)
        }

        let cumpleValidacionRut = true;
        if (rootItems.length > 0) {            
            const rutValue = rootItems[0].attributeValues.Rut;
            cumpleValidacionRut = rootItems[0].attributeValues.ContratLegal === 'Ninguno' ? true : window.checkRut(rutValue);
        }

        if (cumpleValidacionRut) {
            //Update childItems
            if (childItems.length > 0) {
                this._actionUtil
                .executeAction(params, null, this, null, null)
                .then((response) => {
                    attributeChangesList.forEach((qli) => {
                        this.attributeActualValues.set(qli.quoteLineId, qli.attributeValues)
                    })
                    this.attributeChanges = {};
                    this.rootLineItem.needReprice = true;
                    commonUtils.showSuccessToast.call(this, this.successMessages.update);
                    const inputMap = {
                        lineId: this.rootLineItem.quoteLineItemId,
                    };
                    this.getLineDetails(inputMap);
                    this.invalidAttributeValues = true;
                    this.hasUnsavedChildItems = false;
                })
                .catch((error) => {
                    this.isLoaded = true;
                    commonUtils.showErrorToast.call(this, message);
                });
            }
            //Update rootItems
            if (rootItems.length > 0) {
                const quoteLineId = rootItems[0].quoteLineId;
                const attributeValues = rootItems[0].attributeValues;
                const attributeValueDecoder = {};
                this.insQuoteSingleRootService
                .updateChildLine(
                    quoteLineId,
                    attributeValues,
                    this.rootProductId,
                    this.rootLineId,
                    attributeValueDecoder,
                    this.recordId
                )
                .then((response) => {
                    this.attributeActualValues = this.attributeActualValues.set(quoteLineId, attributeValues);                    
                    this.attributeChanges = {};
                    this.rootLineItem.needReprice = true;
                    commonUtils.showSuccessToast.call(this, this.successMessages.update);
                    const inputMap = {
                        lineId: this.rootLineItem.quoteLineItemId,
                    };
                    this.getLineDetails(inputMap);
                    this.invalidAttributeValues = true;
                    this.hasUnsavedRootItems = false;
                })
                .catch((message) => {
                    this.isLoaded = true;
                    commonUtils.showErrorToast.call(this, message);
                });    
            }            
        } else {
            this.isLoaded = true;
            commonUtils.showErrorToast.call(this, "El formato de RUT no es el correcto");
        }

    }

    /**
     * Clones root product
     */
    cloneRootLine(rootId) {
        this.isLoaded = false;
        this.insQuoteSingleRootService
            .cloneRootQuoteLine(rootId)
            .then(() => {
                this.isLoaded = true;
                this.handleUpdate(this.successMessages.create, true);
            })
            .catch((message) => {
                this.isLoaded = true;
                commonUtils.showErrorToast.call(this, message);
            });
    }

    updateGroupClasses(payload) {
        pubsub.fire(this.rootQuoteChannel, 'updateGroupClasses', payload);
    }

    /**
     * Prices root and child products
     */
    priceRootItem() {
        this.isLoaded = false;
        this.isBatchMode = this.useRatingFact ? this.isBatchMode : false;

        this.insQuoteSingleRootService
            .priceRootItem(
                this.recordId,
                this.rootLineItem.Id,
                this.priceQuoteAsync,
                this.useRatingFact,
                this.isBatchMode
            )
            .then(() => {
                pubsub.fire(`insuranceQuoteChannel-${this.recordId}`, 'refreshInsuredItems');
                this.handleUpdate(this.successMessages.update, true);
            })
            .catch((message) => {
                commonUtils.showErrorToast.call(this, message);
                this.isLoaded = true;
            });
    }

    handleUpdate(message, clearFetched = false) {
        this.isEditorOpen = false;
        if (message) {
            commonUtils.showSuccessToast.call(this, message);
        }
        if (clearFetched) {
            this.clearFetchedLines(true, true);
        }
        pubsub.fire(this.rootQuoteChannel, 'refreshQuote', { isLoaded: this.isLoaded });
    }

    /**
     * Notifies parent component to toggle root line
     */
    toggleRootLine(Id) {
        pubsub.fire(this.rootQuoteChannel, 'toggleRootLine', { Id });
    }

    /**
     * Disables reprice if there are coverage rule errors
     */
    handleDisableReprice() {
        let childReprice = false;
        if (this.rootLineItem.childProducts && this.rootLineItem.childProducts.records) {
            childReprice = this.rootLineItem.childProducts.records.some(this.hasDisableRepriceErrors);
        }
        this.rootLineItem.disableReprice = this.rootLineItem.disableReprice || childReprice;
        this.rootLineItem = { ...this.rootLineItem };
    }

    /**
     * Helper method to check if child product has disableReprice (if child product is root coverage, check if coverage message has severity 'ERROR')
     * @param {Object} lineItem
     */
    hasDisableRepriceErrors(lineItem) {
        return (
            lineItem.disableReprice ||
            (lineItem.messages && lineItem.messages.some((message) => message.severity === 'ERROR'))
        ); // check if rootProduct coverages have errors
    }

    /**
     * Updates associated insProductInstance element
     * @param {string} quoteLineItemId
     */
    setDetailsFetched(quoteLineItemId, detailsFetched = true) {
        const el = this.template.querySelector(`[data-product-id*="${quoteLineItemId}"]`);
        if (el) {
            el.detailsFetched = detailsFetched;
            el.showCoverages = detailsFetched;
            el.isLoaded = true;
        }
    }

    updateEditorFlag() {
        this.isEditorOpen = false;
    }

    openProductList() {
        pubsub.fire(this.rootQuoteChannel, 'openProductList');
    }

    debugMode() {
        pubsub.fire(this.rootQuoteChannel, 'debugMode');
    }

    openRecordEditor() {
        this.isEditorOpen = true;
        this.template.querySelector('.vloc-ins-record-editor').openRecordEditor();
    }

    closeRecordEditor() {
        this.isEditorOpen = false;
        this.template.querySelector('.vloc-ins-record-editor').closeRecordEditor();
    }

    disconnectedCallback() {
        pubsub.unregister(this.rootChannel, this.pubsubPayload);
        pubsub.unregister(this.rootQuoteChannel, this.closeRecordEditor);
        pubsub.unregister(this.stateTransitionChannel, this.stateChange);
        pubsub.unregister('omniscript_action', this.omniscriptAction);
        pubsub.unregister('policy_action', this.issuePolicy);
    }

    get labelDebugButton() {
        return `${this.inDebugMode ? this.labels.InsQuoteProduction : this.labels.InsQuoteDebug} ${
            this.labels.InsQuoteMode
        }`;
    }

    get isDeviceSizeSupported() {
        return formFactorPropertyName.toUpperCase() !== 'SMALL';
    }

    get showDebugMode() {
        return this.isDeviceSizeSupported && this.enableDebugMode;
    }
}