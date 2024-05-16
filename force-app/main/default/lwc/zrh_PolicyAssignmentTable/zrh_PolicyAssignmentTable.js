import { LightningElement, api, wire } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin';
import getContractGroupPlans from '@salesforce/apex/ZRH_PolicyAssingmentTableController.getContractGroupPlans';
import assignUserToContractGroupPlans from '@salesforce/apex/ZRH_PolicyAssingmentTableController.assignUserToContractGroupPlans';

const columns = [
    { label: 'Contratante', fieldName: 'Contratante'},
    { label: 'Plan', fieldName: 'Plan'},
    { label: 'Número Póliza', fieldName: 'NumeroPoliza'},
    { label: 'Usuario Asignado', fieldName: 'UsuarioAsignado'},
];

export default class zrh_PolicyAssignmentTable extends OmniscriptBaseMixin(LightningElement) {
    @api holdingContractId;
    @api omniJsonData;
    columns = columns;
    data = [];
    error;
    selectedRows = [];

    connectedCallback() {
        getContractGroupPlans({holdingContractId: this.holdingContractId})
            .then((data) => {
                this.data = data;
                console.log('this.data: ' + JSON.stringify(this.data));
                
            })
            .catch((error) => {
                this.error = error;
            })
    }

    handleClick() {
        console.log('omniJsonData: ' + JSON.stringify(this.omniJsonData));
        let userId;
        if (this.omniJsonData && this.omniJsonData.AsignacionPolizas && this.omniJsonData.AsignacionPolizas["BuscarUsuarios-Block"]) {
            userId = this.omniJsonData.AsignacionPolizas["BuscarUsuarios-Block"].Id;
        } else {
            userId = null;
        }
        console.log('userId: ' + userId);

        assignUserToContractGroupPlans({userId: userId, listCGP: this.selectedRows})
            .then((result) => {
                getContractGroupPlans({holdingContractId: this.holdingContractId})
                    .then((data) => {
                        this.data = data;
                        console.log('data: ',JSON.stringify(data));
                        const unassignedPolicies = this.data.filter((record) => !record.hasOwnProperty('UsuarioAsignado'));
                        console.log('unassignedPolicies: ', JSON.stringify(unassignedPolicies));
                        console.log('unassignedPolicies.lenght: ', unassignedPolicies.length );
                        var postToOmni = {
                            allPoliciesAssigned: unassignedPolicies.length == 0
                        }
                        console.log('postToOmni: ' + JSON.stringify(postToOmni));
                        this.omniApplyCallResp(postToOmni);
                        
                    })
                    .catch((error) => {
                        this.error = error;
                    })
            })
            .catch((error) => {
            })
    }
    
    onRowSelection(event) {
         this.selectedRows = event.detail.selectedRows;
    }

    get noSelectedRows() {
        return this.selectedRows.length < 1;
    }
}