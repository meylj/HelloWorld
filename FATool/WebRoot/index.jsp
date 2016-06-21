<%@ page language="java" import="java.util.*" pageEncoding="BIG5"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
  	<link rel="stylesheet" type="text/css" href="css/Default.css">
    <base href="<%=basePath%>">
    
    <title>Web FA Tool</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
  </head>
  <script language="javascript" type="text/javascript" src="js/jquery.js"></script>
  <script>
	$(document).ready(function(){
		OpenPort();
	})

	function MSComm1_OnComm()
	     {   
	         widow.alert(MSComm1.CommEvent);
	         if(MSComm1.CommEvent==1)//send
	         {   
	           window.alert("send ok");//send success   
	         }   
	         else if(MSComm1.CommEvent==2)//receive 
	         {   
	        	 window.alert("receive");
	         //  window.alert(MSComm1.CommEvent);//
	         //  window.alert(MSComm1.Input);   
	         //  document.form1.txtReceive.value=document.form1.txtReceive.value + MSComm1.Input;   
	         }  
	     }
	 
	  function OpenPort()   
	  {   
	  	
		  alert(document.getElementById("MSComm1").classid);
		  alert(m_mscom1.GetPortOpen());
		  alert(MSComm1.CommEvent);
	      if(MSComm1.PortOpen==false)   
	      {   
	    	  window.alert("send");
	          MSComm1.PortOpen=true;   
	          MSComm1.Output="R";
	      }   
	      else   
	      {   
	        window.alert ("start received!");   
	      }   
	  }
  </script>
  
  <body style="text-align: center;">
  
  <object classid="clsid:648A5600-2C6E-101B-82B6-000000000014" id="MSComm1" codebase="C:\WINDOWS\system\MSCOMM32.OCX"  
      type="application/x-oleobject" style="left: 54px; top: 14px">  
     <param name="CommPort" value="1 " />  
     <param name="DTREnable" value="1" />  
     <param name="Handshaking" value="0" />  
     <param name="InBufferSize" value="1024" />  
     <param name="InputLen" value="0" />  
     <param name="NullDiscard" value="0" />  
     <param name="OutBufferSize" value="512" />  
     <param name="ParityReplace" value="63" />
     <param name="RThreshold" value="0" />  
     <param name="RTSEnable" value="0" />  
     <param name="BaudRate" value="9600" />  
     <param name="ParitySetting" value="0" />  
     <param name="DataBits" value="8" />  
     <param name="StopBits" value="0" />  
     <param name="SThreshold" value="0 " />  
     <param name="EOFEnable" value="0" />  
     <param name="InputMode" value="0" />  
     </object>
  
 
  </body>
</html>
