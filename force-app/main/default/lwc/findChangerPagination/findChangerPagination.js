import { LightningElement, api, track } from 'lwc';
export default class FindChangerPagination extends LightningElement {

    @api opentab;

    @api totalrecords;
    @api currentpage;
    @api pagesize;
    /*
        @api totalrecordsf;
        @api currentpagef;
        @api pagesizef;
    
        @api totalrecordst;
        @api currentpaget;
        @api pagesizet;*/

    get showFirstButton() {
        /* if (this.opentab === 1) {
             if (this.currentpagef === 1) {
                 return true;
             }
             return false;
         } else if (this.opentab === 3) {
             if (this.currentpaget === 1) {
                 return true;
             }
             return false;
         }*/
        if (this.currentpage === 1) {
            return true;
        }
        return false;
    }

    get showLastButton() {
        /*  if (this.opentab === 1) {
              if (this.totalrecordsf === 0) {
                  return true;
              } else if (Math.ceil(this.totalrecordsf / this.pagesizef) === this.currentpagef) {
                  return true;
              }
              return false;
          } else if (this.opentab === 3) {
              if (this.totalrecordst === 0) {
                  return true;
              } else if (Math.ceil(this.totalrecordst / this.pagesizet) === this.currentpaget) {
                  return true;
              }
              return false;
          }*/

        if (this.totalrecords === 0) {
            return true;
        } else if (Math.ceil(this.totalrecords / this.pagesize) === this.currentpage) {
            return true;
        }
        return false;
    }

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous', { detail: false }));
        this.moveUpTheTopPage();
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next', { detail: false }));
        this.moveUpTheTopPage();
    }

    handleFirst() {
        this.dispatchEvent(new CustomEvent('first', { detail: false }));
        this.moveUpTheTopPage();
    }

    handleLast() {
        this.dispatchEvent(new CustomEvent('last', { detail: false }));
        this.moveUpTheTopPage();
    }

    moveUpTheTopPage() {
        window.scrollTo({
            top: 0,
            left: 0,
            behavior: 'smooth'
        });
    }
}