
//WARNING: Load removing breaks if you try to play Rextro's games from the main menu.

state("YookaLaylee64", "NEW"){
	int loadingControl : "mono.dll", 0x00295BC8, 0x20, 0x2B8, 0x0, 0xC8, 0x170, 0x20, 0x64; //Values: Loading = 65537, Selecting file from menu = 65536, Not Loading = 1(after loading any level once) or 0(in the menu on game startup)
	
	float CameraZ: "AkSoundEngine.dll", 0x1614E0; //Z coord of the camera
	float CameraY: "AkSoundEngine.dll", 0x1614DC; //Height of the camera
	float CameraX: "AkSoundEngine.dll", 0x1614D8; //X coord of the camera
	
	int spendablePagies: "YookaLaylee64.exe", 0x012C5790, 0x8, 0x10, 0x28, 0x18, 0x20, 0x20, 0x10, 0x2C; //Number of spendable pagies
}

state("YookaLaylee64", "OLD"){
	int loadingControl : "mono.dll", 0x00295BC8, 0x20, 0x220, 0x0, 0x64; //Values: Loading = 65537, Selecting file from menu = 65536, Not Loading = 1(after loading any level once) or 0(in the menu on game startup)
	
	float CameraY: "AkSoundEngine.dll", 0x1614DC; //height of the camera
	
	int spendablePagies: "YookaLaylee64.exe", 0x012C5790, 0x8, 0x10, 0x28, 0x18, 0x20, 0x20, 0x10, 0x2C //Number of spendable pagies
}

startup{
	settings.Add("Split at start of 2nd phase of CapB fight", false);
	settings.Add("Split at start of 3rd phase of CapB fight", false);
	settings.Add("Split at start of Missiles of CapB fight", false);
	
	//This code creates all the settings for splitting on collecting pagies
	settings.Add("Split on total number of pagies collected", false);
	for(int i=1; i<146; i++){
		settings.Add(i.ToString() + " pagies", false, i.ToString() + " pagies", "Split on total number of pagies collected");
	}
	
	//This code creates all the settings for splitting on loads
	settings.Add("Split on total number of loads", false);
	for(int i=1; i<51; i++){
		settings.Add(i.ToString() + " loads", false, i.ToString() + " loads", "Split on total number of loads");
	}

}

