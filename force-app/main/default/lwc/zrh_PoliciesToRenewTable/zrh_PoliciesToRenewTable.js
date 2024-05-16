import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin';

export default class zrh_PoliciesToRenewTable extends OmniscriptBaseMixin(LightningElement) {
    @api policiesToRenew;
    @api accounts;
    @api omniJsonData;
    data = [];
    error;
    selectedRows = [];

    connectedCallback() {
        if (this.omniJsonData['actualState']) {
            this.data = this.omniJsonData['actualState']
        } else {
            const processedArray = this.processData(this.policiesToRenew);
            this.data = processedArray; 
        }
    }

    processData(inputArray) {
        
        //ADD ACCOUNTS RETURNED BY THE POLICY REQUEST
        let newArray = inputArray.map(item => {
            return {
                accountName: item.Empresa,
                accountRut: item.RutContratante + '-' + item.DvContratante,
                folio: item.NumeroPoliza + '-' + item.DigitoPoliza,
                policyEndDate: item.FechaVigenciaFinal,
                period: +item.Periodo,
                planCode: item.Plan
            }
        });

        const accountNameMap = {};
        newArray.forEach(item => {
            accountNameMap[item.accountRut] = item.accountName;
        });

        const uniqueRutContratante = [...new Set(newArray.map(item => item.accountRut))];
        uniqueRutContratante.forEach(rut => {
            const accountName = accountNameMap[rut];
            newArray.push({
                accountName: accountName,
                accountRut: rut,
                isAccount: true,
                id: rut,
                rowClass: 'slds-hint-parent policy-holder-row'
            });
        });

        //ADD ACCOUNTS THAT ARE NOT RETURNED BY THE POLICY REQUEST
        const accs = [];
        this.accounts.forEach(item => {
            if (!newArray.find(acc => acc.accountRut === item.RutEmpresaContratante)) {
                accs.push({
                    accountName: item.NombreEmpresaContratante, 
                    accountRut: item.RutEmpresaContratante, 
                    isAccount: true, 
                    hasNoPoliciesToRenew: true, 
                    id: item.RutEmpresaContratante, 
                    rowClass: 'slds-hint-parent policy-holder-row'
                });
            }
        })

        newArray.push(...accs);

        // Add Id key to all nodes
        newArray = newArray.map(item => {
            return {
                ...item,
                id: item.id || (item.accountRut + '-' + item.folio),
                checked: false,
                rowClass: item.rowClass || 'slds-hint-parent policy-row'
            }
            
        });

        const accountPolicyMap = new Map();
        newArray.forEach(item => {
            if (!item.isAccount) {
                accountPolicyMap.set(item.accountRut, true);
            }
        });

        newArray.sort((a, b) => {
            const aHasPolicies = accountPolicyMap.get(a.accountRut) || a.hasNoPoliciesToRenew === false;
            const bHasPolicies = accountPolicyMap.get(b.accountRut) || b.hasNoPoliciesToRenew === false;
            const aIsEndNode = a.isAccount && (!aHasPolicies || a.hasNoPoliciesToRenew);
            const bIsEndNode = b.isAccount && (!bHasPolicies || b.hasNoPoliciesToRenew);

            // Move isAccount nodes with no associated non-isAccount nodes or hasNoPoliciesToRenew to the end
            if (!aIsEndNode && bIsEndNode) return -1;
            if (aIsEndNode && !bIsEndNode) return 1;

            // Group by accountRut
            if (a.accountRut < b.accountRut) return -1;
            if (a.accountRut > b.accountRut) return 1;

            // Sort by isAccount flag to ensure account nodes come first within their group
            if (a.isAccount && !b.isAccount) return -1;
            if (!a.isAccount && b.isAccount) return 1;

            return 0;
        });
        return newArray;
    }

    handleRowSelection(event) {

        const selected = event.target.checked;
        const rowId = event.currentTarget.dataset.id;
        const selectedRow = this.data.filter(row => row.id === rowId);
        const isAccount = selectedRow[0].isAccount;
        const accountRut = selectedRow[0].accountRut;
    
        if (isAccount) {
            this.data = this.data.map(row => {
                if (row.accountRut === accountRut) {
                    return {...row, checked: selected};
                }
                return row;
            });
            this.updateSelection();
        } else {
            this.data = this.data.map(row => {
                if (row.id === rowId) {
                    return {...row, checked: !row.checked};
                } else if (!selected && row.isAccount && row.accountRut === accountRut) {
                    return {...row, checked: selected};
                }
                return row;
            });
            this.updateSelection();
        }
    }    
    
    handleFullSelection(event) {
        const selected = event.target.checked;
        this.data = this.data.map(row => ({
            ...row,
            checked: selected
        }));
        this.updateSelection();
    }

    updateSelection() {

        // selected policies to omni json
        const selectedPolicies = this.data
            .filter(row => ((!row.isAccount || row.hasNoPoliciesToRenew) && row.checked))
            .map(({ planCode, folio, accountRut, period }) => ({ planCode, folio, accountRut, period }));


        // new quotes to omni json
        const quotesToCreate = Array.from(new Set(selectedPolicies.map(item => item['accountRut'])));
        const mergedQuoteToCreate = quotesToCreate
        .filter(rut => this.accounts.some(acc => acc.RutEmpresaContratante === rut))
        .map(rut => {
            const matchingAcc = this.accounts.find(acc => acc.RutEmpresaContratante === rut);
            const matchingNode = this.data.find(acc => acc.accountRut === rut);
            return { ...matchingAcc, Renovacion: !matchingNode.hasNoPoliciesToRenew};
        });

        // actual state to omni json
        const actualState = this.data;

        const postToOmni = {
            selectedPolicies: selectedPolicies.filter(row => row.planCode !== undefined),
            quotesToCreate: mergedQuoteToCreate,
            actualState: actualState
        }

        this.omniApplyCallResp(postToOmni);
    }

}