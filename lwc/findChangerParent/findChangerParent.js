import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FindChangerParent extends NavigationMixin(LightningElement) {

    // @track opentab = 1;

    @api page = 1;
    @api totalrecords;
    @api _pagesize = 10;

    @api iscallingback = false;

    /*@api pagef = 1;
    @api totalrecordsf;
    @api _pagesizef = 10;

    @api paget = 1;
    @api totalrecordst;
    @api _pagesizet = 10;*/

    handleActive(event) {

        var numberOfTab = event.target.value;
        /*this.opentab = 0;
        if (numberOfTab === 'tab-5') {
            this.opentab = 3;
        } else if (numberOfTab === 'tab-4') {
            this.opentab = 2;
        } else if (numberOfTab === 'tab-3') {
            this.opentab = 1;
        }*/

    }

    /* get pagesizef() {
         return this._pagesizef;
     }
     set pagesizef(value) {
         this._pagesizef = value;
     }
 
     get pagesizet() {
         return this._pagesizet;
     }
     set pagesizet(value) {
         this._pagesizet = value;
     }*/


    get pagesize() {
        return this._pagesize;
    }
    set pagesize(value) {
        this._pagesize = value;
    }

    handlePrevious(event) {
        /* if (this.opentab === 1) {
             if (this.pagef > 1) {
                 this.pagef = this.pagef - 1;
             }
         } else if (this.opentab === 3) {
             if (this.paget > 1) {
                 this.paget = this.paget - 1;
             }
         }*/
        if (this.page > 1) {
            this.page = this.page - 1;
        }
        this.iscallingback = event.detail;
    }
    handleNext(event) {
        /*if (this.opentab === 1) {
            if (this.pagef < this.totalPagesf) {
                this.pagef = this.pagef + 1;
            }
        } else if (this.opentab === 3) {
            if (this.paget < this.totalPagest) {
                this.paget = this.paget + 1;
            }
        }*/
        if (this.page < this.totalPages) {
            this.page = this.page + 1;
        }
        this.iscallingback = event.detail;
    }
    handleFirst(event) {
        /*if (this.opentab === 1) {
            this.pagef = 1;
        } else if (this.opentab === 3) {
            this.paget = 1;
        }*/
        this.page = 1;
        this.iscallingback = event.detail;
    }
    handleLast(event) {
        /*  if (this.opentab === 1) {
              this.pagef = this.totalPagesf;
          } else if (this.opentab === 3) {
              this.paget = this.totalPagest;
          }*/
        this.page = this.totalPages;
        this.iscallingback = event.detail;
    }
    handleRecordsLoad(event) {

        // if (this.opentab === 1) {
        //     this.pagef = event.detail.page;
        //     this.totalrecordsf = event.detail.recordsCount;
        //     this.pagesizef = event.detail.pagesize;
        //     this.totalPagesf = Math.ceil(this.totalrecordsf / this.pagesizef);
        // } else if (this.opentab === 3) {
        //     this.paget = event.detail.page;
        //     this.totalrecordst = event.detail.recordsCount;
        //     this.pagesizet = event.detail.pagesize;
        //     this.totalPagest = Math.ceil(this.totalrecordst / this.pagesizet);
        // }

        this.page = event.detail.page;
        this.totalrecords = event.detail.recordsCount;
        this.pagesize = event.detail.pagesize;
        this.totalPages = Math.ceil(this.totalrecords / this.pagesize);
        this.iscallingback = false;
    }

    handlePageChange(event) {
        /* if (this.opentab === 1) {
             this.pagef = event.detail;
         } else if (this.opentab === 3) {
             this.paget = event.detail;
         }*/
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