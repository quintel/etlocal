DatasetInterface.Analyzer = (function () {
    'use strict';

    function formAttributesToJSON(form) {
        var value,
            result = {},
            object = form.serializeObject();

        object.edits.dataset_edits_attributes.forEach(function (el) {
            if (/^has/.test(el.key)) {
                value = (el.value === '1');
            } else {
                value = parseFloat(el.value);
            }

            result[el.key] = value;
        });

        return JSON.stringify(result);
    }

    return {
        analyze: function () {
            var form = $("form.dataset_editor");

            $.ajax({
                url: form.data('calculateUrl'),
                type: "POST",
                data: {
                    previous: {},
                    edits: formAttributesToJSON(form)
                },
            });
        }
    }
}());
