//  page

$(document).ready(function() {
	// init page
	getPortPath();
	// Concurrent.Thread.create(receiveMessage);
	});

function findTestItem(a) {
	var url = 'getTestItems.action';
	jQuery.post(url, getStation(a.innerText), findTestItemOver, 'json');
}
function getStation(str) {
	var params = {
		station : str
	};
	return params;
}
function findCommand(a) {
	var url = 'getCommands.action';
	jQuery.post(url, getTestItem(a.innerText), aa, 'json');
}
function getTestItem(str) {
	var params = {
		itemName : str
	};
	return params;
}
function findTestItemOver(data) {
	$("form[id=infoForm]").submit();
	if (null != data.strMessage) {
		alert(data.strMessage);
	}
}
function aa(data){
	$("#tbCommand tbody").find("tr").remove();
	var strItem = data.itemName;
	var json = data.tbCommand;
	document.getElementById("lbItemName").innerText=strItem;
	$("#tbCommand").append(json);
}

function checkButton(){
	if(event.keyCode==8) 
	{
		return false;
	}
}
function sleep(n) {
	var start = new Date().getTime();
	while (1)
		if ((new Date().getTime()) - start > n)
			break;
}








// comm

function sendMessage(a) {
	// a.disabled=true;
	// a.readOnly=true;
	var strSend = a.innerText;
	var fso, f;
	fso = new ActiveXObject("Scripting.FileSystemObject");
	// f = fso.OpenTextFile("c:/FATool/Uart_Send.txt", 2, true);
	// f.WriteLine(strSend);
	// f.close();

	var exeGetCommand = "c:/FATool/ConsoleFATool.exe " + strSend;
	try {
		var objShell = new ActiveXObject("wscript.shell");
		objShell.run(exeGetCommand);
		objShell = null;
	} catch (e) {
		alert("can't find '" + exeGetCommand + "'");
	}
	sleep(300);
	for(var i=0;i<21;i++){
		if (fso.FileExists("c:/FATool/Uart_Receive.txt")) {
			f = fso.OpenTextFile("c:/FATool/Uart_Receive.txt", 1);
			var s = ""; 
			while(!f.AtEndOfStream) 
			{
				s += f.ReadLine(); 
			}
			f.close();
			
			document.getElementById("txtSend").value = strSend;
			document.getElementById("txtReceive").value = s;
			
			f = fso.GetFile("c:/FATool/Uart_Receive.txt");
			f.Delete();
			f.close();
			break;
		}else{
			if(19==i){
				alert("time out!");
			}
			sleep(300);
		}
	}
}


function getPortPath() {
	var fso, f, s = "";
	fso = new ActiveXObject("Scripting.FileSystemObject");
	if (!fso.FileExists("c:/FATool/Uart_Path.txt")) {
		var exePath = "c:/FATool/ConsoleGetPath.exe";
		try {
			var objShell = new ActiveXObject("wscript.shell");
			objShell.run(exePath);
			objShell = null;
			sleep(3000);
		} catch (e) {
			alert("can't find '" + exePath + "'");
		}
	}else {
		f = fso.OpenTextFile("c:/FATool/Uart_Path.txt", 1);
		var s = "";
		s += f.ReadLine();
		f.close();
		document.getElementById("lbPath").innerText = "(" + s + ")";
	}
}

function reconnect() {
	var fso, f;
	fso = new ActiveXObject("Scripting.FileSystemObject");
	if (fso.FileExists("c:/FATool/Uart_Path.txt")) {
		f = fso.GetFile("c:/FATool/Uart_Path.txt");
		f.Delete();
	}
	alert("Please use it after 3s.")
	getPortPath();
}
