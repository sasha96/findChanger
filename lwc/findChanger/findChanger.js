import { LightningElement, track, wire, api } from "lwc";
import searchElementsWithoutChacheable from "@salesforce/apex/SL_ctrl_FindElement.searchElementsWithoutChacheable";
import getRecordCount from "@salesforce/apex/SL_ctrl_FindElement.getRecordCount";
import getRecordsList from "@salesforce/apex/SL_ctrl_FindElement.getRecordsList";

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import strUserId from '@salesforce/user/Id';

export default class SL_FindElement extends NavigationMixin(LightningElement) {

    @api currentpage;
    @api pagesize = this.limitOfRecordsValue;
    @api totalpages;
    @api localCurrentPage = null;
    @api isSearchChangeExecuted = false;

    @track selectedElement = "ApexClass";
    @track pickListDefValue = "ApexClass";
    @track limitOfRecordsValue = "10";
    @track limitDefValue = "10";
    @track searchValue = "";
    @track searchKey = "";
    @track error;
    @track userId = strUserId;
    @track lstElements = [];
    @track showTable = false;
    @track isDisableReload = false;

    @track headerItems = [
        "Record Id",
        "Name",
        "Last Modified Date",
        "Last Modified By",
        "Created Date",
        "Created By"
    ];

    @track
    elementTypes = [
        {
            value: "ApexClass",
            label: "Apex Class"
        },
        {
            value: "AuraDefinitionBundle",
            label: "Aura Bundle"
        },
        {
            value: "ApexPage",
            label: "Apex Page"
        },
        {
            value: "StaticResource",
            label: "Static Resource"
        },
        {
            value: "ApexTrigger",
            label: "Apex Trigger"
        }
    ];

    @track
    limitList = [
        {
            value: "5",
            label: "5"
        },
        {
            value: "10",
            label: "10"
        },
        {
            value: "15",
            label: "15"
        },
        {
            value: "20",
            label: "20"
        },
        {
            value: "30",
            label: "30"
        },
        {
            value: "50",
            label: "50"
        }
    ];

    renderedCallback() {

        if (this.isSearchChangeExecuted && (this.localCurrentPage === this.currentpage)) {
            return;
        }
        this.isSearchChangeExecuted = true;
        this.localCurrentPage = this.currentpage;
        getRecordCount({
            typeOfElement: this.selectedElement,
            searchString: this.searchKey
        })
            .then(recordsCount => {
                this.totalrecords = recordsCount;
                this.lstElements = [];
                if (recordsCount !== 0 && !isNaN(recordsCount)) {
                    this.pagesize = this.limitOfRecordsValue;
                    this.totalpages = Math.ceil(recordsCount / this.pagesize);
                    getRecordsList({
                        typeOfElement: this.selectedElement,
                        pagenumber: this.currentpage,
                        numberOfRecords: recordsCount,
                        pageSize: this.pagesize,
                        searchString: this.searchKey
                    })
                        .then(result => {
                            this.lstElements = [];
                            var returnedData = JSON.parse(result);
                            this.prepareDataForDisplaying(returnedData);
                            this.showTable = this.lstElements.length > 0;
                            this.isDisableReload = !this.showTable;
                            this.error = undefined;
                        })
                        .catch(error => {
                            this.error = error;
                            this.lstElements = undefined;
                        });
                } else {
                    this.lstElements = [];
                    this.totalpages = 1;
                    this.totalrecords = 0;
                    this.showTable = false;
                }
                const event = new CustomEvent('recordsload', {
                    detail: {
                        page: this.currentpage,
                        recordsCount: recordsCount,
                        pagesize: this.limitOfRecordsValue
                    }
                });
                this.dispatchEvent(event);
            })
            .catch(error => {
                this.error = error;
                this.totalrecords = undefined;
            });

    }

    refreshData(event) {

        searchElementsWithoutChacheable({
            typeOfElement: this.selectedElement,
            pagenumber: this.currentpage,
            numberOfRecords: this.totalrecords,
            pageSize: this.pagesize,
            searchString: this.searchKey
        })
            .then(result => {
                this.lstElements = [];
                var returnedData = JSON.parse(result);
                this.prepareDataForDisplaying(returnedData);
            })
            .catch(error => {
                this.showError();
            });

    }

    changePicklist(event) {

        const select = event.detail.value;
        this.selectedElement = select;
        this.isSearchChangeExecuted = false;
        this.renderedCallback();

    }

    changeSearchElement(event) {

        if (this.searchKey !== event.target.value) {
            this.isSearchChangeExecuted = false;
            this.searchKey = event.target.value;
            this.currentpage = 1;
        }
    }

    changeLimitRecordOnPage(event) {

        const select = event.detail.value;
        this.limitOfRecordsValue = select;
        this.isSearchChangeExecuted = false;
        this.currentpage = 1;
        this.renderedCallback();

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

        var recordId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });

    }

    navigateToRecordViewPage(event) {

        var recordId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: this.selectedElement,
                actionName: 'view'
            }
        });

    }

    navigateToRecordViewPageInNewTab(event) {

        var recordId = event.target.dataset.id2;
        window.open('/' + recordId);

    }

    prepareDataForDisplaying(returnedData) {

        if (returnedData.length > 0) {
            for (var key in returnedData) {
                returnedData[key].record.LastModifiedDate = this.formatDate(new Date(returnedData[key].record.LastModifiedDate));
                returnedData[key].record.CreatedDate = this.formatDate(new Date(returnedData[key].record.CreatedDate));
                this.lstElements.push({
                    value: returnedData[key].record,
                    lastModifiedUser: returnedData[key].lastModifiedUser,
                    lastCrearedUser: returnedData[key].lastCrearedUser
                });
            }
        }

    }

    showError() {

        if (this.searchKey.length > 0) {
            let elementLabel = this.elementTypes.filter(item => item.value === this.selectedElement)[0].label;
            const toastEvnt = new ShowToastEvent({
                title: 'Hint',
                message: 'There are no ' + elementLabel + ' that contain name ' + this.searchKey,
                variant: 'warning',
            });
            this.dispatchEvent(toastEvnt);
        }

    }

}