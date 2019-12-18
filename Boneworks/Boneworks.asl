//Help is welcome! https://discord.gg/mjmpUR8 #speedrunning-disscusion and ping @DerKO

state("BONEWORKS", "CurrentUpdate"){
	//bool loading : "vrclient_x64.dll", 0x3068EC;
	bool loading : "vrclient_x64.dll", 0x31FCAC;
}

// state("BONEWORKS", "LastUpdate"){
// }

startup{
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
	//This code identifies different BONEWORKS versions with MD5 checksum on the Assembly-CSharp.dll.
	// byte[] exeMD5HashBytes = new byte[0];
	// using (var md5 = System.Security.Cryptography.MD5.Create())
	// {
		// using (var s = File.Open(modules.First().FileName.Substring(0, modules.First().FileName.Length-13)
		// + "YLILWin64_Data\\Managed\\Assembly-CSharp.dll", FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
		// {
			// exeMD5HashBytes = md5.ComputeHash(s); 
		// } 
	// }
	// vars.MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	
	// if(vars.MD5Hash == "CB12AA291173D934E2462D6C4537DF6C"){
		// version = "LastUpdate";
	// }
	// else{
		// version = "CurrentUpdate";
	// }
	
	vars.loadCount = 0;
	
	vars.logFileName = "BONEWORKS.log";
	vars.maxFileSize = 4000000;
	vars.timerSecondOLD = -1;
	vars.timerSecond = 0;
	vars.timerMinuteOLD = -1;
	vars.timerMinute = 0;
	
	// If the logging setting is checked, this function logs game info to a log file.
	// If the file reaches maz size, it will delete the oldest entries.
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
	
	// If a second/minute has passed, log important values
	vars.PeriodicLogging = (Action)( () => {
		vars.timerMinute = timer.CurrentTime.RealTime.Value.Minutes;
	
		if(vars.timerMinute != vars.timerMinuteOLD){
			vars.timerMinuteOLD = vars.timerMinute;
			
			vars.Log("TimeOfDay: " + DateTime.Now.ToString() + "\n" +
			"Version: " + version.ToString() + "\n"/*  +
			"MD5Hash: " + vars.MD5Hash.ToString() + "\n" */);
		}
		
		vars.timerSecond = timer.CurrentTime.RealTime.Value.Seconds;
	
		if(vars.timerSecond != vars.timerSecondOLD){
			vars.timerSecondOLD = vars.timerSecond;
			
			vars.Log("RealTime: "+timer.CurrentTime.RealTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"GameTime: "+timer.CurrentTime.GameTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"current.loading: " + current.loading.ToString() + "\n" +
			"vars.loadCount: " + vars.loadCount.ToString() + "\n");
		}
	});
}



reset{
	
}

isLoading{
	return current.loading; //stops timer when loading is true
}

start{
	if(current.loading == true && old.loading == false){
		vars.loadCount = 0;
		return true;
	}
}

split{
	vars.PeriodicLogging();
	
	if(current.loading == true && old.loading == false && settings[vars.SplitOnLoadSettingName]){
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
		vars.Log("-Splitting-");
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
