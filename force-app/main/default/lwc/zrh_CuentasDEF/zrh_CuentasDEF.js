/*********************************************************************************
Project      : Zurich 
Created By   : Deloitte
Created Date : 23/08/2023
Description  : Javascript - Creation of DEF accounts
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                         ACRONYM
Mateo Long                        ML
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0       ML	     20/09/2023		  initial version
********************************************************************************/
import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin'
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class zrh_CuentasDEF extends OmniscriptBaseMixin(LightningElement) {
    @api jsonData = [];
    @api accountsDEF;
    @api omniJsonData;
    @api recordId;
    @api fieldsForDEF;
    @api availablePlansList = [];
    @api availablePlansLabel;
    @api planOptions;
    @api maxDEF;
    @api actualDEF = 0;
    @api objectName;
    
    jsonAccountsDEF;

    _actionUtil;
    showSpinner = false;


    /**
    *  @Description: Initializes the component to be able to display records
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    connectedCallback() {
        this._actionUtil = new OmniscriptActionCommonUtil();
        if(this.recordId){
            this.initRecord();
        }else{
            this.init();
        }
       
    }

    /**
    *  @Description: Retrives data for read only
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    initRecord() {
        if (this.objectName == 'Quote') {
            this.getQuoteDEFRecords(this.recordId);
        } else if (this.objectName == 'Contract') {
            this.getContractDEFRecords(this.recordId);
        }
    }

    /**
    *  @Description: Retrives data to be modified
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */    
    init() {
        if (Array.isArray(this.omniJsonData.CuentasDEF)) {
            this.jsonData = [...this.omniJsonData.CuentasDEF];
        } else {
            this.jsonData.push(this.omniJsonData.CuentasDEF);
        }
        this.fieldsForDEF = this.omniJsonData.CamposDEF;
        if (this.jsonData && this.jsonData[0] != null) {
            this.jsonAccountsDEF = this.jsonData;
            this.actualDEF = this.jsonAccountsDEF.length;
            this.accountsDEF = this.jsonData.map((account) => {
            
                return {
                    ...account,
                    isVisible: false,
                    nameDEF: 'DEF ' + account.Planes.join(' - '),
                    CamposDEF: account.CamposDEF.map((campo) => ({
                        ...campo,
                        isVisibleValor: campo.Aplica == 'Si',
                    })),
                    plansSelected: !(account.Planes.length > 0),
                    unsavedChanges: false,
                };
            });
            this.accountsDEF.sort(this.compareDatesDescending);
        } else {
            this.accountsDEF = [];
            this.jsonAccountsDEF = [];
        }
        const plans = [...new Set(this.omniJsonData.PlanesCotizacion)];
        plans.sort((a,b) => a - b);
        this.planOptions = plans.map(plan => ({label: String(plan), value: String(plan)}));
        this.availablePlansList = this.getAvailablePlansList();
        this.availablePlansLabel = this.getAvailablePlans();
        this.maxDEF = this.planOptions.length;
        
    }

    /**
    *  @Description: Handles selection of DEF
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    toggleDEF(event) {
        const accountId = event.target.dataset.accountId;
        const updatedAccountsDEF = [...this.accountsDEF]; // Create a shallow copy
        const accountToToggle = updatedAccountsDEF.find(account => account.Id == accountId);
        const accountToClose = updatedAccountsDEF.filter(account => account.Id != accountId);
        accountToClose.forEach(account => account.isVisible = false);
        if (accountToToggle) {
            accountToToggle.isVisible = !accountToToggle.isVisible;
            this.accountsDEF = updatedAccountsDEF; // Set the updated array to trigger reactivity
        }
    }

    /**
    *  @Description: Adds new DEF
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    addNewDEF() {
        const updatedAccountsDEF = JSON.parse(JSON.stringify(this.accountsDEF));
        updatedAccountsDEF.forEach(account => account.isVisible = false);
        const newDEF = {};
        newDEF.CamposDEF = this.fieldsForDEF;
        newDEF.Planes = [];
        newDEF.nameDEF = 'DEF ';
        newDEF.Id = this.getMaxAccountDEFId(updatedAccountsDEF) + 1;
        newDEF.isVisible = true;
        newDEF.plansSelected = !(newDEF.Planes.length > 0);
        newDEF.unsavedChanges = true;
        newDEF.createdDate = this.getCurrentDate();
        newDEF.lastModifiedDate = newDEF.createdDate;
        updatedAccountsDEF.push(newDEF);
        this.accountsDEF = updatedAccountsDEF;
        this.actualDEF = this.actualDEF + 1;
    }

    /**
    *  @Description: Deletes DEF record
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    deleteDEF(event) {
        const accountId = event.target.dataset.accountId;
        const accountsDEF = [...this.accountsDEF]; // Create a shallow copy
        const jsonAccountsDEF = [...this.jsonAccountsDEF];
        
        const jsonAccountsToMantain = jsonAccountsDEF.filter(account => account.Id != accountId);
        this.jsonAccountsDEF = jsonAccountsToMantain;

        if (this.jsonAccountsDEF.length > 0) {
            this.updateDEFRecords(this.jsonAccountsDEF);        
        } else {
            this.updateDEFRecords('$Vlocity.NULL');        
        }
        

        const accountsToMantain = accountsDEF.filter(account => account.Id != accountId);
        this.accountsDEF = accountsToMantain;
        
        this.availablePlansList = this.getAvailablePlansList();
        this.availablePlansLabel = this.getAvailablePlans();
        this.actualDEF = this.actualDEF - 1;

    }
    
    /**
    *  @Description: Saves DEF records
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    saveDEF(event) {

        const accountId = event.target.dataset.accountId;
        const updatedAccountsDEF = [...this.accountsDEF]; // Create a shallow copy
        const accountToSave = updatedAccountsDEF.find(account => account.Id == accountId);

        const aplicaButNoValue = accountToSave.CamposDEF.some(
            (campo) => campo.Aplica == 'Si' && (campo.Valor == null || campo.Valor == '')
        );

        if (aplicaButNoValue) {
            this.pushMessage('Advertencia', 'warning', 'Hay campos que aplican y no tienen valor ingresado');
            return;  
        } 

        const newDEF = {};
        newDEF.CamposDEF = accountToSave.CamposDEF;
        newDEF.Planes = accountToSave.Planes;
        newDEF.Id = accountToSave.Id;
        newDEF.createdDate = accountToSave.createdDate;
        newDEF.lastModifiedDate = this.getCurrentDate();

        const jsonAccountsDEF = [...this.jsonAccountsDEF];
        const index = jsonAccountsDEF.findIndex(account => account.Id == accountId);
        if (index !== -1) {
            jsonAccountsDEF[index] = newDEF;
        } else {
            jsonAccountsDEF.push(newDEF);
        }
        this.jsonAccountsDEF = jsonAccountsDEF;

        this.updateDEFRecords(jsonAccountsDEF);

        accountToSave.unsavedChanges = false;
        accountToSave.lastModifiedDate = this.getCurrentDate();
        this.accountsDEF = updatedAccountsDEF;
        this.accountsDEF.sort(this.compareDatesDescending);
    }

    /**
    *  @Description: Handles changes in plan selection of DEF
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    handlePlanChange(event) {

        const accountId = event.target.dataset.accountId;
        const otherAccountsDEF = [...this.accountsDEF];
        const accountsToCompare = otherAccountsDEF.filter(account => account.Id != accountId);
        const usedPlanValues = [];
        for (const account of accountsToCompare) {
            for (const plan of account.Planes) {
                if (!usedPlanValues.includes(plan)) {
                    usedPlanValues.push(plan);
                }
            }
        }
        const values = event.target.value;
        const availablePlansToPick = values.filter(plan => !usedPlanValues.includes(plan));

        const updatedAccountsDEF = [...this.accountsDEF];
        const accountToUpdate = updatedAccountsDEF.find(account => account.Id == accountId);

        if (accountToUpdate) {
            accountToUpdate.Planes = availablePlansToPick;
            accountToUpdate.plansSelected = !(accountToUpdate.Planes.length);
            accountToUpdate.unsavedChanges = true;
            accountToUpdate.nameDEF = 'DEF ' + accountToUpdate.Planes.join(' - ');
            this.accountsDEF = updatedAccountsDEF;
        }

        this.availablePlansList = this.getAvailablePlansList();
        this.availablePlansLabel = this.getAvailablePlans();
    }

    /**
    *  @Description: Handles change in Aplica picklist field
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    handleAplicaChange(event) {
        
        const campoAplica = event.target.value;
        const campoName = event.target.name;
        const accountId = event.target.dataset.accountId;

        const updatedAccountsDEF = JSON.parse(JSON.stringify(this.accountsDEF));
        const accountIndex = updatedAccountsDEF.findIndex(account => account.Id == accountId);
        if (accountIndex !== -1) {
            const campoIndex = updatedAccountsDEF[accountIndex].CamposDEF.findIndex(campo => campo.Campo == campoName);
            if (campoIndex !== -1 && campoAplica == 'No') {
                updatedAccountsDEF[accountIndex].CamposDEF[campoIndex].Valor = undefined;
                updatedAccountsDEF[accountIndex].CamposDEF[campoIndex].Aplica = 'No';
                updatedAccountsDEF[accountIndex].CamposDEF[campoIndex].isVisibleValor = false;
                updatedAccountsDEF[accountIndex].unsavedChanges = true;
                
            } else {
                updatedAccountsDEF[accountIndex].CamposDEF[campoIndex].Aplica = 'Si';
                updatedAccountsDEF[accountIndex].CamposDEF[campoIndex].isVisibleValor = true;
                updatedAccountsDEF[accountIndex].unsavedChanges = true;

            }
        }
        this.accountsDEF = updatedAccountsDEF;
    }

    /**
    *  @Description: Handles change in value inputs
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    handleValorChange(event) {
        
        const campoValor = event.target.value;
        const campoName = event.target.name;
        const accountId = event.target.dataset.accountId;

        const updatedAccountsDEF = JSON.parse(JSON.stringify(this.accountsDEF));
        const accountIndex = updatedAccountsDEF.findIndex(account => account.Id == accountId);
        if (accountIndex !== -1) {
            const campoIndex = updatedAccountsDEF[accountIndex].CamposDEF.findIndex(campo => campo.Campo == campoName);
            if (campoIndex !== -1) {
                setTimeout(() => {
                    updatedAccountsDEF[accountIndex].CamposDEF[campoIndex].Valor = campoValor;
                    updatedAccountsDEF[accountIndex].unsavedChanges = true;
                    this.accountsDEF = updatedAccountsDEF;
                }, 0);
            }
        }
        this.accountsDEF = updatedAccountsDEF;
    }

    /**
    *  @Description: Retrives DEF records from quote
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    getQuoteDEFRecords(recordId) {
        this.showSpinner = true;
        const options = {};
        const params = {
            input: { IdCotizacion: recordId },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhExtraerCuentasDEF_SegurosColectivos",
            options: JSON.stringify(options)
        }
        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            if(response.error == false && response.result.IPResult.CuentasDEF != null){

                if (Array.isArray(response.result.IPResult.CuentasDEF)) {
                    this.jsonData = [...response.result.IPResult.CuentasDEF];
                } else {
                    this.jsonData.push(response.result.IPResult.CuentasDEF);
                }

                this.accountsDEF = this.jsonData.map((account) => {
                
                    return {
                        ...account,
                        isVisible: false,
                        nameDEF: 'DEF ' + account.Planes.join(' - '),
                        CamposDEF: account.CamposDEF.map((campo) => ({
                            ...campo,
                            isVisibleValor: campo.Aplica == 'Si',
                        })),
                        plansSelected: !(account.Planes.length > 0),
                        unsavedChanges: false,
                    };
                });
                this.accountsDEF.sort(this.compareDatesDescending);

            } else {
                this.accountsDEF = [];
            }
            this.showSpinner = false;
        }).catch((error) => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
        });
    }
    /**
    *  @Description: Retrives DEF records from contract
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    getContractDEFRecords(recordId) {
        this.showSpinner = true;
        const options = {};
        const params = {
            input: { IdContrato: recordId },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhExtraerCuentasDEFContrato_SegurosColectivos",
            options: JSON.stringify(options)
        }
        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            if(response.error == false && response.result.IPResult.CuentasDEF != null){

                if (Array.isArray(response.result.IPResult.CuentasDEF)) {
                    this.jsonData = [...response.result.IPResult.CuentasDEF];
                } else {
                    this.jsonData.push(response.result.IPResult.CuentasDEF);
                }

                this.accountsDEF = this.jsonData.map((account) => {
                
                    return {
                        ...account,
                        isVisible: false,
                        nameDEF: 'DEF ' + account.Planes.join(' - '),
                        CamposDEF: account.CamposDEF.map((campo) => ({
                            ...campo,
                            isVisibleValor: campo.Aplica == 'Si',
                        })),
                        plansSelected: !(account.Planes.length > 0),
                        unsavedChanges: false,
                    };
                });
                this.accountsDEF.sort(this.compareDatesDescending);

            } else {
                this.accountsDEF = [];
            }
            this.showSpinner = false;
        }).catch((error) => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
        });
    }
    
    /**
    *  @Description: Updates DEF records
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    updateDEFRecords(accountsDEFToUpdate) {
        this.showSpinner = true;
        const options = {};
        const params = {
            input: { Id: this.omniJsonData.ContextId, CuentasDEF: accountsDEFToUpdate },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhCrearCuentasDEF_SegurosColectivos",
            options: JSON.stringify(options)
        }
        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            if(response.error == false){
                this.pushMessage('Exito', 'success', 'Datos guardados exitosamente.');

            }else {
                this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
            }
            this.showSpinner = false;
        }).catch((error) => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
        });
    }

    /**
    *  @Description: Returns max Id 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    getMaxAccountDEFId(accountsDEFArray) {
        let maxId = 0;
        for (const accountDEF of accountsDEFArray) {
            if (accountDEF.Id > maxId) {
                maxId = accountDEF.Id;
            }
        }
        return maxId;
    }
    
    /**
    *  @Description: Returns available plans in a string 
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    getAvailablePlans() {
        const usedPlanValuesDEF = [];
        for (const account of this.accountsDEF) {
            for (const plan of account.Planes) {
                if (!usedPlanValuesDEF.includes(plan)) {
                    usedPlanValuesDEF.push(plan);
                }
            }
        }
        const avPlans = this.planOptions.filter(plan => !usedPlanValuesDEF.includes(plan.value));
        const avPlansValues = avPlans.map(plan => plan.value);
        const avPlansLabel = avPlansValues.join(' - ');
        return avPlansLabel;
    }

    /**
    *  @Description: Returns available plans to select
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    getAvailablePlansList() {
        const usedPlanValuesDEF = [];
        for (const account of this.accountsDEF) {
            for (const plan of account.Planes) {
                if (!usedPlanValuesDEF.includes(plan)) {
                    usedPlanValuesDEF.push(plan);
                }
            }
        }
        const avPlans = this.planOptions.filter(plan => !usedPlanValuesDEF.includes(plan.value));
        return avPlans;
    }

    /**
    *  @Description: Returns current date in dd/mm/yyyy format
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    getCurrentDate() {
        const currentDate = new Date();
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth() + 1;
        const day = currentDate.getDate();
        
        const date = `${day}/${month}/${year}`;

        return date;
    }

    /**
    *  @Description: Compares dates in descending order
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    compareDatesDescending(a, b) {
        const dateA = new Date(
          a.createdDate.split("/").reverse().join("-") // Convert to "yyyy-mm-dd" format
        );
        const dateB = new Date(
          b.createdDate.split("/").reverse().join("-") // Convert to "yyyy-mm-dd" format
        );
      
        // Sort in descending order
        return dateB - dateA;
    }

    /**
    *  @Description: Display message on screen
    *  @Autor:       ML, Deloitte, mlongg@deloitte.com
    *  @Date:        20/09/2023
    */
    pushMessage(title,variant,msj){
        const message = new ShowToastEvent({
                title: title,
                variant: variant,
                message: msj
            });
            this.dispatchEvent(message);
    }

    get applicableOptions() {
        return [
            { label: 'Si', value: 'Si' },
            { label: 'No', value: 'No' },
        ];
    }

    get min() {
        return 1;
    }

    get disableNewDEF() {
        //disable if no plans available or more tables than plans
        return !(this.availablePlansList.length > 0) || !(this.actualDEF < this.maxDEF);
    }

    get noPlansAvailable() {
        return !(this.availablePlansList.length) > 0;
    }

    get isReadOnly() {
        return !!(this.recordId);
    }
}