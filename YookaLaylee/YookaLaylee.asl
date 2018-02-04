
//WARNING: This script breaks if you try to play Rextro's games from the main menu.

state("YookaLaylee64", "NEW"){
	int loadingControl : "mono.dll", 0x00295BC8, 0x20, 0x2B8, 0x0, 0xC8, 0x170, 0x20, 0x64; //Values: Loading = 65537, Selecting file from menu = 65536, Not Loading = 1(after loading any level once) or 0(in the menu on game startup)
}

state("YookaLaylee64", "OLD"){
	int loadingControl : "mono.dll", 0x00295BC8, 0x20, 0x220, 0x0, 0x64; //Values: Loading = 65537, Selecting file from menu = 65536, Not Loading = 1(after loading any level once) or 0(in the menu on game startup)
}

init{
	//This code identifies different YookaLaylee versions with MD5 checksum on the Assembly-CSharp.dll. Copied and pasted from Zment's Defy Gravity code.
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
		print("OLD");
		version = "OLD";
	}
	else if(MD5Hash == "CB12AA291173D934E2462D6C4537DF6C"){
		print("NEW");		
		version = "NEW";
	}
	else{
		print("OLD");
		version = "OLD";
	}
	
    vars.loading = false;
}

start{
	
    bool ret = false;
	
	//"loading" should have a value of 665536 as soon as you play file, then have a value of 65537 as it loads
	if(current.loadingControl == 65536){
		return true;
	}

    return ret;
}

isLoading{
	return vars.loading;
}

/*split{
	Last hit on Capital B
}*/

update{
	//print(modules.First().FileName.Substring(0, modules.First().FileName.Length-17) + "YookaLaylee64_Data\\Managed\\Assembly-CSharp.dll"); //DEBUG
	//print(vars.loading.ToString()); //DEBUG
	
	
	//"loadingControl" somtimes goes to 0 in the loading screen, so we use the persistant "vars.loading" to turn it on or off.
	if(current.loadingControl == 65537){ //Turns loading on
		vars.loading = true;
	}
	else if(current.loadingControl == 1){ //Turns loading off
		vars.loading = false;
	}	
}
