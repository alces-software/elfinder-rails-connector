/*=============================================================================
 * Copyright (C) 2012 Stephen F Norledge & Alces Software Ltd.
 *
 * This file is part of elfinder-rails.
 *
 * Some portions of this file have been adapted from the elFinder
 * codebase and are Copyright (C) 2009-2011 Studio 42, licensed under
 * a 3-clause BSD license.  The portions are marked inline below.
 * Please see LICENSE.txt for further details.
 *
 * Some rights reserved, see LICENSE.txt.
 *===========================================================================*/
(function($) {
    $.fn._elfinder = $.fn.elfinder;

    $.fn.elfinder = function(o) {
	var r = this._elfinder(o);
	if ( typeof(o) === 'object' ) {
	    // if we were called with an object, we're constructing
	    $(r).getElFinder().patch();
	}
	return r;
    }

    var patch = function() {
	if ( this._patched ) {
	    return;
	}
	this._patched = true;
	var self = this;
	$.each(this._patches,function(i, val) {
	    val.call(self);
	});
    }

    /* As we've forcibly removed bind('rm') from the elFinder.js source,
     * we add it back in here, but with modifications. */
    var patches = [ function() {
	/* The following section of code has been adapted from elFinder.js */
	var beeper = $(document.createElement('audio')).hide().appendTo('body')[0];

	this.bind('rm', function(e) {
            var play = beeper.canPlayType && beeper.canPlayType('audio/wav; codecs="1"');
	    /* mjt - pull sounds from options */
            var sound = self.options.sounds && self.options.sounds.rm;
            play && play != '' && play != 'no' && sound && $(beeper).html('<source src="' + sound + '" type="audio/wav">')[0].play()
	})
	/* End of adapted code. */
    } ];

    elFinder.prototype._patches = patches;
    elFinder.prototype.patch = patch;
})(jQuery);
