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

    /*  @api nubmerOfPage = 1;
      @api opentab = 1;*/

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

    get lstElements() {
        return this.lstElements;
    }
    @track showTable = false;
    @track isDisableReload = false;

    /* @api headerItemsInitial = [
         "Record Id",
         "Name",
         "Last Modified Date",
         "Last Modified By",
         "Created Date",
         "Created By"
     ];*/

    @api headerItemsInitial = [

        {
            'nameOfHeader': 'Record Id',
            'isArrow': false
        },
        {
            'nameOfHeader': 'Name',
            'isArrow': false
        },
        {
            'nameOfHeader': 'Last Modified Date',
            'isArrow': false
        },
        {
            'nameOfHeader': 'Last Modified By',
            'isArrow': false
        },
        {
            'nameOfHeader': 'Created Date',
            'isArrow': false
        },
        {
            'nameOfHeader': 'Created By',
            'isArrow': false
        }
    ]



    @track _headerItems = [];

    @api
    get headerItems() {
        return this._headerItems;
    }

    set headerItems(value) {
        //this._headerItems = value;
    }

    /*  set opentab(value) {
          this.nubmerOfPage = value;
          this.calcTab();
      }
      get opentab() {
          return this.nubmerOfPage;
      }
     
      calcTab() {
          console.log(this.nubmerOfPage);
          //this.loadData();
      }*/

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

    @track typesList = this.typesListFull;


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

    @track preventcallingcallback;

    get preventcallingcallback() {
        return this.preventcallingcallback;
    }
    set preventcallingcallback(value) {
        //this.isPrevent = value;
    }

    renderedCallback() {
        /* debugger;
         if (this.showCheckers) {
             this.returnDataDebug();
         } else {*/

        /*if (this.preventCallDebugmode === false) {
            if (this.showCheckers) {
                this.preventCallDebugmode = true;
            } else {
                this.preventCallDebugmode = false;
            }
    
    
            if (this.preventCallDebugmode) {
                this.returnDataDebug();
            } else {
                this.returnDataAfterCallBack();
            }
        }else{
    
        }*/
        //debugger;
        /* if (this.showCheckers) {
     
             console.log(this.preventcallingcallback);
             if (this.preventcallingcallback === false) {
                 this.returnDataDebug();
             }
         } else {*/
        this.returnDataAfterCallBack();
        //}
    }

    returnDataAfterCallBack(event) {
        console.log('11111111111111111111' + this.isSearchChangeExecuted);
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
                        console.log(this.showCheckers);
                        console.log(this.preventcallingcallback);
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
                                    //this.headerItems.push(temporary[key]);
                                    this.headerItems.push({
                                        name: temporary[key],
                                        isArrow: false
                                    });
                                }
                                this.lstElements = [];

                                var returnedData = JSON.parse(result);

                                this.prepareDataForDisplaying(returnedData);

                                this.showSpinner = false;

                                if (returnedData[0].recordForMetadata) {
                                    if (returnedData[0].recordForMetadata.SobjectType) {
                                        //this.headerItems.push('Object Type');
                                        this.headerItems.push({
                                            nameOfHeader: 'Object Type',
                                            isArrow: false
                                        });
                                        this.showSobjectType = true;
                                    }
                                    if (returnedData[0].recordForMetadata.MasterLabel) {
                                        //this.headerItems.push('Master Label'); 
                                        this.headerItems.push({
                                            nameOfHeader: 'Master Label',
                                            isArrow: false
                                        });
                                        this.MasterLabel = true;
                                    }
                                    if (returnedData[0].recordForMetadata.Type) {
                                        //this.headerItems.push('Type'); 
                                        this.headerItems.push({
                                            nameOfHeader: 'Type',
                                            isArrow: false
                                        });
                                        this.showType = true;
                                    }
                                    if (returnedData[0].recordForMetadata.Label) {
                                        // this.headerItems.push('Label'); 
                                        this.headerItems.push({
                                            nameOfHeader: 'Label',
                                            isArrow: false
                                        });
                                        this.showLabel = true;
                                    }
                                    if (returnedData[0].recordForMetadata.isCustom) {
                                        //this.headerItems.push('Custom'); 
                                        this.headerItems.push({
                                            nameOfHeader: 'Custom',
                                            isArrow: false
                                        });
                                        this.showisCustom = true;
                                    }
                                    if (returnedData[0].recordForMetadata.TableEnumOrId) {
                                        //this.headerItems.push('Table Enum Or Id'); 
                                        this.headerItems.push({
                                            nameOfHeader: 'Table Enum Or Id',
                                            isArrow: false
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
        // console.log("!!!!!!!!!!" + this.lstElements);

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

        var typeOfElement = this.selectedElement;
        var lstOfElements = this.listForDebugging;

        //
        debugger;
        var isAlreadyInArray = false;
        var listOfRecords = this.lstElements;

        // console.log(selectedId + 'selectedId');
        for (var t in listOfRecords) {
            //console.log(listOfRecords[t].value.Id + '~!!');
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

        //
        /*for (var element in lstOfElements) {
            if (typeOfElement === lstOfElements[element].label) {
    
                var arrayOfIds = lstOfElements[element].elements;
                arrayOfIds = arrayOfIds.filter(function (el) {
                    return el != null && el != undefined;
                });
                var isAlreadyInArray = false;
                if (arrayOfIds) {
                    if (arrayOfIds.length > 0) {
                        for (var i = 0; i < arrayOfIds.length; i++) {
                            if (arrayOfIds[i].id === selectedId) {
                                isAlreadyInArray = true;
                                //break;
                                delete arrayOfIds[i].id;
    
    
                            }
                        }
                    }
                }
                debugger;
                if (isAlreadyInArray) {
                    this.removeNewElementInCustomMetadata(event, selectedId, nameOFElement);
                } else {
                    lstOfElements[element].elements.push(
                        { 'id': selectedId });
                    var nameOFElement = '';
                    if (selectedName !== '' && selectedName !== undefined) {
                        nameOFElement = selectedName;
                    } else {
                        nameOFElement = selectedDeveloperName;
                    }
                    this.addNewElementInCustomMetadata(event, selectedId, nameOFElement);
                    //arrayOfIds[arrayOfIds.length] = selectedId;
                }
                // console.log(arrayOfIds);
    
    
                //break;
            }
        }
        for (var item in lstOfElements) {
    
    
            var arrayOfIds = lstOfElements[item].elements;
            arrayOfIds = arrayOfIds.filter(function (el) {
                return el != null && el.id != undefined;
            });
    
            if (arrayOfIds) {
    
                if (arrayOfIds.length > 0) {
                    // console.log('lstOfElements        ' + lstOfElements[item].label);
                    for (var i = 0; i < arrayOfIds.length; i++) {
                        //    console.log('---------' + arrayOfIds[i].id);
                    }
                }
            }
        }
        console.log('****************** ' + this.lstElements);*/
    }

    addNewElementInCustomMetadata(event, selectedId, nameOFElement) {
        changeRecordFromMetadata({
            typeOfElement: this.selectedElement,
            isNewValue: true,
            value: nameOFElement,
        })
            .then(result => {
                console.log('here1');
                //var returnedData = JSON.parse(result);
                //console.log(returnedData);


            })
            .catch(error => {
                console.log('here2');
                this.showError();
            });
        console.log('here 3');
    }

    removeNewElementInCustomMetadata(event, selectedId, nameOFElement) {
        changeRecordFromMetadata({
            typeOfElement: this.selectedElement,
            isNewValue: false,
            value: nameOFElement,
        })
            .then(result => {
                console.log('here1');
                //var returnedData = JSON.parse(result);
                //console.log(returnedData);


            })
            .catch(error => {
                console.log('here2');
                this.showError();
            });
        console.log('here 3');
    }

    changeDebugMode(event) {
        //console.log('here debug mode');
        this.showCheckers = !this.showCheckers;

        if (this.showCheckers) {
            this.selectedElement = "ApexClass";
            this.returnDataDebug();
        } else {
            this.typesList = this.typesListFull;
        }

    }

    returnDataDebug(event) {
        //debugger;
        this.showSpinner = true;
        this.typesList = this.typesListForDebugMode;
        //  this.isSearchChangeExecuted = false;
        this.pickListDefValue = "ApexClass";
        //  this.returnDataAfterCallBack();
        this.pagesize = this.limitOfRecordsValue;

        getRecordOfMetadataForDebugg({
            typeOfElement: this.selectedElement,
            pagenumber: this.currentpage,
            numberOfRecords: this.totalrecords,
            pageSize: this.pagesize,
            searchString: this.searchKey
        })
            .then(result => {
                // console.log('here1');
                var returnedData = JSON.parse(result);
                // console.log(returnedData);
                this.lstElements = [];
                this.prepareDataForDisplaying(returnedData);
                setTimeout(() => {
                    this.showSpinner = false;
                }, 1000);

            })
            .catch(error => {
                // console.log('here2');
                this.showError();
            });

        //console.log('here3');
        // this.preventcallingcallback = true;
    }

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

    set listForDebugging(value) {
        // this.listForDebugging = value;
    }

    get listForDebugging() {
        return listForDebugging;
    }

    @api test3 = false;

    /*  @api isAsk = false;
      @api isArrow = false;*/
    sortHelper(event) {
        debugger;
        //this.isArrow = !this.isArrow;

    }
}