import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import strUserId from '@salesforce/user/Id';

import getAllPages from "@salesforce/apex/SL_ctrl_FindElement.getAllPages";
import getAllDataDueToPage from "@salesforce/apex/SL_ctrl_FindElement.getAllDataDueToPage";

import { navigateToRecordViewPageInNewTab } from 'c/findChangerHelper';
import { formatDatehelper } from 'c/findChangerHelper';

export default class FindChangerSecondTab extends NavigationMixin(LightningElement) {

    @track lstElements = [];
    @track defvalue = "";
    @track _typesList = [];
    @track userId = strUserId;
    @track _headerItems = [];

    @api showTable = false;
    @api showSpinner = false;
    @api selectedPage = "";
    @api headerItemsInitial = [
        {
            'nameOfHeader': 'Element type',
            'isNtSelected': true,
            'nameOfHeaderApi': 'typeOfElement'
        },
        {
            'nameOfHeader': 'Record Id',
            'isNtSelected': true,
            'nameOfHeaderApi': 'Id'
        },
        {
            'nameOfHeader': 'Name',
            'isNtSelected': false,
            'nameOfHeaderApi': 'Name'
        },
        {
            'nameOfHeader': 'Last Modified Date',
            'isNtSelected': true,
            'nameOfHeaderApi': 'LastModifiedDate'
        },
        {
            'nameOfHeader': 'Last Modified By',
            'isNtSelected': true,
            'nameOfHeaderApi': 'LastModifiedById'
        },
        {
            'nameOfHeader': 'Created Date',
            'isNtSelected': true,
            'nameOfHeaderApi': 'CreatedDate'
        },
        {
            'nameOfHeader': 'Created By',
            'isNtSelected': true,
            'nameOfHeaderApi': 'CreatedById'
        },
    ];

    @api
    get headerItems() {
        return this._headerItems;
    }

    set headerItems(value) {
        this._headerItems = value;
    }

    connectedCallback() {
        this.initialize();
    }

    initialize() {

        this.showSpinner = true;
        this.showTable = false;

        var temporary = this.headerItemsInitial;

        this._headerItems = [];
        for (var key in temporary) {
            this.headerItems.push({
                'nameOfHeader': temporary[key].nameOfHeader,
                'isArrow': false,
                'isNtSelected': temporary[key].isNtSelected,
                'nameOfHeaderApi': temporary[key].nameOfHeaderApi
            });
        }

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
                const toastEvnt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error happend when you tried to retrieve all pages from custom metadata',
                    variant: 'error',
                    duration: 5000
                });
                this.dispatchEvent(toastEvnt);
            });

    }

    changePicklist(event) {

        this.showSpinner = true;
        this.showTable = false;
        this.selectedPage = event.detail.value;
        this.returnData(this.selectedPage);

    }

    returnData(pageName) {

        getAllDataDueToPage({
            pageName: pageName,
            dataModified: null
        }).then(result => {
            this.lstElements = [];

            var returnedData = JSON.parse(result);
            this.prepareDataForDisplaying(returnedData);

            this.showTable = this.lstElements.length > 0;
        })
            .catch(error => {
                const toastEvnt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error happend when you change picklist value and tried to retrieve all pages from custom metadata',
                    variant: 'error',
                    duration: 5000
                });
                this.dispatchEvent(toastEvnt);
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
                            name: item[keyInner].record.Name !== undefined ? item[keyInner].record.Name : item[keyInner].record.DeveloperName,
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
        return formatDatehelper(date);
    }

    navigateToRecordViewPageByUser(event) {

        this.dispatchEvent(new CustomEvent('navigatetouser', {
            detail: {
                userId: event.target.dataset.id
            }
        }));

    }

    navigateToRecordInNewTab(event) {
        navigateToRecordViewPageInNewTab(event.target.dataset.id2);
    }

    openRecord(event) {

        this.dispatchEvent(new CustomEvent('openrecord', {
            detail: {
                recordId: event.target.dataset.id
            }
        }));

    }

    sortHelper(event) {

        var selectedItem = event.target.dataset.name;

        var sortAsc = false;
        for (let j = 0; j < this.headerItems.length; j++) {
            this.headerItems[j].isNtSelected = true;
            if (this.headerItems[j].nameOfHeaderApi === selectedItem) {
                this.headerItems[j].isNtSelected = !this.headerItems[j].isNtSelected;
            }

            this.isArrow = false;
            if (this.headerItems[j].nameOfHeaderApi === selectedItem) {
                this.headerItems[j].isArrow = !this.headerItems[j].isArrow;
                sortAsc = this.headerItems[j].isArrow;
            }
        }

        var temporary = this.lstElements;

        if (selectedItem === 'Name') {
            temporary.sort(function (a, b) {
                var t1 = a.name == b.name,
                    t2 = (!a.name && b.name) || (a.name < b.name);
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);
            });
        } else if (selectedItem === 'typeOfElement') {
            temporary.sort(function (a, b) {
                var t1 = a.typeOfElement == b.typeOfElement,
                    t2 = (!a.typeOfElement && b.typeOfElement) || (a.typeOfElement < b.typeOfElement);
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);
            });
        } else {
            temporary.sort(function (a, b) {
                var t1 = a.value[selectedItem] == b.value[selectedItem],
                    t2 = (!a.value[selectedItem] && b.value[selectedItem]) || (a.value[selectedItem] < b.value[selectedItem]);
                return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);
            });
        }
        this.lstElements = temporary;

    }


}