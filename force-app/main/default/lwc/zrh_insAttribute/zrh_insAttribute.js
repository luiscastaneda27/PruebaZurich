import {api, track } from 'lwc';
import pubsub from 'vlocity_ins/pubsub';
import { clientRules107, dataFormatter, commonUtils } from 'vlocity_ins/insUtility';
import { insAttributeLabels } from 'vlocity_ins/insLabels';
import { isMobile } from 'vlocity_ins/utility';
import oldUiTemplate from './zrh_insAttribute.html';
import newUiTemplate from './zrh_insAttribute_new.html';
import insAttribute from 'vlocity_ins/insAttribute';

export default class zrh_insAttribute extends insAttribute {
    @api rootChannel;
    @api insuredItemsChannel;
    @api theme = 'slds';
    @api currency = dataFormatter.currency;
    @api isReadonly = false;
    @api ruleContext;
    @api stackLabels;

    @api
    get attributeStyle() {
        return this._attributeStyle;
    }

    set attributeStyle(data) {
        this._attributeStyle = data || '';
    }

    @api
    get attribute() {
        return this._attribute;
    }

    set attribute(data) {
        this._attribute = JSON.parse(JSON.stringify(data));
        if (!this.cachedRules) {
            this.messages = this.formatMessages(data.messages); //events are used for rules, cache the rules bc re-rate is out of sync
        } else {
            this.attribute.rules = this.cachedRules;
        }
        if (this.cachedChanges) {
            this.implementRuleChanges(this.cachedChanges);
        }
        if (this.isReadonly) {
            this.displayValue = dataFormatter.formatDisplayValue(data, this.currency);
        }
        this.isDisabled = data.readonly || data.isSetValue;
        this.isHidden = data.hidden || data.inputType === 'equalizer' || data.hiddenByRule || this.isHiddenByRule;
        this.isLabelHidden = data.hideLabel;

        this.isCurrency = data.dataType === 'currency';
        this.isPercentage = data.dataType === 'percentage';
        this.isPlainNumber = !this.isCurrency && !this.isPercentage;
        this.isDateTime = data.dataType === 'datetime';
        this.isDate = data.dataType === 'date';

        this.isInputText = data.inputType === 'text';
        this.isInputTextarea = data.inputType === 'textarea';
        this.isInputNumber = data.inputType === 'number';
        this.isInputRange = data.inputType === 'range';
        this.isInputRadio = data.inputType === 'radio';

        this.isInputDropdown = data.inputType === 'dropdown' && !data.multiselect;
        this.isInputMultiSelectDropdown = data.inputType === 'dropdown' && data.multiselect;
        this.isInputCheckbox = data.inputType === 'checkbox' && !data.multiselect;
        this.isInputMultiSelectCheckbox = data.inputType === 'checkbox' && data.multiselect;

        if (this.isInputDropdown) {
            if (this._attribute.userValues === 0) {
                this._attribute.userValues = JSON.stringify(this._attribute.userValues);
            } else if (typeof this._attribute.userValues === 'boolean') {
                // Combobox component expects value to be a string or number
                this._attribute.userValues = JSON.stringify(this._attribute.userValues);
            }
        }

        if (this.isInputMultiSelectDropdown) {
            const isUserValuesArr =
                this._attribute.userValues &&
                Array.isArray(this._attribute.userValues) &&
                this._attribute.userValues.length;
            // In Omniscript, userValues can be returned as list containing empty string
            if (isUserValuesArr && this._attribute.userValues[0] === '') {
                this._attribute.userValues = [];
            }
            this.multiSelectLabel = `${isUserValuesArr ? this._attribute.userValues.length : '0'} ${
                this.labels.Selected
            }`;
        }

        if (this.isDate) {
            // If date format returned is MM/DD/YYYY, it is either legacy date format from Product Admin or previously saved in this format.
            // In this case, do not change date formt to YYYY-MM-DD. Otherwise, store date as YYYY-MM-DD. This is added to resolve customer issue: W-10294956
            this.isLegacyDateFormat =
                this._attribute.userValues && this.validateDateFormatRegx(this._attribute.userValues);
        }
        this.userValues = this._attribute.userValues;
        this.setCheckedFlag(data.userValues);
        if (!this._attribute.valuesBeforeRules && this._attribute.values) {
            this._attribute.valuesBeforeRules = JSON.parse(JSON.stringify(this._attribute.values));
        }
    }
    
    @api noCumpleConRut = false;

    @api 
    get esRut(){
        console.log("Entro al Es Rut");
        return this.attribute.label == "Rut";
    }

