memoize = require 'memoizee'

module.exports = (fn, opts = {}) ->
	# Default the length option to that of the true fn,
	# as memoizee won't be able to generate a sensible default
	# (due to our wrapper fn for promises)
	opts.length ?= fn.length
	return memoizedFn = memoize(
		# We put the catch/delete inside the memoization so that we don't add catch clauses
		# to an already memoized call - ie the need for deletion is also memoized
		(args...) ->
			fn(args...)
			.then null, (err) ->
				memoizedFn.delete(args...)
				throw err
		opts
	)
