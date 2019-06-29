import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import strUserId from '@salesforce/user/Id';

import searchElementsWithoutChacheable from "@salesforce/apex/SL_ctrl_FindElement.searchElementsWithoutChacheable";
import getRecordCount from "@salesforce/apex/SL_ctrl_FindElement.getRecordCount";
import getRecordsList from "@salesforce/apex/SL_ctrl_FindElement.getRecordsList";
import getRecordOfMetadataForDebugg from "@salesforce/apex/SL_ctrl_FindElement.getRecordOfMetadataForDebugg";
import changeRecordFromMetadata from "@salesforce/apex/SL_ctrl_FindElement.changeRecordFromMetadata";

import { loadStyle } from 'lightning/platformResourceLoader';
import findchanger from '@salesforce/resourceUrl/findchanger';


export default class FindChangerFirstTab extends NavigationMixin(LightningElement) {

    @api currentpage;
    @api pagesize = this.limitOfRecordsValue;
    @api totalpages;
    @api localCurrentPage = null;
    @api isSearchChangeExecuted = false;
    @api showSobjectType;
    @api showType;
    @api showLabel;
    @api showisCustom;
    @api showTableEnumOrId;
    @api showMasterLabel;
    @api showSpinner = false;
    @api isOpenCurentTabId = false;
    @api isOpenNewTabId = false;
    @api showCheckers = false;

    @track selectedElement = "ApexClass";
    @track pickListDefValue = "ApexClass";
    @track limitOfRecordsValue = "10";
    @track recordOnPage = "10";
    @track searchValue = "";
    @track searchKey = "";
    @track error;
    @track userId = strUserId;
    @track lstElements = [];
    @track showTable = false;
    @track isDisableReload = false;
    @track typesList = this.typesListFull;
    @track preventcallingcallback;

    picvlistSortValues = [
        {
            value: true
        },
        {
            value: false
        }
    ];

    @api headerItemsInitial = [

        {
            'nameOfHeader': 'Record Id',
            'isArrow': this.picvlistSortValues[0],
            'isNtSelected': true
        },
        {
            'nameOfHeader': 'Name',
            'isArrow': this.picvlistSortValues[1],
            'isNtSelected': true
        },
        {
            'nameOfHeader': 'Last Modified Date',
            'isArrow': this.picvlistSortValues[1],
            'isNtSelected': true
        },
        {
            'nameOfHeader': 'Last Modified By',
            'isArrow': this.picvlistSortValues[1],
            'isNtSelected': true
        },
        {
            'nameOfHeader': 'Created Date',
            'isArrow': this.picvlistSortValues[1],
            'isNtSelected': true
        },
        {
            'nameOfHeader': 'Created By',
            'isArrow': this.picvlistSortValues[1],
            'isNtSelected': true
        }
    ]

    @track _headerItems = [];

    @track listForDebugging = [
        {
            label: "ApexClass",
            elements: []
        },
        {
            label: "AuraDefinitionBundle",
            elements: []
        },
        {
            label: "ApexPage",
            elements: []
        },
        {
            label: "ApexTrigger",
            elements: []
        },
        {
            label: "ApexComponent",
            elements: []
        }
    ];

