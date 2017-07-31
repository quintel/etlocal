var Slider = (function () {
    'use strict';

    var ENTER_KEY = 13;

    // Update span text value next to the slider
    function setVal(val) {
        this.spanVal.text(val);
    }

    // Callback for dragging the slider
    function drag(val) {
        setVal.call(this, val);

        this.input.val(val);
        DatasetInterface.ChangeTrigger.trigger(this.sliderEl);
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

        window.onkeydown = null;
    }

    function updateSlider(e) {
        this.slider.setValue($(e.target).val());
    }

    function updateWithEnter(e) {
        var key = e.keyCode ? e.keyCode : e.which;

        if (key === ENTER_KEY) {
            e.preventDefault();

            this.input.trigger('change');
            hideInput.call(this);
        }
    }

    function addUpdateListener() {
        this.input.on('change', updateSlider.bind(this));

        window.onkeydown = updateWithEnter.bind(this);
    }

    Slider.prototype = {
        create: function () {
            this.slider = new $.Quinn(this.sliderEl, {
                value:   this.input.val(),
                step:    0.01,
                setup:   setVal.bind(this),
                drag:    drag.bind(this),
                disable: true
            });

            // Enable slider when a default value is already present from
            // previously edited values.
            if (this.input.val()) {
                this.slider.enable();
            }

            this.spanVal.on("click", showInput.bind(this));
            this.input.on('blur', hideInput.bind(this));
            this.input.on('focus', addUpdateListener.bind(this));

            return this.slider;
        },

        setDefaultValue: function (value) {
            // Enable slider from a default graph value, only do this
            // when there's no previously edited value present.
            if (this.input.val() === "") {
                this.slider.enable();
                this.slider.setValue(value);
            }
        }
    };

    function Slider(scope) {
        this.scope      = $(scope);
        this.sliderEl   = this.scope.find('.slider');
        this.spanVal    = this.scope.find('span.value');
        this.key        = this.sliderEl.data('key');
        this.input      = this.scope.find('input.' + this.key);
    }

    return Slider;
}());
