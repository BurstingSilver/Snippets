//Here we're making a call to an IQA called QueryMembers
//Instead of using RequestVerificationToken method, we use OAuth to call the sheduler
//Can be used in cases when the user is not logged in

var tokenPostBody = "grant_type=password&username=MANAGER&password=PASSWORD";

return $http.post("https://" + window.location.hostname + "/asi.scheduler_imis/token", tokenPostBody, {}).then(function (response)
{
	window.asi_token = response.data.access_token;

	return $http(
	{
		method: 'GET',
		url: "https://" + window.location.hostname + "/asi.scheduler_imis/api/IQA?QueryName=%24%2FBSI_Case_Mgmt%2FOnlineSubmission%2FQueryMembers&Parameter=" + query,
		headers:
		{
			"authorization": "Bearer " + window.asi_token
		},
	})
	.then(function successCallback(response)
	{
		//do stuff heere
		console.log("success");
		console.log(response);

		var records = response.data.Items.$values;
	},
	function errorCallback(response)
	{
		// called asynchronously if an error occurs
		// or server returns response with an error status.
	});
});
