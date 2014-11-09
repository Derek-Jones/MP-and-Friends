angular.module("openDataApp", ['ui.bootstrap'])
    .controller("openDataCtrl", ["$scope", "$http", "$location", "$filter", function ($scope, $http, $location, $filter) {

        $scope.radioModel = 'postcode';

        function openDataViewModel() {
            var self = this;

            self.postcode = "ox145hw";
            self.constituency = "";
            self.mpList = [];
           self.mpInfo = null;
            self.birthDate = "";
            self.constituency = "";
            self.fullName = "";
            self.familyName = "";
            self.givenName = "";
            self.homePage = "";
            self.party = "";
            self.twitter = "";
            self.autoCompleteFullName = "";
            self.isPostcode=true;


            self.searchInput = "";

            self.postcodeSearch = function () {

                str = self.postcode;
                str = str.replace(/\s+/g, '');

                var httpRequest = $http({
                    method: "GET",
                    url: "http://lpanoview.lookfor.hk/hack/postcodeSearch?postcode=" + str
                });
                httpRequest.success(function (data, status, headers, config) {

                    self.constituency = data.administrative.constituency.title;
                    console.log("self.constituency: " + self.constituency);
                    self.mpFilter();

                });

            }
            self.mpEnter = function () {
                self.isPostcode = false;
            }

            self.postcodeEnter = function () {
                self.isPostcode = true;
            }

            self.loadGraph = function () {
                d3LoadData("data/mps.json");
            }

            self.searchMP = function () {

                alert(self.autoCompleteFullName.fullName);
            }
            self.search = function () {

                if ($scope.radioModel == 'postcode') {
                    console.log("postcode");
                    self.postcode = self.searchInput;
                    self.postcodeSearch();

                } else {
                    console.log("mp");
                    self.fullName = self.autoCompleteFullName.fullName;
                    self.mpFullNameFilter();

                }
            }

            self.mpFullNameFilter = function(){
                //	console.log(self.mpList.result.items[0].constituency.label._value);
                console.log(self.mpList.result.items.length);
                angular.forEach(self.mpList.result.items, function (value, key) {


                    try {

                        if (value.fullName.trim() == self.fullName.trim()) {
                            //console.log(value);
                            self.mpInfo = value;
                            //self.searchInput = value.fullName;


                            self.birthDate = value.birthDate._value;
                            self.constituency = value.constituency.label._value;
                            self.fullName = value.fullName;
                            self.familyName = value.familyName;
                            self.givenName = value.givenName;
                            self.homePage = value.homePage;
                            self.party = value.party;
                            self.twitter = value.twitter;

                            console.log( self);
                            self.loadGraph();

                        }
                    }
                    catch (err) {

                    }
                });
            }

            self.mpSearch = function () {
                url = "http://lda.data.parliament.uk/commonsmembers.json?_properties=familyName,fullName,constituency.label,birthDate,givenName,twitter,gender,party,homePage,constituency.prefLabel&_view=basic&_page=0&_pageSize=500";
                url = "data/commonsmembers.json";
                var httpRequest = $http({
                    method: "GET",
                    url: url
                });
                httpRequest.success(function (data, status, headers, config) {
                    self.mpList = data;
                    //	console.log(data);

                });

            }

            self.mpFilter = function () {

                //	console.log(self.mpList.result.items[0].constituency.label._value);
                console.log(self.mpList.result.items.length);
                angular.forEach(self.mpList.result.items, function (value, key) {


                    try {

                        if (value.constituency.label._value.trim() == self.constituency.trim()) {
                            //console.log(value);
                            self.mpInfo = value;
                            //self.searchInput = value.fullName;


                            self.birthDate = value.birthDate._value;
                            self.constituency = value.constituency.label._value;
                            self.fullName = value.fullName;
                            self.familyName = value.familyName;
                            self.givenName = value.givenName;
                            self.homePage = value.homePage;
                            self.party = value.party;
                            self.twitter = value.twitter;

                            console.log( self);
                            self.loadGraph();

                        }
                    }
                    catch (err) {

                    }


                });
            }
        }

        angular.element(document).ready(function () {
            $scope.model = new openDataViewModel();
            $scope.model.mpSearch();
            //$scope.model.postcodeSearch();
            //	console.log("test");
            $scope.$digest();
        });

    }]);

