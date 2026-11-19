-- Run from the repository root: lua5.1 tests/raidroll-layout.lua
function UnitName() return "Officer" end

local function frame(x, width)
    return {
        x = x or 0, width = width or 0, textWidth = 0,
        SetHeight = function(self, height) self.height = height end,
        GetHeight = function(self) return self.height end,
        SetWidth = function(self, value) self.width = value end,
        GetWidth = function(self) return self.width end,
        GetStringWidth = function(self) return self.textWidth end,
        GetChecked = function(self) return self.checked end,
        Show = function(self) self.shown = true end,
        Hide = function(self) self.shown = false end,
        ClearAllPoints = function() end,
        SetPoint = function(self, point, relative, relativePoint, dx, dy)
            self.x = relative.x + dx
        end,
        SetText = function(self, text) self.text = text end,
    }
end

RaidRoll_DBPC = { Officer = {
    RR_ShowTenPlayers = true, RR_ExtraWidth = 0,
    RR_Show_Ranks = false, RR_ShowGroupNumber = true, RR_EPGP_Enabled = true,
} }
RR_RollFrame = frame(0, 215)
RR_Rolled = frame(170)
RR_Rolled.textWidth = 16
RR_Group0 = frame(200)
RR_Group0.textWidth = 22
Raid_Roll_Rank_String0 = frame()
RR_RollCheckBox_ShowRanks_panel = frame()
RR_RollCheckBox_ShowRanks_panel.checked = false
RR_RollCheckBox_ShowGroupNumber_panel = frame()
RR_RollCheckBox_ShowGroupNumber_panel.checked = true
RR_RollModeButton = frame()
Raid_Roll_Name = frame()
RaidRoll_Slider = frame()
for i = 1, 10 do
    for _, prefix in ipairs({ "RR_RollerPos", "RR_Roller", "RR_Rolled", "RR_Group", "Raid_Roll_Rank_String", "Raid_Roll_SetSymbol" }) do
        _G[prefix .. i] = frame()
    end
end

dofile("RaidRoll/RaidRoll_ExtraRollFrames.lua")

local function assertFits()
    local settings = RaidRoll_DBPC.Officer
    RR_RollFrame_SortOutSize()
    local edge = settings.RR_ShowGroupNumber and (RR_Group0.x + RR_Group0.textWidth) or RR_Rolled.x
    assert(edge + 20 <= RR_RollFrame.width,
        "table reaches " .. edge .. " but frame width is " .. RR_RollFrame.width)
end

-- Initial anchors can still reserve space for ranks while options are unset.
assertFits()
assert(RR_Rolled.x == 120 and RR_RollFrame.width == 215)

local cases = 0
for _, ranks in ipairs({ false, true }) do
    for _, groups in ipairs({ false, true }) do
        for _, tenRows in ipairs({ false, true }) do
            for _, extra in ipairs({ 0, 80, 200 }) do
                for _, mode in ipairs({ "PR", "PR / Roll", "Roll" }) do
                    local settings = RaidRoll_DBPC.Officer
                    settings.RR_Show_Ranks = ranks
                    settings.RR_ShowGroupNumber = groups
                    settings.RR_ShowTenPlayers = tenRows
                    settings.RR_ExtraWidth = extra
                    settings.RR_EPGP_Enabled = mode ~= "Roll"
                    settings.RR_Show_Roll_EPGP = mode == "PR / Roll"
                    -- Stale checkbox state must not override the saved character settings.
                    RR_RollCheckBox_ShowRanks_panel.checked = not ranks
                    RR_RollCheckBox_ShowGroupNumber_panel.checked = not groups
                    RR_Rolled.x = 999
                    RR_Rolled10.textWidth = tenRows and 120 or 999
                    RR_Rolled1.textWidth = mode == "PR" and 100 or 80
                    RR_Group10.textWidth = tenRows and 40 or 999
                    assertFits()
                    local rowCount = tenRows and 10 or 5
                    local rollWidth = math.max(50, RR_Rolled:GetStringWidth() + 10)
                    local groupWidth = math.max(25, RR_Group0:GetStringWidth())
                    for i = 1, rowCount do
                        rollWidth = math.max(rollWidth, _G["RR_Rolled" .. i]:GetStringWidth() + 10)
                        groupWidth = math.max(groupWidth, _G["RR_Group" .. i]:GetStringWidth())
                    end
                    assert(RR_Rolled.x == (ranks and 170 or 120) + extra)
                    assert(RR_Group0.x >= RR_Rolled.x + rollWidth)
                    if groups then assert(RR_Group0.x + groupWidth + 20 <= RR_RollFrame.width) end
                    assert(RR_RollFrame.height == (tenRows and 215 or 155))
                    assert(RR_Roller10.shown == tenRows)
                    assert(RR_Group0.shown == groups and Raid_Roll_Rank_String0.shown == ranks)
                    assert(RR_RollModeButton.text == (mode == "Roll" and "by Roll" or "by PR"))
                    local width = RR_RollFrame.width
                    RR_RollFrame_SortOutSize()
                    assert(RR_RollFrame.width == width, "repeated sizing must not grow the frame")
                    cases = cases + 1
                end
            end
        end
    end
end
print("PASS: initial character layout and " .. cases .. " layout combinations")
