-- Codyd by MohammadT9030

require "AI_setting"

local SHAPE_UNSET = 0
local SHAPE_CROSS = 1
local SHAPE_CIRCLE = 2

function TableCopy(t)
    local t2 = {}
    for k,v in pairs(t) do
       t2[k] = v
    end
    return t2
 end

function Terminal(state)
    -- Check if O is the winner
    if state[1] == SHAPE_CIRCLE and state[2] == SHAPE_CIRCLE and state[3] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    if state[4] == SHAPE_CIRCLE and state[5] == SHAPE_CIRCLE and state[6] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    if state[7] == SHAPE_CIRCLE and state[8] == SHAPE_CIRCLE and state[9] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    if state[1] == SHAPE_CIRCLE and state[4] == SHAPE_CIRCLE and state[7] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    if state[2] == SHAPE_CIRCLE and state[5] == SHAPE_CIRCLE and state[8] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    if state[3] == SHAPE_CIRCLE and state[6] == SHAPE_CIRCLE and state[9] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    if state[1] == SHAPE_CIRCLE and state[5] == SHAPE_CIRCLE and state[9] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    if state[3] == SHAPE_CIRCLE and state[5] == SHAPE_CIRCLE and state[7] == SHAPE_CIRCLE then
        return {
            t = true,
            utility = 1 -- O wins
        }
    end
    -- Check if X is the winner
    if state[1] == SHAPE_CROSS and state[2] == SHAPE_CROSS and state[3] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    if state[4] == SHAPE_CROSS and state[5] == SHAPE_CROSS and state[6] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    if state[7] == SHAPE_CROSS and state[8] == SHAPE_CROSS and state[9] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    if state[1] == SHAPE_CROSS and state[4] == SHAPE_CROSS and state[7] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    if state[2] == SHAPE_CROSS and state[5] == SHAPE_CROSS and state[8] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    if state[3] == SHAPE_CROSS and state[6] == SHAPE_CROSS and state[9] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    if state[1] == SHAPE_CROSS and state[5] == SHAPE_CROSS and state[9] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    if state[3] == SHAPE_CROSS and state[5] == SHAPE_CROSS and state[7] == SHAPE_CROSS then
        return {
            t = true,
            utility = -1 -- X wins
        }
    end
    -- Check if there is a tie
    if state[1] ~= SHAPE_UNSET and state[2] ~= SHAPE_UNSET and state[3] ~= SHAPE_UNSET and state[4] ~= SHAPE_UNSET and state[5] ~= SHAPE_UNSET and state[6] ~= SHAPE_UNSET and state[7] ~= SHAPE_UNSET and state[8] ~= SHAPE_UNSET and state[9] ~= SHAPE_UNSET then
        return {
            t = true,
            utility = 0 -- Tie
        }
    end
    -- Otherwise, game is not over
    return {
        t = false
    }

end

function Result(state0, action, player)
    local state = TableCopy(state0)
    local res = state
    res[action] = player
    return res
end

function MaxPlayerO(state0, min_parent)
    local state = TableCopy(state0)
    if RANDOM_FIRST and state[1] == SHAPE_UNSET and state[2] == SHAPE_UNSET and state[3] == SHAPE_UNSET and state[4] == SHAPE_UNSET and state[5] == SHAPE_UNSET and state[6] == SHAPE_UNSET and state[7] == SHAPE_UNSET and state[8] == SHAPE_UNSET and state[9] == SHAPE_UNSET then
        math.randomseed(os.time())
        return { 0, math.random(1,9) }
    end

    local ter = Terminal(state)
    if ter.t then
        return {ter.utility}
    end

    local max_utility = -1
    local action = 0
    for i = 1, 9 do
        if state[i] == SHAPE_UNSET then
            local m = MinPlayerX(Result(state, i, SHAPE_CIRCLE), max_utility)[1]
            if max_utility < m then
                max_utility = m
                action = i
            end
            if max_utility >= min_parent then return {1, action} end
        end
    end
    return {max_utility, action}
end

function MinPlayerX(state0, max_parent)
    local state = TableCopy(state0)
    local ter = Terminal(state)
    if ter.t then
        return {ter.utility}
    end

    local min_utility = 1
    local action = 0
    for i = 1, 9 do
        if state[i] == SHAPE_UNSET then
            local m = MaxPlayerO(Result(state, i, SHAPE_CROSS), min_utility)[1]
            if min_utility > m then
                min_utility = m
                action = i
            end
            if min_utility <= max_parent then return {-1, action} end
        end
    end
    return {min_utility, action}
end