/*
    $Header:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/ParameterValidator.java-arc   1.3   Dec 21 2015 11:22:42   schwarje  $

    $Log:   //PVCS_FIF/archives/FIF_API/FIF/src/net/arcor/fif/messagecreator/ParameterValidator.java-arc  $
 * 
 *    Rev 1.3   Dec 21 2015 11:22:42   schwarje
 * PMM-100281: added validateSOMIndicator, validatePositiveInteger
 * 
 *    Rev 1.2   Aug 20 2014 07:09:08   schwarje
 * PPM-143282: improved support for regular expression checks of input parameters
 * 
 *    Rev 1.1   Jan 31 2014 12:16:18   schwarje
 * SPN-FIF-000126779: corrected validation of CCB date format
 * 
 *    Rev 1.0   Nov 21 2013 08:50:44   schwarje
 * Initial revision.
*/
package net.arcor.fif.messagecreator;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.regex.Pattern;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.common.FIFException;

import org.apache.log4j.Logger;

public class ParameterValidator {
	
    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(ParameterValidator.class);
    
    /**
     * The date format used by FIF.
     */
    private static String sdfFIFString = "yyyy.MM.dd HH:mm:ss";
    private static String regexFIFDateFormat = "^[0-9]{4}.[0-9]{2}.[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$";

	private static boolean initialized = false;

    private static SimpleDateFormat sdfFIF = new SimpleDateFormat(sdfFIFString);
    
    private static Map<String, String> regularExpressions = new HashMap<String, String>(); 
    
    private static void init () {
    	initialized = true;
    	
    	try {
			// Initializing parameter validations by regular expressions from ini file
			String prefix = "messagecreator.ParameterValidator.";
			Properties props = ClientConfig.getProps();
			for (Entry<Object, Object> entry : props.entrySet()) {
				if (entry.getKey().toString().startsWith(prefix)) {
					String parameter = entry.getKey().toString().substring(prefix.length());
					String regularExpression = ClientConfig.getSetting(entry.getKey().toString());
					regularExpressions.put(parameter, regularExpression);
				}
			}
		} catch (FIFException e) {
			logger.warn("Parameter validations by regular expressions from ini file could not be initialized", e);
		}
    	
    }
    
	public static synchronized void validateRegularExpression(String parameterName, String parameterValue) throws FIFException {		
		if (!initialized) 
			init();	
		if (regularExpressions.containsKey(parameterName)) {
			if (logger.isDebugEnabled())
				logger.debug("Value '" + parameterValue + "' and regular expression '" 
						+ regularExpressions.get(parameterName) + "'");
			if (!Pattern.matches(regularExpressions.get(parameterName), parameterValue))
				throw new FIFInvalidRequestException ("Wrong value '" + parameterValue + "' for a parameter " + parameterName + 
					". Allowed values (regular expression): " + regularExpressions.get(parameterName));
		}
		else
			throw new FIFException ("Regular expression for parameter " + parameterName + " is not defined.");
	}
    
	public static void validateCCMIndicator(String parameterName, String parameterValue) throws FIFException {		
		if (!parameterValue.equals("Y") && !parameterValue.equals("N"))
			throw new FIFInvalidRequestException ("Wrong value for a CCM indicator (Y|N). Parameter: "
					+ parameterName + ", value: " + parameterValue);
	}
    
	public static void validateCCBDate(String parameterName, String parameterValue) throws FIFException {
		
		if (!Pattern.matches(regexFIFDateFormat, parameterValue))
			throw new FIFInvalidRequestException ("Wrong date format for " + parameterValue
					+ " (" + sdfFIFString + ", parameter " + parameterName + ").");
		
		synchronized (sdfFIF) {
			try {
				sdfFIF.parse(parameterValue);
			} catch (ParseException e) {
				throw new FIFInvalidRequestException ("Wrong date format for " + parameterValue
						+ " (" + sdfFIFString + ", parameter " + parameterName + ").");
			}
		}
	}
    
	public static void validateSOMIndicator(String parameterName, String parameterValue) throws FIFException {		
		if (!parameterValue.equals("true") && !parameterValue.equals("false"))
			throw new FIFInvalidRequestException ("Wrong value for a SOM indicator (true|false). Parameter: "
					+ parameterName + ", value: " + parameterValue);
	}
    
	public static void validatePositiveInteger(String parameterName, String parameterValue) throws FIFException {		
		boolean correct = false;
		try {
			int i = Integer.parseInt(parameterValue);
			if (i > 0) correct = true;
		} catch (NumberFormatException e) {}
		if (!correct)
			throw new FIFInvalidRequestException ("Wrong value for a positive integer. Parameter: "
					+ parameterName + ", value: " + parameterValue);
	}
	
}
