export { navigateToRecordViewPageInNewTab, formatDatehelper }

function navigateToRecordViewPageInNewTab(recordId) {
    window.open('/' + recordId, '_blank');
}

function formatDatehelper(date) {

    var hours = date.getHours();
    var minutes = date.getMinutes();
    var ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours ? hours : 12;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    var strTime = hours + ':' + minutes + ' ' + ampm;
    return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;

}




