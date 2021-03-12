var LanguageChanger = (function () {
    'use strict';

    return {
        init: function () {
            $('.dropdown .lang-select').on('click', function (){
                $(this).next().toggle();
            });
        }
    }
}());
