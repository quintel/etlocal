var Slider = (function () {
    'use strict';

    var ENTER_KEY = 13;

    function setValue(value) {
        this.input.val(value / 100.0);

        setVal.call(this, value);
    }

    // Update span text value next to the slider
    function setVal(value) {
        this.spanVal.text((Math.round(value * 100) / 100).toLocaleString(undefined));
    }

    // Callback for changing the slider
    function change(value) {
        setValue.call(this, value);

        DatasetInterface.ChangeTrigger.trigger(this.input);
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
                value:   this.input.val() * 100,
                step:    1,
                setup:   setVal.bind(this),
                drag:    setVal.bind(this),
                change:  change.bind(this),
                max:     100,
                disable: true
            });

            // Enable slider when a default value is already present from
            // previously edited values.
            if (this.isEnabled() && this.editable) {
                this.slider.enable();
            }

            this.spanVal.on("click", showInput.bind(this));
            this.input.on('blur', hideInput.bind(this));
            this.input.on('focus', addUpdateListener.bind(this));

            return this.slider;
        },

        isEnabled: function () {
            return this.input.val();
        },

        setDefaultValue: function (value) {
            // Enable slider from a default graph value, only do this
            // when there's no previously edited value present.
            if (!this.isEnabled()) {
                if (this.editable) {
                    this.slider.enable();
                }

                // Oddly specific: the last argument is a silent call so
                // no changes are being triggered (which is what we want
                // when setting the defaults).
                this.slider.setTentativeValue(value * 100.0, false, true);

                setValue.call(this, value * 100.0);
            }
        }
    };

    function Slider(scope) {
        this.scope      = $(scope);
        this.sliderEl   = this.scope.find('.slider');
        this.spanVal    = this.scope.find('span.val > span.display_value');
        this.key        = this.sliderEl.data('key');
        this.editable   = this.sliderEl.data('editable') === 1;
        this.flexible   = this.sliderEl.data('flexible') === 'flex';
        this.input      = this.scope.find('input.' + this.key);
    }

    return Slider;
}());
