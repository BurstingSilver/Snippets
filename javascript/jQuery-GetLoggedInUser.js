// jQuery passed in as $ to an Immediately Invoked Function Expression (IIFE)
(function ($) {
    $.ajax(gWebRoot + "/asicommon/services/Membership/MembershipWebService.asmx/GetUserName", {
        "method": "post",
    })
    .done(function(data) {
        var result = data.firstChild;
        if (result !== undefined && result.innerHTML != "") {
            var username = result.innerHTML;
            console.log("username: " + username);
            getUserId(username);
        }
    })
    .fail(function(data) {console.log(data);});

   function getUserId(username) {
        $.ajax(gWebRoot + "/api/CsWebUser?UserId=" + username, {
            "method": "get",
            "headers": { "RequestVerificationToken" : $("#__RequestVerificationToken").val()}
        })
        .done(function(data) {
            console.log("userId: " + data.Items[0].Identity.IdentityElements[0]);
        })
        .fail(function(data) {console.log(data);});
   }
})(jQuery);