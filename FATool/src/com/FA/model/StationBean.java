package com.FA.model;

import java.util.List;

import com.framework.BaseModel;


public class StationBean extends BaseModel{
	
	private String stationName;
	
	public String getStationName()
	{
		return stationName;
	}
	
	public void setStationName(String stationName)
	{
		this.stationName = stationName;
	}
	
	private List testItems;
	
	public List getTestItems()
	{
		return testItems;
	}
	
	public void setTestItems(List testItems)
	{
		this.testItems = testItems;
	}
}
