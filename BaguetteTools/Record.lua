function Alerte(msg)
    PrintChat("<b><font color=\"#F5D76E\">></font></b> <font color=\"#fd576e\"> " .. msg .. "</font>");
end

function Record()
    local GameId = ID();
    DelayAction(function()
        if GameId ~= nil then
            GetWebResult(string.lower(GetGameRegion())..".op.gg", "/summoner/ajax/requestRecording/gameId="..GameId)
            Alerte("[OPGG] Record Started!");
        end
    end, 5);
end

function ID()
    local Host = "spyk.space";
    local summsID = (GetCommandLine():reverse():sub(2, GetCommandLine():reverse():find(" ") - 1)):reverse();
    return GetWebResult(Host, "/elo/CurrentGame.php?SummonerID="..summsID.."&Region="..string.upper(GetGameRegion()));
end

DelayAction(function()
  Record()
end, 5);
