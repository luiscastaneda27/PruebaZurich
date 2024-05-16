import { LightningElement, api,wire} from 'lwc';
import getInsurancePolicyCoverageById from '@salesforce/apex/ZRH_GetInsurancePolicyCoverageId.getInsurancePolicyCoverageById';
import getAttributeCategories from '@salesforce/apex/ZRH_GetInsurancePolicyCoverageId.getAttributeCategories';
export default class Zrh_VerDatosCoberturaspolizaDeSeguros extends LightningElement {
    @api recordId;
    dataJsonCoberturaPolicyCov;
    attributesInfo;
    errorAtts;
    dataAttributes;
    categoriesArray;
    attributesPolicyToDisplay = [];
    attributesTopicklist;
    categoriesMap = new Map();
    
        @wire(getInsurancePolicyCoverageById, { InsurancePolicyCoverageId: '$recordId' })
        wiredInsurancePolicyCoverage({ error, data }) {
            if (data) {
                this.dataJsonCoberturaPolicyCov = data.vlocity_ins_fsc__AttributesSelectedValues__c;
                this.dataAttributesObject = JSON.parse(this.dataJsonCoberturaPolicyCov);

                getAttributeCategories()
                    .then((result) => {
                        this.attributesInfo = result;
                            for (let key in this.dataAttributesObject ) {
                         
                                for (let keyAtrribute in this.attributesInfo ) { 
                                const keyAtt = this.attributesInfo[keyAtrribute];
                                    if (keyAtt.vlocity_ins__Code__c == key) { 
                                        this.categoriesMap.set(keyAtt.Name,this.dataAttributesObject[key]);

                                            }

                                }
                        }
                            
                            const resultArray = Array.from(this.categoriesMap, ([category, attributes]) => ({
                                category,
                                attributes
                            }));
                              this.attributesPolicyToDisplay = resultArray;
                        })
                        .catch((error) => {
                        this.errorAtts = error;
                        });
           
        }
    }

}