init{
	//This code identifies different YookaLaylee versions with MD5 checksum on the Assembly-CSharp.dll. Copied and pasted from Zment's Defy Gravity asl script. Theres probably a simpler way but its already made so meh.
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
	{
		using (var s = File.Open(modules.First().FileName.Substring(0, modules.First().FileName.Length-17) + "YookaLaylee64_Data\\Managed\\Assembly-CSharp.dll", FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
		{
			exeMD5HashBytes = md5.ComputeHash(s); 
		} 
	}
	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	//print(MD5Hash.ToString()); //DEBUG
	
	if(MD5Hash == "79E639895D675A54A7C97B199CE33128"){
		version = "OLD";
	}
	else if(MD5Hash == "CB12AA291173D934E2462D6C4537DF6C"){		
		version = "NEW";
	}
	else{
		version = "NEW";
	}
	
    vars.loading = false;				//Current status of loading or not loading
	vars.OLDloading = false;			//Old loading is used to detect a change in loading status and then is updated immediatly
	vars.accumulativeLoading = 0;		//Total number of loads in the run so far
	
	vars.accumulativePagies = 0;		//Total number of pagies collected in the run so far
	vars.OLDaccumulativePagies = 0;		//
	
	vars.accumulativePhase3CapBDialogues = 0;
	vars.OLDaccumulativePhase3CapBDialogues = 0;
}

start{
	//"loading" should have a value of 665536 as soon as you play file, then have a value of 65537 as it loads
	if(current.loadingControl == 65536){	//This happens when the file is selected
	
		vars.accumulativeLoading = 0; 		//resets total loads and pagies after starting new run
		vars.accumulativePagies = 0;		//
		vars.OLDaccumulativePagies = 0;		//
		vars.accumulativePhase3CapBDialogues = 0;
		vars.OLDaccumulativePhase3CapBDialogues = 0;
		
		return true;						//start the timer
	}
}

isLoading{
	return vars.loading;					//stops timer when loading is true
}

split{
	//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>current.CameraX: " + current.CameraX.ToString()); //DEBUG
	//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>current.CameraY: " + current.CameraY.ToString()); //DEBUG
	//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>current.CameraZ: " + current.CameraZ.ToString()); //DEBUG
	
	//print(((current.CameraX >= 4.699999809) && (current.CameraX <= 4.7)).ToString());
	//print(((current.CameraZ >= -2.3) && (current.CameraZ <= -2.299999952)).ToString());
	
	//Splits on the start of phase 2
	if(!(old.CameraX >= 4.699999809 && old.CameraX <= 4.7) && (current.CameraX >= 4.699999809 && current.CameraX <= 4.7)){
		if((current.CameraY >= 9.8) && (current.CameraY <= 9.800000191)){
			if((current.CameraZ >= -2.3) && (current.CameraZ <= -2.299999952)){
				vars.accumulativePhase3CapBDialogues = 0;
				vars.OLDaccumulativePhase3CapBDialogues = 0;
				if(settings["Split at start of 2nd phase of CapB fight"]){
					return true;
				}
			}
		}
	}
	
	//Splits on the start of phase 3
	if(!(old.CameraX >= 13.31 && old.CameraX <= 13.31000042) && (current.CameraX >= 13.31 && current.CameraX <= 13.31000042)){
		if((current.CameraY >= 12.69) && (current.CameraY <= 12.69000054)){
			if((current.CameraZ >= -3.460000039) && (current.CameraZ <= -3.46)){
				if(settings["Split at start of 3rd phase of CapB fight"]){
					return true;
				}
			}
		}
	}
	
//	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>current.CameraX: " + ((current.CameraX >= 31.71999931 && current.CameraX <= 31.72))); //DEBUG
//	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>current.CameraY: " + ((current.CameraY >= 20.95) && (current.CameraY <= 20.95000077))); //DEBUG
//	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>current.CameraZ: " + ((current.CameraZ >= 48.33) && (current.CameraZ <= 48.33000184))); //DEBUG
	
	//Splits on the start of Missiles
	if(!(old.CameraX >= 31.71999931 && old.CameraX <= 31.72) && (current.CameraX >= 31.71999931 && current.CameraX <= 31.72)){
		if((current.CameraY >= 20.95) && (current.CameraY <= 20.95000077)){
			if((current.CameraZ >= 48.33) && (current.CameraZ <= 48.33000184)){
				vars.accumulativePhase3CapBDialogues++;
				print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>vars.accumulativePhase3CapBDialogues: " + vars.accumulativePhase3CapBDialogues.ToString());
				if(settings["Split at start of Missiles of CapB fight"]){
					if((vars.accumulativePhase3CapBDialogues == 4) && (vars.OLDaccumulativePhase3CapBDialogues == 3)){
						vars.OLDaccumulativePhase3CapBDialogues = vars.accumulativePhase3CapBDialogues;
						return true;
					}
				}
				vars.OLDaccumulativePhase3CapBDialogues = vars.accumulativePhase3CapBDialogues;
			}
		}
	}
	
	float XZMagnitude = (float)Math.Sqrt(Math.Pow(current.CameraX, 2) + Math.Pow(current.CameraZ, 2)); 
	//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>XZMagnitude: " + XZMagnitude.ToString()); //DEBUG
	//Splits on last hit of Capital B. The Camera goes to this specific height on the last hit. It is hard to accidently trigger.
	if((current.CameraY >= 17.09999 && current.CameraY <= 17.10001) && !(old.CameraY >= 17.09999 && old.CameraY <= 17.10001)){      //If the camera height is really close to 17.01 
		//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>height is good"); //DEBUG
		//float XZMagnitude = Math.Sqrt(Math.Pow(current.CameraX, 2) + Math.Pow(current.CameraZ, 2)); 
		//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>XZMagnitude: " + XZMagnitude.ToString()); //DEBUG
		if(XZMagnitude >= 30 && XZMagnitude <= 42.95){																			//and the radius of the camera is close to 42.85
			return true;																											//split 
		}
		
	}
	
	//Split on Pagie
	if(vars.accumulativePagies > vars.OLDaccumulativePagies){				//If pagie collected
		vars.OLDaccumulativePagies = vars.accumulativePagies;				
		if(settings[vars.accumulativePagies.ToString() + " pagies"]){		//If total pagies is a selected number
			return true;													//split
		}
		
	}
	
	//Split on Load
	if((vars.OLDloading == false) && (vars.loading == true)){       		//If the start of load
		vars.accumulativeLoading++;											//total number of loads increases
		if(settings[vars.accumulativeLoading.ToString() + " loads"]){ 		//if total loads is a selected number
			vars.OLDloading = vars.loading;
			return true;													//split
		}
	}
	vars.OLDloading = vars.loading;
}

update{
	//"loadingControl" somtimes goes to 0 in the loading screen and makes timer stutter, so we use the persistant "vars.loading" to turn it on or off.
	if(current.loadingControl == 65537){ //Turns loading on
		vars.loading = true;
	}
	else if(current.loadingControl == 1){ //Turns loading off
		vars.loading = false;
	}
	
	
	if(current.spendablePagies == old.spendablePagies+1){			//If pagie is collected, increment the number of pagies collected
		vars.accumulativePagies = vars.accumulativePagies + 1;
		
		//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>accumulativePagies: " + vars.accumulativePagies.ToString()); //DEBUG
		//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>spendablePagies: " + current.spendablePagies.ToString()); //DEBUG
	}
	
}
