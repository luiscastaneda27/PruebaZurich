import { LightningElement, api, wire } from 'lwc';
import  retrieveToken  from '@salesforce/apex/ZRH_BotonCotizador_Controller.retrieveToken';

export default class ZrhBotonCotizador extends LightningElement {
    @api recordId;

    urlState = "Preparando..."
    url = '';
    disabled = true;

    @wire(retrieveToken, { recordId: '$recordId' })
    wiredToken({error, data}) {
        if(data) {
            console.log(data);
            this.url = 'https://www12.chilena.cl/Corporate/Web/auto-ejecutivos/#/?tokenSalesforce=' + data;
            this.urlState = 'Ir a cotizador';
            this.disabled = false;
            console.log(this.url);
        } else if(error) {
            console.log(error)
        }
    }

    handleClick() {
        console.log('URL='+this.url)
        window.open(this.url, "_blank");
    }
}