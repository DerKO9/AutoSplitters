
state("YookaLaylee64", "CurrentUpdate"){
	//int loadingControl : "", 0x0; We are looking for an address(es) that can detect main menu vs. in-game vs. loading, preferably one address rather than two
}

state("YookaLaylee64", "LastUpdate"){
	//Keeping track of the last version will help support the game on GoG which is usualy a version behind.
	//No old versions yet. 
}

startup{
	vars.LoggingSettingName = "Debug Logging (Log files help solve auto-splitting issues)";
	
	settings.Add(vars.LoggingSettingName, false);
}

init{
	//This code identifies different YookaLayleeIL versions with MD5 checksum on the Assembly-CSharp.dll.
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
	{
		using (var s = File.Open(modules.First().FileName.Substring(0, modules.First().FileName.Length-17)
		+ "YookaLaylee64_Data\\Managed\\Assembly-CSharp.dll", FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
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
			"current.loadingControl: " + current.loadingControl.ToString() + "\n" +
			"loading: " + vars.loading + "\n");
		}
	});
}

start{
	"loading" should have a value of ### as soon as you play file, then have a value of ### as it loads
	if(current.loadingControl == Starting file){	//This happens when the file is selected
		return true;						        //start the timer
	}
}

reset{
	if(return to main menu?){
		return true;
	}
}

isLoading{
	return vars.loading;					        //stops timer when loading is true
}

split{
	vars.PeriodicLogging();
	
	if(Last hit of boss?){
		return true;
	}
}

update{
	//Update loading from loadingControl
	if(current.loadingControl == 65537){ //Turns loading on
		vars.loading = true;
		
	}
	else if(current.loadingControl == 1){ //Turns loading off
		vars.loading = false;
	}
}


// Performance Tool:

// var watch = System.Diagnostics.Stopwatch.StartNew();
// Code to measure
// watch.Stop();
// var elapsedMs = watch.ElapsedMilliseconds;
// print(elapsedMs.ToString());