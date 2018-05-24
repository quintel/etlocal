var LanguageChanger = (function () {
    'use strict';

    return {
        init: function () {
            $('select#locale').off('change').on('change', function (){
                $.ajax({
                    url: '/set_locale',
                    method: 'PUT',
                    data: {
                        locale: $(this).val()
                    },
                    success: function () {
                        window.location.reload();
                    }
                });
            });
        }
    }
}());
