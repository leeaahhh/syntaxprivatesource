--[[
	Allows creation of expectation statements designed for behavior-driven
	testing (BDD). See Chai (JS) or RSpec (Ruby) for examples of other BDD
	frameworks.

	The Expectation class is exposed to tests as a function called `expect`:

		expect(5).to.equal(5)
		expect(foo()).to.be.ok()

	Expectations can be negated using .never:

		expect(true).never.to.equal(false)

	Expectations throw errors when their conditions are not met.
]]

local Expectation = {}

--[[
	These keys don't do anything except make expectations read more cleanly
]]
local SELF_KEYS = {
	to = true,
	be = true,
	been = true,
	have = true,
	was = true,
	at = true,
}

--[[
	These keys invert the condition expressed by the Expectation.
]]
local NEGATION_KEYS = {
	never = true,
}

--[[
	Extension of Lua's 'assert' that lets you specify an error level.
]]
local function assertLevel(condition, message, level)
	message = message or "Assertion failed!"
	level = level or 1

	if not condition then
		error(message, level + 1)
	end
end

--[[
	Returns a version of the given method that can be called with either . or :
]]
local function bindSelf(self, method)
	return function(firstArg, ...)
		if (firstArg == self) then
			return method(self, ...)
		else
			return method(self, firstArg, ...)
		end
	end
end

local function formatMessage(result, trueMessage, falseMessage)
	if result then
		return trueMessage
	else
		return falseMessage
	end
end

--[[
	Create a new expectation
]]
function Expectation.new(value)
	local self = {
		value = value,
		successCondition = true,
		condition = false
	}

	setmetatable(self, Expectation)

	self.a = bindSelf(self, self.a)
	self.an = self.a
	self.ok = bindSelf(self, self.ok)
	self.equal = bindSelf(self, self.equal)
	self.throw = bindSelf(self, self.throw)
	self.called = bindSelf(self, self.called)

	return self
end

function Expectation.__index(self, key)
	-- Keys that don't do anything except improve readability
	if SELF_KEYS[key] then
		return self
	end

	-- Invert your assertion
	if NEGATION_KEYS[key] then
		local newExpectation = Expectation.new(self.value)
		newExpectation.successCondition = not self.successCondition

		return newExpectation
	end

	-- Fall back to methods provided by Expectation
	return Expectation[key]
end

--[[
	Called by expectation terminators to reset modifiers in a statement.

	This makes chains like:

		expect(5)
			.never.to.equal(6)
			.to.equal(5)

	Work as expected.
]]
function Expectation:_resetModifiers()
	self.successCondition = true
end

--[[
	Assert that the expectation value is the given type.

	expect(5).to.be.a("number")
]]
function Expectation:a(typeName)
	local result = (type(self.value) == typeName) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value of type %q, got value %q of type %s"):format(
			typeName,
			tostring(self.value),
			type(self.value)
		),
		("Expected value not of type %q, got value %q of type %s"):format(
			typeName,
			tostring(self.value),
			type(self.value)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our expectation value is truthy
]]
function Expectation:ok()
	local result = (self.value ~= nil) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value %q to be non-nil"):format(
			tostring(self.value)
		),
		("Expected value %q to be nil"):format(
			tostring(self.value)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our expectation value is equal to another value
]]
function Expectation:equal(otherValue)
	local result = (self.value == otherValue) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value %q (%s), got %q (%s) instead"):format(
			tostring(otherValue),
			type(otherValue),
			tostring(self.value),
			type(self.value)
		),
		("Expected anything but value %q (%s)"):format(
			tostring(otherValue),
			type(otherValue)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our functoid expectation value throws an error when called
]]
function Expectation:throw()
	local ok, err = pcall(self.value)
	local result = ok ~= self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected function to succeed, but it threw an error: %s"):format(
			tostring(err)
		),
		"Expected function to throw an error, but it did not."
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

return Expectation