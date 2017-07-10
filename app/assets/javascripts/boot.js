$(document).on('turbolinks:load', function () {
    'use strict';

    FileUpload.setFields();
    Areas.init();

    $(window).on('scroll', function (s) {
        var isOver = ($(this).scrollTop() > $('body > .container').height());

        $('.content-map #map').toggleClass('wrapped', isOver);
    });
});

String.prototype.interpolate = function (opts) {
    var reg = /\$\{(.*?)\}/g,
        str = this,
        res;

    while (res = reg.exec(str)) {
        str = str.replace(res[0], opts[res[1]]);
    }
    return str;
};
