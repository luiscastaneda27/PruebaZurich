import {api, track } from 'lwc';
import insAttributeCategory from 'vlocity_ins/insAttributeCategory';
export default class zrh_insAttributeCategory extends insAttributeCategory {
    @api rootChannel;
    @api theme = 'slds';
    @api currency;
    @api displayCategoryName = false;
    @api attributeStyle = '';
    @api ruleContext;
    @api isReadonly = false;
    @api colWidth = 5;

    @track productAttributes = {};

    @api
    get attributeCategory() {
        return this._attributeCategory;
    }

    set attributeCategory(data) {
        if (data) {
            this._attributeCategory = JSON.parse(JSON.stringify(data));
            this.productAttributes = this.setAttrContainerClasses(this._attributeCategory.productAttributes);
            this.hideCategoryLabel = !this.displayCategoryName || this.isAllAttrsInCategoryHidden();
        }
    }

    // deprecated properties
    @api currencySymbol;

    hiddenAttributes = {};

    connectedCallback() {
        this.template.addEventListener('updatecategory', this.updateAttrContainerClasses.bind(this));
        this.productAttributes = this.setAttrContainerClasses(this.productAttributes);
        this.hideCategoryLabel = !this.displayCategoryName || this.isAllAttrsInCategoryHidden();
    }

    setAttrContainerClasses(productAttributes) {
        if (productAttributes.records) {
            productAttributes.records.forEach((attr) => {
                let isHidden = attr.hidden || attr.hiddenByRule || attr.inputType === 'equalizer';
                // Apply condition for LEX UI only
                if (this.ruleContext) {
                    isHidden = isHidden || this.hiddenAttributes[attr.attributeId];
                }
                this.hiddenAttributes[attr.attributeId] = isHidden;
                attr.classes = this.setAttrContainerClassesHelper(isHidden, attr.attributeId);
            });
        }
        return productAttributes;
    }

    updateAttrContainerClasses(data) {
        const idx = this.productAttributes.records.findIndex(
            (record) => record.attributeId === data.detail.attributeId
        );
        this.hiddenAttributes[data.detail.attributeId] = data.detail.isHidden;
        this.productAttributes.records[idx].classes = this.setAttrContainerClassesHelper(
            data.detail.isHidden,
            data.detail.attributeId
        );
        this.hideCategoryLabel = !this.displayCategoryName || this.isAllAttrsInCategoryHidden();
    }

    setAttrContainerClassesHelper(isAttributeHidden) {
        return isAttributeHidden
            ? `${this.theme}-hide`
            : `${this.theme}-col ${this.theme}-size_1-of-1 ${this.theme}-small-size_1-of-${this.colWidth}`;
    }

    isAllAttrsInCategoryHidden() {
        return Object.values(this.hiddenAttributes).every((attr) => attr);
    }

    get attributeInnerContainerClasses() {
        return `vloc-ins-attribute-container ${
            this.attributeStyle === 'communities'
                ? `${this.theme}-border_bottom ${this.theme}-p-vertical_small ${this.theme}-m-horitzonal_small`
                : `${this.theme}-m-right_small ${this.theme}-m-vertical_small`
        }`;
    }
}