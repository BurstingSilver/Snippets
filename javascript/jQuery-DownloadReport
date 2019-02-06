/**
 * This can be used to download reports from iMIS
 * Note* The page containing the report must have the export as PDF option enabled
 * 
 * @param url Url of the page containing the report to download
 */
function downloadReport(url: string) {    
    if (document.getElementById(url)) { // Check if repoort is already loaded
        const iframe = document.getElementById(url);
        const element = iframe.contentWindow.document.querySelectorAll("[title='Export to PDF']")[0];

        element.click();
    } else { // If does not exist append the report to the page, note this is hidden so the user will not see it
        jQuery("body").append("<iframe src='" + url + "' width='100%' height='100%' id='" + url + "' style='position: absolute; display: none;'></iframe>");

        document.getElementById(url).addEventListener("load", function () {
            const iframe = document.getElementById(url) as any;
            const element = iframe.contentWindow.document.querySelectorAll("[title='Export to PDF']")[0];

            element.click();
        }); 
    }
}
