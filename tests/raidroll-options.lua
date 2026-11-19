-- Run from the repository root: lua5.1 tests/raidroll-options.lua
function UnitName() return "Officer" end
RaidRoll_DBPC = { Officer = { RR_AllowExtraRolls = false, RR_Accept_All_Rolls = false } }
RaidRoll_DB = {}
MaxPlayers = { [1] = 5 }
rr_CurrentRollID = 99
RollerName = { { "HighPR", "HighRoll", "", "", "" } }
RollerRoll = { { 12, 97, 0, 0, 0 } }
RollerFirst = { { true, true, false, false, false } }
RollerRank = { { "Member", "Member", "", "", "" } }
RollerRankIndex = { { 1, 1, 1, 1, 1 } }
Roll_Number = { { 1, 1, 1, 1, 1 } }
RaidRoll_LegitRoll = { { true, true, false, false, false } }
RollerColor = { { "", "", "", "", "" } }
RR_EPGPAboveThreshold = { { true, true, false, false, false } }
RR_EPGP_PRValue = { { 20, 10, 0, 0, 0 } }
RR_RollData = { { {}, {}, {}, {}, {} } }
RR_IgnoredList = { {} }

dofile("RaidRoll/RaidRoll_OnLoad.lua")

local settings = RaidRoll_DBPC.Officer
local color = "|cFFFF0000|r"
for _, epgp in ipairs({ false, true }) do
    settings.RR_EPGP_Enabled = epgp
    local winner
    local order
    for _, combined in ipairs({ false, true }) do
        settings.RR_Show_Roll_EPGP = combined
        rr_RollSort(1)
        local currentWinner = RR_FindWinner(1)
        assert(currentWinner == (epgp and "highpr" or "highroll"))
        local currentOrder = table.concat(RollerName[1], ",")
        if order then assert(order == currentOrder and winner == currentWinner) end
        order, winner = currentOrder, currentWinner

        local expectedHeader = combined and "PR / Roll" or (epgp and "PR" or "Roll")
        assert(RR_GetRollColumnHeader() == expectedHeader)
        local pr, roll = RR_EPGP_PRValue[1][1], RollerRoll[1][1]
        local expectedText = combined and ("|cFFABD473" .. pr .. "|r / " .. color .. roll .. "|r")
            or (epgp and ("|cFFABD473" .. pr) or (color .. roll))
        assert(RR_GetRollColumnText(1, 1, color) == expectedText)
        assert(RR_GetRollColumnText(1, 5, color) == "")
    end
end

-- Combined display preserves the existing extra-roll and invalid-range markers.
settings.RR_EPGP_Enabled = false
settings.RR_Show_Roll_EPGP = true
RollerFirst[1][1] = false
RaidRoll_LegitRoll[1][1] = false
Roll_Number[1][1] = 2
RR_EPGPAboveThreshold[1][1] = false
assert(RR_GetRollColumnText(1, 1, color) == "|cFFC41F3B20|r / " .. color .. "(2) 12*|r")
print("PASS: display is independent of sorting and winner selection in all four option combinations")
