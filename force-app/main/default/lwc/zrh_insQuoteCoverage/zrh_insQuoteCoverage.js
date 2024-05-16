import { api, track } from 'lwc';
import { namespace } from 'vlocity_ins/utility';
import insQuoteCoverageTemplate from './zrh_insQuoteCoverage.html';
import { LABELS } from './zrh_insQuoteCoverageLabels.js';
import insQuoteCoverage from 'vlocity_ins/insQuoteCoverage';

export default class zrh_insQuoteCoverage extends insQuoteCoverage {
    @api
    get coverage() {
        return super.coverage;
    }

    @api displayPrice = false;
    showAttributes = false;
    showAttributesClass = 'att-cat-container hidden';

    set coverage(data) {
        super.coverage = data;
        if (data) {
            this.isSelected = this._coverage.isSelected;
            this.needReprice = this._coverage.needReprice;
            this.isExcluded = this._coverage.isExcluded;
            this.coverageCode = `(${data.ProductCode})`;
            // Quote coverage rules
            if (this._coverage[`${namespace}AttributeMetadataChanges__c`]) {
                const rules = this._coverage[`${namespace}AttributeMetadataChanges__c`];
                this.setCoverageRules(JSON.parse(rules));
            }
        }
    }

    get chevronName() {
        return this.showAttributes ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get displayAttributes() {
        return this.isSelected;
    }

    get iconColor() {
        return this.isSelected ? '#0070D2' : '#7c7c7c';
    }

    @track needReprice;
    @track isSelected;
    @track isExcluded;

    labels = LABELS;
    messages = [];

    connectedCallback() {
        this.labels.Includes = this.labels.Includes.charAt(0).toUpperCase() + this.labels.Includes.substring(1);
    }


    setCoverageRules(rules) {
        const {
            relationshipRuleResult = {},
            validationRuleResult = {},
            eligibilityRuleResult = {},
        } = rules.optionalCoverageRuleResult;

        const relationshipMessages = relationshipRuleResult.messages || [];
        const validationMessages = validationRuleResult.messages || [];
        const eligibilityMessages = eligibilityRuleResult.messages || [];

        const messages = [...relationshipMessages, ...validationMessages, ...eligibilityMessages];
        this.messages = messages.length ? this.formatMessages(messages) : [];
        this.disableReprice = relationshipRuleResult.disableReprice;
    }

    toggleAttributes() {
        this.showAttributes = !this.showAttributes;
        this.showAttributesClass = this.showAttributes ? 'att-cat-container' : 'att-cat-container hidden';
    }

    formatMessages(messages) {
        //Set classes for message
        return messages.map((message, i) => {
            const map = { ...message };
            let styles = `${this.theme}-text-title ${this.theme}-p-top_xx-small `;
            if (map.severity === 'ERROR') {
                styles += `${this.theme}-text-color_error`;
            } else if (map.severity === 'WARN') {
                styles += `vloc-ins-text-color_warn`;
            } else {
                styles += `vloc-ins-text-color_info`;
            }
            map.id = i;
            map.styles = styles;
            return map;
        });
    }

    renderedCallback() {
        this.onPageLoad('renderedCallback');
    }

    render() {
        return insQuoteCoverageTemplate;
    }

    get priceClasses() {
        let classes = `${this.theme}-text-heading_small`;
        if (this.needReprice) {
            classes += ` ${this.theme}-text-color_error`;
        }
        return classes;
    }

    get disableRemove() {
        return this.options.isReadonly || !this.options.isDeletable;
    }

    get displayRuleMessages() {
        return this.messages.length && this.isSelected;
    }

    get disableAdd() {
        return this.options.isReadonly || this.isExcluded;
    }

    get displayCoverageDescription() {
        return this.options.showCovDescriptions && this.coverage && this.coverage.Description;
    }

    /* For readability purposes we limit the tooltip content to 240 characters */
    get coverageDescription() {
        return this.coverage.Description && this.coverage.Description.length > 240
            ? this.coverage.Description.slice(0, 240) + '...'
            : this.coverage.Description;
    }

}