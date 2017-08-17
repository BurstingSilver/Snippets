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
        var userID = 123456;
        var entityTypeName = "My_MultiInstance_UDT"

        // POST (create)
        var item = {
            "$type": "Asi.Soa.Core.DataContracts.GenericEntityData, Asi.Contracts",
            "EntityTypeName": entityTypeName,
            "Properties": {
                "$type": "Asi.Soa.Core.DataContracts.GenericPropertyDataCollection, Asi.Contracts",
                "$values": [
                    {
                        "$type": "Asi.Soa.Core.DataContracts.GenericPropertyData, Asi.Contracts",
                        "Name": "PartyId",
                        "Value": userID
                    },
                    {
                        "$type": "Asi.Soa.Core.DataContracts.GenericPropertyData, Asi.Contracts",
                        "Name": "Info",
                        "Value": "Hello World!"
                    },
                    {
                        "$type": "Asi.Soa.Core.DataContracts.GenericPropertyData, Asi.Contracts",
                        "Name": "Life_Universe_Everything",
                        "Value": {
                            "$type": "System.Int32",
                            "$value": 42
                        }
                    }
                ]
            }
        };

        $.ajax({
            method: "POST",
            url: schedulerUrl + "/api/" + entityTypeName,
            contentType: "application/json",
            headers:
            {
                "authorization": "Bearer " + data.access_token
            },
            data: JSON.stringify(item)
        })
        .done(function(data) {console.log(data);})
        .fail(function(data) {console.log(data);});

        // GET (read) + PUT (update)
        $.ajax({
            method: "GET",
            url: schedulerUrl + "/api/" + entityTypeName + "?PartyID=" + userID,
            headers:
            {
                "authorization": "Bearer " + data.access_token
            }
        })
        .done(function(data) {
            console.log(data);
            
            var first = data.Items.$values[0];
            console.log(first);

            var seqn = first.Identity.IdentityElements.$values[1];
            var property = $.grep(first.Properties.$values, function(value, index) { return value.Name == "Info" });
            property[0].Value = "Hello updated World!";
    
            $.ajax({
                method: "PUT",
                url: schedulerUrl + "/api/" + entityTypeName + "/" + userID + "," + seqn,
                contentType: "application/json",
                headers:
                {
                    "authorization": "Bearer " + data.access_token
                },
                data: JSON.stringify(first)
            })
            .done(function(data) {console.log(data);})
            .fail(function(data) {console.log(data);});
        })
        .fail(function(data) {console.log(data);});
        })
    .fail(function(data) {console.log(data);});

    
})(jQuery)
