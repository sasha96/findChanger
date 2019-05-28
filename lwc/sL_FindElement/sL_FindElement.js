import { LightningElement, track, wire } from "lwc";
import searchElements from "@salesforce/apex/SL_ctrl_FindElement.searchElements";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import strUserId from '@salesforce/user/Id';

export default class SL_FindElement extends NavigationMixin(LightningElement) {
  @track selectedElement = "ApexClass";
  @track pickListDefValue = "ApexClass";

  @track limitOfRecordsValue = "10";
  @track limitDefValue = "10";

  @track searchValue = "";
  @track searchKey = "";

  @track error;

  @track userId = strUserId;

  @track headerItems = [
    "Record Id",
    "Name",
    "Last Modified Date",
    "Last Modified By Id",
    "Created Date",
    "Created By Id"
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
      value: "20",
      label: "20"
    },
    {
      value: "50",
      label: "50"
    }
  ];

  @track lstElements = [];
  @track showTable = false;

  @wire(searchElements, {
    typeOfElement: "$selectedElement",
    searchString: "$searchKey",
    limitOfRecords: "$limitOfRecordsValue"
  })
  wiredElents({ error, data }) {
    this.lstElements = [];
    this.showTable = false;

    if (error) {
      alert(error + "ERROR");
    } else if (data) {
      var returnedData = JSON.parse(data);
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
      } else {
        let elementLabel = this.elementTypes.filter(item => item.value === this.selectedElement)[0].label;
        const toastEvnt = new ShowToastEvent({
          title: 'Hint',
          message: 'There are no ' + elementLabel + ' that contain name ' + this.searchKey,
          variant: 'warning',
        });
        this.dispatchEvent(toastEvnt);
      }

      this.showTable = this.lstElements.length > 0;
    }
  }

  changePicklist(event) {
    const select = event.detail.value;
    this.selectedElement = select;
  }

  changeSearchElement(event) {
    const searchKey = event.target.value;
    this.searchKey = searchKey;
  }

  changeLimitPicklist(event) {
    const select = event.detail.value;
    this.limitOfRecordsValue = select;
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

}