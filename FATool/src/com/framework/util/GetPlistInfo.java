package com.framework.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class GetPlistInfo {

	private boolean isStart = false;
	private boolean flag = true;
	private List valueList = new ArrayList();

	public List getStationValue(String stationPath) {
		File f = new File(stationPath);
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
				if (isStart) {
					if (flag) {
						this.findValue(strLine);
					} else {
						this.findDictEnd(strLine);
					}
				}else{
					this.isStart = strLine.contains("<dict>");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		return valueList;
	}

	private void findDictEnd(String strLine) {
		if (strLine.contains("</dict>")) {
			this.flag = true;
		}
	}

	private void findValue(String strLine) {
		if (strLine.contains("<key>")) {
			strLine = strLine.substring(6, strLine.length() - 6);
			valueList.add(strLine);
		} else if (strLine.contains("<dict>")) {
			this.flag = false;
		}
	}
}
