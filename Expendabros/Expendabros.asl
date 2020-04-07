state("Expendabros")
{
	bool loading : "Expendabros.exe", 0x00A1AD00, 0xB0;
}

startup
{
	vars.SplitOnLoadSettingName = "Split the timer on every load";
	settings.Add(vars.SplitOnLoadSettingName, false);
}

split
{
	return (settings[vars.SplitOnLoadSettingName] && current.loading == true && old.loading == false);
}

isLoading
{
    return current.loading;
}
