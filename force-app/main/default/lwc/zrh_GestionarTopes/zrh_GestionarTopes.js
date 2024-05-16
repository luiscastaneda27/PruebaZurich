/*********************************************************************************
Project      : Zurich 
Created By   : Deloitte
Created Date : 05/02/2024
Description  : JS - Table to display values from JSON Topes
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                         ACRONYM
Josue Alejandro Aguilar        JAA
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0       JAA	     05/02/2024		  initial version
********************************************************************************/

import { LightningElement, api, track, wire} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin'
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import COVERAGE_GROUP_FIELD from "@salesforce/schema/Product2.ZRH_GrupoDeCobertura__c";

export default class Zrh_GestionarTopes extends OmniscriptBaseMixin(LightningElement) {
    @track TopesList = [];
    @track RolesList = [];
    @track optionsRoles = [];
    @track CoberturasList = [];
    @track data = {};
    @track dataParent = {}; 
    @api tipoTope;
    @api omniJsonData;
    @api recordId;

    disabledNewTope = true;
    numberOfCharacters = 32768;
    showSpinner = false;
    topeGrupoCobertura = false;
    topePoliza = false;
    topeAdicional = false;
    showValue = false;
    optionsGrupoCobertura;
    rolesArray = [];
    _actionUtil;

    @api outputNode;
    filteredData = [];
    filterValue = '';
    selectedIds = [];

    /**
    *  @Description: return Convenios types
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        23/08/2023
    */
    
    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    productInfo;

    @wire(getPicklistValues, { recordTypeId: "$productInfo.data.defaultRecordTypeId", fieldApiName: COVERAGE_GROUP_FIELD })
    grupoCoberturaValues({ error, data }) {
        if (data) {
            this.optionsGrupoCobertura = [];
            var tempList = [];
            for (var i = 0; i < this.CoberturasList.length; i++){
                for (var j = 0; j < data.values.length; j++){
                    if(this.CoberturasList[i].GrupoCobertura === data.values[j].value && !tempList.includes(data.values[j].value)){
                        var grupoCobertura = {};
                        grupoCobertura.value = data.values[j].value;
                        grupoCobertura.label = data.values[j].label;
                        this.optionsGrupoCobertura.push(grupoCobertura);
                        tempList.push(grupoCobertura.value);
                    }
                }
            }
        } else if (error) {
            console.log(error);
        }
    }
    

