import { LightningElement, api } from 'lwc';

export default class SL_FindChangerParent extends LightningElement {
  @api page = 1;
  @api totalrecords;
  @api _pagesize = 10;
  get pagesize() {
    return this._pagesize;
  }
  set pagesize(value) {
    this._pagesize = value;
  }
  handlePrevious() {
    if (this.page > 1) {
      this.page = this.page - 1;
    }
  }
  handleNext() {
    if (this.page < this.totalPages) {
      this.page = this.page + 1;
    }
  }
  handleFirst() {
    this.page = 1;
  }
  handleLast() {
    this.page = this.totalPages;
  }
  handleRecordsLoad(event) {
    this.totalrecords = event.detail.recordsCount;
    this.pagesize = event.detail.pagesize;
    this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
  }    
handlePageChange(event) {
this.page = event.detail;
}
}
 