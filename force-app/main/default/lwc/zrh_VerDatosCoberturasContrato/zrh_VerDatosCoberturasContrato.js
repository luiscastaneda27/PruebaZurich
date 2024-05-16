import { LightningElement, api,track, wire } from 'lwc';
import getContractGroupPlanById from '@salesforce/apex/ZRH_GetContractGroupPlanId.getContractGroupPlanById';
import getAttributeCategories from '@salesforce/apex/ZRH_GetContractGroupPlanId.getAttributeCategories';

export default class Zrh_VerDatosCoberturasContrato extends LightningElement {
    @api recordId;
    dataJsonCobertura;
    attributesInfo;
    errorAtts;
    dataAttributes;
    categoriesArray;
    attributesToDisplay = [];
    attributesTopicklist;
    
        @wire(getContractGroupPlanById, { contractGroupPlanId: '$recordId' })
        wiredContractGroupPlan({ error, data }) {
            if (data) {

                this.dataJsonCobertura = data.vlocity_ins_fsc__AttributeSelectedValues__c;
                this.dataJsonAtrributeProduct = JSON.parse(data.vlocity_ins_fsc__Product2Id__r.vlocity_ins__AttributeMetadata__c);

                getAttributeCategories()
                    .then((result) => {
                        
                        this.dataAttributes = JSON.parse(this.dataJsonCobertura);
                        this.attributesInfo = result;
                        let categoriesMap = new Map();
                        
                        for (let key in this.dataAttributes ) {
    
                            for (let keyAtrribute in this.attributesInfo ) { 
                                const keyAtt = this.attributesInfo[keyAtrribute];
                                
                                if (keyAtt.vlocity_ins__Code__c == key) {  
                                    
                                    const att = {
                                        label: keyAtt.Name,
                                        code: key,
                                        value: this.dataAttributes[key]
                                    };
                                    
                                    if (!categoriesMap.has(keyAtt.vlocity_ins__AttributeCategoryId__r.Name)) {
                                        
                                        categoriesMap.set(keyAtt.vlocity_ins__AttributeCategoryId__r.Name, [att]);

                                    } else {
                                        categoriesMap.get(keyAtt.vlocity_ins__AttributeCategoryId__r.Name).push(att);
                                    }
                                }
                            }
                        }

                        const resultArray = Array.from(categoriesMap, ([category, attributes]) => ({
                            category,
                            attributes
                        }));

                        this.attributesToDisplay = resultArray;

                     ////////empezar a recorrer los atributos de productos

                     for (let keyRecord in resultArray){

                             for (let keyRecord2 in resultArray[keyRecord].attributes ){

                                 const codeAttribute = resultArray[keyRecord].attributes[keyRecord2].code;
                                 const valueAttribute = resultArray[keyRecord].attributes[keyRecord2].value;
                                 const matchCategory = this.dataJsonAtrributeProduct.records.filter((obj) => resultArray[keyRecord].category == obj.Name )
                                 const matchAttribute = matchCategory[0].productAttributes.records.filter((obj) => codeAttribute == obj.code)
                                 if(matchAttribute[0].inputType == 'dropdown'){ 
                                    const matchValueAttribute = matchAttribute[0].values.filter((obj) => valueAttribute == obj.value ) 
                                    resultArray[keyRecord].attributes[keyRecord2].value = matchValueAttribute[0].label;

                                 }

                             }
   
                     }  

    
                    })
                    .catch((error) => {
                    this.errorAtts = error;
                    });

            } else if (error) {
                
            }
        }
    
}