var Slider = (function () {
    'use strict';

    function setVal(val) {
        this.spanVal.text(val);
    }

    function drag(val) {
        setVal.call(this, val);

        this.input.val(val);

        FormEnabler.enable(this.sliderEl);
    }

    function defaultFor() {
        return this.input.val() || this.defaultVal * 100;
    }

    function showInput() {
        this.input.attr('type', 'text');
        this.input.focus();
        this.spanVal.hide();
    }

    function hideInput() {
        this.input.attr('type', 'hidden');
        this.input.off('change');
        this.spanVal.show();
    }

    function updateSlider(e) {
        this.slider.setValue($(e.target).val());
    }

    function addUpdateListener() {
        this.input.on('change', updateSlider.bind(this));
    }

    Slider.prototype = {
        create: function () {
            this.slider = new $.Quinn(this.sliderEl, {
                value: defaultFor.call(this),
                step:  0.01,
                setup: setVal.bind(this),
                drag:  drag.bind(this)
            });

            this.spanVal.on("click", showInput.bind(this));
            this.input.on('blur', hideInput.bind(this));
            this.input.on('focus', addUpdateListener.bind(this));

            return this.slider;
        }
    };

    function Slider(scope) {
        this.scope      = $(scope);
        this.sliderEl   = this.scope.find('.slider');
        this.spanVal    = this.scope.find('span.value');
        this.key        = this.sliderEl.data('key');
        this.input      = this.scope.find('input.' + this.key);
        this.defaultVal = this.input.data('default');
    }

    return Slider;
}());
