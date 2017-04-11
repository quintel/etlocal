var DatasetInterface = (function () {
    'use strict';

    return {
        enable: function () {
            var scope = $("form#new_edits");

            $("div.input span.val input[type='text']").on("change", function () {
                $(this).addClass("changed");

                scope.find("input[type='submit']").prop('disabled', false);
            });
        }
    }
}());
