<%@ page language="java" import="java.util.*" pageEncoding="BIG5"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
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
	<script type="text/x-script.multithreaded-js" src="js/FATool.js"></script>
	<script type="text/javascript" src="js/Concurrent.Thread.js"></script>


	<body style="text-align: center;">
		<div style="width: 800px;">
			<%-- head start --%>
			<div style="height: 50px;"></div>
			<div style="float: left;">
				<div style="float: left;">
					<b>Web FA Tool<label id="lbPath"></label> </b>
				</div>
				<div style="float: right;">
					<input onclick="reconnect();" type="button" value="reconnection"
						class="conbtn6" />
					<input type="button" value="update Station" class="conbtn6" />
					<input type="button" value="update TestAll" class="conbtn6" />
				</div>
				<br />
				=========================================================================================
			</div>
			<br />
			<%-- head end --%>
			<%-- main start --%>
			<s:form id="infoForm" action="getStationList.action">
				<div style="width: 98%;">
					<table width="100%" class="contb3" border="0">
						<tr>
							<td>
								<div style="width: 100%;">
									<%-- first table --%>
									<div style="float: left; width: 180px;">
										<table width="100%" cellpadding="1" cellspacing="1" border="0"
											class="contb">
											<tr height="25px" class="conth">
												<td>
													Stations
												</td>
											</tr>
										</table>
										<div style="width: 100%; height: 350px; overflow: auto;">
											<table width="100%" cellpadding="1" cellspacing="1"
												border="0" class="contb">
												<s:iterator value="stationList" status="station">
													<tr class="contr1">
														<td align="left">
															<a style="cursor: pointer;" onclick="findTestItem(this);"><s:property
																	value="stationName" /></a>
														</td>
													</tr>
												</s:iterator>
											</table>
										</div>
									</div>
									<%-- second table --%>
									<div style="float: left; width: 250px; margin-left: 5px;">
										<table style="table-layout: fixed;" width="100%"
											cellpadding="1" cellspacing="1" border="0" class="contb">
											<tr height="25px" class="conth">
												<td style="overflow: hidden;">
													<s:property value="station" />
												</td>
											</tr>
										</table>
										<div style="width: 100%; height: 350px; overflow: auto;">
											<table id="tbTestItem" width="100%" cellpadding="1"
												cellspacing="1" border="0" class="contb">
												<s:iterator value="testItemList" status="testItem">
													<tr class="contr1">
														<td align="left">
															<a style="cursor: pointer;" onclick="findCommand(this);"><s:property
																	value="testItemName" /></a>
														</td>
													</tr>
												</s:iterator>
											</table>
										</div>
									</div>
									<%-- third table --%>
									<div style="float: left; width: 355px; margin-left: 5px;">
										<table style="table-layout: fixed;" width="100%"
											cellpadding="1" cellspacing="1" border="0" class="contb">
											<tr height="25px" class="conth">
												<td style="overflow: hidden;">
													<label id="lbItemName">Command</label>
												</td>
											</tr>
										</table>
										<div style="width: 100%; height: 350px; overflow: auto;">
											<table id="tbCommand" width="100%" cellpadding="1" cellspacing="1"
												border="0" class="contb">
												<s:iterator value="commandList" status="commandName">
													<tr class="contr1">
														<td align="left">
															<a style="cursor: pointer;" onclick="sendMessage(this);"><s:property />
															</a>
														</td>
													</tr>
												</s:iterator>
											</table>
										</div>
									</div>
								</div>
							</td>
						</tr>
					</table>
				</div>
			</s:form>
			<%-- main end --%>
			<%-- foot start --%>
			<div>
				<table width="750px" cellpadding="1" cellspacing="1" border="0"
					class="contb">
					<tr class="contr1">
						<td width="10%">
							<b><label>
									TX:
								</label> </b>
						</td>
						<td>
							<textarea onkeydown="return checkButton();" id="txtSend" cols="85" rows="3" readonly="readonly"></textarea>
						</td>
					</tr>
					<tr class="contr">
						<td width="10%">
							<b><label>
									RX:
								</label> </b>
						</td>
						<td>
							<textarea onkeydown="return checkButton();" id="txtReceive" cols="85" rows="5" readonly="readonly"></textarea>
						</td>
					</tr>
				</table>
			</div>
			<%-- foot end --%>


		</div>
	</body>
</html>
