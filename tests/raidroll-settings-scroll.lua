-- Run from the repository root: lua5.1 tests/raidroll-settings-scroll.lua
function UnitName() return "Officer" end
function GetLocale() return "ruRU" end
function InterfaceOptions_AddCategory() end
function IsInGuild() return false end
RaidRoll_DB = { Scale = 100 }
RaidRoll_DBPC = { Officer = {} }
local methods = {
    SetWidth = function(self, value) self.width = value end,
    GetWidth = function(self) return self.width end,
    SetHeight = function(self, value) self.height = value end,
    SetScale = function(self, value) self.scale = value end,
    SetPoint = function(self, ...) self.anchor = { ... } end,
    SetScript = function(self, name, fn) self.scripts[name] = fn end,
    GetName = function(self) return self.name end,
    SetValue = function(self, value)
        self.value = value
        if rawget(self, "scrollOwner") then self.scrollOwner:SetVerticalScroll(value) end
    end,
    GetValue = function(self) return self.value end,
    SetScrollChild = function(self, child) self.child = child end,
    SetVerticalScroll = function(self, value) self.offset = value end,
    GetVerticalScroll = function(self) return self.offset end,
    GetVerticalScrollRange = function(self)
        return math.max(0, self.child.height * self.child.scale - self.height)
    end,
    CreateFontString = function(self, name) return makeFrame(name, self) end,
}
function makeFrame(name, parent)
    local frame = setmetatable({ name = name, parent = parent, width = 560, height = 360, scale = 1, offset = 0, scripts = {} }, {
        __index = function(_, key) return methods[key] or function() end end,
    })
    if name then _G[name] = frame end
    return frame
end
function CreateFrame(kind, name, parent, template)
    local frame = makeFrame(name, parent)
    if template == "OptionsSliderTemplate" or template == "UICheckButtonTemplate" then makeFrame(name .. "Text", frame) end
    if template == "OptionsSliderTemplate" then makeFrame(name .. "Low", frame); makeFrame(name .. "High", frame) end
    if template == "UIPanelScrollFrameTemplate" then makeFrame(name .. "ScrollBar", frame).scrollOwner = frame end
    return frame
end
RR_RollFrame = makeFrame("RR_RollFrame")
dofile("RaidRoll/Locale/RaidRoll_Localization.en.lua")
dofile("RaidRoll/Locale/RaidRoll_Localization.ru.lua")
dofile("RaidRoll/RaidRoll_OptionsMenu.lua")
Setup_RR_Panel()

local scroll = RaidRoll_OptionsScrollFrame
local content = RaidRoll_OptionsContent
assert(scroll.parent == RaidRoll_Panel.panel and content.parent == scroll)
for _, control in ipairs({ RR_RollCheckBox_Unannounced_panel, RR_RollCheckBox_ShowTenPlayers, RR_RollCheckBox_Show_Roll_EPGP, RaidRoll_Scale_Slider, RaidRoll_ExtraWidth_Slider, RaidRoll_Rolling_Time_Slider }) do
    assert(control.parent == content, "every main settings control must scroll together")
end
local anchor = RaidRoll_Rolling_Time_Slider.anchor
local footer = -anchor[#anchor] + 40
assert(content.height >= footer, "content height must include the slider endpoint labels")
for _, height in ipairs({ 260, 360, 520 }) do
    for _, width in ipairs({ 400, 560, 760 }) do
        scroll.height, scroll.width = height, width
        scroll.scripts.OnSizeChanged()
        assert(content.width * content.scale <= width + 0.001)
        scroll.scripts.OnMouseWheel(scroll, -100)
        assert(scroll.offset + height >= footer * content.scale)
        scroll.scripts.OnMouseWheel(scroll, 100)
        assert(scroll.offset == 0)
    end
end
print("PASS: settings controls scroll together; footer reachable in nine viewport sizes")
