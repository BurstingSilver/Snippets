// jQuery passed in as $ to an Immediately Invoked Function Expression (IIFE)
(function($){
    var schedulerPath = "Asi.Scheduler_Web";
    var schedulerUrl = "https://" + window.location.hostname + "/" + schedulerPath;
    var username = "MANAGER";
    var password = "password";
    $.ajax({
        method: "POST",
        url: schedulerUrl + "/token",
        data: "grant_type=password&username=" + username + "&password=" + password
    })
    .done(function(data) {
        
        $.ajax({
            method: "GET",
            url: schedulerUrl + "/api/Relationship/_metadata",
            headers:
            {
                "authorization": "Bearer " + data.access_token
            },
        })
        .done(function(data) {console.log(data);})
        .fail(function(data) {console.log(data);});
        
        $.ajax({
            method: "GET",
            url: schedulerUrl + "/api/Party",
            headers:
            {
                "authorization": "Bearer " + data.access_token
            },
        })
        .done(function(data) {console.log(data);})
        .fail(function(data) {console.log(data);});
     })
    .fail(function(data) {console.log(data);});
})(jQuery)
