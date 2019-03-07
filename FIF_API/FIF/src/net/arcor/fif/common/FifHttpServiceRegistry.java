package net.arcor.fif.common;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;


public class FifHttpServiceRegistry {
    protected final static Map<String, FifHttpServiceHandler> internalRegistry = new HashMap<String, FifHttpServiceHandler>();

	public static Map<String, FifHttpServiceHandler> getInternalregistry() {
		return internalRegistry;
	}

    public void setFifHttpServiceHandler(final Collection<FifHttpServiceHandler> serviceConfigs) {
        for (FifHttpServiceHandler serviceConfigToAdd : serviceConfigs) {
            String serviceName = serviceConfigToAdd.getSoapAction();
            internalRegistry.put(serviceName, serviceConfigToAdd);
        }
    }
}
