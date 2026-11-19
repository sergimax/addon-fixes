-- Run from the repository root: lua5.1 tests/raidroll-startup.lua
function UnitName() return "Officer" end
function time() return 1000 end
function CreateFrame() return {} end
RaidRoll_DBPC = { Officer = { RR_AllowExtraRolls = false } }
RaidRoll_DB = {}
dofile("RaidRoll/RaidRoll_OnLoad.lua")
RR_ClearAllData_Startup()
local displayed = false
RR_Display = function() displayed = true end
-- Empty startup lists must be safe with every independent sort option enabled.
for _, epgp in ipairs({ false, true }) do
    for _, rankPriority in ipairs({ false, true }) do
        local settings = RaidRoll_DBPC.Officer
        settings.RR_EPGP_Enabled = epgp
        settings.RR_EPGP_Priority = true
        settings.RR_RankPriority = rankPriority
        settings.RR_Accept_All_Rolls = false
        rr_RollSort(rr_CurrentRollID)
        assert(not displayed)
    end
end
assert(MaxPlayers[0] == nil and RollerName[0][1] == "")
print("PASS: initial empty roll can be sorted before any player has rolled")
