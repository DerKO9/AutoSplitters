state("Toybox64"){
	float XPos: "mono.dll", 0x00261A28, 0x138, 0xEF0, 0xB8, 0x18, 0x40;
	float YPos: "mono.dll", 0x00261A28, 0x138, 0xEF0, 0xB8, 0x18, 0x44;
	float ZPos: "mono.dll", 0x00261A28, 0x138, 0xEF0, 0xB8, 0x18, 0x48;
	int QuillCount: "mono.dll", 0x00261110, 0x740, 0x28, 0x18, 0x28, 0x50;
	int PagieCount: "mono.dll", 0x00261110, 0x740, 0x28, 0x18, 0x28, 0x54;
	int IsDialogComplete: "mono.dll", 0x00295BC8, 0x20, 0x268, 0x0, 0x30, 0x18, 0x20, 0x64;
}

startup{
	vars.QuillsSplitSettingName = "Split on collecting X amount of total quills";
	vars.PagieSplitSettingName = "Split on collecting the pagie";
	
	//This code creates all the settings for splitting on collecting quills
	settings.Add(vars.QuillsSplitSettingName, false);
	for(int i=1; i<100; i++){
		settings.Add(i.ToString() + " pagies", false, i.ToString() + " pagies", vars.QuillsSplitSettingName);
	}
	settings.Add(vars.PagieSplitSettingName, true);
}

start{
	if(current.IsDialogComplete == 1 && old.IsDialogComplete == 0 
		&& current.QuillCount == 0){										//This happens when the player exits the first dialog	
		return true;														//start the timer
	}
}

split{
	//Split on quill
	if(current.QuillCount == old.QuillCount + 1){							//If quill collected			
		if(settings[current.QuillCount.ToString() + " pagies"]){			//If total quills is a selected number
			print("Split on " + current.QuillCount + " quills");
			return true;													//split
		}
	}
	else if(current.QuillCount == old.QuillCount + 2){						//If 2 quills collected at the same time
		if(settings[current.QuillCount.ToString() + " pagies"]				
			|| settings[(current.QuillCount - 1).ToString() + " pagies"]){	//If total quills is a selected number
			print("Split on " + current.QuillCount + " quills");
			return true;													//split
		}
	}
	
	//Split on pagie
	if(current.PagieCount == 1 && old.PagieCount != 1){						//If pagie collected			
		if(settings[vars.PagieSplitSettingName]){							//If split on pagie setting is selected
			print("Split on pagie collected");
			return true;													//split
		}
	}
}

reset{
	if(current.XPos == 0 && current.YPos == 0 && current.ZPos == 0 && current.QuillCount == 0) {
		return true;
	}
}

update{
	// print("current.XPos: " + current.XPos.ToString());
	// print("current.YPos: " + current.YPos.ToString());
	// print("current.ZPos: " + current.ZPos.ToString());
	// print("current.QuillCount: " + current.QuillCount.ToString());
	// print("current.PagieCount: " + current.PagieCount.ToString());
	// print("current.IsDialogComplete: " + current.IsDialogComplete.ToString());
	// print(" ");
	// print("------------------------");
	// print(" ");
}