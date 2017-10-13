var eventId = "SCC17ATT";
var eventRecordCount = 0;
var registrantIds = "";

// Retrieves all cart objects, and extracts the iMIS ids that have a pending registration for event ID matching the eventId variable
// Runs recursively with 500 records at a time due to the default limit of 500 results
(function($){
	console.log("Starting Processing");
	ProcessData(500, 0);
	

	function ProcessData(limit, offset){
		$.ajax({
		"method": "get",
		"url": gWebRoot + "/api/Cart?Limit=" + limit + "&offset=" + offset,
		"headers": { "RequestVerificationToken" : $("#__RequestVerificationToken").val()}
		})
		.done(function(data) {
		var cartItems = data.Items.$values;
		var cartCount = Object.keys(data.Items.$values).length;
		if (cartCount > 0)
		{
			ProcessData(limit, offset + limit, $);
		} else {
			console.log("Finished Processing");
			console.log("Found " + eventRecordCount + " records that registered for event " + eventId);
			console.log("Registrant Ids list: " + registrantIds);
		}

		ProcessResults(data);
		})
		.fail(function(data) {console.log(data);})
	}

	function ProcessResults(data){
		//var userID = 241658;
		var cartItems = data.Items.$values;
		var cartCount = Object.keys(data.Items.$values).length;
	//    	console.log("Returned " + cartCount + " records from Cart");

		for (j=0;j<=cartCount;j++){
		if (data.Items.$values[j] != null){
			var orderLines = data.Items.$values[j].ComboOrder.Order.Lines;
			var imisId = data.Items.$values[j].UserId;
			var lineCount = Object.keys(orderLines.$values).length;
		//        console.log("line count: " + lineCount + " imisid: " + imisId);

			for (i=0;i<=lineCount;i++)
			{
			var orderLine = orderLines.$values[i];
			if (orderLine != null){
	//                    	console.log("Event id: " + orderLine.Event.EventId);
				if (eventId == orderLine.Event.EventId){
				//console.log("ID: " + imisId);
				if (registrantIds == "")
					registrantIds = '"' + imisId + '"';
				else
					registrantIds += ',"' + imisId + '"';

				eventRecordCount++;
				break;
				}
			}
			}
		}
		}
	}
})(jQuery)

