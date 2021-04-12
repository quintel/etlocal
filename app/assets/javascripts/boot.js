$(document).on('turbolinks:load', function () {
    'use strict';

    FileUpload.setFields();
    Areas.init();
    LanguageChanger.init();
    Header.init();

    $(window).on('scroll', function (s) {
        var isOver = ($(this).scrollTop() > $('body > .container').height());

        $('.content-map #map').toggleClass('wrapped', isOver);
    });

    $(window).on('load', router);
    $(window).on('hashchange', router);
});

// Simple router, get the current URL and generate correct content
let router = (_) => {
    const url = window.location.pathname || "/";
    generateContent(url);
};

// Check if we're dealing with a dataset request, if so, try to open dataset
function generateContent(route) {
    var splitRoute = route.split('/')
    if (splitRoute.length == 3 && splitRoute[1] == 'datasets'){
        openDataset(splitRoute[2])
    }
};

function openDataset(geoId) {
    $.ajax({
        url: "/datasets/" + geoId + ".json",
        type: 'GET',
        dataType: 'json',
        success: function (data) {
            if (data) {
                DatasetInterface.open(data.id);
            } else {
                DatasetNotFound.open(geoId);
            }
        },
        error: function (_) {
            DatasetNotFound.open(geoId);
        }
    });
}
