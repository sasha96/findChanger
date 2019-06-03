import { LightningElement, api } from 'lwc';
export default class PaginatorBottom extends LightningElement {
    // Api considered as a reactive public property.  
    @api totalrecords;
    @api currentpage;
    @api pagesize;
    // Following are the private properties to a class.  
    lastpage = false;
    firstpage = false;
    // getter  
    get showFirstButton() {
        if (this.currentpage === 1) {
            return true;
        }
        return false;
    }
    // getter  
    get showLastButton() {
        debugger;
        if (this.totalrecords === 0) {
            return true;
        } else if (Math.ceil(this.totalrecords / this.pagesize) === this.currentpage) {
            return true;
        }
        return false;
    }
    //Fire events based on the button actions  
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