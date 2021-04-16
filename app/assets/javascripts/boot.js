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

    $(window).on('load', router);
    $(window).on('hashchange', router);
});

function router() {
    var route = window.location.pathname || '/';
    var splitRoute = route.split('/')
    if (splitRoute.length == 3 && splitRoute[1] == 'datasets'){
        var geoId = splitRoute[2]
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
}
