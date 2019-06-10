import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FindChangerParent extends NavigationMixin(LightningElement) {
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
        this.page = event.detail.page;
        this.totalrecords = event.detail.recordsCount;
        this.pagesize = event.detail.pagesize;
        this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
    }
    handlePageChange(event) {
        this.page = event.detail;
    }

    navigateToRecordViewPageByUser(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.userId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });

    }

    navigateToRecordViewPageInNewTab(event) {

        var recordId = event.detail.recordId;
        window.open('/' + recordId, '_blank');

    }

    openRecord(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.recordId,
                actionName: 'view'
            }
        });

    }

}