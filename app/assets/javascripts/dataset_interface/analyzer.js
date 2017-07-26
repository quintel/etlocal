DatasetInterface.Analyzer = (function () {
    'use strict';

    return {
        analyze: function () {
            var form = $("form.dataset_editor");

            $.ajax({
                url: form.data('calculateUrl'),
                type: "POST",
                success: function (data) {
                    console.log(data);
                }
            });
        }
    }
}());
