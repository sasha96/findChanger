import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import strUserId from '@salesforce/user/Id';

import getAllPages from "@salesforce/apex/SL_ctrl_FindElement.getAllPages";
import getAllDataDueToPage from "@salesforce/apex/SL_ctrl_FindElement.getAllDataDueToPage";

export default class SL_FindPageChanger extends NavigationMixin(LightningElement) {

    @track lstElements = [];
    @track defvalue = "";
    @track _typesList = [];
    @track userId = strUserId;
    @api showTable = false;
    @api showSpinner = false;
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
        this.showSpinner = true;

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
                this.returnData(this.selectedPage);

            })
            .catch(error => {

            });
    }

    changePicklist(event) {
        this.showSpinner = true;
        this.selectedPage = event.detail.value;
        this.returnData(this.selectedPage);
    }

    returnData(pageName) {

        getAllDataDueToPage({
            pageName: pageName
        }).then(result => {
            this.lstElements = [];
            this.showTable = false;
            var returnedData = JSON.parse(result);
            this.prepareDataForDisplaying(returnedData);

            this.showTable = this.lstElements.length > 0;
        })
            .catch(error => {

            });

        this.showSpinner = false;
    }

    prepareDataForDisplaying(returnedData) {

        for (var key in returnedData) {

            var item = returnedData[key];
            if (item) {
                if (item.length > 0) {
                    for (var keyInner in item) {
                        item[keyInner].record.LastModifiedDate = this.formatDate(new Date(item[keyInner].record.LastModifiedDate));
                        item[keyInner].record.CreatedDate = this.formatDate(new Date(item[keyInner].record.CreatedDate));
                        this.lstElements.push({
                            value: item[keyInner].record,
                            lastModifiedUser: item[keyInner].lastModifiedUser,
                            lastCrearedUser: item[keyInner].lastCrearedUser,
                            typeOfElement: item[keyInner].typeOfElement
                        });

                    }
                }
            }
        }

    }

    formatDate(date) {

        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12;
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;

    }

    navigateToRecordViewPageByUser(event) {

        this.dispatchEvent(new CustomEvent('navigatetouser', {
            detail: {
                userId: event.target.dataset.id
            }
        }));
    }

    navigateToRecordViewPageInNewTab(event) {

        this.dispatchEvent(new CustomEvent('navigatetorecordviewnewtab', {
            detail: {
                recordId: event.target.dataset.id2
            }
        }));

    }

}