    handleRutChange(e){
        console.log("Entro al handle Rut Change");
        this.noCumpleConRut = window.checkRut(e.currentTarget.dataset.value);
    }

    @track userValues;
    @track displayValue;
    @track isDisabled;
    @track isHidden;
    @track isInputText;
    @track isInputNumber;
    @track isInputDropdown;
    @track isInputCheckbox;
    @track isInputRange;
    @track isComboboxOpen;

    //Rules:
    @track messages = [];
    @track interests;
    @track rulesDebug;
    @track inDebugMode;

    _attributeStyle = '';
    hasAttrRuleErrors;
    isLegacyDateFormat;
    _attribute = {};
    labels = insAttributeLabels;
    dateFormat = isMobile ? '' : 'MM/DD/YYYY';

    // deprecated properties
    @api currencySymbol;
    @api newUi;

    render() {
        // Deprecated, but reference needed for patch build
        return this.newUi ? newUiTemplate : oldUiTemplate;
    }

    connectedCallback() {
        // Init insClientRules107 (bottom-up approach);
        this.initRules();

        this.imaskNumberAttributes = {
            // eslint-disable-next-line no-new-wrappers
            mask: new Number(),
            numberMask: true,
            scale: 50,
            radix: '.',
            thousandsSeparator: ',',
        };

        if (this.isReadonly) {
            if (
                this.attribute.dataType.toLowerCase() === 'date' &&
                this.validateDateFormatRegx(this._attribute.userValues)
            ) {
                // Run this method ONLY when date is stored in MM/DD/YYYY
                this.displayValue = dataFormatter.formatAttributeDateValueWithoutTimeZone(this.attribute);
            } else {
                this.displayValue = dataFormatter.formatDisplayValue(this.attribute, this.currency);
            }
        }
    }

    disconnectedCallback() {
        if (this.pubsubPayload) {
            pubsub.unregister(this.uniqueProductChannel, this.pubsubPayload.uniqueProductChannel);
            pubsub.unregister(this.rootChannel, this.pubsubPayload.rootChannel);
        }
    }

    formatMessages(messages) {
        //Set classes for message
        this.hasAttrRuleErrors = false;
        const result = [];
        if (!messages) {
            return result;
        }
        for (let i = 0; i < messages.length; i++) {
            const message = JSON.parse(JSON.stringify(messages[i]));
            let styles = `${this.theme}-text-title ${this.theme}-p-vertical_xx-small `;
            if (message.severity === 'ERROR') {
                this.hasAttrRuleErrors = true;
                styles += `${this.theme}-text-color_error`;
            } else if (message.severity === 'WARN') {
                styles += `vloc-ins-text-color_warn`;
            } else {
                styles += `vloc-ins-text-color_info`;
            }
            message.id = message.code + '-' + i;
            message.styles = styles;
            result.push(message);
        }
        this.triggerAttrRuleErrorEvent();
        return result;
    }

    setCheckedFlag(userValues) {
        if (this.isInputCheckbox) {
            this.userValues = userValues === true || userValues === 'true' ? true : false;
        } else if (this.isInputMultiSelectCheckbox) {
            this.attribute.values.forEach((attrValue) => {
                attrValue.checkboxId = `checkbox-${attrValue.id}`;
                if (userValues && Array.isArray(userValues)) {
                    userValues.forEach((userValue) => {
                        if (userValue[attrValue.value] !== undefined) {
                            attrValue.checked = userValue[attrValue.value];
                        }
                    });
                } else {
                    this.userValues = [];
                }
            });
        } else if (this.isInputMultiSelectDropdown) {
            if (userValues && Array.isArray(userValues)) {
                this.attribute.values.forEach((attrValue) => {
                    userValues.forEach((userVal) => {
                        let userValue = JSON.parse(JSON.stringify(userVal));
                        if (userValue === attrValue.value) {
                            attrValue.checked = true;
                        }
                    });
                });
            } else {
                this.attribute.values.forEach((attrValue) => {
                    if (userValues === attrValue.value) {
                        attrValue.checked = !attrValue.checked;
                    }
                });
            }
        }
    }

