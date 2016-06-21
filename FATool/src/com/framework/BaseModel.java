package com.framework;

import java.io.Serializable;
import java.util.List;

public class BaseModel implements Serializable{

	private List list;

	public List getList(){
		return this.list;
	}
	public void setList(List list){
		this.list = list;
	}
}
