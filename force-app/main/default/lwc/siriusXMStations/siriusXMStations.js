import { LightningElement, track } from 'lwc';
import getStationsHTML from '@salesforce/apex/SiriusXMPlaylistController.getStationsHTML';

export default class SiriusXMStations extends LightningElement {
    @track records;
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Unsynced Songs', fieldName: 'expr0' }
    ];


    connectedCallback() {
        getStationsHTML().then(data => {
            console.log(data);
            this.records = data;
        }).catch(error => {
            this.records = error;
            JSON.stringify(error);
        })
    }


    handleSelection(event) {
        console.log(JSON.stringify(event));
    }
}