    /**
    *  @Description: Initializes the component to be able to display records
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    connectedCallback() {
        console.log('recordId '+ this.recordId);
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.dataParent.TopesGrupoCobertura = [];
        this.dataParent.TopesPoliza = []; 
        this.dataParent.TopesAdicional = [];
        if(this.recordId){
            this.initRecord();
        }else{
            this.init();
        }
       
    }
    initRecord(){
        this.showSpinner = true;
        const options = {};
        const params = {
            input: { quoteLineItemId: this.recordId },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhBuscarTopes_SegurosColectivos",
            options: JSON.stringify(options)
        }
        this._actionUtil
        .executeAction(params, null, this, null, null)
        .then((response) => {
            if(response.error == false && response.result.IPResult.Plan.AtributosTopes != null){
                if(response.result.IPResult.ListaTopes.length == undefined){
                    this.ConveniosList.push(response.result.IPResult.ListaTopes);
                }else{
                    this.ConveniosList = response.result.IPResult.ListaTopes;
                }
            }
            this.showSpinner = false;
        }).catch((error) => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador');
        });
    }

    /**
    *  @Description: Consult all the existing limits in the plan.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    init(){
        this.showSpinner = true;
        if(this.omniJsonData.Plan.AtributosTopes != null){
            this.dataParent = JSON.parse(this.omniJsonData.Plan.AtributosTopes);
        }

        this.tipoTope = this.omniJsonData.TipoTope;
        this.CoberturasList = this.omniJsonData.Coberturas;
        this.RolesList = this.omniJsonData.Roles;

        if (this.RolesList.length != 0) {
            this.rolesArray = JSON.parse(JSON.stringify(this.RolesList));
            if (Array.isArray(this.rolesArray)) {
                this.optionsRoles = this.rolesArray.map(role => ({
                    label: role.label,
                    value: role.value
                }));
            } else {
                this.optionsRoles = [{
                    label: this.rolesArray.label,
                    value: this.rolesArray.value
                }];
            }
        }

        if(this.tipoTope == 'G'){
            this.TopesList = this.dataParent.TopesGrupoCobertura;
            this.topeGrupoCobertura = true;
        }
        if(this.tipoTope == 'P'){
            this.TopesList = this.dataParent.TopesPoliza;
            this.topePoliza = true;
        }
        if(this.tipoTope == 'A'){
            this.TopesList = this.dataParent.TopesAdicional;
            this.topeAdicional = true;
        }
        this.showSpinner = false;
    }

    /**
    *  @Description: Event that is executed when the "Editar" button is clicked.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    onclickShow(event){
        this.showSpinner = true;
        const name = event.target.name;
        this.data = {};
        for(let i = 0; i < this.TopesList.length; i++){
            if(this.TopesList[i].Id == name){
                this.data = {};
                this.data.showTopes = true;
                this.data.isNew = false;
                this.data.Id = this.TopesList[i].Id;
                this.data.Tope = this.TopesList[i].Tope;
                this.data.TopeLabel = this.TopesList[i].TopeLabel;
                this.data.Agrupacion = this.TopesList[i].Agrupacion;
                this.data.AgrupacionLabel = this.TopesList[i].AgrupacionLabel;
                this.data.Alternativa = this.TopesList[i].Alternativa;
                this.data.Rol = this.TopesList[i].Rol;
                this.data.RolLabel = this.TopesList[i].RolLabel;
                this.data.GrupoCobertura = this.TopesList[i].GrupoCobertura;
                this.data.GrupoCoberturaLabel = this.TopesList[i].GrupoCoberturaLabel;
                this.data.Valor = this.TopesList[i].Valor;
                this.data.ValorDeducible = this.TopesList[i].ValorDeducible;
                this.data.NroPrestAnuales = this.TopesList[i].NroPrestAnuales;
            }
        }
        this.showSpinner = false;
    }

    /**
    *  @Description: Event that is executed when any of the values in a new or existing limit stop are changed.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    handleChange(event){
        const name = event.target.name;
        const value = event.target.value.trim() != '' ? event.target.value.trim() : null;
        if(name == "tope"){
            this.data.Tope = value;
            this.data.TopeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;;
        }else if(name == "agrupacion"){
            this.data.Agrupacion = value;
            this.data.AgrupacionLabel = event.target.options.find(opt => opt.value === event.detail.value).label;;
        }
        else if(name == "alternativa"){
            this.data.Alternativa = value;
            if(this.data.Alternativa === 'Si'){
                this.showValue = true;
            }else{
                this.showValue = false;
            }
        }
        else if(name == "rol"){
            this.data.Rol = value;
            this.data.RolLabel = event.target.options.find(opt => opt.value === event.detail.value).label;;
        }
        else if(name == "grupo-cobertura"){
            this.data.GrupoCobertura = value;
            this.data.GrupoCoberturaLabel = event.target.options.find(opt => opt.value === event.detail.value).label;;
        }
        else if(name == "nro-prestaciones"){
            this.data.NroPrestAnuales = value;
        }
        else if(name == "valor"){
            this.data.Valor = value;
        }
        else if(name == "valor-deducible"){
            this.data.ValorDeducible = value;
        }
        this.validationData();
    }

    /**
    *  @Description: Validate if a repeated stop does not exist.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    validationData(){
        this.data.hasError = false;
        if(this.tipoTope == 'G'){
            for(let i = 0; i<this.TopesList.length; i++){
                if(this.data.Id != this.TopesList[i].Id && this.data.Tope == this.TopesList[i].Tope &&
                    this.data.Agrupacion == this.TopesList[i].Agrupacion && this.data.Rol == this.TopesList[i].Rol &&
                    this.data.GrupoCobertura == this.TopesList[i].GrupoCobertura){
                    this.pushMessage('Advertencia', 'warning', 'Ya existe una combinación de este tope.');
                    this.data.hasError = true;
                }
                    
            }
        }else if(this.tipoTope == 'P'){
            for(let i = 0; i<this.TopesList.length; i++){
                if(this.data.Id != this.TopesList[i].Id && this.data.Tope == this.TopesList[i].Tope &&
                    this.data.Agrupacion == this.TopesList[i].Agrupacion && this.data.Rol == this.TopesList[i].Rol){
                    this.pushMessage('Advertencia', 'warning', 'Ya existe una combinación de este tope.');
                    this.data.hasError = true;
                }
            }
        }else if(this.tipoTope == 'A'){
            for(let i = 0; i<this.TopesList.length; i++){
                if(this.data.Id != this.TopesList[i].Id && this.data.Tope == this.TopesList[i].Tope &&
                     this.data.Rol == this.TopesList[i].Rol){
                    this.pushMessage('Advertencia', 'warning', 'Ya existe una combinación de este tope.');
                    this.data.hasError = true;
                }
            }
        }
    }

    /**
    *  @Description: Validate if a repeated stop does not exist.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    validationSave(){
        let hasError = false;
        if(this.data.hasError){
            this.pushMessage('Advertencia', 'warning', 'Ya existe una combinación de este tope.');
            hasError = true;
        }else if(this.tipoTope == 'G' && (this.data.Tope == null || this.data.Agrupacion == null || 
            this.data.Rol == null || this.data.GrupoCobertura == null || this.data.NroPrestAnuales == null
            || this.data.Valor == null || this.data.ValorDeducible == null) ){
                this.pushMessage('Error', 'error', 'Debe completar todos los campos.');
                hasError = true;
        }else if(this.tipoTope == 'P' && (this.data.Tope == null || this.data.Agrupacion == null || 
                this.data.Rol == null || this.data.Valor == null || this.data.ValorDeducible == null)){
                this.pushMessage('Error', 'error', 'Debe completar todos los campos.');
                hasError = true;
        }else if(this.tipoTope == 'A' &&  (this.data.Tope == null || this.data.Alternativa == null || 
            this.data.Rol == null || (this.showValue && this.data.Valor == null))){
                this.pushMessage('Error', 'error', 'Debe completar todos los campos.');
                hasError = true;
        }
        return hasError;
    }

    /**
    *  @Description: Event that is executed when the "Agregar Tope" button is clicked.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    onclickNewTopes(){
        let index = 0;
        for(let i = 0; i<this.TopesList.length; i++){
            index = this.TopesList[i].Id > index ? this.TopesList[i].Id  : index;
        }
        this.showValue = false;
        this.data = {};
        this.data.showTopes = false;
        this.data.isNew = true;
        this.data.Id = index + 1;
        this.data.Tope = null;
        this.data.TopeLabel = null;
        this.data.Agrupacion = null;
        this.data.AgrupacionLabel = null;
        this.data.Alternativa = null;
        this.data.Rol = null;
        this.data.RolLabel = null;
        this.data.GrupoCobertura = null;
        this.data.GrupoCoberturaLabel = null;
        this.data.Valor = null;
        this.data.ValorDeducible = null;
        this.data.NroPrestAnuales = null;
    }

    /**
    *  @Description: Event that is executed when the "Cancelar" button is clicked.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    onclickCancel(){
        this.data.showTopes = false;
        this.data.isNew = false;
    }

    /**
    *  @Description: Method that stores the data of new or edited limits.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    onclickSaveTopes(){
        var object = {};
        if(this.validationSave()){
            return;
        }
        console.log('Antes de entrar al agregar: '+ JSON.stringify(this.dataParent))
        if(this.tipoTope == 'G'){
            object.Id = this.data.Id;
            object.Tope = this.data.Tope;
            object.TopeLabel = this.data.TopeLabel;
            object.Agrupacion = this.data.Agrupacion;
            object.AgrupacionLabel = this.data.AgrupacionLabel;
            object.Rol = this.data.Rol;
            object.RolLabel = this.data.RolLabel;
            object.GrupoCobertura = this.data.GrupoCobertura;
            object.GrupoCoberturaLabel = this.data.GrupoCoberturaLabel;
            object.Valor = this.data.Valor;
            object.ValorDeducible = this.data.ValorDeducible;
            object.NroPrestAnuales = this.data.NroPrestAnuales;
            this.dataParent.TopesGrupoCobertura = this.dataParent.TopesGrupoCobertura.filter(record => record.Id != this.data.Id);
            this.dataParent.TopesGrupoCobertura.push(object);
            this.TopesList = this.dataParent.TopesGrupoCobertura;
        }
        if(this.tipoTope == 'P'){
            object.Id = this.data.Id;
            object.Tope = this.data.Tope;
            object.TopeLabel = this.data.TopeLabel;
            object.Agrupacion = this.data.Agrupacion;
            object.AgrupacionLabel = this.data.AgrupacionLabel;
            object.Rol = this.data.Rol;
            object.RolLabel = this.data.RolLabel;
            object.Valor = this.data.Valor;
            object.ValorDeducible = this.data.ValorDeducible;
            this.dataParent.TopesPoliza = this.dataParent.TopesPoliza.filter(record => record.Id != this.data.Id);
            this.dataParent.TopesPoliza.push(object);
            this.TopesList = this.dataParent.TopesPoliza;
        }
        if(this.tipoTope == 'A'){
            object.Id = this.data.Id;
            object.Tope = this.data.Tope;
            object.TopeLabel = this.data.TopeLabel;
            object.Alternativa = this.data.Alternativa;
            object.Rol = this.data.Rol;
            object.RolLabel = this.data.RolLabel;
            object.Valor = this.data.Valor;
            this.dataParent.TopesAdicional = this.dataParent.TopesAdicional.filter(record => record.Id != this.data.Id);
            this.dataParent.TopesAdicional.push(object);
            this.TopesList = this.dataParent.TopesAdicional;
        }
        console.log("Lista con Nuevo Valor: "+JSON.stringify(this.dataParent));
        if(JSON.stringify(this.TopesList).length > this.numberOfCharacters){
            this.pushMessage('Advertencia', 'warning', 'Los Topes exceden el número de caracteres permitidos.');
            return;
        }
        this.callIntegrationProcedure();
    }

    /**
    *  @Description: Method that eliminates the limit data.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    onclickDeleteTopes(){
        if(this.tipoTope == 'G'){
            this.dataParent.TopesGrupoCobertura = this.dataParent.TopesGrupoCobertura.filter(record => record.Id != this.data.Id);
            this.TopesList = this.dataParent.TopesGrupoCobertura;
        }
        if(this.tipoTope == 'P'){
            this.dataParent.TopesPoliza = this.dataParent.TopesPoliza.filter(record => record.Id != this.data.Id);
            this.TopesList = this.dataParent.TopesPoliza;
        }
        if(this.tipoTope == 'A'){
            this.dataParent.TopesAdicional = this.dataParent.TopesAdicional.filter(record => record.Id != this.data.Id);
            this.TopesList = this.dataParent.TopesAdicional;
        }
        this.callIntegrationProcedure();
    }

    /**
    *  @Description: Method calling the integration procedure "zrhGuardarDatosTopes_SegurosColectivos".
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    callIntegrationProcedure(){
        console.log("Entra IP");
        this.showSpinner = true;
        console.log(this.TopesList);
        const ListaActualizar = JSON.stringify(this.dataParent);
        const options = {};
        const params = {
            input: { IdProductoCotizacion: this.omniJsonData.ContextId, ListaActualizar: ListaActualizar },
            sClassName: `vlocity_ins.IntegrationProcedureService`,
            sMethodName: "zrhGuardarDatosTopes_SegurosColectivos",
            options: JSON.stringify(options)
        }
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
    *  @Description: Return Limits Types.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    get optionsTopes() {
        return [
            { label: 'Tope Máximo Anual', value: 'TMA' },
            { label: 'Tope Máximo por Evento', value: 'TME' },
        ];
    }

    /**
    *  @Description: Return Groups Types.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    get optionsAgrupacion() {
        return [
            { label: 'Asegurado', value: 'A' },
            { label: 'Grupo Familiar', value: 'G' },
            { label: 'Póliza', value: 'P' },
        ];
    }

    /**
    *  @Description: Return Alternative Types.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    get optionsAlternativa() {
        return [
            { label: 'Si', value: 'Si' },
            { label: 'No', value: 'No' },
        ];
    }

    /**
    *  @Description: Return Aditional Limits Types.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
    */
    get optionsTopesAdicionales() {
        return [
            { label: '494 - KINESIOLOGIA IMED', value: '494' },
            { label: '601 - TOPE ADICIONAL ONCOLOGICO', value: '601' },
            { label: '602 - TOPE ADICIONAL CATASTROFICO', value: '602' },
            { label: '750 - CONTROLES PREVENTIVOS', value: '750' },
            { label: '760 - PSIQUIATRIA/PSICOLOGIA', value: '760' },
            { label: '990 - CONT. Y/O ATENCIONES DENTAL AUN NO EFECTUADOS', value: '990' },
        ];
    }

    /**
    *  @Description: Displays messages that are displayed on the screen.
    *  @Autor:       JAA, Deloitte, jaguilars@deloitte.com
    *  @Date:        06/02/2024
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