/*********************************************************************************
Project      : Zurich 
Created By   : Deloitte
Created Date : 11/05/2023
Description  : Javascript - Table to display values from SObject
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                         ACRONYM
Mateo Long                        ML
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0       ML	     20/04/2023		  initial version
********************************************************************************/
import { LightningElement, api, wire } from 'lwc';
// import queryRecords from '@salesforce/apex/ZRH_SObjectQueryController.queryRecords';
import { commonUtils, dataFormatter, omniscriptUtils } from 'vlocity_ins/insUtility';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin'
const PAGE_SIZE = 200; // Number of records to fetch per page

export default class Zrh_TableWithSelectionQueryObject extends OmniscriptBaseMixin(LightningElement) {
    @api sObjectName;
    @api omniJsonData;
    @api outputNode;
    data = [];
    filteredData = [];
    filterValue = '';
    selectedIds = [];
    isLoading = true;
    
    connectedCallback() {
        console.log('Convenios omniJsonData: ' + JSON.stringify(this.omniJsonData[this.outputNode]));
        this.init();
    }

    handleFilterChange(event) {
        this.filterValue = event.target.value;
      
        if (this.filterValue) {
          this.filteredData = this.data.filter(record => {
            const codeString = record.ZRH_Codigo__c.toString();
            const filterString = this.filterValue.toString();
            return (
              codeString.includes(filterString) ||
              record.Name.toLowerCase().includes(this.filterValue.toLowerCase())
            );
          });
        } else {
          this.filteredData = this.data;
        }
    }      

    handleCheckboxChange(event) {
        const id = event.target.dataset.id;
        const name = event.target.dataset.name;
        const isChecked = event.target.checked;
        let rec = {};

        this.data = this.data.map(row => {
            if (row.Id === id) {
                return { ...row, selected: isChecked };
            }
            return row;
        });

        console.log('unsorted: ' + JSON.stringify(this.data));
        //sort
        const sortedByChecked = this.data.sort(this.booleanSort);
        this.filteredData = sortedByChecked;
        console.log('sortedByChecked: ' + JSON.stringify(this.filteredData));
        //filter, if any filter
        if (this.filterValue) {
            this.filteredData = this.data.filter(record => {
                const codeString = record.ZRH_Codigo__c.toString();
                const filterString = this.filterValue.toString();
                return (
                  codeString.includes(filterString) ||
                  record.Name.toLowerCase().includes(this.filterValue.toLowerCase())
                );
              });
        } else {
            this.filteredData = this.data;
        }
        
        if (isChecked) {
            rec = {Name: name, Id: id};
            this.selectedIds.push(rec);

        } else {
            const index = this.selectedIds.findIndex(rec => rec.Id === id);
            if (index > -1) {
                this.selectedIds.splice(index, 1);
            }
        }

        this.omniApplyCallResp({[this.outputNode]:this.selectedIds});
    }

    init(){
        this.initAction = {
            className: "ZRH_TableWithSelectionController",
            methodName: "queryRecordsForTable",
            inputMap: {},
            optionsMap : {},
            vlocityAsync : false
        }
        
        this.initAction.inputMap.sObjectName = this.sObjectName;
        const previousStateArray = this.omniJsonData[this.outputNode];
        const previousStateIds = {};
        if (previousStateArray) {
            for (const element of previousStateArray) {
                previousStateIds[element.Id] = true;
            }
        }
        omniscriptUtils.omniGenericInvoke(this, this.initAction)
        .then(response => {
            const allData = JSON.parse(response);
            this.data = JSON.parse(allData.listRecords);

            if (previousStateArray) {
                this.data = this.data.map((element) => {
                    if (previousStateIds[element.Id]) {
                        this.selectedIds.push({Name: element.Name, Id: element.Id});
                        return {...element, selected: true}
                    } else {
                        return {...element}
                    }
                });
                
            }

            this.data.sort(this.booleanSort);
            this.filteredData = this.data;
            this.filteredData.sort(this.booleanSort);
            this.isLoading = false;
        })
        .catch(error => {
            console.log('Error: '+JSON.stringify(error));
            this.isLoadinf = false;
        })
    }

    booleanSort(a, b) {
        const aSelected = 'selected' in a ? a.selected : false;
        const bSelected = 'selected' in b ? b.selected : false;
    
        if (aSelected && !bSelected) {
        return -1; // a is checked, b is unchecked => a comes before b
        } else if (!aSelected && bSelected) {
        return 1; // a is unchecked, b is checked => a comes after b
        } else {
        // Both a and b are either checked or unchecked
        if (aSelected && bSelected) {
            // If both are checked, first compare by Name, then by Codigo
            const nameComparison = a.Name.localeCompare(b.Name);
            if (nameComparison !== 0) {
            return nameComparison; // Compare by Name
            } else {
            return a.Codigo - b.Codigo; // Compare by Codigo
            }
        } else {
            // If both are unchecked, first compare by Name, then by Codigo
            const nameComparison = a.Name.localeCompare(b.Name);
            if (nameComparison !== 0) {
            return nameComparison; // Compare by Name
            } else {
            return a.Codigo - b.Codigo; // Compare by Codigo
            }
        }
        }
    }
       
}