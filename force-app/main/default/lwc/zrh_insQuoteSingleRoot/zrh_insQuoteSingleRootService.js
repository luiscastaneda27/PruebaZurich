import { remoteAction } from 'vlocity_ins/insUtility';

export default class InsQuoteService {
    getAllLines(recordId, needQuoteHeader, needsState) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'getAllLines',
            inputMap: {
                quoteId: recordId
            },
            optionsMap: {
               bFieldFlat: true,
               disableCoverages: true,
               disableAttributeCategories: true,
               rootAttributeCategoryOnly: true,
               needsState: needsState || false,
               needQuoteHeader: needQuoteHeader || false
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getQuoteLineItemDetail(childLineType, rootLineId, rootProdId) {
        const dataMapValue = {
            className: 'InsuranceQuoteProcessingService',
            methodName: 'getQuoteLineItemDetail',
            inputMap: {
                childLineType,
                rootLineId,
                rootProdId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getLineDetails(
        inputMap,
        optionsMap
    ) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'getLineDetails',
            inputMap,
            optionsMap
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getRootDetails(rootLineId, rootProdId) {
        const dataMapValue = {
            className: 'InsuranceQuoteProcessingService',
            methodName: 'getQuoteLineItemDetail',
            inputMap: {
                rootLineId,
                rootProdId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getInsuredItems(productId) {
        const dataMapValue = {
            className: 'InsProductService',
            methodName: 'getInsuredItems',
            inputMap: {
                productId
            },
            optionsMap: {
                bFieldFlat: true
            }
        }
        return remoteAction.genericInvoke(dataMapValue);
    }

    deleteProduct(payload){
        const methodName = payload.isRootProduct ? 'deleteRootItem' : 'deleteInsuredItem';
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName,
            inputMap: {
                quoteLineId: payload.quoteLineItemId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getInsuredItemAttrs(childProductId, productId) {
        const dataMapValue = {
            className: 'InsProductService',
            methodName: 'getInsuredItemSpec',
            inputMap: {
                productId,
                childProductId
            }
        }
        return remoteAction.genericInvoke(dataMapValue);
    }

    addInsuredItem(inputMap, optionsMap) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'addInsuredItem',
            inputMap,
            optionsMap
        }
        return remoteAction.genericInvoke(dataMapValue);
    }

    addGrandchild(attributeValues, rootLineId, productId, parentLineId, isPrimary){
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'addInsuredItem',
            inputMap: {
                rootLineId,
                productId,
                parentLineId,
                attributeValues,
                isPrimary
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    /**
     * Change primary child line item for target parent
     *
     * @param {string} parentLineId Id of target parent line item
     * @param {string} childLineId Id of new primary child line item for parent
     */
    setPrimary(parentLineId, childLineId) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'updatePrimaryInsuredItem',
            inputMap: {
                parentLineId,
                childLineId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    editInsuredItem(inputMap, optionsMap) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'updateChildLine',
            inputMap,
            optionsMap
        }
        return remoteAction.genericInvoke(dataMapValue);
    }

    associateProduct(parentLineId, childLineId, isPrimary) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'addInsuredItemRelationship',
            inputMap: {
                parentLineId,
                childLineId,
                isPrimary
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    unassociateProduct(parentLineId, childLineId) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'deleteInsuredItemRelationship',
            inputMap: {
                parentLineId,
                childLineId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getAllGrandChildInsuredItems(quoteId, childProductId) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'getAllGrandChildInsuredItems',
            inputMap: {
                quoteId,
                childProductId
            },
            optionsMap: {}
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getInstanceGrandchildren(primaryItemId) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'getGrandChildLines',
            inputMap: {
                primaryItemId
            },
            optionsMap: {
                disableAttributeCategories: false
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    addChildLine(inputs) {
        const { quoteId, productId, subParentId, rootLineId } = inputs;
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'addChildLine',
            inputMap: {
                quoteId,
                productId,
                subParentId,
                rootLineId,
                reprice: false,
                prodRecordType: 'CoverageSpec'
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    deleteChildLine(quoteLineId) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'deleteChildLine',
            inputMap: {
                quoteLineId,
                reprice: false,
                itemRecordType: 'CoverageSpec'
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    updateChildLine(quoteLineId, attributeValues, rootProductId, rootItemId, attributeValueDecoder, quoteId, fieldValues) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'updateChildLine',
            inputMap: {
                quoteLineId,
                attributeValues,
                reprice: false,
                rootProductId,
                rootItemId,
                quoteId,
                fieldValues
            }
        };
        if (attributeValueDecoder) {
            dataMapValue.inputMap.attributeValueDecoder = attributeValueDecoder;
        }
        return remoteAction.genericInvoke(dataMapValue);
    }

    priceRootItem(quoteId, rootLineId, vlocityAsync = false, useRatingFact, isBatchMode) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'priceRootItem',
            inputMap: { quoteId, rootLineId },
            optionsMap: { useRatingFact, isBatchMode },
            vlocityAsync
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    cloneRootQuoteLine(id) {
        const dataMapValue = {
            className: 'InsuranceClonerHandler',
            methodName: 'cloneRootQuoteLine',
            inputMap: {
                healthQuoteLineId: id
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }
}