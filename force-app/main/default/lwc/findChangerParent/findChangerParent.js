import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FindChangerParent extends NavigationMixin(LightningElement) {

    @api page = 1;
    @api totalrecords;
    @api _pagesize = 10;

    @api iscallingback = false;

    checkexist() {
        this.dispatchEvent(new CustomEvent('checkvaluechange', {}));
    }

    get pagesize() {
        return this._pagesize;
    }
    set pagesize(value) {
        this._pagesize = value;
    }

    handlePrevious(event) {

        if (this.page > 1) {
            this.page = this.page - 1;
        }
        this.iscallingback = event.detail;

    }

    handleNext(event) {

        if (this.page < this.totalPages) {
            this.page = this.page + 1;
        }
        this.iscallingback = event.detail;

    }

    handleFirst(event) {

        this.page = 1;
        this.iscallingback = event.detail;

    }

    handleLast(event) {

        this.page = this.totalPages;
        this.iscallingback = event.detail;

    }

    handleRecordsLoad(event) {

        this.page = event.detail.page;
        this.totalrecords = event.detail.recordsCount;
        this.pagesize = event.detail.pagesize;
        this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
        this.iscallingback = false;

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