
//WARNING: Load removing breaks if you try to play Rextro's games from the main menu.

state("YookaLaylee64", "NEW"){
	int loadingControl : "mono.dll", 0x00295BC8, 0x20, 0x2B8, 0x0, 0xC8, 0x170, 0x20, 0x64; //Values: Loading = 65537, Selecting file from menu = 65536, Not Loading = 1(after loading any level once) or 0(in the menu on game startup)
	
	float CameraY: "AkSoundEngine.dll", 0x1614DC; 
}

state("YookaLaylee64", "OLD"){
	int loadingControl : "mono.dll", 0x00295BC8, 0x20, 0x220, 0x0, 0x64; //Values: Loading = 65537, Selecting file from menu = 65536, Not Loading = 1(after loading any level once) or 0(in the menu on game startup)
	
	float CameraY: "AkSoundEngine.dll", 0x1614DC;
}

init{
	//This code identifies different YookaLaylee versions with MD5 checksum on the Assembly-CSharp.dll. Copied and pasted from Zment's Defy Gravity asl script.
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
		version = "OLD";
	}
	
    vars.loading = false;
}

start{
	//"loading" should have a value of 665536 as soon as you play file, then have a value of 65537 as it loads
	if(current.loadingControl == 65536){
		return true;
	}
}

isLoading{
	return vars.loading;
}

split{
	//The Camera goes to this specific height on the last hit. It is hard to accidently trigger.
	if((current.CameraY >= 17.09999 && current.CameraY <= 17.10001) && !(old.CameraY >= 17.09999 && old.CameraY <= 17.10001)){
		return true;
	}
}

update{
	//"loadingControl" somtimes goes to 0 in the loading screen and makes timer stutter, so we use the persistant "vars.loading" to turn it on or off.
	if(current.loadingControl == 65537){ //Turns loading on
		vars.loading = true;
	}
	else if(current.loadingControl == 1){ //Turns loading off
		vars.loading = false;
	}	
}
