memoize = require '..' 
Promise = require 'bluebird'
chai = require 'chai' 
chaiAsPromised = require 'chai-as-promised'
chai.use(chaiAsPromised)
{ expect } = chai

describe 'memoizee-async', ->
	it 'should memoize resolved promises', ->
		callCount = 0
		testFunc = memoize ->
			callCount += 1
			Promise.resolve(callCount)

		results = []
		results[0] = testFunc('test')
		results[1] = results[0].then(-> testFunc('test'))
		results[2] = results[1].then(-> testFunc('test'))
		expect(results[0]).to.eventually.equal(1)
		expect(results[1]).to.eventually.equal(1)
		expect(results[2]).to.eventually.equal(1)

	it 'should not memoize rejected promises', ->
		callCount = 0
		testFunc = memoize ->
			callCount += 1
			Promise.reject(new Error(callCount))

		results = []
		results[0] = testFunc('test')
		results[1] = results[0].catch(->).then(-> testFunc('test'))
		results[2] = results[1].catch(->).then(-> testFunc('test'))
		expect(results[0]).to.be.rejectedWith(Error, 1)
		expect(results[1]).to.be.rejectedWith(Error, 2)
		expect(results[2]).to.be.rejectedWith(Error, 3)

	it 'should memoize a function on first resolution', ->
		callCount = 0
		testFunc = memoize ->
			callCount += 1
			if callCount is 1
				Promise.reject(new Error(callCount))
			else
				Promise.resolve(callCount)

		results = []
		results[0] = testFunc('test')
		results[1] = results[0].catch(->).then(-> testFunc('test'))
		results[2] = results[1].then(-> testFunc('test'))
		expect(results[0]).to.be.rejectedWith(Error, 1)
		expect(results[1]).to.eventually.equal(2)
		expect(results[2]).to.eventually.equal(2)
