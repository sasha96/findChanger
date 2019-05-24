import getContactList from "@salesforce/apex/contactController.getContactList";

import { LightningElement, track, wire } from "lwc";
const DELAY = 300;
export default class findLWC extends LightningElement {
  @track
  greeting = "World";
  changeHandler(event) {
    this.greeting = event.target.value;
  }

  @track email = "@ukr.net";
  changeEmailHandler(event) {
    this.email = event.target.value;
  }
  /*
  @wire(getContactList, {})
  findClass({ error, data }) {
    if (error) {
      alert("$email!!!" + error + "");
      alert(Json.parse(data) + "123");
    } else if (data) {
      alert(Json.parse(data) + "1111");
    }
  }*/

  @track searchKey = "";
  @wire(getContactList, { searchKey: "$searchKey" })
  contacts;

  handleKeyChange(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this.delayTimeout = setTimeout(() => {
      this.searchKey = searchKey;
    }, DELAY);
  }
}