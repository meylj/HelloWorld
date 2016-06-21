package com.framework.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.*;

import com.FA.model.TestItemBean;

public class GetCommandInfo {

	private int flag = 0;
	private String str;
	private TestItemBean testItemBean = new TestItemBean();

	public TestItemBean getCommandInfoByTestItem(String testItem) {
		if (null == testItem) {
			return null;
		}
		File f = new File("c:/TestAll/TESTALL.plist");
		if (!f.exists()) {
			return null;
		}
		InputStream instream;
		try {
			instream = new FileInputStream(f);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return null;
		}
		BufferedReader reader = new BufferedReader(new InputStreamReader(
				instream));
		String strLine;
		try {
			while ((strLine = reader.readLine()) != null) {
				switch (flag) {
				case 0:
					this.findKey(strLine, testItem);
					break;
				case 1:
					this.findCommand(strLine);
					break;
				case 2:
					this.putCommandToStr(strLine);
					break;
				case 3:
					this.listAddStr(strLine);
					break;
				case 100:
					return testItemBean;

				default:
					break;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return testItemBean;
	}

	// 0
	private void findKey(String strLine, String testItem) {
		if (strLine.length() > 1) {
			strLine = strLine.substring(1);
			String strItem = "<key>" + testItem + "</key>";
			if (strLine.length() >= strItem.length() && strItem.equals(strLine)) {
				flag = 1;
				testItemBean.setDataFlag(true);
			}
		}
	}

	// 1
	private void findCommand(String strLine) {
		if (strLine.length() > 7) {
			String s = strLine.substring(1, 8);
			if ("</dict>".equals(s)) {
				flag = 100;
			} else {
				if (strLine.contains("<key>COMMAND</key>")) {
					flag = 2;
				}
			}
		}
	}

	// 2
	private void putCommandToStr(String strLine) {
		if (strLine.contains("<string>")) {
			str = strLine.substring(11, strLine.length() - 9);
			flag = 3;
		}
	}

	// 3
	private void listAddStr(String strLine) {
		if (strLine.contains("<string>")) {
			strLine = strLine.substring(11, strLine.length() - 9);
			if ("USB_PORT_0".equals(strLine)) {
				testItemBean.getCommandList().add(str);
				System.out.println("command:" + str);
			}
			flag = 1;
		}
	}

}
