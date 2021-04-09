$(document).on('turbolinks:load', function () {
    'use strict';

    FileUpload.setFields();
    Areas.init();
    LanguageChanger.init();
    Header.init();
    Introduction.init();

    $(window).on('scroll', function (s) {
        var isOver = ($(this).scrollTop() > $('body > .container').height());

        $('.content-map #map').toggleClass('wrapped', isOver);
    });

    // For first load or when routes are changed in browser url box.
    $(window).on('load', router);
    $(window).on('hashchange', router);
});

// Simple router, get the current URL and generate correct content
let router = (evt) => {
    const url = window.location.pathname || "/";
    resolveRoute(url);
};

// Check if we're dealing with a dataset request, if so, try to open dataset
let resolveRoute = (route) => {
    var splitRoute = route.split('/')
    if (splitRoute.length == 3 && splitRoute[1] == 'datasets'){
        openDataset(splitRoute[2])
    }
};

function openDataset(geoId){
    $.ajax({
        url: "/datasets/" + geoId + ".json",
        type: 'GET',
        dataType: 'json',
        success: function (data) {
            if (data) {
                DatasetInterface.open(data.id);
            } else if (console) {
                // open popup that says that the dataset is not available
                console.log("No dataset with " + geoId + " found");
            }
        },
        error: function (e) {
            // open popup that says that the dataset is not available
            alert(e);
        }
    });
}
