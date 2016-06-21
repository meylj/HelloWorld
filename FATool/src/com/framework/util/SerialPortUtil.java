package com.framework.util;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

import javax.comm.*;

public class SerialPortUtil {

	public List<CommPortIdentifier> listPoetChoice() {
		List list = new ArrayList<CommPortIdentifier>();
		CommPortIdentifier porId;
		Enumeration en = CommPortIdentifier.getPortIdentifiers();
		while (en.hasMoreElements()) {
			porId = (CommPortIdentifier) en.nextElement();
			if (porId.getPortType() == CommPortIdentifier.PORT_PARALLEL) {
				list.add(porId);
				System.out.println(porId.getName());
				System.out.println(porId.getPortType());
			}
		}

		return list;
	}

	public Boolean openPort(String portName) {
		Boolean flag = true;
		CommPortIdentifier portId = null;
		SerialPort serialPort = null;
		try {
			portId = CommPortIdentifier.getPortIdentifier("COM3");
		} catch (NoSuchPortException e) {
			flag = false;
			e.printStackTrace();
		}
		try {
			serialPort = (SerialPort) portId.open("testApp", 3000);
		} catch (PortInUseException e) {
			flag = false;
			e.printStackTrace();
		}

		System.out.println(serialPort.getName());
		return flag;
	}
}
