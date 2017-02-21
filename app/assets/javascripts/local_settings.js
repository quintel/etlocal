var LocalSettings = (function () {
    'use strict';

    function isSupportingLocalStorage() {
        try {
            return 'localStorage' in window && window.localStorage !== null;
        } catch (e) {
            return false;
        }
    }

    function write(value) {
        if (isSupportingLocalStorage() && value !== null) {
            window.localStorage.setItem(this.key, JSON.stringify(value));
        }
    }

    function read() {
        if (isSupportingLocalStorage()) {
            return JSON.parse(window.localStorage.getItem(this.key));
        }
    }

    LocalSettings.prototype = {
        set: function (key, value) {
            var settings = read.call(this);
            settings[key] = value;
            write.call(this, settings);
        },

        get: function (key) {
            return read.call(this)[key];
        },

        getAll: function () {
            return read.call(this);
        },

        remove: function (key) {
            var localValue = this.getAll();
            delete localValue[key];
            write.call(this, localValue);
        }
    };

    function LocalSettings(key) {
        if (key === undefined) {
            throw ("Dataset key should be defined!");
        }

        this.key = key;

        write.call(this, read.call(this) || {});
    }

    return LocalSettings;
}());
