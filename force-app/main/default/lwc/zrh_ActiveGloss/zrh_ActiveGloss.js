/*********************************************************************************
Project      : Zurich 
Created By   : Deloitte
Created Date : 25/09/2023
Description  : Javascript - Manage gloss for plan
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                         ACRONYM
Luis E Castañeda                 LEC
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0       LC	     25/09/2023		  initial version
********************************************************************************/
import { LightningElement, api } from 'lwc';
import manageGloss from '@salesforce/apex/ZRH_ControllerGloss.manageGloss';
import getGlossNumber from '@salesforce/apex/ZRH_ControllerGloss.getGlossNumberForPlan';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import messageInitialGloss from "@salesforce/label/c.ZRH_MensajeInicialGlosas";
import messageInitiaWithlGloss from "@salesforce/label/c.ZRH_MensajeInicialConGlosas";
import messageFinallGloss from "@salesforce/label/c.ZRH_MensajeExitoGlosas";
import messageSuccess from "@salesforce/label/c.ZRH_MensajeProcesoExitoGlosas";
import messageError from "@salesforce/label/c.ZRH_MensajeProcesoErrorGlosas";


export default class Zrh_ActiveGloss extends LightningElement {
    @api recordId;
    showSpinner = true;
    message = messageInitialGloss;
    disabledButton = false;

    connectedCallback(){
        getGlossNumber({ recordId: this.recordId})
        .then(result => {
            if(result > 0 ){
                this.message += ' ' + messageInitiaWithlGloss + ' '+result;
            }
            this.showSpinner = false;
		})
    }

    activeGloss(){
        this.showSpinner = true;
        this.disabledButton = true;
        manageGloss({ recordId: this.recordId})
        .then(result => {
            this.message = messageFinallGloss + ' ' + result;
            this.pushMessage("Exitoso", "success", messageSuccess);
            this.showSpinner = false;
		})
		.catch(error => {
            this.showSpinner = false;
			this.pushMessage("Error", "error", messageError);
		})
	}

    pushMessage(title,variant,msj){
        const message = new ShowToastEvent({
            "title": title,
            "variant": variant,
            "message": msj
            });
            this.dispatchEvent(message);
    }
}