import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAllPages from "@salesforce/apex/SL_ctrl_FindElement.getAllPages";
import getAllDataDueToPage from "@salesforce/apex/SL_ctrl_FindElement.getAllDataDueToPage";

export default class SL_FindPageChanger extends NavigationMixin(LightningElement) {

    @track defvalue = "";
    @track _typesList = [];
    @api selectedPage = "";
    @api headerItems = [
        "Element type",
        "Record Id",
        "Name",
        "Last Modified Date",
        "Last Modified By",
        "Created Date",
        "Created By"
    ];

    connectedCallback() {

        getAllPages()
            .then(result => {

                var returnedData = JSON.parse(result);

                this.defvalue = returnedData[0];
                this.selectedPage = returnedData[0];
                var temporary = [];
                for (var key in returnedData) {
                    temporary.push({
                        value: returnedData[key],
                        label: returnedData[key]
                    })
                }
                this._typesList = temporary;

            }).then(result => {
                this.returnData(this._typesList);
            })
            .catch(error => {

            });
    }

    changePicklist(event) {
        this.selectedPage = event.detail.value;
        console.log(this.selectedPage);
        this.returnData(this.selectedPage);
    }

    returnData(pageName) {


        getAllDataDueToPage({
            pageName: pageName
        }).then(result => {

            var returnedData = JSON.parse(result);

            console.log(returnedData);
        })
            .catch(error => {

            });
    }

}