    handleValueChange(e) {
        if (this.isDisabled) return; //ensures never change on readonly

        const allValid = [
            ...this.template.querySelectorAll('vlocity_ins-masked-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        // console.log('valid: ', allValid);
        // if (allValid) {
        //     alert('All form entries look valid. Ready to submit!');

        // } else {
        //     alert('Please update the invalid form entries and try again.');
        // }
        
        let newUserValues = this.isInputCheckbox ? e.target.checked : e.target.value;

        if (this.isInputMultiSelectCheckbox) {
            if (this.userValues && Array.isArray(this.userValues)) {
                const userValue = this.userValues.find((attrUserValues) => {
                    return attrUserValues.hasOwnProperty(newUserValues);
                });
                // In Omniscript, userValues can be returned as null or contain no metadata
                if (userValue) {
                    userValue[newUserValues] = !userValue[newUserValues];
                } else {
                    const newUserValue = {};
                    newUserValue[newUserValues] = true;
                    this.userValues.push(newUserValue);
                }
            }
            newUserValues = this.userValues;
            this.setCheckedFlag(this.userValues);
        } else if (this.isInputMultiSelectDropdown) {
            newUserValues = e.currentTarget.dataset.value;
            this.setCheckedFlag(newUserValues);

            if (!this.userValues) {
                this.userValues = [];
            }
            if (!this.userValues.includes(newUserValues)) {
                this.userValues.push(newUserValues);
            } else {
                const idx = this.userValues.indexOf(newUserValues);
                this.userValues.splice(idx, 1);
            }
            newUserValues = this.userValues;
            this.multiSelectLabel = `${this.userValues ? this.userValues.length : '0'} ${this.labels.Selected}`;
        } else if (this.userValues === 'true' || this.userValues === 'false') {
            // Convert string booleans back to boolean
            this.userValues = JSON.parse(this.userValues);
        } else if (this.isDateTime) {
            newUserValues = newUserValues ? new Date(newUserValues).toISOString() : newUserValues;
        }
        const sameValue =
            this.userValues === newUserValues ||
            (this.userValues != null && newUserValues && this.userValues.toString() === newUserValues.toString());
        if (sameValue && !this.isInputMultiSelectCheckbox && !this.isInputMultiSelectDropdown) {
            return;
        }

        const payload = {
            attributeId: this.attribute.attributeId,
            path: this.attribute.path,
            userValues: newUserValues,
            attrCode: this.attribute.code,
            valueDecoder: this.attribute.valueDecoder,
            validValue: allValid
        };
        this.userValues = newUserValues;
        if (this.ruleContext) {
            this.attributePostValue();
        }
        if (this.insuredItemsChannel) {
            pubsub.fire(this.insuredItemsChannel, 'changeAttributeValue', payload);
        } else {
            pubsub.fire(this.rootChannel, 'changeAttributeValue', payload);
        }
    }

    toggleMultiDropdown() {
        this.isComboboxOpen = !this.isComboboxOpen;
    }

    get comboboxDropdownClasses() {
        return (
            `${this.theme}-combobox` +
            ` ${this.theme}-dropdown-trigger` +
            ` ${this.theme}-dropdown-trigger_click` +
            `${this.isComboboxOpen ? ` ${this.theme}-is-open` : ''}`
        );
    }

    get multiComboboxLabel() {
        return this.attribute.multiSelectLabel;
    }

    get uniqueOptionsName() {
        return this.attribute.id;
    }

    get containerClasses() {
        this.stackLabels = true;
        if (this.stackLabels) {
            return '';
        }

        let classes = `${this.theme}-grid ${this.theme}-grid_align-spread`;

        if (this.attributeStyle === 'recordEditor') {
            return this.isReadonly ? classes : '';
        }

        // Community attribute styles
        if (this.isCommunityStyles) {
            classes += ` ${this.theme}-communities-attr`;
            return this.attributeStyle === 'communitiesCoverage'
                ? `${classes} ${this.theme}-communities-attr_coverage ${this.theme}-p-top_small ${this.theme}-m-horizontal_medium ${this.theme}-p-left_xx-small`
                : `${classes}`;
        }

        classes = `${this.theme}-grid ${this.theme}-grid_vertical-align-center ${this.theme}-wrap`;

        // Coverages attribute styles
        if (this.attributeStyle === 'coveragelist') {
            classes += ' vloc-ins-attribute-component';
        } else if (this.attributeStyle === 'adminCoverage') {
            classes += ` ${this.theme}-p-top_small`;
        }
        return classes;
    }

    get valueContainerClasses() {
        let classes = '';
        if (!this.attribute.hideLabel) {
            if (this.attributeStyle === 'coveragelist') {
                classes += `${this.theme}-size_1-of-1 ${this.theme}-large-size_5-of-12`;
            } else if (this.attributeStyle === 'recordEditor') {
                if (this.isReadonly) {
                    classes += ` ${this.theme}-size_1-of-2 ${this.theme}-text-align_right`;
                } else {
                    classes += ` ${this.theme}-size_1-of-1`;
                }
            } else if (this.isCommunityStyles) {
                return `${this.theme}-size_1-of-2`;
            } else {
                classes += `${this.theme}-size_1-of-1 ${this.theme}-small-size_1-of-1`;
            }
            if (this.isReadonly) {
                const isMobileCoverageList = this.attributeStyle !== 'recordEditor' && isMobile;
                classes += ` ${this.theme}-text-align_${isMobileCoverageList ? 'left' : 'right'}`;
            }
        }
        return classes;
    }

    get labelContainerClasses() {
        if (this.attributeStyle === 'recordEditor') {
            return this.isReadonly ? ` ${this.theme}-size_1-of-2` : '';
        }

        if (this.isCommunityStyles) {
            return `${this.theme}-communities-attr-label ${this.theme}-size_1-of-2 ${
                this.attributeStyle === 'communitiesCoverage' ? ` ${this.theme}-p-left_xxx-small` : ''
            }`;
        }

        let classes = `${this.theme}-p-right_small`;
        if (!this.attribute.hideLabel) {
            if (this.attributeStyle === 'coveragelist') {
                classes += ` ${this.theme}-size_1-of-1 ${this.theme}-small-size_1-of-1 ${this.theme}-large-size_7-of-12`;
            } else {
                classes += ` ${this.theme}-size_1-of-1 ${this.theme}-small-size_1-of-1 equal-label-size`;
            }
        }
        return classes;
    }

    get labelClasses() {
        let classes = '';
        if (this.attributeStyle === 'coveragelist') {
            classes += 'vloc-ins-label';
        } else if (this.attributeStyle === 'adminCoverage') {
            classes += `vloc-ins-admin-text vloc-ins-admin-label ${this.theme}-p-bottom_xx-small`;
        } else if (this.isCommunityStyles) {
            classes = `${this.theme}-communities-attr-label`;
        }
        return classes;
    }

    get attributeStep() {
        return this.attribute.step || 1;
    }

    get readonlyValueClasses() {
        return this.isCommunityStyles
            ? `${this.theme}-communities-attr-label ${this.theme}-communities-attr-value`
            : 'vloc-ins-admin-text';
    }

    get isCommunityStyles() {
        return this.attributeStyle.includes('communities');
    }

    //______107 RULES______//

    /*
     * On load, init attribute rules
     * Find interests, init event channels, and share interests (if any)
     * An interest is an attribute who's value I need to evaluate a rule
     */
    initRules() {
        //  insClientRules107 - Bottom-up rules evaluation approach (i.e., used in original Quote LWC and insRecordEditor LWC in Commercial Quote LWC)
        if (this.ruleContext) {
            this.uniqueCode = (this.ruleContext.productCode || this.attribute.productCode) + '.' + this.attribute.code;
            this.productChannel = this.ruleContext.productChannel;
            this.uniqueProductChannel = this.ruleContext.uniqueProductChannel;
            this.inDebugMode = this.ruleContext.debugMode;
            this.pubsubPayload = {
                uniqueProductChannel: { attributePostValue: this.attributePostValue.bind(this) },
                rootChannel: { setDebugMode: this.setDebugMode.bind(this) },
            };
            pubsub.register(this.rootChannel, this.pubsubPayload.rootChannel);
            this.hasRules();
            if (this.attribute.hasRules) {
                this.attribute.uniqueCode = this.uniqueCode;
                this.attribute.userProfile = this.ruleContext.userProfile;
                const result = JSON.parse(JSON.stringify(clientRules107.getInterests(this.attribute)));
                this.interests = result.interests;
                this.attribute = result.attribute;
                this.cachedRules = this.attribute.rules;
                this.rulesDebug = Object.values(this.interests);
                if (this.interests) {
                    this.shareInterests();
                    this.pubsubPayload.uniqueProductChannel.getValue = this.getValue.bind(this);
                }
            }
            pubsub.register(this.uniqueProductChannel, this.pubsubPayload.uniqueProductChannel);
        }
    }

    //function to set hasRules flag correctly
    hasRules() {
        this.attribute.hasRules = Array.isArray(this.attribute.rules) || this.attribute.hasRules;
        if (!this.attribute.hasRules && this.attribute.values) {
            this.attribute.hasRules = this.attribute.values.some((value) => {
                return value.rules && value.rules.length > 0;
            });
        }
    }

    //toggle debug mode (event sent by insQuote)
    setDebugMode(e) {
        this.inDebugMode = e;
    }

    /*
     * Share attributes interest with parent product
     * Fn runs on load only
     */
    shareInterests() {
        const message = {
            uniqueCode: this.uniqueCode,
            interests: this.interests,
            productCode: this.ruleContext.productCode,
        };
        pubsub.fire(this.uniqueProductChannel, 'getChildInterests', JSON.stringify(message));
    }

    //Post new token value to all products
    attributePostValue() {
        // console.log('ins_post:', this.uniqueCode, this.userValues);
        const message = {
            uniqueCode: this.uniqueCode,
            newValue: this.userValues,
            valueDecoder: this.attribute.valueDecoder,
        };
        pubsub.fire(this.productChannel, 'postValue', JSON.stringify(message));
    }

    // insClientRules107 (Bottoms-up approach): Listener to get new value and re-evaluate rules with dependencies on this new token value
    getValue(e) {
        const response = JSON.parse(e);
        if (this.attribute.uniqueCode === response.uniqueCode) {
            this.attribute.userValues = response.newValue;
            this.userValues = this.attribute.userValues;
            if (response.hasOwnProperty('isSetValue')) {
                this.isDisabled = this.attribute.readonly || response.isSetValue;
            }
        }
        if ((this.interests && this.interests[response.uniqueCode]) || this.interests.USER_PROFILE) {
            this.messages = [];
            const result = clientRules107.evaluateRules(this.attribute.rules, this.interests, response, this.attribute);
            this.interests = result.interests;
            this.attribute.rules = result.rules;
            this.rulesDebug = Object.values(this.interests); //updated interests (rule evals)
            this.cachedChanges = result.changes;
            this.implementRuleChanges(result.changes);
        }
    }

    /*
     * Impelement changes from rules
     * changes can be: hide {Boolean}, showMessages {Array of messages}, dropdown {Array of indexes to hide in values}
     */
    implementRuleChanges(changes) {
        if (changes.hasOwnProperty('hide')) {
            if (!this.isHidden || !this.attribute.hidden || (this.attribute.visibleBeforeRules && !changes.hide)) {
                this.isHidden = changes.hide;
                if (changes.hide !== this.isHiddenByRule) {
                    //If hide flag is updated by rule, send event to category to hide/show attribute classes and category label
                    commonUtils.triggerCustomEvent.call(this, 'updatecategory', {
                        detail: {
                            isHidden: this.isHidden,
                            attributeId: this.attribute.attributeId,
                        },
                    });
                }
                this.isHiddenByRule = this.isHidden; //have own flag bc it gets rest every render
            }
        }
        if (changes.showMessages) {
            this.messages = this.formatMessages(changes.showMessages);
        } else if (this.hasAttrRuleErrors) {
            this.hasAttrRuleErrors = false;
            this.triggerAttrRuleErrorEvent();
        }
        if (this.attribute.valuesBeforeRules) {
            if (changes.hideDropdownValues) {
                this.hideShowDropdownValues(changes.hideDropdownValues, 'hide');
            }
            if (changes.showDropdownValues) {
                this.hideShowDropdownValues(changes.showDropdownValues, 'show');
                this.updateDefaultDropdownValue();
            }
        }
    }

    /**
     * Regex test for MM/DD/YYYY date format
     * @param {String} date
     */
    validateDateFormatRegx(date) {
        const dateReg = /^\d{2}\/\d{2}\/\d{4}$/;
        return dateReg.test(date);
    }

    /**
     * Hide or show dropdown values
     * @param {array} indexes dropdown indexes to take action on
     * @param {array} action hide or show
     */
    hideShowDropdownValues(indexes, action) {
        indexes.forEach((index) => {
            const val = this.attribute.valuesBeforeRules[index];
            const visibleIndex = this.attribute.values.findIndex((dropdownVal) => dropdownVal.value === val.value);
            if (action === 'hide' && visibleIndex >= 0) {
                this.attribute.values.splice(visibleIndex, 1); // hide
            } else if (action === 'show' && visibleIndex < 0) {
                this.attribute.values.splice(index, 0, val); // show
            }
        });
        this.attribute.values = [...this.attribute.values];
    }

    triggerAttrRuleErrorEvent() {
        pubsub.fire(this.rootChannel, 'attributeruleerrors', {
            hasAttrRuleError: this.hasAttrRuleErrors,
            attributeCode: this.attribute.code,
        });
    }

    updateDefaultDropdownValue() {
        if (
            this.isInputDropdown &&
            this.userValues &&
            this.attribute.values &&
            !this.attribute.values.some((attrValue) => attrValue.value === this.userValues)
        ) {
            this.handleValueChange({
                target: {
                    value: this.attribute.values[0].value,
                },
            });
        }
    }
}