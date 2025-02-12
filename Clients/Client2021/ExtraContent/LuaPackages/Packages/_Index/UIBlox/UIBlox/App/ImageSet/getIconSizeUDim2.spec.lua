local ImageSet = script.Parent
local IconSizeEnum = require(ImageSet.Enum.IconSize)

return function()
	local getIconSizeUDim2 = require(ImageSet.getIconSizeUDim2)
	describe("getIconSizeUDim2()", function()
		it("should return a UDim2 of value (0, 16, 0, 16)", function()
			local iconSize = getIconSizeUDim2(IconSizeEnum.Small)
			expect(iconSize).to.equal(UDim2.fromOffset(16, 16))
		end)
		it("should return a UDim2 of value (0, 36, 0, 36)", function()
			local iconSize = getIconSizeUDim2(IconSizeEnum.Medium)
			expect(iconSize).to.equal(UDim2.fromOffset(36, 36))
		end)
		it("should return a UDim2 of value (0, 48, 0, 48)", function()
			local iconSize = getIconSizeUDim2(IconSizeEnum.Large)
			expect(iconSize).to.equal(UDim2.fromOffset(48, 48))
		end)
		it("should return a UDim2 of value (0, 96, 0, 96)", function()
			local iconSize = getIconSizeUDim2(IconSizeEnum.XLarge)
			expect(iconSize).to.equal(UDim2.fromOffset(96, 96))
		end)
		it("should return a UDim2 of value (0, 192, 0, 192)", function()
			local iconSize = getIconSizeUDim2(IconSizeEnum.XXLarge)
			expect(iconSize).to.equal(UDim2.fromOffset(192, 192))
		end)

		it("should error", function()
			expect(function()
				return getIconSizeUDim2("ASD")
			end).to.throw()
		end)
	end)
end
