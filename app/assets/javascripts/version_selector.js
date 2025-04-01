var VersionSelector = (function () {
    'use strict';

    return {
        init: function () {
            $('.dropdown .version-select').on('click', function () {
                $(this).next().toggle();
            });
        }
    }
}());
