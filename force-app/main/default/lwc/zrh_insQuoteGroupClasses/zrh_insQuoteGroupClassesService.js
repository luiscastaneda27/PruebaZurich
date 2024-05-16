import { remoteAction } from 'vlocity_ins/insUtility';

export default class InsQuoteGroupClassesService {
    getGroupClasses(quoteId, lineId) {
        const dataMapValue = {
            className: 'InsuranceQuoteProcessingService',
            methodName: 'getGroupClasses',
            inputMap: {
                quoteId,
                lineId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    associateGroupClassesToLine(quoteId, lineId, groupClassIds) {
        const dataMapValue = {
            className: 'InsuranceQuoteProcessingService',
            methodName: 'associateGroupClassesToLine',
            inputMap: {
                quoteId,
                lineId,
                groupClassIds
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }

    removeQliGroupClass(qliGroupClassId) {
        const dataMapValue = {
            className: 'InsuranceQuoteProcessingService',
            methodName: 'removeQliGroupClass',
            inputMap: {
                qliGroupClassId
            }
        };
        return remoteAction.genericInvoke(dataMapValue);
    }
}