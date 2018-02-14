var CommitForm = (function () {
    'use strict';

    return {
        convertValues: function () {
            var data,
                value,
                converted;

            $(".attributes-changed .edit span.val").each(function () {
                data      = $(this).data();
                value     = parseFloat($(this).text());
                converted = new Quantity(value, data.to).to(data.from);

                $(this).text(converted.roundedValue);
            });
        }
    }
}());
