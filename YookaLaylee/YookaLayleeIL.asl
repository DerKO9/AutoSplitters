
state("YLILWin64", "CurrentUpdate"){
	int isLoadingA : "mono.dll", 0x002675E0, 0x48, 0xE68, 0x98, 0x98;
	int isLoadingB : "mono.dll", 0x002675E0, 0x48, 0xE68, 0x98, 0x99;
	int restartTrigger : "mono.dll", 0x00264A68, 0x50, 0xF40, 0xB0, 0x5C0;
	int beeBreak : "mono.dll", 0x002675E0, 0x40, 0xE30, 0x90;
}

state("YLILWin64", "LastUpdate"){
	//Keeping track of the last version will help support the game on GoG which is usualy a version behind.
	//No old versions yet. 
}

startup{
	vars.LoggingSettingName = "Debug Logging (Log files help solve auto-splitting issues)";
	vars.SplitOnBeeBreakSettingName = "Split on freeing the bee at the end of a chapter";
	vars.ILRunsModeSettingName = "Reset and start the timer upon restarting a level (For IL runs only. Other actions in the game will also trigger this.)";
	
	settings.Add(vars.LoggingSettingName, false);
	settings.Add(vars.SplitOnBeeBreakSettingName, false);
	settings.Add(vars.ILRunsModeSettingName, false);
}

init{
	//This code identifies different YookaLayleeIL versions with MD5 checksum on the Assembly-CSharp.dll.
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
	{
		using (var s = File.Open(modules.First().FileName.Substring(0, modules.First().FileName.Length-13)
		+ "YLILWin64_Data\\Managed\\Assembly-CSharp.dll", FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
		{
			exeMD5HashBytes = md5.ComputeHash(s); 
		} 
	}
	vars.MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	
	if(vars.MD5Hash == "CB12AA291173D934E2462D6C4537DF6C"){
		version = "LastUpdate";
	}
	else{
		version = "CurrentUpdate";
	}
	
    vars.loading = false;				//Current status of loading or not loading
	
	vars.logFileName = "YLIL.log";
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
			"Version: " + version.ToString() + "\n" +
			"MD5Hash: " + vars.MD5Hash.ToString() + "\n");
		}
		
		vars.timerSecond = timer.CurrentTime.RealTime.Value.Seconds;
	
		if(vars.timerSecond != vars.timerSecondOLD){
			vars.timerSecondOLD = vars.timerSecond;
			
			vars.Log("RealTime: "+timer.CurrentTime.RealTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"GameTime: "+timer.CurrentTime.GameTime.Value.ToString(@"hh\:mm\:ss") + "\n" +
			"current.isLoadingA: " + current.isLoadingA.ToString() + "\n" +
			"current.isLoadingB: " + current.isLoadingB.ToString() + "\n" +
			"loading: " + vars.loading + "\n");
		}
	});
}

start{
	// "loading" should have a value of ### as soon as you play file, then have a value of ### as it loads
	if(current.restartTrigger == 256){	//This happens when the file is selected
		return true;						        //start the timer
	}
}

reset{
	if(current.restartTrigger == 256 && old.restartTrigger == 257 && settings[vars.ILRunsModeSettingName]){
		return true;						        //reset the timer
	}
}

isLoading{
	return vars.loading;					        //stops timer when loading is true
}

split{
	vars.PeriodicLogging();
	
	if(current.beeBreak == 1 && old.beeBreak == 2 && settings[vars.SplitOnBeeBreakSettingName]){
		return true;
	}
}

update{
	//Update loading from loadingControl
	if(current.isLoadingA == 1 || current.isLoadingB == 1){ //Turns loading on
		vars.loading = true;
		
	}
	else if(current.isLoadingA != 1 && current.isLoadingB != 1){ //Turns loading off
		vars.loading = false;
	}
}


// Performance Tool:

// var watch = System.Diagnostics.Stopwatch.StartNew();
// Code to measure
// watch.Stop();
// var elapsedMs = watch.ElapsedMilliseconds;
// print(elapsedMs.ToString());
