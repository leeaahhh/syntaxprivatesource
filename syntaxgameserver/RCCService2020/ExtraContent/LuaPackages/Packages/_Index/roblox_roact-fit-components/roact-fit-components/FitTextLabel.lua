local root = script.Parent
local Packages = root.Parent

local Cryo = require(Packages.Cryo)
local Roact = require(Packages.Roact)

local EngineFeatureTextBoundsRoundUp do
	local success, value = pcall(function()
		return game:GetEngineFeature("TextBoundsRoundUp")
	end)
	EngineFeatureTextBoundsRoundUp = success and value
end

-- We need to add 2 to these values as a workaround to a documented engine bug
local TextService = game:GetService("TextService")
local function getTextHeight(text, fontSize, font, widthCap)
	if EngineFeatureTextBoundsRoundUp then
		return TextService:GetTextSize(text, fontSize, font, Vector2.new(widthCap, 10000)).Y
	else
		return TextService:GetTextSize(text, fontSize, font, Vector2.new(widthCap, 10000)).Y + 2
	end
end

local function getTextWidth(text, fontSize, font)
	if EngineFeatureTextBoundsRoundUp then
		return TextService:GetTextSize(text, fontSize, font, Vector2.new(10000, 10000)).X
	else
		return TextService:GetTextSize(text, fontSize, font, Vector2.new(10000, 10000)).X + 2
	end
end

local FitTextLabel = Roact.PureComponent:extend("FitTextLabel")
FitTextLabel.Width = {
	FitToText = {},
}
FitTextLabel.defaultProps = {
	Font = Enum.Font.SourceSans,
	Text = "Label",
	TextSize = 12,
	TextWrapped = true,

	maximumWidth = math.huge,
}

function FitTextLabel:init()
	self.frameRef = Roact.createRef()

	self.onResize = function()
		if not self.frameRef.current then
			return
		end

		self.frameRef.current.Size = self:__getSize(self.frameRef.current)
	end
end

function FitTextLabel:render()
	local instanceType = self.props.onActivated and "TextButton" or "TextLabel"
	return Roact.createElement(instanceType, self:__getFilteredProps())
end

function FitTextLabel:didMount()
	self.onResize()
end

function FitTextLabel:didUpdate()
	self.onResize()
end

function FitTextLabel:__getFilteredProps()
	-- Will return a new prop map after removing
	-- Roact.Children and any defaultProps in an effort
	-- to only return safe Roblox Instance "TextLabel"
	-- properties that may be present.
	local filteredProps = {
		width = Cryo.None,
		maximumWidth = Cryo.None,
		onActivated = Cryo.None,
		Size = UDim2.new(self.props.width, UDim.new(0, 0)),
		[Roact.Ref] = self.frameRef,

		[Roact.Children] = Cryo.Dictionary.join(self.props[Roact.Children] or {}, {
			sizeConstraint = self.props.maximumWidth < math.huge and Roact.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(self.props.maximumWidth, math.huge),
			})
		}),

		[Roact.Event.Activated] = self.props.onActivated,

		[Roact.Change.AbsoluteSize] = function(rbx)
			if self.props[Roact.Change.AbsoluteSize] then
				self.props[Roact.Change.AbsoluteSize](rbx)
			end
			self.onResize()
		end,
	}

	return Cryo.Dictionary.join(self.props, filteredProps)
end

function FitTextLabel:__getSize(rbx)
	local maximumWidth = self.props.maximumWidth
	local width = self.props.width
	if width == FitTextLabel.Width.FitToText then
		local textWidth = getTextWidth(self.props.Text, self.props.TextSize, self.props.Font)
		width = UDim.new(0, math.min(textWidth, maximumWidth))
	end

	local widthCap = math.max(maximumWidth < math.huge and maximumWidth or 0, rbx.AbsoluteSize.X)
	local textHeight = getTextHeight(
		self.props.Text,
		self.props.TextSize,
		self.props.Font,
		widthCap
	)

	return UDim2.new(width, UDim.new(0, textHeight))
end

return FitTextLabel
