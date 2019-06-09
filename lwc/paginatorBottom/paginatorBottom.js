import { LightningElement, api } from 'lwc';
export default class PaginatorBottom extends LightningElement {

    @api totalrecords;
    @api currentpage;
    @api pagesize;

    lastpage = false;
    firstpage = false;

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
        this.dispatchEvent(new CustomEvent('previous'));
        this.moveUpTheTopPage();
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
        this.moveUpTheTopPage();
    }

    handleFirst() {
        this.dispatchEvent(new CustomEvent('first'));
        this.moveUpTheTopPage();
    }

    handleLast() {
        this.dispatchEvent(new CustomEvent('last'));
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