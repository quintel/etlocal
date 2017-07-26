$(document).on('turbolinks:load', function () {
    'use strict';

    FileUpload.setFields();
    Areas.init();

    $(window).on('scroll', function (s) {
        var isOver = ($(this).scrollTop() > $('body > .container').height());

        $('.content-map #map').toggleClass('wrapped', isOver);
    });
});
