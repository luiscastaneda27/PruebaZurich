import { remoteAction } from 'vlocity_ins/insUtility';

export default class InsQuoteService {
    getAllLines(recordId, needQuoteHeader, needsState, includeGroupClasses) {
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
               needQuoteHeader: needQuoteHeader || false,
               isMultiRoot: true,
               includeGroupClasses
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    getLineDetails(lineItemId) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'getLineDetails',
            inputMap: {
                lineId: lineItemId,
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    priceQuote(quoteId, vlocityAsync = false) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'priceQuote',
            inputMap: {
                quoteId
            },
            vlocityAsync
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    addRootItems(productIds, quoteId) {
        const dataMapValue = {
            className: 'InsurancePCRuntimeHandler',
            methodName: 'addRootItems',
            inputMap: {
                productIds,
                quoteId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }
}