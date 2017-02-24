// jQuery passed in as $ to an Immediately Invoked Function Expression (IIFE)
(function($){
    $.ajax({
        "method": "get",
        "url": gWebRoot + "/api/Country",
        "headers": { "RequestVerificationToken" : $("#__RequestVerificationToken").val()}
    })
    .done(function(data) {console.log(data);})
    .fail(function(data) {console.log(data);})
})(jQuery)