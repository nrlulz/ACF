hook.Add("CreateMove", "Old ACF", function(Move)
    if Move:GetButtons() ~= 0 then
        chat.AddText(Color(255, 255, 255), "[ACF] ", Color(255, 25, 25), "This version of ACF no longer maintained.")
        chat.AddText(Color(255, 255, 255), "The newest version is available at ", Color(160, 255, 160), "https://github.com/Stooberton/ACF-3")

        hook.Remove("CreateMove", "Old ACF")
    end
end)