var Quantity = (function() {
    'use strict';

    var i,
        j,
        len,
        len1,
        base,
        power,
        conv,
        split,
        unit,
        otherUnit,
        compiledUnits = {},
        compiledConversions = {
            Wh_J: 3600.0
        },
        BASE_UNITS = [
            { name: 'J' },
            { name: 'm' },
            { name: 'm3' },
            { name: 'W' },
            { name: 'Wh' }
        ],
        POWERS = [
            { prefix: 'Y', multiple: 1e24 },
            { prefix: 'Z', multiple: 1e21 },
            { prefix: 'E', multiple: 1e18 },
            { prefix: 'P', multiple: 1e15 },
            { prefix: 'T', multiple: 1e12 },
            { prefix: 'G', multiple: 1e9  },
            { prefix: 'M', multiple: 1e6  },
            { prefix: 'k', multiple: 1e3  },
            { prefix: '',  multiple: 1    }
        ];

    for (conv in compiledConversions) {
        split = conv.split('_');

        compiledConversions[split[1] + '_' + split[0]] = (1 / compiledConversions[conv]);
    }

    // Initialize compiled units
    for (i = 0, len = BASE_UNITS.length; i < len; i++) {
        base = BASE_UNITS[i];
        for (j = 0, len1 = POWERS.length; j < len1; j++) {
            power = POWERS[j];
            name = "" + power.prefix + base.name;
            compiledUnits[name] = {
                name: name,
                base: base,
                power: power
            };
        }
    }

    function isSupported(name) {
        return compiledUnits.hasOwnProperty(name);
    }

    function getUnit(name) {
        if (isSupported(name)) {
            return compiledUnits[name];
        } else {
            throw "Unknown unit: " + name;
        }
    }

    function getConversion(unit, otherUnit) {
        var conversionKey = unit.base.name + '_' + otherUnit.base.name;

        if (compiledConversions.hasOwnProperty(conversionKey)) {
            return compiledConversions[conversionKey];
        } else if (unit.base.name === otherUnit.base.name) {
            return 1;
        } else {
            throw "Unknown conversion";
        }
    }

    Quantity.prototype = {
        to: function (otherName) {
            var newValue, otherUnit;

            otherUnit = getUnit(otherName);
            newValue = this.value *
                (this.unit.power.multiple / otherUnit.power.multiple) *
                getConversion(this.unit, otherUnit);

            return new Quantity(newValue, otherUnit.name);
        }
    };

    function Quantity (value1, unitName) {
        this.value        = value1;
        this.roundedValue = Math.round(value1 * 100) / 100;
        this.unit         = getUnit(unitName);
    }

    return Quantity;
})();
