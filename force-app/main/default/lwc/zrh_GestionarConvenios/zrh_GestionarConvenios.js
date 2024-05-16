/*********************************************************************************
Project      : Zurich 
Created By   : Deloitte
Created Date : 23/08/2023
Description  : Javascript - Table to display values from JSON Convenios
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                         ACRONYM
Mateo Long                        ML
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0       LC	     04/09/2023		  initial version
********************************************************************************/

import { LightningElement, api, track} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin'
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NumeroConveniosPlan from "@salesforce/label/c.ZRH_NumeroConveniosPorPlan";

export default class Zrh_GestionarConvenios extends OmniscriptBaseMixin(LightningElement) {
    @track ConveniosList = [];
    @track coveragesListAll = [];
    @track preferredProvidersListAll = [];
    @track coveragesListTable = [];
    @track preferredProvidersListTable = [];
    @track data = {};
    @api omniJsonData;
    @api recordId;
    @api objectName;

    disabledNewConvenio = true;
    numberOfCharacters = 131072;
    showSpinner = false;
    _actionUtil;

    @api outputNode;
    filteredData = [];
    filterValue = '';
    selectedIds = [];
    

    /**
    *  @Description: Initializes the component to be able to display records
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    connectedCallback() {
        console.log('recordId '+ this.recordId);
        this._actionUtil = new OmniscriptActionCommonUtil();
        if(this.recordId){
            if (this.objectName == "QuoteLineItem") {
                this.initRecord();
            } else if (this.objectName == "ContractGroupPlan") {
                this.initRecordContract();

            }
        }else{
            this.init();
        }
       
    }

    initRecord(){
        console.log('recordId2 '+ this.recordId);
        this.showSpinner = true;
        const options = {};
        const params = {
            input: { IdProductoCotizacion: this.recordId },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhBuscarConvenios_SegurosColectivos",
            options: JSON.stringify(options)
        }
        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            console.log('Respuesta: '+ response.error);
            console.log('Respuesta: '+ JSON.stringify(response.result.IPResult.ListaConvenios));
            if(response.error == false && response.result.IPResult.Plan.AtributosConvenios != null){
                if(response.result.IPResult.ListaConvenios.length == undefined){
                    this.ConveniosList.push(response.result.IPResult.ListaConvenios);
                }else{
                    this.ConveniosList = response.result.IPResult.ListaConvenios;
                }
            }
            this.showSpinner = false;
        }).catch((error) => {
            console.log('error: ');
            console.error(error, "ERROR");
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
        });
    }

    initRecordContract(){
        console.log('recordId2 '+ this.recordId);
        this.showSpinner = true;
        const options = {};
        const params = {
            input: { IdProductoContrato: this.recordId },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhBuscarConvenios_SegurosColectivos",
            options: JSON.stringify(options)
        }
        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            console.log('Respuesta: '+ response.error);
            console.log('Respuesta: '+ JSON.stringify(response.result.IPResult.ListaConvenios));
            if(response.error == false && response.result.IPResult.Plan.AtributosConvenios != null){
                if(response.result.IPResult.ListaConvenios.length == undefined){
                    this.ConveniosList.push(response.result.IPResult.ListaConvenios);
                }else{
                    this.ConveniosList = response.result.IPResult.ListaConvenios;
                }
            }
            this.showSpinner = false;
        }).catch((error) => {
            console.log('error: ');
            console.error(error, "ERROR");
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
        });
    }

    /**
    *  @Description: Consult all the existing coverages and preferred providers of the Product
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    init(){
        console.log('omniJsonData: ' + JSON.stringify(this.omniJsonData));
        this.coveragesListAll = this.omniJsonData.ListaCoberturas;
        this.preferredProvidersListAll = this.omniJsonData.ListaPrestadores;
        if(this.omniJsonData.Plan.AtributosConvenios != null){
            console.log('ENTRO');
            if(this.omniJsonData.ListaConvenios.length == undefined){
                this.ConveniosList.push(this.omniJsonData.ListaConvenios);
            }else{
                this.ConveniosList = this.omniJsonData.ListaConvenios;
            }
            console.log('SALIO');
        }
        this.disabledNewConvenio = this.ConveniosList.length >= NumeroConveniosPlan;
    }

    /**
    *  @Description: Event that is executed when a Convenios is clicked
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    onclickShow(event){
        this.showSpinner = true;
        const name = event.target.name;
        this.preferredProvidersListTable = [];
        this.coveragesListTable = [];
        this.data = {};
        for(let i = 0; i < this.ConveniosList.length; i++){
            if(this.ConveniosList[i].Id == name){

                this.data = {};
                this.data.showConvenios = true;
                this.data.isNew = false;
                this.data.disabledLowerUse = this.ConveniosList[i].ConvPref != "Si";
                this.data.Conv470ClinicaDVHospCH = this.ConveniosList[i].Conv470ClinicaDVHospCH;
                this.data.ConvPref = this.ConveniosList[i].ConvPref;
                this.data.Id = this.ConveniosList[i].Id;
                this.data.ListaPrestadores = [];
                this.data.ListaCoberturas = [];

                for(let j=0; j < this.ConveniosList[i].ListaPrestadores.length; j++){
                    this.data.ListaPrestadores.push({Id: this.ConveniosList[i].ListaPrestadores[j].Id, Nombre: this.ConveniosList[i].ListaPrestadores[j].Nombre});
                }
                for(let j=0; j < this.ConveniosList[i].ListaCoberturas.length; j++){
                    this.data.ListaCoberturas.push({Id: this.ConveniosList[i].ListaCoberturas[j].Id, Nombre: this.ConveniosList[i].ListaCoberturas[j].Nombre});
                }

                this.coveragesListTable = this.orderListUnfiltered(this.coveragesListAll, this.data.ListaCoberturas);
                this.preferredProvidersListTable = this.orderListUnfiltered(this.preferredProvidersListAll, this.data.ListaPrestadores);
            }
        }
        this.showSpinner = false;
    }

    /**
    *  @Description: Event that is executed when a Convenios is clicked Record
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
     onclickShowRecord(event){
        this.showSpinner = true;
        const name = event.target.name;
        this.data = {};
        for(let i = 0; i < this.ConveniosList.length; i++){
            if(this.ConveniosList[i].Id == name){

                this.data = {};
                this.data.Conv470ClinicaDVHospCH = this.ConveniosList[i].Conv470ClinicaDVHospCH;
                this.data.ConvPref = this.ConveniosList[i].ConvPref;
                this.data.ListaPrestadores = [];
                this.data.ListaCoberturas = [];

                for(let j=0; j < this.ConveniosList[i].ListaPrestadores.length; j++){
                    this.data.ListaPrestadores.push({Id: this.ConveniosList[i].ListaPrestadores[j].Id, Nombre: this.ConveniosList[i].ListaPrestadores[j].Nombre});
                }
                for(let j=0; j < this.ConveniosList[i].ListaCoberturas.length; j++){
                    this.data.ListaCoberturas.push({Id: this.ConveniosList[i].ListaCoberturas[j].Id, Nombre: this.ConveniosList[i].ListaCoberturas[j].Nombre});
                }
            }
        }
        this.showSpinner = false;
    }

    /**
    *  @Description: Event that is executed when a Convenios is selected
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    handleChange(event){
        const name = event.target.name;
        const value = event.target.value;
        if(name == "convenio-preferente"){
            this.data.ConvPref = value;
            if(value == "Si"){
                this.data.disabledLowerUse = false;
            }else{
                this.data.disabledLowerUse = true;
            }
        }else if(name == "conv470-clinicaDV-hospCH"){
            this.data.Conv470ClinicaDVHospCH = value;
        }
    }

    /**
    *  @Description: Event that is executed when a Convenios is filtered
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    onchangeFilter(event){
        const name = event.target.name;
        const value = event.target.value.trim() != "" ? event.target.value.trim() : null;
        if(name == "filterPreferred"){
            this.data.filterPreferred = value;
            if(this.data.filterPreferred != null && this.data.filterPreferred.length > 2){
                this.preferredProvidersListTable = this.orderListFilter(this.preferredProvidersListAll, this.data.ListaPrestadores, value);
            }else if (this.data.filterPreferred == null){
                this.preferredProvidersListTable = this.orderListUnfiltered(this.preferredProvidersListAll, this.data.ListaPrestadores);
            }
        }else if(name == "filterCoverage"){
            this.data.filterCoverage = value;
            if(this.data.filterCoverage != null && this.data.filterCoverage.length > 2){
                this.coveragesListTable = this.orderListFilter(this.coveragesListAll, this.data.ListaCoberturas, value);
            }else if (this.data.filterCoverage == null){
                this.coveragesListTable = this.orderListUnfiltered(this.coveragesListAll, this.data.ListaCoberturas);
            }
        }
    }

    /**
    *  @Description: Event that is executed when the new Convenios button is clicked
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    onclickNewConvenios(){
        let index = 0;
        for(let i = 0; i<this.ConveniosList.length; i++){
            index = this.ConveniosList[i].Id > index ? this.ConveniosList[i].Id  : index;
        }
        this.data = {};
        this.data.filterCoverage = "";
        this.data.filterPreferred = "";
        this.data.showConvenios = true;
        this.data.isNew = true;
        this.data.disabledLowerUse = true;
        this.data.Conv470ClinicaDVHospCH = null;
        this.data.ConvPref = null;
        this.data.Id = index + 1;
        this.data.ListaPrestadores = [];
        this.data.ListaCoberturas = [];
        this.coveragesListTable = this.coveragesListAll;
        this.preferredProvidersListTable = this.preferredProvidersListAll;
    }

    /**
    *  @Description: Event that is executed when a coverage or provider is selected
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    handleCheckboxChange(event){
        const id = event.target.dataset.id;
        const name = event.target.dataset.name;
        const isChecked = event.target.checked;
        var listAll = name == "coverage" ? this.coveragesListTable : this.preferredProvidersListTable;
        if(name == "coverage"){
            if(isChecked){
                this.data.ListaCoberturas.push(this.getObjectForId(this.coveragesListAll, id));
            }else{
                this.data.ListaCoberturas = this.data.ListaCoberturas.filter(record => record.Id != id);
            }
            this.coveragesListTable =[];
            this.coveragesListTable = this.orderListUnfilteredTable(listAll, this.data.ListaCoberturas);
        }else if(name == "preferredProviders"){
            if(isChecked){
                this.data.ListaPrestadores.push(this.getObjectForId(this.preferredProvidersListAll, id));
            }else{
                this.data.ListaPrestadores = this.data.ListaPrestadores.filter(record => record.Id != id);
            }
            this.preferredProvidersListTable =[];
            this.preferredProvidersListTable = this.orderListUnfilteredTable(listAll, this.data.ListaPrestadores);
        }
    }

    /**
    *  @Description: Returns an object from the list by Id
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    getObjectForId(listAll, id){
        var object = {};
        for(let i=0; i < listAll.length; i++){
            if(listAll[i].Id == id){
                object.Nombre = listAll[i].Nombre;
                object.Id = listAll[i].Id;
            }
        }
        return object;
    }

    /**
    *  @Description: Store Convenios Information
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    onclickSaveConvenios(){
        var object = {};
        if(this.data.ConvPref == null || this.data.Conv470ClinicaDVHospCH == null){
            this.pushMessage('Advertencia', 'warning', 'Debe seleccionar un convenio.');
            return;
        }else if(this.data.ConvPref == 'Si' && (this.data.ListaCoberturas.length == 0 || this.data.ListaPrestadores.length == 0)){
            this.pushMessage('Advertencia', 'warning', 'Debe completar todos los campos.');
            return;
        }
        object.ConvPref = this.data.ConvPref;
        object.Id = this.data.Id;
        object.Conv470ClinicaDVHospCH = this.data.Conv470ClinicaDVHospCH;
        object.ListaCoberturas = this.data.ConvPref == 'Si' ? this.data.ListaCoberturas : [];
        object.ListaPrestadores = this.data.ConvPref == 'Si' ? this.data.ListaPrestadores : [];
        this.ConveniosList = this.ConveniosList.filter(record => record.Id != this.data.Id);
        this.ConveniosList.push(object);
        if(JSON.stringify(this.ConveniosList).length > this.numberOfCharacters){
            this.pushMessage('Advertencia', 'warning', 'Los Convenios exceden el número de caracteres permitidos, debe desmarcar coberturas o prestadores preferente.');
            return;
        }
        this.callIntegrationProcedure();
    }

    /**
    *  @Description: Delete Convenios Information
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    onclickDeleteConvenios(){
        this.ConveniosList = this.ConveniosList.filter(record => record.Id != this.data.Id);
        this.callIntegrationProcedure();
    }

    /**
    *  @Description: call Integration ProcedureService zrhGuardarInformacionConvenios
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    callIntegrationProcedure(){
        this.showSpinner = true;
        const ListaActualizar = Object.values(this.ConveniosList);
        const options = {};
        const params = {
            input: { IdProductoCotizacion: this.omniJsonData.ContextId, ListaActualizar: ListaActualizar },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhGuardarInformacionConvenios_SegurosColectivos",
            options: JSON.stringify(options)
        }
        this.disabledNewConvenio = this.ConveniosList.length >= NumeroConveniosPlan;
        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            console.log(JSON.stringify(response));
            if(response.error == false){
                this.data = {};
                this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente.');
            }else{
                this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
            }
            this.showSpinner = false;
        }).catch((error) => {
            console.error(error, "ERROR");
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
        });
        
    }

    /**
    *  @Description: Sort selected objects
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    orderListFilter(listAll, listSelected, filter){
        var listRecords = listAll.filter(record => record.Nombre.toLowerCase().includes(filter.toLowerCase()));
        var listReturn = [];
        for(let i = 0; i < listRecords.length; i++){
            if(listSelected.filter(record => record.Id == listRecords[i].Id).length > 0){
                var object = {};
                object.Nombre = listRecords[i].Nombre;
                object.Id = listRecords[i].Id;
                object.selected = true;
                listReturn.push(object);
            }
        }
        for(let i = 0; i < listRecords.length; i++){
            if(listSelected.filter(record => record.Id == listRecords[i].Id).length == 0){
                var object = {};
                object.Nombre = listRecords[i].Nombre;
                object.Id = listRecords[i].Id;
                object.selected = false;
                listReturn.push(object);
            }
        }
        return listReturn;
    }
    
    /**
    *  @Description: Sort selected objects un filtered
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    orderListUnfiltered(listAll, listSelected){
        var listReturn = [];
        for(let j = 0; j < listSelected.length; j++){
            var object = {};
            object.Nombre = listSelected[j].Nombre;
            object.Id = listSelected[j].Id;
            object.selected = true;
            listReturn.push(object);
        }
        for(let i = 0; i < listAll.length; i++){
            if(listSelected.filter(record => record.Id == listAll[i].Id).length == 0){
                var object = {};
                object.Nombre = listAll[i].Nombre;
                object.Id = listAll[i].Id;
                object.selected = false;
                listReturn.push(object);
            }
        }
        return listReturn;
    }

    /**
    *  @Description: Sort selected objects table
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    orderListUnfilteredTable(listAll, listSelected){
        var listReturn = [];
        for(let j = 0; j < listSelected.length; j++){
            if(listAll.filter(record => record.Id == listSelected[j].Id).length > 0){
                var object = {};
                object.Nombre = listSelected[j].Nombre;
                object.Id = listSelected[j].Id;
                object.selected = true;
                listReturn.push(object);
            }
           
        }
        for(let i = 0; i < listAll.length; i++){
            if(listSelected.filter(record => record.Id == listAll[i].Id).length == 0){
                var object = {};
                object.Nombre = listAll[i].Nombre;
                object.Id = listAll[i].Id;
                object.selected = false;
                listReturn.push(object);
            }
        }
        return listReturn;
    }

    /**
    *  @Description: return Convenios types
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    get optionsConvenios() {
        return [
            { label: 'Si', value: 'Si' },
            { label: 'No', value: 'No' },
        ];
    }

    /**
    *  @Description: Displays messages that are displayed on the screen
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        24/03/2023
    */
     pushMessage(title,variant,msj){
        const message = new ShowToastEvent({
            "title": title,
            "variant": variant,
            "message": msj
            });
            this.dispatchEvent(message);
    }

}