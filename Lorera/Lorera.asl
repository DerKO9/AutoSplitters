state("Lorera") {
    int roomNumber : "Lorera.exe", 0x6C2DB8;
}

startup {
	vars.EnteredBloodCastle = false;
	vars.EnteredSkydor = false;
	vars.EnteredLurid = false;
	vars.EnteredVoid = false;
}

update {
	
}

start {
	if(current.roomNumber == 83 && old.roomNumber == 2){
		vars.EnteredBloodCastle = false;
		vars.EnteredSkydor = false;
		vars.EnteredLurid = false;
		vars.EnteredVoid = false;
		return true;
	}
}

split {
	if(current.roomNumber == 122 && !vars.EnteredBloodCastle){
		vars.EnteredBloodCastle = true;
		return true;
	}
	if(current.roomNumber == 72 && !vars.EnteredSkydor){
		vars.EnteredSkydor = true;
		return true;
	}
	if(current.roomNumber == 141 && !vars.EnteredLurid){
		vars.EnteredLurid = true;
		return true;
	}
	if(current.roomNumber == 15 && !vars.EnteredVoid){
		vars.EnteredVoid = true;
		return true;
	}
	if(current.roomNumber == 4 && old.roomNumber == 5){
		vars.EnteredVoid = true;
		return true;
	}
}

reset {
	
}
