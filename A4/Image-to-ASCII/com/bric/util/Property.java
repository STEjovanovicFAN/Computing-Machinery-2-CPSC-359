/*
 * @(#)Property.java
 *
 * $Date: 2014-04-27 23:08:51 -0500 (Sun, 27 Apr 2014) $
 *
 * Copyright (c) 2011 by Jeremy Wood.
 * All rights reserved.
 *
 * The copyright of this software is owned by Jeremy Wood. 
 * You may not use, copy or modify this software, except in  
 * accordance with the license agreement you entered into with  
 * Jeremy Wood. For details see accompanying license terms.
 * 
 * This software is probably, but not necessarily, discussed here:
 * https://javagraphics.java.net/
 * 
 * That site should also contain the most recent official version
 * of this software.  (See the SVN repository for more details.)
 */
package com.bric.util;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.Vector;

public class Property<T> {
	final String name;
	
	T value;
	Vector<PropertyChangeListener> listeners;
	
	boolean isEnabled = true;
	boolean isUserAdjustable = true;
	
	public Property(String propertyName) {
		name = propertyName;
	}
	
	public boolean isEnabled() {
		return isEnabled;
	}
	
	public boolean isUserAdjustable() {
		return isUserAdjustable;
	}
	
	public void setEnabled(boolean b) {
		if(b==isEnabled)
			return;
		isEnabled = b;
		firePropertyChangeListeners(name+".enabled",
				new Boolean(!b), new Boolean(b));
	}
	
	public void setUserAdjustable(boolean b) {
		if(b==isUserAdjustable)
			return;
		isUserAdjustable = b;
		firePropertyChangeListeners(name+".adjustable",
				new Boolean(!b), new Boolean(b));
	}
	
	public final T getValue() {
		return value;
	}
	
	public final String getName() {
		return name;
	}
	
	public final boolean setValue(T obj) {
		validateValue(obj);
		if(obj==null && value==null)
			return false;
		if(obj!=null && value!=null) {
			if(obj.equals(value)) {
				return false;
			}
		}
		Object oldValue = obj;
		value = obj;
		firePropertyChangeListeners(name, oldValue, value);
		return true;
	}
	
	/** Subclasses should override this method to throw
	 * an IllegalArgumentException if a value is inappropriate
	 * for this property.
	 * @param value
	 */
	protected void validateValue(T value) {}
	
	public void addPropertyChangeListener(PropertyChangeListener l) {
		if(listeners==null) {
			listeners = new Vector<PropertyChangeListener>();
		}
		if(listeners.contains(l))
			return;
		listeners.add(l);
	}
	
	public void removePropertyChangeListener(PropertyChangeListener l) {
		listeners.remove(l);
	}

	protected void firePropertyChangeListeners(String propertyName,Object oldValue,Object newValue) {
		if(listeners==null)
			return;
		for(int a = 0; a<listeners.size(); a++) {
			PropertyChangeListener l = listeners.get(a);
			try {
				l.propertyChange(new PropertyChangeEvent(this, propertyName, oldValue, newValue));
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
	}
}
