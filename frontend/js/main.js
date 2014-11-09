angular.module("openDataApp", ['ui.bootstrap'])
.controller("openDataCtrl", ["$scope", "$http","$location","$filter", function ($scope, $http,$location,$filter) {

	$scope.radioModel = 'postcode';

	function openDataViewModel() {
		var self = this;

		self.title = "yayaya";
		self.postcode="ox145hw";
		self.constituency="";
		self.mpList=[];

		self.postcodeSearch = function(){

			str = self.postcode;
			str = str.replace(/\s+/g, '');

			var httpRequest =  $http({
				method: "GET",
				url: "http://lpanoview.lookfor.hk/hack/postcodeSearch?postcode="+str
			});
			httpRequest.success(function (data, status, headers, config) {
				console.log(data);
				self.constituency=data.administrative.constituency.title;
				console.log(data.administrative.constituency.title);
			});

		}



		self.mpSearch =function(){
			url="http://lda.data.parliament.uk/commonsmembers.json?_properties=familyName,fullName,constituency.label,birthDate,givenName,twitter,gender,party,homePage,constituency.prefLabel&_view=basic&_page=0&_pageSize=500";
			var httpRequest =  $http({
				method: "GET",
				url: url
			});
			httpRequest.success(function (data, status, headers, config) {
				self.mpList = data;
				console.log(data);

			});

		}

		self.mpFilter =function(){

			console.log(self.mpList.result.items[0].constituency.label._value);

			angular.forEach(self.mpList.result.items, function(value, key) {
				t =value.constituency.label


					try {

						if(value.constituency.label._value==self.constituency){
							console.log(value);
						}
					}
				catch(err) {

				}



			});
		}
	}

	angular.element(document).ready(function () {
		$scope.model = new openDataViewModel();
		$scope.model.mpSearch();
		$scope.model.postcodeSearch();
		console.log("test");
		$scope.$digest();
	});

}]);

