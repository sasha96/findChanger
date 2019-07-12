import { LightningElement, api, track } from 'lwc';
export default class FindChangerPagination extends LightningElement {

    @api opentab;
    @api totalrecords;
    @api currentpage;
    @api pagesize;

    get showFirstButton() {

        if (this.currentpage === 1) {
            return true;
        }
        return false;

    }

    get showLastButton() {

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