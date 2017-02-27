var FileUpload = (function () {
    'use strict';

    return {
        setFields: function () {
            var inputs = document.querySelectorAll('input[type=file]');

            Array.prototype.forEach.call(inputs, function(input) {
                var label    = input.nextElementSibling,
                    labelVal = label.innerHTML;

                input.addEventListener('change', function(e) {
                    label.querySelector('span').innerHTML = e.target.value.split('\\').pop();
                });
            });
        }
    }
}());
