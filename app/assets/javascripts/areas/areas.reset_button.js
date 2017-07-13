Areas.ResetButton = (function () {
    'use strict';

    function resetPosition() {
        this.view.animate({
            center: ol.proj.fromLonLat(this.center),
            zoom: this.zoom,
            duration: 2000
        });
    }

    var ResetButton = function (opt_options) {
        var options = opt_options || {},
            button  = document.createElement('button'),
            element = document.createElement("div");

        button.innerHTML = 'R';
        button.addEventListener('click', resetPosition.bind(options.scope), false);

        element.className = "rotate-north ol-unselectable ol-control";
        element.appendChild(button);

        ol.control.Control.call(this, {
            element: element,
            target: options.target
        });
    };

    return ResetButton;
}());
