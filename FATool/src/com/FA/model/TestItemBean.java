package com.FA.model;

import java.util.ArrayList;
import java.util.List;

import com.framework.BaseModel;


public class TestItemBean extends BaseModel {
	private Boolean dataFlag = false;
	
	public Boolean getDataFlag()
	{
		return dataFlag;
	}
	
	public void setDataFlag(Boolean dataFlag)
	{
		this.dataFlag = dataFlag;
	}

	private String testItemName;
	
	public String getTestItemName()
	{
		return testItemName;
	}
	
	public void setTestItemName(String testItemName)
	{
		this.testItemName = testItemName;
	}
	
	private List commandList = new ArrayList();
	
	public List getCommandList()
	{
		return commandList;
	}
	
	public void setCommandList(List commandList)
	{
		this.commandList = commandList;
	}
}
