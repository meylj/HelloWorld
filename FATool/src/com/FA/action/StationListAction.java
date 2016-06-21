package com.FA.action;

import java.io.File;
import java.util.*;

import javax.servlet.http.HttpSession;

import com.FA.model.StationBean;
import com.FA.model.TestItemBean;
import com.framework.AbstractAction;
import com.framework.util.*;

public class StationListAction extends AbstractAction {
	private String strMessage;

	public String getStrMessage() {
		return strMessage;
	}

	public void setStrMessage(String strMessage) {
		this.strMessage = strMessage;
	}

	private List stationList;

	public List getStationList() {
		return stationList;
	}

	private List testItemList;

	public List getTestItemList() {
		return testItemList;
	}

	private List commandList;

	public List getCommandList() {
		return commandList;
	}

	private String station = "TestItem";

	public void setStation(String station) {
		this.station = station.trim();
	}

	public String getStation() {
		return station;
	}

	private String itemName = "Command";

	public String getItemName() {
		return itemName;
	}

	public void setItemName(String itemName) {
		this.itemName = itemName.trim();
	}

	private String tbCommand = "";

	public String getTbCommand() {
		return tbCommand;
	}

	// get all stations, show first table
	public String getStations() throws Exception {
		File f = new File("c:/Stations");
		File[] files = f.listFiles();
		stationList = new ArrayList();
		for (int i = 0; i < files.length; i++) {
			StationBean station = new StationBean();
			String stationName = files[i].getName();
			station.setStationName(stationName.substring(0, stationName
					.length() - 6));
			stationList.add(station);
			System.out.println(stationName);
		}
		System.out.println(station);
		getTestItems();
		System.out.println(itemName);
		getCommandByItem();

		return SUCCESS;
	}

	// show second table
	private void getTestItems() {
		if (session.get("station") == null && "TestItem" == station) {
			System.out.println("no station message");
		} else {
			if ("TestItem" != station) {
				session.put("station", station);
				itemName = "Command";
				session.remove("itemName");
			} else {
				station = session.get("station");
			}
			GetPlistInfo gpi = new GetPlistInfo();
			testItemList = new ArrayList();
			List list = gpi
					.getStationValue("c:/Stations/" + station + ".plist");
			for (int i = 0; i < list.size(); i++) {
				TestItemBean testItem = new TestItemBean();
				testItem.setTestItemName(list.get(i).toString());
				testItemList.add(testItem);
				System.out.println(list.get(i));
			}

		}
	}

	// show third table
	private void getCommandByItem() {
		if (null == session.get("itemName") && "Command" == itemName) {
			System.out.println("no item message");
		} else {
			if ("Command" != itemName) {
				session.put("itemName", itemName);
			} else {
				itemName = session.get("itemName");
			}
			GetCommandInfo gci = new GetCommandInfo();
			commandList = new ArrayList();
			TestItemBean tItem = gci.getCommandInfoByTestItem(itemName);
			if (null == tItem) {
				return;
			}
			if (tItem.getDataFlag()) {
				commandList = tItem.getCommandList();
				for (Object obj : commandList) {
					tbCommand += "<tr class='contr1'><td align='left'><a style='cursor: pointer;' onclick='sendMessage(this);'>"
							+ obj.toString() + "</a></td></tr>";
				}
			} else {
				commandList = null;
				if (null != itemName && !itemName.equals(""))
					strMessage = "can't find  '" + itemName + "'";
			}

		}
	}

	public String getItems() throws Exception {
		return SUCCESS;
	}

	public String getCommands() throws Exception {
		return SUCCESS;
	}
}
