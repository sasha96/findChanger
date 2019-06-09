import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import strUserId from '@salesforce/user/Id';

import searchElementsWithoutChacheable from "@salesforce/apex/SL_ctrl_FindElement.searchElementsWithoutChacheable";
import getRecordCount from "@salesforce/apex/SL_ctrl_FindElement.getRecordCount";
import getRecordsList from "@salesforce/apex/SL_ctrl_FindElement.getRecordsList";

export default class SL_FindElement extends NavigationMixin(LightningElement) {

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

    @api headerItemsInitial = [
        "Record Id",
        "Name",
        "Last Modified Date",
        "Last Modified By",
        "Created Date",
        "Created By"
    ];
    @track _headerItems = [];

    @api
    get headerItems() {
        return this._headerItems;
    }

    set headerItems(value) {
        this._headerItems = value;
    }

    @track
    typesList = [
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

    renderedCallback() {

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
                            this.showSobjectType = false;
                            this.showType = false;
                            this.showLabel = false;
                            this.showisCustom = false;
                            this.showTableEnumOrId = false;
                            this.showMasterLabel = false;

                            var temporary = this.headerItemsInitial
                            this._headerItems = [];
                            for (var key in temporary) {
                                this.headerItems.push(temporary[key]);
                            }
                            this.lstElements = [];

                            var returnedData = JSON.parse(result);

                            this.prepareDataForDisplaying(returnedData);

                            this.showSpinner = false;

                            if (returnedData[0].recordForMetadata) {
                                if (returnedData[0].recordForMetadata.SobjectType) {
                                    this.headerItems.push('Object Type');
                                    this.showSobjectType = true;
                                }
                                if (returnedData[0].recordForMetadata.MasterLabel) {
                                    this.headerItems.push('Master Label');
                                    this.MasterLabel = true;
                                }
                                if (returnedData[0].recordForMetadata.Type) {
                                    this.headerItems.push('Type');
                                    this.showType = true;
                                }
                                if (returnedData[0].recordForMetadata.Label) {
                                    this.headerItems.push('Label');
                                    this.showLabel = true;
                                }
                                if (returnedData[0].recordForMetadata.isCustom) {
                                    this.headerItems.push('Custom');
                                    this.showisCustom = true;
                                }
                                if (returnedData[0].recordForMetadata.TableEnumOrId) {
                                    this.headerItems.push('Table Enum Or Id');
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

    changePicklist(event) {

        this.selectedElement = event.detail.value;
        this.isSearchChangeExecuted = false;
        this.currentpage = 1;
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

        this.limitOfRecordsValue = event.detail.value;
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
                        lastCrearedUser: returnedData[key].lastCrearedUser
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

}