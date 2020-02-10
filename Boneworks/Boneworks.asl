//Help is welcome! https://discord.gg/mjmpUR8 #speedrunning-disscusion and ping @DerKO

state("BONEWORKS", "UNKNOWN"){ //This should default to CurrentUpdate values
	int loading : "vrclient_x64.dll", 0x339F14;
	int currentLevel : "GameAssembly.dll", 0x01C2B090, 0xD70;
	int menuButtonCount : "GameAssembly.dll", 0x01C37B80, 0xB8, 0x480, 0x18
}

state("BONEWORKS", "Could not read MD5"){ //This should default to CurrentUpdate values
	int loading : "vrclient_x64.dll", 0x321E6C;
	int currentLevel : "GameAssembly.dll", 0x01C2B090, 0xD70;
	int menuButtonCount : "GameAssembly.dll", 0x01C37B80, 0xB8, 0x480, 0x18
}

state("BONEWORKS", "CurrentUpdate"){
	int loading : "vrclient_x64.dll", 0x321E6C;
	int currentLevel : "GameAssembly.dll", 0x01C2B090, 0xD70;
	int menuButtonCount : "GameAssembly.dll", 0x01C37B80, 0xB8, 0x480, 0x18
}

state("BONEWORKS", "BETA"){
	int loading : "vrclient_x64.dll", 0x339F14;
	int currentLevel : "GameAssembly.dll", 0x01C2B090, 0xD70;
	int menuButtonCount : "GameAssembly.dll", 0x01C37B80, 0xB8, 0x480, 0x18
}


startup{
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
	//This code identifies different BONEWORKS versions with MD5 checksum on the vrclient_x64.dll.
	vars.MD5Hash = new byte[0];
	try{
		byte[] exeMD5HashBytes = new byte[0];
		using (var md5 = System.Security.Cryptography.MD5.Create())
		{
			using (var s = File.Open(modules.Single(m => m.FileName.Contains("vrclient_x64")).FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			{
				exeMD5HashBytes = md5.ComputeHash(s); 
			}
		}
		vars.MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
		if(vars.MD5Hash == "A1889E933415EFA3F50D7E0721C09B2D"){ 
			version = "BETA";
		}
		else if(vars.MD5Hash == "EF9F92F46EA844CDFD0E592CA1B2085D"){
			version = "CurrentUpdate";
		}
		else{
			version = "UNKNOWN";
		}
	}	
	catch{
		version = "Could not read MD5";
	}
	
	// Logs AOB from pointer to improve AOB consistency
	vars.loadingAOB = "";
	var baseOffset = 0;
	if(version == "CurrentUpdate") baseOffset = 0x321E6C;
	if(version == "BETA" || version == "UNKNOWN") baseOffset = 0x339F14;
	byte[] aob = new DeepPointer("vrclient_x64.dll", baseOffset, new int[0]).DerefBytes(game, 250);
	foreach(byte b in aob){
		vars.loadingAOB += b.ToString("X2") + " ";
	}
	
	vars.currentLevel = 0;
	vars.menuButtonCount = 0;
	vars.loading = 0;
	vars.loadCount = 0;
	
	vars.logFileName = "BONEWORKS.log";
	vars.maxFileSize = 4000000;
	vars.timerSecondOLD = -1;
	vars.timerSecond = 0;
	vars.timerMinuteOLD = -1;
	vars.timerMinute = 0;
	
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
	// Cannot log state variables inside anonymous function, can only log vars variables:
	// e.g. vars.log(current.loading) doesnt work but 
	// vars.loading = current.loading, vars.log(vars.loading) works
	vars.PeriodicLogging = (Action)( () => {
		vars.timerMinute = timer.CurrentTime.RealTime.Value.Minutes;
	
		if(vars.timerMinute != vars.timerMinuteOLD){
			vars.timerMinuteOLD = vars.timerMinute;
			
			vars.loadingAOB = "";
			var baseOffset = 0;
			baseOffset = 0x321E6C;
			if(version == "BETA" || version == "UNKNOWN") baseOffset = 0x339F14;
			byte[] aob = new DeepPointer("vrclient_x64.dll", baseOffset, new int[0]).DerefBytes(game, 250);
			foreach(byte b in aob){
				vars.loadingAOB += b.ToString("X2") + " ";
			}
			
			vars.Log("TimeOfDay: " + DateTime.Now.ToString() + "\n" +
			"Version: " + version.ToString() + "\n" +
			"MD5Hash: " + vars.MD5Hash.ToString() + "\n" +
			"settings[vars.SplitOnLoadSettingName]: " + settings[vars.SplitOnLoadSettingName].ToString() + "\n" +
			"settings[vars.SkipSplitOnFirstLoadingScreenName]: " + settings[vars.SkipSplitOnFirstLoadingScreenName].ToString() + "\n" +
			"settings[vars.SkipSplitOnTenthLoadingScreenName]: " + settings[vars.SkipSplitOnTenthLoadingScreenName].ToString() + "\n" +
			"settings[vars.LoggingSettingName]: " + settings[vars.LoggingSettingName].ToString() + "\n" +
			"loadingAOB: " + vars.loadingAOB + "\n");
		}
		
		vars.timerSecond = timer.CurrentTime.RealTime.Value.Seconds;
	
		if(vars.timerSecond != vars.timerSecondOLD){
			vars.timerSecondOLD = vars.timerSecond;
			
			vars.Log("RealTime: "+timer.CurrentTime.RealTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"GameTime: "+timer.CurrentTime.GameTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"loading: " + vars.loading.ToString() + "\n" +
			"loadCount: " + vars.loadCount.ToString() + "\n" +
			"currentLevel: " + vars.currentLevel.ToString() + "\n" +
			"menuButtonCount: " + vars.menuButtonCount.ToString() + "\n");
		}
	});
}

reset{
	if(current.menuButtonCount == 8 && old.menuButtonCount == 0){
		vars.Log("-Resetting-\n");
		return true;
	}
	else if(current.currentLevel == 1 && old.currentLevel != 1){
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
	vars.currentLevel = current.currentLevel;
	vars.loading = current.loading;
	vars.menuButtonCount = current.menuButtonCount;
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

update{
	
}


// Performance Tool:

// var watch = System.Diagnostics.Stopwatch.StartNew();
// Code to measure
// watch.Stop();
// var elapsedMs = watch.ElapsedMilliseconds;
// print(elapsedMs.ToString());
