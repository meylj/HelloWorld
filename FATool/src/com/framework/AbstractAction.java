package com.framework;

import java.util.Map;

import com.opensymphony.xwork2.ActionSupport;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts2.interceptor.ServletRequestAware;
import org.apache.struts2.interceptor.ServletResponseAware;
import org.apache.struts2.interceptor.SessionAware;

public class AbstractAction extends ActionSupport implements ServletResponseAware,ServletRequestAware,SessionAware
{
	
	public HttpServletRequest request;
    public HttpServletResponse response;
    public Map<String, String> session;
    public ServletContext application;
    
    public void setServletRequest(HttpServletRequest request) {
        this.request = request;    
    }
    
    public void setServletResponse(HttpServletResponse response) {
        this.response = response;    
    }

    public void setSession(Map session) {
        this.session = session;        
    }

    public void setServletContext(ServletContext application) {
        this.application = application;
    }
    

    
	@Override
	public void validate(){
		
	}
}
