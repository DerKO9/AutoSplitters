//Help is welcome! https://discord.gg/mjmpUR8 #speedrunning-disscusion and ping @DerKO

state("BONEWORKS", "UNKNOWN"){ //This should default to CurrentUpdate values
	int currentLevel : "GameAssembly.dll", 0x01C2B090, 0xD70;
	int menuButtonCount : "GameAssembly.dll", 0x01C37B80, 0xB8, 0x480, 0x18
}

startup{
	vars.scanTarget = new SigScanTarget(-44, "49 6E 45 3F 00 00 00 00 B5 CB 41 BE");
	
	vars.logFileName = "BONEWORKS.log";
	
	vars.SplitOnLoadSettingName = "Split the timer on every loading screen";
	vars.SkipSplitOnFirstLoadingScreenName = "Skip 1st loading screen";
	vars.SkipSplitOnTenthLoadingScreenName = "Skip 10th loading screen";
	vars.LoggingSettingName = "Debug Logging (Log files help solve auto-splitting issues)";
	
	settings.Add(vars.SplitOnLoadSettingName, true);
	settings.Add(vars.SkipSplitOnFirstLoadingScreenName, true, "Skip 1st loading screen", vars.SplitOnLoadSettingName );
	settings.Add(vars.SkipSplitOnTenthLoadingScreenName, true, "Skip 10th loading screen", vars.SplitOnLoadSettingName );
	settings.Add(vars.LoggingSettingName, false);
}

init{	
	vars.maxFileSize = 4000000;
	vars.timerSecondOLD = -1;
	vars.timerSecond = 0;
	vars.timerMinuteOLD = -1;
	vars.timerMinute = 0;

	ProcessModuleWow64Safe module = modules.SingleOrDefault(m => m.FileName.Contains("vrclient_x64"));
	if (module == null) {
		Thread.Sleep(1000);
        throw new Exception("vrclient_x64 module not found");
	}
	var scanner = new SignatureScanner(game, module.BaseAddress, module.ModuleMemorySize);
	var ptr = scanner.Scan(vars.scanTarget);
	if (ptr == IntPtr.Zero) {
        Thread.Sleep(1000);
        throw new Exception("AOB not found");
    }

    vars.loading = new MemoryWatcher<byte>(ptr);

    vars.watchers = new MemoryWatcherList() {
        vars.loading,
    };

	vars.currentLevel = 0;
	vars.menuButtonCount = 0;
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
			"loading: " + vars.loading.Current.ToString() + "\n" +
			"loadCount: " + vars.loadCount.ToString() + "\n" +
			"currentLevel: " + current.currentLevel.ToString() + "\n" +
			"menuButtonCount: " + current.menuButtonCount.ToString() + "\n");
		}
	});
}

reset{
	if(current.menuButtonCount == 8){
		vars.Log("-Resetting-\n");
		return true;
	}
	else if(current.currentLevel == 1 && old.currentLevel != 1){
		vars.Log("-Resetting-\n");
		return true;
	}
}

isLoading{
	return vars.loading.Current == 1; //stops timer when loading is 1
}

start{
	if(vars.loading.Current == 1 && vars.loading.Old == 0){
		vars.loadCount = 0;
		vars.Log("-Starting-\n");
		return true;
	}
}

split{
	vars.currentLevel = current.currentLevel;
	vars.menuButtonCount = current.menuButtonCount;
	vars.PeriodicLogging();
	
	if(vars.loading.Current == 1 && vars.loading.Old == 0 && settings[vars.SplitOnLoadSettingName]){
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

update{
	vars.watchers.UpdateAll(game);
}

// Performance Tool:

// var watch = System.Diagnostics.Stopwatch.StartNew();
// Code to measure
// watch.Stop();
// var elapsedMs = watch.ElapsedMilliseconds;
// print(elapsedMs.ToString());
