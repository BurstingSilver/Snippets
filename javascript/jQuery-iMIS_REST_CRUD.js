// jQuery passed in as $ to an Immediately Invoked Function Expression (IIFE)
(function($){
    var userID = 18043;
    
    $.ajax({
        "method": "get",
        "url": gWebRoot + "/api/Activity?PartyID=" + userID,
        "headers": { "RequestVerificationToken" : $("#__RequestVerificationToken").val()}
    })
    .done(function(data) {
        var activity = data.Items.$values[0];
        var seqn = activity.Identity.IdentityElements.$values[0];
        var thruDateProp = $.grep(activity.Properties.$values, function(value, index) { return value.Name == "THRU_DATE" });

        var d = new Date();
        d.setMonth(d.getMonth() + 8)
        thruDateProp[0].Value = d;

        $.ajax({
            "method": "put",
            "url": gWebRoot + "/api/Activity/" + seqn,
            "contentType": "application/json",
            "headers": { "RequestVerificationToken" : $("#__RequestVerificationToken").val()},
            "data": JSON.stringify(activity)
        })
        .done(function(data) {console.log(data);})
        .fail(function(data) {console.log(data);});
    })
    .fail(function(data) {console.log(data);})
})(jQuery)