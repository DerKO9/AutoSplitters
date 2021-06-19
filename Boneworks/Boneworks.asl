// If anyone wants to take over maintaince for this ASL, that would be GREAT! https://discord.gg/MW2zUcV2Fv ping @DerKO

// currentLevel: The id of the current level
// 	Main Menu = 1, BreakRoom = 3, Museum = 4, Streets = 5, Runoff = 6, Sewers = 7, Warehouse = 8, Central Station = 9,
//	Tower = 10, Time Tower = 11, Dungeon = 13, Arena = 14, Throne Room = 15
// MeunButtonCount: The number of buttons displayed in the menu. There are 8 buttons displayed when first opening the "Scene Select" menu.

state("BONEWORKS"){ //This should default to CurrentUpdate values
	int currentLevel : "GameAssembly.dll", 0x01E7E4E0, 0xB8, 0x590;
	int menuButtonCount : "GameAssembly.dll", 0x01E6A7F8, 0xB8, 0x20, 0x18;
	int loading : "vrclient_x64.dll", 0x3D5C84;
}

startup{
	vars.logFileName = "BONEWORKS.log";
	vars.maxFileSize = 4000000;
	
	vars.SplitOnLoadSettingName = "Split the timer on every loading screen";
	vars.SkipSplitOnFirstLoadingScreenName = "Skip 1st loading screen";
	vars.SkipSplitOnTenthLoadingScreenName = "Skip 10th loading screen";
	vars.LoggingSettingName = "Debug Logging (Log files help solve auto-splitting issues)";
	
	settings.Add(vars.SplitOnLoadSettingName, true);
	settings.Add(vars.SkipSplitOnFirstLoadingScreenName, true, "Skip 1st loading screen", vars.SplitOnLoadSettingName );
	settings.Add(vars.SkipSplitOnTenthLoadingScreenName, true, "Skip 10th loading screen", vars.SplitOnLoadSettingName );
	settings.Add(vars.LoggingSettingName, true);
}

init{
	vars.timerSecondOLD = -1;
	vars.timerSecond = 0;
	vars.timerMinuteOLD = -1;
	vars.timerMinute = 0;

	vars.loadCount = 0;
	
	// If the logging setting is checked, this function logs game info to a log file.
	// If the file reaches max size, it will delete the oldest entries.
	vars.Log = (Action<string>)( myString => {
		
		if(settings[vars.LoggingSettingName]){
			
			vars.logwriter = File.AppendText(vars.logFileName);
			
			print(myString);
			vars.logwriter.WriteLine(myString); 
			
			vars.logwriter.Close();
			
			if((new FileInfo(vars.logFileName)).Length > vars.maxFileSize){
				string[] lines = File.ReadAllLines(vars.logFileName);
				File.WriteAllLines(vars.logFileName, lines.Skip(lines.Length/8).ToArray());
			}
		}
		else{
			if(File.Exists(vars.logFileName)){
				File.Delete(vars.logFileName);
			}
		}
	});
	
	// If a second/minute has passed, log important values.
	vars.PeriodicLogging = (Action)( () => {
		vars.timerMinute = timer.CurrentTime.RealTime.Value.Minutes;
	
		if(vars.timerMinute != vars.timerMinuteOLD){
			vars.timerMinuteOLD = vars.timerMinute;
			
			vars.Log("TimeOfDay: " + DateTime.Now.ToString() + "\n" +
			"Version: " + version.ToString() + "\n" +
			"settings[vars.SplitOnLoadSettingName]: " + settings[vars.SplitOnLoadSettingName].ToString() + "\n" +
			"settings[vars.SkipSplitOnFirstLoadingScreenName]: " + settings[vars.SkipSplitOnFirstLoadingScreenName].ToString() + "\n" +
			"settings[vars.SkipSplitOnTenthLoadingScreenName]: " + settings[vars.SkipSplitOnTenthLoadingScreenName].ToString() + "\n" +
			"settings[vars.LoggingSettingName]: " + settings[vars.LoggingSettingName].ToString() + "\n");
		}
		
		vars.timerSecond = timer.CurrentTime.RealTime.Value.Seconds;
	
		if(vars.timerSecond != vars.timerSecondOLD){
			vars.timerSecondOLD = vars.timerSecond;
			
			vars.Log("RealTime: "+timer.CurrentTime.RealTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"GameTime: "+timer.CurrentTime.GameTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"loading: " + current.loading.ToString() + "\n" +
			"loadCount: " + vars.loadCount.ToString() + "\n" +
			"currentLevel: " + current.currentLevel.ToString() + "\n" +
			"menuButtonCount: " + current.menuButtonCount.ToString() + "\n");
		}
	});
}

reset{
	if(current.menuButtonCount == 8 && old.menuButtonCount == 0){
		vars.Log("-Resetting-\n");
		return true;
	}
	else if(current.currentLevel == 1 && old.currentLevel != 1 && old.currentLevel != 15){
		vars.Log("-Resetting-\n");
		return true;
	}
}

isLoading{
	return current.loading == 1; //stops timer when loading is 1
}

start{
	if(current.loading == 1 && old.loading == 0){
		vars.loadCount = 0;
		vars.Log("-Starting-\n");
		return true;
	}
}

split{
	vars.PeriodicLogging();
	
	if(current.loading == 1 && old.loading == 0 && settings[vars.SplitOnLoadSettingName]){
		if(settings[vars.SkipSplitOnFirstLoadingScreenName]){
			if(vars.loadCount == 0){
				vars.loadCount++;
				return false;
			}
		}
		if(settings[vars.SkipSplitOnTenthLoadingScreenName]){
			if(vars.loadCount == 9){
				vars.loadCount++;
				return false;
			}
		}
		vars.loadCount++;
		vars.Log("-Splitting-\n");
		return true;
	}
}

// Performance Tool:

// var watch = System.Diagnostics.Stopwatch.StartNew();
// Code to measure
// watch.Stop();
// var elapsedMs = watch.ElapsedMilliseconds;
// print(elapsedMs.ToString());
