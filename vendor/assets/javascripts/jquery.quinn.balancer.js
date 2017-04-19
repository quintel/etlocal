// vim: set sw=4 ts=4 et:

(function ( $, _ ) {
    'use strict';

    /**
     * Creates a balancer instance.
     *
     * Terminology:
     *
     *   master:
     *     When the user begins to alter a slider, this slider is designated
     *     the master. A slider is only a master while the user is making a
     *     change.
     *
     *   subordinates:
     *     When the user is altering a slider value, all of the other sliders,
     *     minus those which are disabled, are considered subordinates. The
     *     subordinates are the sliders whose values are changes to ensure
     *     that the group remains balanced.
     */
    function Balancer( options ) {
        _.bindAll(this, 'start', 'drag', 'change', 'abort');

        this.options = _.extend( {}, {
            target: 100, algo: 'least_recently_used'
        }, options );

        if ( Balancer.algo.hasOwnProperty( this.options.algo ) ) {
            this.algo = Balancer.algo[ this.options.algo ];
        } else {
            throw "No such balancing algorithm: " + this.options.algo;
        }

        this.target       = this.options.target;
        this.precision    = 1;
        this.callbacks    = {};
        this.members      = [];
        this.subordinates = [];
        this.order        = [];
        this.masterId     = null;
        this.oValues      = null;
        this.disabled     = false;
    }

    // Add support for binding and triggering events on the balancer.
    Balancer.prototype.on      = $.Quinn.prototype.on;
    Balancer.prototype.trigger = $.Quinn.prototype.trigger;

    /**
     * Add a Quinn instance to be balanced.
     *
     * Returns self.
     */
    Balancer.prototype.add = function( quinn ) {
        quinn.balanceId = _.uniqueId( 'qbalance.' );

        quinn.on( 'begin',  this.start );
        quinn.on( 'drag',   this.drag );
        quinn.on( 'change', this.change );
        quinn.on( 'abort',  this.abort );

        this.members.push( quinn );
        this.order.push( quinn.balanceId );

        this.precision = _.max( _.map( this.members, function ( quinn ) {
            var split = ( '' + quinn.model.step ).split( '.' );
            return ( split[1] && split[1].length + 1 ) || 1;
        } ) );

        return this;
    };

    /**
     * Triggered in the drag callback; performs balancing of the subordinate
     * sliders in the balancer.
     */
    Balancer.prototype.doBalance = function( newValue, quinn ) {
        var amountChanged = newValue - this.oValues.value( quinn ),
            valuesBeforeBalancing, flex;

        // Return quickly if the amount changed is larger than the balancer
        // allows, as the change is impossible.
        if ( Math.abs( amountChanged ) > this.max ) {
            return false;
        }

        // Return quickly if none of the subordinate sliders can be moved.
        if ( this.subordinates.length === 0 ) {
            return false;
        }

        valuesBeforeBalancing = new OriginalValues( this.subordinates );

        // Flex is the amount of "value" which needs to be adjusted for. For
        // example:
        //
        //   balancer target: 100
        //   slider 1 value:    0
        //   slider 2 value:  100
        //
        // If slider 1 is moved to 25, the flex is -25 since, in order to
        // balance the group, we need to subtract 25 from the subordinates.

        flex = this.oValues.sumOf( this.subordinates ) + newValue;
        flex = this.snap( this.target - flex );

        if ( this.algo.call( this, flex ) !== 0 ) {
            valuesBeforeBalancing.revert();
            return false;
        }
    };

    // ### Events

    /**
     * Triggered when a slider starts to be moved by a user. The first slider
     * to be moved will be considered the "master"; the others will be
     * automatically adjusted to ensure that sum still balances.
     */
    Balancer.prototype.start = function( value, quinn ) {
        if ( this.disabled ) {
            return true;
        }

        if ( this.masterId === null ) {
            this.masterId     = quinn.balanceId;
            this.subordinates = this.getSubordinates();
            this.oValues      = new OriginalValues( this.members );

            this.callSubordinates( 'start' );

            this.trigger( 'start' );
        }
    };

    /**
     * Triggered when a slider belonging to this balancer is moved. We only
     * care about movement of the master.
     */
    Balancer.prototype.drag = function( value, quinn ) {
        if ( this.isMaster( quinn ) ) {
            if ( this.doBalance( value, quinn ) === false ) {
                // Can't do the balance, so prevent the slider movement.
                return false;
            }

            this.trigger( 'change' );
        }
    };

    /**
     * Triggered when the user has finished moving the master slider.
     */
    Balancer.prototype.change = function( value, quinn ) {
        if ( this.isMaster( quinn ) ) {
            this.sliderUsed( quinn );
            this.finish( 'resolve' );
            this.trigger( 'change' );
        }
    };

    /**
     * Triggered when the the master slider aborts the slider movement (e.g.
     * the slider value is reset back to it's original.
     */
    Balancer.prototype.abort = function( value, quinn ) {
        if ( this.isMaster( quinn ) ) {
            this.finish( 'reject' );
            this.trigger( 'abort' );
        }
    };

    // ### Internal Methods

    /**
     * Called as the user begins moving a slider. Returns all of the other
     * sliders in the balancer, minus those which are disabled.
     */
    Balancer.prototype.getSubordinates = function() {
        var self = this, subs;

        subs = _.select( this.members, function( quinn ) {
            return ! self.isMaster( quinn ) && ! quinn.disabled;
        } );

        if ( this.members.length < 2 ) {
            return subs;
        }

        // The subordinates are now re-ordererd so that the most recently used
        // sliders are at the end of the array so that these sliders are
        // balanced last (preferring to preserve values the user has set).
        return _.sortBy( subs, function( quinn ) {
            return _.indexOf( self.order, quinn.balanceId );
        } );
    };

    /**
     * Finishes editing slider values by resetting this.masterId and
     * this.subordinates, and calling "method" on the subordinates.
     */
    Balancer.prototype.finish = function( method ) {
        this.callSubordinates( method );

        this.masterId     = null;
        this.subordinates = null;
        this.oValues      = null;
    };

    /**
     * Runs a method on all the subordinates.
     */
    Balancer.prototype.callSubordinates = function( method ) {
        var length = this.subordinates.length, i;

        for ( i = 0; i < length; i++ ) {
            this.subordinates[i][method]();
        }
    };

    /**
     * Given a float, "snaps" it to match the precision (i.e. if the smallest
     * step value of any of the balanced sliders is 0.1, it will round the
     * number to the nearest 0.1). Used heavily in doBalance to account for the
     * _vast_ number of floating point errors which occur when a group contains
     * three or more sliders.
     */
    Balancer.prototype.snap = function ( value ) {
        var pow = Math.pow( 10, this.precision );
        return Math.round( value * pow ) / pow;
    };

    /**
     * Returns if the given Quinn instance is the current master slider.
     */
    Balancer.prototype.isMaster = function ( quinn ) {
        return this.masterId !== null &&
               this.masterId === quinn.balanceId;
    };

    /**
     * Marks a slider as used, pushing it to the back of the order array. This
     * means that doBalance will try to balance the unused sliders first.
     */
    Balancer.prototype.sliderUsed = function( quinn ) {
        if ( this.members.length <= 2 ) {
            return true;
        }

        this.order = _.without( this.order, quinn.balanceId );
        this.order.push( quinn.balanceId );
    };

    // Balancing Algorithms --------------------------------------------------

    /**
     * Holds functions for different balancers (least-recently-used, fair,
     * etc).
     */
    Balancer.algo = {};

    /**
     * The least-recently-used balancer seeks to assign the full flex amount
     * to one slider at a time. When this isn't possible, it trys to assign
     * the remaining amount to the next slider, and so on... It will always
     * assign to sliders which the user has not modified when possible, thus
     * preserving values the user has chosen.
     */
    Balancer.algo.least_recently_used = function ( flex ) {
        var length = this.subordinates.length, i, slider, prevValue;

        for ( i = 0; i < length; i++ ) {
            // The balancer seeks to assign the full flex amount to one
            // slider; if this can't be done, it moves on to th enext slider,
            // and keeps going until either all the flex has been assigned, or
            // we run out of sliders.

            slider    = this.subordinates[i];
            prevValue = this.oValues.value( slider );

            slider.setTentativeValue( this.snap( prevValue + flex ), false );

            // Reduce the flex by the amount by which the slider was changed,
            // ready for the next slider.

            flex = this.snap( flex - ( slider.model.value - prevValue ) );
        }

        return flex;
    };

    /**
     * A balancing algorithm which seeks to assign the flex amount as fairly
     * as possible between all of the subordinates.
     */
    Balancer.algo.fair = function( flex ) {
        var iteration = 0,
            sliders   = this.subordinates,
            length    = sliders.length,

            nextIterationSliders, i,                     // while loop
            flexPerSlider, slider, prevValue, prevFlex;  // for loop

        while( 20 >= iteration++ ) {
            nextIterationSliders = [];

            for( i = 0; i < length; i++ ) {
                // The amount of flex given to each slider. Calculated each
                // time we blanace a slider since the previous one may have
                // used up all the available flex.
                flexPerSlider = flex / ( length - i );

                slider    = sliders[i];
                prevValue = slider.model.value;

                if ( iteration === 1 ) {
                    prevValue = this.oValues.value( slider );
                }

                slider.setTentativeValue( prevValue + flexPerSlider, false );

                // Reduce the flex by the amount by which the slider was
                // changed, ready for subsequent iterations.
                flex -= ( slider.model.value - prevValue );

                // Finally, if this slider can still be moved further, it may
                // be used again in the next iteration.
                if ( canMove( slider, flex ) ) {
                    nextIterationSliders.push( slider );
                }
            }

            sliders = nextIterationSliders;
            length  = sliders.length;

            // We can't go any further if the flex is 0, or if the flex value
            // hasn't changed in this iteration.
            if ( flex === 0 || prevFlex === flex || length === 0 ) {
                break;
            }

            prevFlex = flex;
        }

        return flex;
    };

    // OriginalValues --------------------------------------------------------

    /**
     * Given an array of Quinn instances, Originalvalues keeps track of the
     * value of each slider at the time the OriginalValues instance was
     * created.
     */
    function OriginalValues( quinns ) {
        var i;

        this.length  = quinns.length;
        this.members = quinns;
        this.values  = {};

        for ( i = 0; i < this.length; i++ ) {
            this.values[ quinns[i].balanceId ] = quinns[i].model.value;
        }
    }

    /**
     * Given a Quinn instance, returns the value of that instance at the time
     * the OriginalValues was created.
     */
    OriginalValues.prototype.value = function( quinn ) {
        return this.values[ quinn.balanceId ];
    };

    /**
     * Given an array of Quinns, returns the sum of their values at the time
     * the OriginalValues was initialized.
     */
    OriginalValues.prototype.sumOf = function( sliders ) {
        var length = sliders.length, sum = 0, i;

        for ( i = 0; i < length; i++ ) {
            sum += this.value( sliders[i] );
        }

        return sum;
    };

    /**
     * Reverts the Quinn instances back to their original values.
     */
    OriginalValues.prototype.revert = function() {
        var i, quinn;

        for ( i = 0; i < this.length; i++ ) {
            quinn = this.members[i];
            quinn.setTentativeValue( this.values[ quinn.balanceId ] );
        }
    };

    // Helpers ---------------------------------------------------------------

    /**
     * Given a collection of sliders, returns the sum of all their deltas
     * (i.e. determine the difference between each of their minimum and
     * maximum acceptable values, and sum them all together).
     */
    function cumulativeDeltas( sliders ) {
        var sum = 0, length = sliders.length, i;

        for( i = 0; i < length; i++ ) {
            sum += ( sliders[i].model.max - sliders[i].model.min );
        }

        return sum;
    }

    /**
     * Given a flex amount, determines if the given slider may be moved in the
     * direction of that flex.
     */
    function canMove( slider, flex ) {
        return ( flex < 0 && slider.model.value > slider.model.min ) ||
            ( flex > 0 && slider.model.value < slider.model.max );
    }

    // -----------------------------------------------------------------------

    // Expose the balancer constructor as $.Quinn.Balancer.
    $.Quinn.Balancer = Balancer;

})( jQuery, _ );