    @track typesListFull = [
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
        },
        {
            value: "ApexComponent",
            label: "Apex Component"
        },
        {
            value: "AssignmentRule",
            label: "Assignment Rule"
        },
        {
            value: "CustomPermission",
            label: "Custom Permission"
        },
        {
            value: "EmailTemplate",
            label: "Email Template"
        },
        {
            value: "Report",
            label: "Report"
        },
        {
            value: "Dashboard",
            label: "Dashboard"
        },
        {
            value: "FlowDefinition",
            label: "Flow And Process Builder"
        },
        {
            value: "RecordType",
            label: "Record Type"
        },
        {
            value: "CustomTab",
            label: "Custom Tab"
        },
        {
            value: "PermissionSet",
            label: "Pemission Set"
        },
        {
            value: "Profile",
            label: "Profile"
        },
        {
            value: "FieldSet",
            label: "Field Set"
        },
        {
            value: "CustomField",
            label: "Custom Field"
        },
        {
            value: "ValidationRule",
            label: "Validation Rule"
        },
        {
            value: "WorkflowRule",
            label: "Worflow Rule"
        },
        {
            value: "FlexiPage",
            label: "Flexi Page"
        }

    ];

    @track typesListForDebugMode = [
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
            value: "ApexTrigger",
            label: "Apex Trigger"
        },
        {
            value: "ApexComponent",
            label: "Apex Component"
        }


    ];

    @track
    recordLimitList = [
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

    @api
    get headerItems() {
        return this._headerItems;
    }

    get lstElements() {
        return this.lstElements;
    }

    get listForDebugging() {
        return listForDebugging;
    }

    get preventcallingcallback() {
        return this.preventcallingcallback;
    }

    renderedCallback() {
        this.returnDataAfterCallBack();
    }

    returnDataAfterCallBack(event) {

        if (this.isSearchChangeExecuted && (this.localCurrentPage === this.currentpage)) {
            return;
        }

        this.isSearchChangeExecuted = true;
        this.localCurrentPage = this.currentpage;
        this.showSpinner = true;

        getRecordCount({
            typeOfElement: this.selectedElement,
            searchString: this.searchKey
        })
            .then(recordsCount => {

                this.checkAvalibilityOpenRecords();

                this.totalrecords = recordsCount;
                this.lstElements = [];
                if (recordsCount !== 0 && !isNaN(recordsCount)) {
                    this.pagesize = this.limitOfRecordsValue;
                    this.totalpages = Math.ceil(recordsCount / this.pagesize);

                    if (this.showCheckers) {
                        this.returnDataDebug();
                    } else {
                        getRecordsList({
                            typeOfElement: this.selectedElement,
                            pagenumber: this.currentpage,
                            numberOfRecords: recordsCount,
                            pageSize: this.pagesize,
                            searchString: this.searchKey
                        })
                            .then(result => {

                                this.showSobjectType = false;
                                this.showType = false;
                                this.showLabel = false;
                                this.showisCustom = false;
                                this.showTableEnumOrId = false;
                                this.showMasterLabel = false;

                                var temporary = this.headerItemsInitial
                                this._headerItems = [];
                                for (var key in temporary) {
                                    if (temporary[key].nameOfHeader === 'Name' || temporary[key].nameOfHeader === 'DeveloperName') {
                                        this.headerItems.push({
                                            name: temporary[key],
                                            isArrow: this.picvlistSortValues[0],
                                            'isNtSelected': false
                                        });
                                    } else {
                                        this.headerItems.push({
                                            name: temporary[key],
                                            isArrow: this.picvlistSortValues[1],
                                            'isNtSelected': true
                                        });
                                    }
                                }
                                this.lstElements = [];

                                var returnedData = JSON.parse(result);

                                this.prepareDataForDisplaying(returnedData);

                                this.showSpinner = false;

                                if (returnedData[0].recordForMetadata) {
                                    if (returnedData[0].recordForMetadata.SobjectType) {
                                        this.headerItems.push({
                                            nameOfHeader: 'Object Type',
                                            isArrow: this.picvlistSortValues[2],
                                            'isNtSelected': true
                                        });
                                        this.showSobjectType = true;
                                    }
                                    if (returnedData[0].recordForMetadata.MasterLabel) {
                                        this.headerItems.push({
                                            nameOfHeader: 'Master Label',
                                            isArrow: this.picvlistSortValues[2],
                                            'isNtSelected': true
                                        });
                                        this.MasterLabel = true;
                                    }
                                    if (returnedData[0].recordForMetadata.Type) {
                                        this.headerItems.push({
                                            nameOfHeader: 'Type',
                                            isArrow: this.picvlistSortValues[2],
                                            'isNtSelected': true
                                        });
                                        this.showType = true;
                                    }
                                    if (returnedData[0].recordForMetadata.Label) {
                                        this.headerItems.push({
                                            nameOfHeader: 'Label',
                                            isArrow: this.picvlistSortValues[2],
                                            'isNtSelected': true
                                        });
                                        this.showLabel = true;
                                    }
                                    if (returnedData[0].recordForMetadata.isCustom) {
                                        this.headerItems.push({
                                            nameOfHeader: 'Custom',
                                            isArrow: this.picvlistSortValues[2],
                                            'isNtSelected': true
                                        });
                                        this.showisCustom = true;
                                    }
                                    if (returnedData[0].recordForMetadata.TableEnumOrId) {
                                        this.headerItems.push({
                                            nameOfHeader: 'Table Enum Or Id',
                                            isArrow: this.picvlistSortValues[2],
                                            'isNtSelected': true
                                        });
                                        this.showTableEnumOrId = true;
                                    }
                                }

                                this.showTable = this.lstElements.length > 0;
                                this.isDisableReload = !this.showTable;
                                this.error = undefined;

                            })
                            .catch(error => {
                                this.error = error;
                                this.lstElements = undefined;
                                this.showSpinner = false;
                            });
                    }
                } else {
                    this.lstElements = [];
                    this.totalpages = 1;
                    this.totalrecords = 0;
                    this.showTable = false;
                    this.showSpinner = false;
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

        this.showSpinner = true;
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
        this.showSpinner = false;

    }

    refreshData(event) {

        this.showSpinner = true;
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
        this.showSpinner = false;

    }

    changePicklist(event) {

        this.selectedElement = event.detail.value;
        this.isSearchChangeExecuted = false;
        this.currentpage = 1;
        if (this.showCheckers) {
            this.returnDataDebug();
        } else {
            this.returnDataAfterCallBack();
        }

    }

    changeSearchElement(event) {

        if (this.searchKey !== event.target.value) {
            this.isSearchChangeExecuted = false;
            this.searchKey = event.target.value;
            this.currentpage = 1;
        }
    }

    changeLimitRecordOnPage(event) {

        this.limitOfRecordsValue = event.detail.value;
        this.isSearchChangeExecuted = false;
        this.currentpage = 1;
        if (this.showCheckers) {
            this.returnDataDebug();
        } else {
            this.returnDataAfterCallBack();
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

    openRecord(event) {

        this.dispatchEvent(new CustomEvent('openrecord', {
            detail: {
                recordId: event.target.dataset.id
            }
        }));

    }

    prepareDataForDisplaying(returnedData) {

        if (returnedData.length > 0) {
            for (var key in returnedData) {
                if (returnedData[key].record === null || returnedData[key].record === undefined) {
                    returnedData[key].recordForMetadata.LastModifiedDate = this.formatDate(new Date(returnedData[key].recordForMetadata.LastModifiedDate));
                    returnedData[key].recordForMetadata.CreatedDate = this.formatDate(new Date(returnedData[key].recordForMetadata.CreatedDate));
                    this.lstElements.push({
                        value: returnedData[key].recordForMetadata,
                        lastModifiedUser: returnedData[key].lastModifiedUser,
                        lastCrearedUser: returnedData[key].lastCrearedUser
                    });
                } else {
                    returnedData[key].record.LastModifiedDate = this.formatDate(new Date(returnedData[key].record.LastModifiedDate));
                    returnedData[key].record.CreatedDate = this.formatDate(new Date(returnedData[key].record.CreatedDate));
                    this.lstElements.push({
                        value: returnedData[key].record,
                        lastModifiedUser: returnedData[key].lastModifiedUser,
                        lastCrearedUser: returnedData[key].lastCrearedUser,
                        isChecked: returnedData[key].isChecked
                    });
                }
            }
        }

    }

    showError() {

        if (this.searchKey.length > 0) {
            let elementLabel = this.typesList.filter(item => item.value === this.selectedElement)[0].label;
            const toastEvnt = new ShowToastEvent({
                title: 'Hint',
                message: 'There are no ' + elementLabel + ' that contain name ' + this.searchKey,
                variant: 'warning',
            });
            this.dispatchEvent(toastEvnt);
        }

    }

    checkAvalibilityOpenRecords() {

        if (this.selectedElement === 'AssignmentRule' || this.selectedElement === 'FlowDefinition' || this.selectedElement === 'RecordType'
            || this.selectedElement === 'FieldSet' || this.selectedElement === 'CustomField' || this.selectedElement === 'ValidationRule') {
            this.isOpenCurentTabId = false;
        } else {
            this.isOpenCurentTabId = true;
        }

        if (this.selectedElement === 'AssignmentRule' || this.selectedElement === 'RecordType') {
            this.isOpenNewTabId = false;

        } else {
            this.isOpenNewTabId = true;
        }

    }

    handleCheckboxChange(event) {

        var selectedId = event.target.dataset.id;
        var selectedName = event.target.dataset.name;
        var selectedDeveloperName = event.target.dataset.developername;
        var isAlreadyInArray = false;
        var listOfRecords = this.lstElements;

        for (var t in listOfRecords) {
            if (listOfRecords[t].value.Id === selectedId) {
                isAlreadyInArray = listOfRecords[t].isChecked;
            }
        }
        var nameOFElement = '';
        if (selectedName !== '' && selectedName !== undefined) {
            nameOFElement = selectedName;
        } else {
            nameOFElement = selectedDeveloperName;
        }
        if (isAlreadyInArray) {
            this.removeNewElementInCustomMetadata(event, selectedId, nameOFElement);
        } else {
            this.addNewElementInCustomMetadata(event, selectedId, nameOFElement);
        }

    }

    addNewElementInCustomMetadata(event, selectedId, nameOFElement) {

        changeRecordFromMetadata({
            typeOfElement: this.selectedElement,
            isNewValue: true,
            value: nameOFElement,
        })
            .then(result => {
                const toastEvnt = new ShowToastEvent({
                    title: 'success',
                    message: 'You successfully added ' + nameOFElement + ' to custom metadata',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toastEvnt);
            })
            .catch(error => {
                const toastEvnt = new ShowToastEvent({
                    title: 'error',
                    message: 'Error happend when you tried to add element from custom metadata',
                    variant: 'error',
                });
                this.dispatchEvent(toastEvnt);
            });

    }

    removeNewElementInCustomMetadata(event, selectedId, nameOFElement) {

        changeRecordFromMetadata({
            typeOfElement: this.selectedElement,
            isNewValue: false,
            value: nameOFElement,
        })
            .then(result => {
                const toastEvnt = new ShowToastEvent({
                    title: 'success',
                    message: 'You successfully removed ' + nameOFElement + ' from custom metadata',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toastEvnt);
            })
            .catch(error => {
                const toastEvnt = new ShowToastEvent({
                    title: 'error',
                    message: 'Error happend when you tried to remove element from custom metadata',
                    variant: 'error',
                });
                this.dispatchEvent(toastEvnt);
            });

    }

    changeDebugMode(event) {

        this.showCheckers = !this.showCheckers;

        if (this.showCheckers) {
            this.selectedElement = "ApexClass";
            this.returnDataDebug();
        } else {
            this.typesList = this.typesListFull;
        }

    }

    returnDataDebug(event) {

        this.showSpinner = true;
        this.typesList = this.typesListForDebugMode;
        this.pickListDefValue = "ApexClass";
        this.pagesize = this.limitOfRecordsValue;

        getRecordOfMetadataForDebugg({
            typeOfElement: this.selectedElement,
            pagenumber: this.currentpage,
            numberOfRecords: this.totalrecords,
            pageSize: this.pagesize,
            searchString: this.searchKey
        })
            .then(result => {
                var returnedData = JSON.parse(result);
                this.lstElements = [];
                this.prepareDataForDisplaying(returnedData);
                setTimeout(() => {
                    this.showSpinner = false;
                }, 1000);

            })
            .catch(error => {
                this.showError();
            });

    }

    sortHelper(event) {

        var headerItems = this.headerItems;
        var selectedItem = event.target.dataset.name;

        for (let i = 0; i < headerItems.length; i++) {
            if (headerItems[i].name.nameOfHeader === selectedItem) {
                if (headerItems[i].isNtSelected === true) {
                    for (let j = 0; j < headerItems.length; j++) {
                        headerItems[j].isNtSelected = true;
                    }
                }
                headerItems[i].isNtSelected = false;

                if (headerItems[i].isArrow.value === false) {
                    headerItems[i].isArrow.value = true;
                } else {
                    headerItems[i].isArrow.value = false;
                }
            }
        }

    }
}