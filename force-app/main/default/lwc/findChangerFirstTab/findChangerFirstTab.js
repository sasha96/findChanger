import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import strUserId from '@salesforce/user/Id';

import { navigateToRecordViewPageInNewTab } from 'c/findChangerHelper';
import { formatDatehelper } from 'c/findChangerHelper';

import searchElementsWithoutChacheable from "@salesforce/apex/SL_ctrl_FindElement.searchElementsWithoutChacheable";
import getRecordCount from "@salesforce/apex/SL_ctrl_FindElement.getRecordCount";
import getRecordsListFirstTab from "@salesforce/apex/SL_ctrl_FindElement.getRecordsListFirstTab";
import getRecordOfMetadataForDebugg from "@salesforce/apex/SL_ctrl_FindElement.getRecordOfMetadataForDebugg";
import changeRecordFromMetadata from "@salesforce/apex/SL_ctrl_FindElement.changeRecordFromMetadata";
import getRecordMetadataForSendMessage from "@salesforce/apex/SL_ctrl_FindElement.getRecordMetadataForSendMessage";
import updateRecordMetadataForSendMessage from "@salesforce/apex/SL_ctrl_FindElement.updateRecordMetadataForSendMessage";

import { loadStyle } from 'lightning/platformResourceLoader';
import findchanger from '@salesforce/resourceUrl/findchanger';
import SystemModstamp from "@salesforce/schema/CaseContactRole.SystemModstamp";

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
    @api selectedItem = '';
    @api isAsc = false;
    @api isSetTimeOutValue = false;
    @api isSendEmail = false;

    @track _headerItems = [];
    @track selectedElement = "ApexClass";
    @track pickListDefValue = "ApexClass";
    @track limitOfRecordsValue = "10";
    @track recordOnPage = "10";
    @track searchValue = "";
    @track searchKey = "";
    @track userId = strUserId;
    @track lstElements = [];
    @track showTable = false;
    @track isDisableReload = false;
    @track typesList = this.typesListFull;
    @track preventcallingcallback;

    @api headerItemsInitial = [

        {
            'nameOfHeader': 'Record Id',
            'isArrow': false,
            'isNtSelected': true,
            'nameOfHeaderApi': 'Id'
        },
        {
            'nameOfHeader': 'Name',
            'isArrow': true,
            'isNtSelected': false,
            'nameOfHeaderApi': 'Name',
        },
        {
            'nameOfHeader': 'Last Modified Date',
            'isArrow': false,
            'isNtSelected': true,
            'nameOfHeaderApi': 'LastModifiedDate',
        },
        {
            'nameOfHeader': 'Last Modified By',
            'isArrow': false,
            'isNtSelected': true,
            'nameOfHeaderApi': 'LastModifiedById',
        },
        {
            'nameOfHeader': 'Created Date',
            'isArrow': false,
            'isNtSelected': true,
            'nameOfHeaderApi': 'CreatedDate',
        },
        {
            'nameOfHeader': 'Created By',
            'isArrow': false,
            'isNtSelected': true,
            'nameOfHeaderApi': 'CreatedById',
        }
    ]

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

    set headerItems(value) {
        this._headerItems = value;
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
                        this.typesList = this.typesListFull;
                        getRecordsListFirstTab({
                            typeOfElement: this.selectedElement,
                            pagenumber: this.currentpage,
                            pageSize: this.pagesize,
                            searchString: this.searchKey,
                            selectedItem: this.selectedItem,
                            isAsc: this.isAsc
                        })
                            .then(result => {
                                this.showSobjectType = false;
                                this.showType = false;
                                this.showLabel = false;
                                this.showisCustom = false;
                                this.showTableEnumOrId = false;
                                this.showMasterLabel = false;

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

                                this.lstElements = [];

                                var returnedData = JSON.parse(result);

                                this.prepareDataForDisplaying(returnedData);

                                this.showSpinner = false;

                                if (returnedData[0].recordForMetadata) {
                                    if (returnedData[0].recordForMetadata.SobjectType) {
                                        var element = {
                                            'nameOfHeader': 'Object Type',
                                            'isArrow': false,
                                            'isNtSelected': true,
                                            'nameOfHeaderApi': 'SobjectType'
                                        }
                                        this.headerItems.push(element);
                                        this.showSobjectType = true;
                                    }
                                    if (returnedData[0].recordForMetadata.MasterLabel) {
                                        var element = {
                                            'nameOfHeader': 'Master Label',
                                            'isArrow': false,
                                            'isNtSelected': true,
                                            'nameOfHeaderApi': 'MasterLabel'
                                        }
                                        this.headerItems.push(element);
                                        this.MasterLabel = true;
                                    }
                                    if (returnedData[0].recordForMetadata.Type) {
                                        var element = {
                                            'nameOfHeader': 'Type',
                                            'isArrow': false,
                                            'isNtSelected': true,
                                            'nameOfHeaderApi': 'Type'
                                        }
                                        this.headerItems.push(element);
                                        this.showType = true;
                                    }
                                    if (returnedData[0].recordForMetadata.Label) {
                                        var element = {
                                            'nameOfHeader': 'Label',
                                            'isArrow': false,
                                            'isNtSelected': true,
                                            'nameOfHeaderApi': 'Label'
                                        }
                                        this.headerItems.push(element);
                                        this.showLabel = true;
                                    }
                                    if (returnedData[0].recordForMetadata.isCustom) {
                                        var element = {
                                            'nameOfHeader': 'Custom',
                                            'isArrow': false,
                                            'isNtSelected': true,
                                            'nameOfHeaderApi': 'isCustom'
                                        }
                                        this.headerItems.push(element);
                                        this.showisCustom = true;
                                    }
                                    if (returnedData[0].recordForMetadata.TableEnumOrId) {
                                        var element = {
                                            'nameOfHeader': 'Table Enum Or Id',
                                            'isArrow': false,
                                            'isNtSelected': true,
                                            'nameOfHeaderApi': 'TableEnumOrId'
                                        }
                                        this.headerItems.push(element);
                                        this.showTableEnumOrId = true;
                                    }
                                }

                                this.showTable = this.lstElements.length > 0;
                                this.isDisableReload = !this.showTable;

                            })
                            .catch(error => {
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
                this.showToastMessage('error', 'Error happend when in initialization method', 'error', 5000);
                this.totalrecords = undefined;
            });

    }

    refreshData(event) {

        this.showSpinner = true;
        searchElementsWithoutChacheable({
            typeOfElement: this.selectedElement,
            pagenumber: this.currentpage,
            pageSize: this.pagesize,
            searchString: this.searchKey,
            selectedItem: this.selectedItem,
            isAsc: this.isAsc
        })
            .then(result => {
                this.lstElements = [];
                var returnedData = JSON.parse(result);
                this.prepareDataForDisplaying(returnedData);
            })
            .catch(error => {
                this.showToastMessage('error', 'Error happend when you tried to return and prepare data', 'error', 5000);
            });
        this.showSpinner = false;

    }

    changePicklist(event) {

        this.selectedItem = '';
        this.isAsc = false;
        this.selectedElement = event.detail.value;
        this.isSearchChangeExecuted = false;
        this.currentpage = 1;
        if (this.showCheckers) {
            var temporary = this.headerItemsInitial;
            this._headerItems = [];
            for (var key in temporary) {
                this.headerItems.push({
                    'nameOfHeader': temporary[key].nameOfHeader,
                    'isArrow': false,//temporary[key].isArrow,
                    'isNtSelected': temporary[key].isNtSelected,
                    'nameOfHeaderApi': temporary[key].nameOfHeaderApi
                });
            }
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
        return formatDatehelper(date);
    }

    navigateToRecordViewPageByUser(event) {

        this.dispatchEvent(new CustomEvent('navigatetouser', {
            detail: {
                userId: event.target.dataset.id
            }
        }));
    }

    navigateToRecordViewPageInNewTab(event) {
        navigateToRecordViewPageInNewTab(event.target.dataset.id2);
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
                this.showToastMessage('success', 'You successfully added ' + nameOFElement + ' to custom metadata', 'success', 3000, 'dismissable');
            })
            .catch(error => {
                this.showToastMessage('error', 'Error happend when you tried to add element from custom metadata', 'error', 5000);
            });

    }

    removeNewElementInCustomMetadata(event, selectedId, nameOFElement) {

        changeRecordFromMetadata({
            typeOfElement: this.selectedElement,
            isNewValue: false,
            value: nameOFElement,
        })
            .then(result => {
                this.showToastMessage('success', 'You successfully removed ' + nameOFElement + ' from custom metadata', 'success', 3000, 'dismissable');
            })
            .catch(error => {
                this.showToastMessage('error', 'Error happend when you tried to remove element from custom metadata', 'error', 5000);
            });

    }

    showToastMessage(title, message, variant, duration, mode) {
        var toastEvnt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            duration: duration,
            mode: mode
        });
        this.dispatchEvent(toastEvnt);
    }

    changeDebugMode(event) {

        this.showCheckers = !this.showCheckers;

        if (this.showCheckers) {

            this.showSpinner = true;
            var timeSec = 0;
            if (this.isSetTimeOutValue === false) {
                this.dispatchEvent(new CustomEvent('checkexistrecord', {}));
                timeSec = 3000;
            }
            setTimeout(() => {
                this.showSpinner = false;
                this.selectedElement = "ApexClass";
                this.getRecordMetadataForSendMessage();
                this.returnDataDebug();

            }, timeSec);
            this.isSetTimeOutValue = true;
        } else {
            this.typesList = this.typesListFull;
        }

    }

    getRecordMetadataForSendMessage(event) {

        getRecordMetadataForSendMessage({})
            .then(result => {
                var returnedData = JSON.parse(result);
                this.isSendEmail = returnedData;
            })
            .catch(error => {
                this.showToastMessage('error', 'Error happend when you tried to retrieve metadata', 'error', 5000);
            });

    }

    handleSendEmail(event) {

        this.isSendEmail = !this.isSendEmail;

        updateRecordMetadataForSendMessage({
            value: this.isSendEmail,
        })
            .then(result => {
                this.showToastMessage('success', 'You successfully change Send email mode', 'success', 3000, 'dismissable');
            })
            .catch(error => {
                this.showToastMessage('error', 'Error happend when you tried to change send email option', 'error', 5000);
            });
    }

    returnDataDebug(event) {

        this.showSpinner = true;
        this.typesList = this.typesListForDebugMode;
        this.pickListDefValue = "ApexClass";
        this.pagesize = this.limitOfRecordsValue;

        getRecordOfMetadataForDebugg({
            typeOfElement: this.selectedElement,
            pagenumber: this.currentpage,
            pageSize: this.pagesize,
            searchString: this.searchKey,
            selectedItem: this.selectedItem,
            isAsc: this.isAsc
        })
            .then(result => {

                var returnedData = JSON.parse(result);

                this.lstElements = [];
                this.prepareDataForDisplaying(returnedData);
                this.showSpinner = false;

            })
            .catch(error => {
                this.showToastMessage('error', 'Error happend when you tried to turn on debug mode', 'error', 5000);
            });

    }

    sortHelper(event) {

        var selectedItem = event.target.dataset.name;
        var isAsc = false;

        for (var key in this.headerItems) {

            if (this.headerItems[key].nameOfHeaderApi === selectedItem) {

                if (this.headerItems[key].isNtSelected === true) {
                    for (let j = 0; j < this.headerItems.length; j++) {
                        this.headerItems[j].isNtSelected = true;
                    }
                }
                this.headerItems[key].isNtSelected = false;

                if (this.headerItems[key].isArrow === false) {
                    this.headerItems[key].isArrow = true;
                    isAsc = true;
                } else {
                    this.headerItems[key].isArrow = false;
                }

            }
        }
        this.selectedItem = selectedItem;
        this.isAsc = isAsc;

        if (this.showCheckers) {
            this.returnDataDebug(event);
        } else {
            this.returnDataAfterSort(event);
        }

    }

    returnDataAfterSort(event) {

        getRecordsListFirstTab({
            typeOfElement: this.selectedElement,
            pagenumber: this.currentpage,
            pageSize: this.pagesize,
            searchString: this.searchKey,
            selectedItem: this.selectedItem,
            isAsc: this.isAsc
        })
            .then(result => {
                this.lstElements = [];
                var returnedData = JSON.parse(result);
                this.prepareDataForDisplaying(returnedData);
                this.showSpinner = false;
                this.showTable = this.lstElements.length > 0;
                this.isDisableReload = !this.showTable;
            })
            .catch(error => {
                this.showToastMessage('error', 'Error happend when you tried to return data after sorting', 'error', 5000);
                this.lstElements = undefined;
                this.showSpinner = false;
            });

    }

}