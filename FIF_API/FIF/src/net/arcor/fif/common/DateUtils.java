package net.arcor.fif.common;

import static java.util.regex.Pattern.compile;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.arcor.fif.client.ClientConfig;
import net.arcor.fif.db.SomTemplate;
import net.arcor.fif.db.SomTemplateDataAccess;
import net.arcor.fif.db.PSMDataAccess;

import org.apache.log4j.Logger;


/**
 * This class contains date utilities.
 * 
 * @author goethalo
 */
public class DateUtils {
	protected static Logger logger = Logger.getLogger(DateUtils.class);

	private static Map<String, String> somTemplates = new HashMap<String, String> ();
	private static Map<String, String> somSubTemplates = new HashMap<String, String> ();
	private static boolean somTemplatesLoaded = false;
	private static Map<String, String> configServCharDataType = new HashMap<String, String> ();
	
    /**
     * The date format used by FIF.
     */
    private static SimpleDateFormat sdfFIF = new SimpleDateFormat(
            "yyyy.MM.dd HH:mm:ss");

    /**
     * The date format used by FIF with zero seconds.
     */
    private static SimpleDateFormat sdfFIFZeroSeconds = new SimpleDateFormat(
            "yyyy.MM.dd 00:00:00");

    /**
     * The date format used by OPM.
     */
    private static SimpleDateFormat sdfOPM = new SimpleDateFormat("dd.MM.yyyy");

    /**
     * The date format used by KBA.
     */
    private static SimpleDateFormat sdfKBA = new SimpleDateFormat("yyyy-MM-dd");

    /**
     * The date format used by the SOM.
     */
    private static SimpleDateFormat sdfSOM = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");

    /**
     * The date format used by 1und1.
     */
    private static SimpleDateFormat sdf1Und1 = new SimpleDateFormat("yyyyMMdd");

    /**
     * The override system date for retrieving current date from XSLT. Only used in Testframework.
     */
    private static Date overrideDateTime = null;

    /**
     * Creates a new FIF date based on a passed in FIF date and an offset. This
     * method can be called from the XSLT processor.
     * 
     * @param inputDate
     *            the date in FIF format to be modified.
     * @param toModify
     *            the modification to be performed. Currently only DATE and TIME
     *            are supported.
     * @param offset
     *            the offset to be added/removed to the input date. Currently
     *            this is the number of days to add (+) or to substract (-) for
     *            DATE and the number of minutes to add (+) or to substract for
     *            TIME (-).
     * @return the new date in FIF format.
     */
    public static String createFIFDateOffset(String inputDate, String toModify,
            String offset) {
        // Check preconditions
        if (inputDate == null) {
            return (new String());
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdfFIF) {
                date = sdfFIF.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Create the gregorian calendar
        GregorianCalendar calendar = new GregorianCalendar();
        calendar.setTime(date);

        // Perform the operation
        String newDate = null;
        if ((toModify != null) && (toModify.equals("DATE"))) {
            calendar.add(Calendar.DATE, Integer.parseInt(offset));
            date = calendar.getTime();
            synchronized (sdfFIF) {
                newDate = sdfFIF.format(date);
            }
        } else if ((toModify != null) && (toModify.equals("TIME"))) {
            calendar.add(Calendar.MINUTE, Integer.parseInt(offset));
            date = calendar.getTime();
            synchronized (sdfFIF) {
                newDate = sdfFIF.format(date);
            }
        } else if ((toModify != null) && (toModify.equals("MONTH"))) {
            calendar.add(Calendar.MONTH, Integer.parseInt(offset));
            date = calendar.getTime();
            synchronized (sdfFIF) {
                newDate = sdfFIF.format(date);
            }
        } else {
            return (new String());
        }

        return newDate;
    }

    /**
     * Converts a date string in FIF format to a date string in OPM format.
     * 
     * @param inputDate
     *            the date string in FIF format to convert.
     * @return the date string in OPM format.
     */
    public static String createOPMDate(String inputDate) {
        // Check preconditions
        if (inputDate == null || inputDate.length() == 0) {
            Date defaultDate = new Date();
            return (new String(sdfOPM.format(defaultDate)));
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdfFIF) {
                date = sdfFIF.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Return the date in OPM format
        return (sdfOPM.format(date));
    }

    /**
     * Converts a date string in FIF format to a date string in OPM format.
     * 
     * @param inputDate
     *            the date string in FIF format to convert.
     * @return the date string in OPM format.
     * @throws FIFException 
     */
    public static String createSOMDate(String inputDate) throws FIFException {    	
    	// Check preconditions
        if (inputDate == null || inputDate.length() == 0) {
            Date defaultDate = new Date();
            return (new String(sdfSOM.format(defaultDate)));
        }
    	
        Date date = null;
        
    	if (inputDate.startsWith("datetime:") || inputDate.startsWith("date:")) {
			String pattern = "(datetime|date):[\\-|\\+]{0,1}[0-9]+:(hour|minute|date)";
			if (!inputDate.matches(pattern))
				throw new FIFException("Wrong format for date replacement: " + inputDate + ", "+ pattern);
			
			String[] parts = inputDate.split(":");
			if (parts.length != 3)
				return null;
			int offset = Integer.parseInt(parts[1].trim());
			String offsetUnit = parts[2].trim();
		    GregorianCalendar calendar = new GregorianCalendar();
		    calendar.setTime(new Date());
		    calendar.set(Calendar.MILLISECOND, 0);
			if (offsetUnit.equals("hour"))
				calendar.add(Calendar.HOUR, offset);
			else if (offsetUnit.equals("date"))
				calendar.add(Calendar.DATE, offset);
			else if (offsetUnit.equals("minute"))
				calendar.add(Calendar.MINUTE, offset);
			date = calendar.getTime();
		}

    	else {
	        try {
	            synchronized (sdfFIF) {
	                date = sdfFIF.parse(inputDate);
	            }
	        } catch (ParseException e) {}
    	}
    	
    	if (inputDate.startsWith("date:"))
    		return (date == null) ? null : sdfKBA.format(date);
    	else
    		return (date == null) ? null : sdfSOM.format(date);
    }

    /**
     * Converts a date string in FIF format to a date string in KBA format.
     * 
     * @param inputDate
     *            the date string in FIF format to convert.
     * @return the date string in KBA format.
     */
    public static String createKBADate(String inputDate) {
        // Check preconditions
        if (inputDate == null) {
            return (new String());
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdfFIF) {
                date = sdfFIF.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Return the date in KBA format
        return (sdfKBA.format(date));
    }

    /**
     * Converts a date string in FIF format to a date string in 1und1 format.
     * 
     * @param inputDate
     *            the date string in FIF format to convert.
     * @return the date string in 1und1 format.
     */
    public static String create1Und1Date(String inputDate) {
        // Check preconditions
        if (inputDate == null) {
            return (new String());
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdfFIF) {
                date = sdfFIF.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Return the date in KBA format
        return (sdf1Und1.format(date));
    }

    /**
     * Converts a date string in OPM format to a date string in FIF format.
     * 
     * @param inputDate
     *            the date string in OPM format to convert.
     * @return the date string in FIF format.
     */
    public static String convertOPMDate(String inputDate) {
        // Check preconditions
        if (inputDate == null) {
            return (new String());
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdfOPM) {
                date = sdfOPM.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Return the date in OPM format
        return (sdfFIF.format(date));
    }

    /**
     * Converts a date string in 1und1 format to a date string in FIF format.
     * 
     * @param inputDate
     *            the date string in 1und1 format to convert.
     * @return the date string in FIF format.
     */
    public static String convert1Und1Date(String inputDate) {
        // Check preconditions
        if (inputDate == null) {
            return (new String());
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdf1Und1) {
                date = sdf1Und1.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Return the date in OPM format
        return (sdfFIF.format(date));
    }

    public static String SOM2OPMDate(String inputDate) {
        // Check preconditions
        if (inputDate == null) {
            return (new String());
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdfKBA) {
                date = sdfKBA.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Return the date in OPM format
        return (sdfOPM.format(date));
    }

    public static String SOM2CCBDate(String inputDate) {
        // Check preconditions
        if (inputDate == null) {
            return (new String());
        }

        // Parse the FIF date
        Date date = null;
        try {
            synchronized (sdfKBA) {
                date = sdfKBA.parse(inputDate);
            }
        } catch (ParseException e) {
            return (new String());
        }

        // Return the date in OPM format
        return (sdfFIF.format(date));
    }

    /**
     * Returns the current date in FIF format.
     * 
     * @return the current date in FIF format, with the time stamp set to 00:00:00.
     */
    public static String getCurrentDate() {
        return (getCurrentDate(true));
    }

    /**
	 * Returns the current date in FIF format.
	 * 
	 * @param zeroTime indicates whether the time should be set to 00:00:00.
	 * @return the current date in FIF format
	 */
	public static String getCurrentDate(boolean zeroTime) {
		String current = "";
		if (zeroTime) {
			synchronized (sdfFIFZeroSeconds) {
				current = sdfFIFZeroSeconds
						.format((overrideDateTime == null) ? new Date()
								: overrideDateTime);
			}
		} else {
			synchronized (sdfFIF) {
				current = sdfFIF.format((overrideDateTime == null) ? new Date()
						: overrideDateTime);
			}
		}
		return current;
	}

    /**
	 * Returns the passed in date in FIF format.
	 * 
	 * @param date the date to format.
	 * @return the date in FIF format
	 */
    public static String getDateInFifFormat (Date date){
    	return sdfFIF.format(date);
    }

	/**
	 * @param overrideDateTime
	 */
	public static void setOverrideDateTime(Date overrideDateTime) {
		DateUtils.overrideDateTime = overrideDateTime;
	}

	/**
	 * @param overrideDateTime
	 */
	public static void setOverrideDateTime(String overrideDateTimeString) {
		try {
			if (overrideDateTimeString != null)
				DateUtils.overrideDateTime = sdfFIF.parse(overrideDateTimeString);
		} catch (ParseException e) {}
	}

    /**
     * compares two strings, e.g. date strings.
     * 
     * @param string1 the first string to compare
     *        string2 the second string to compare
     * @return -1 if string1 < string2
     *          0 if string1 = string2
     *          1 if string1 > string2
     */
    public static String compareString(String string1, String string2) {
    	if (string1 == null)
    		string1 = "";
    	if (string2 == null)
    		string2 = "";
    	int result = 0;
    	if (string1.compareTo(string2) < 0)
    		result = -1;
    	else if (string1.compareTo(string2) > 0)
    		result = 1;
        return (new Integer(result)).toString();
    }

    /**
     * transforms the string to upper case
     * 
     * @param string the string to change
     * @return the string in upper case
     */
    public static String toUpperCase(String string) {
    	if (string == null)
    		return "";
    	else return string.toUpperCase();
    }

    /**
     * transforms the string to upper case
     * 
     * @param string the string to change
     * @return the string in upper case
     */
    public static String matchPattern(String regex,String input) {
    	if (input == null || regex == null)
    		return "N";
    	
    	if (Pattern.matches(regex, input))
    		return "Y";
    	else
    		return "N";
    }
    
    /**
     * transforms the string to upper case
     * 
     * @param string the string to change
     * @return the string in upper case
     */
    public static String findCustomerNumberInSom(String input) {
    	if (input == null)
    		return "";
    	
    	input = input.replaceAll("\\r\\n", ""); 
    	input = input.replaceAll("\\n", ""); 
    	Pattern pattern = compile("<customer {1}.*ID.*</customer>{1}");
    	Matcher matcher = pattern.matcher(input);

    	 if(matcher.find()) {
			String custNode= matcher.group();			
            if(custNode != null){
            	pattern = compile("<existing>{1}.{12}</existing>{1}");
            	matcher = pattern.matcher(custNode);
            	if(matcher.find()){            	
            		if(matcher.group()!=null){            			
            		     return matcher.group().substring(10, 22);
            		}            		
            	}
            }				
		}
	    return "";
    }
 
	private static Map<String, String> stringMap = new HashMap<String, String>();

    public static String initReplace(String inputString, String id) {
    	String mapID = id + System.currentTimeMillis();
    	stringMap.put(mapID, inputString);
    	return mapID;
    }
    
    public static void replace(String id, String searchPattern, String replacement) {
    	logger.info("Replacing '" + searchPattern
    			+ "' by '" + replacement
    			+ "' in string with ID '" + id
    			+ "'.");
    	stringMap.put(id, (stringMap.get(id)).replaceAll(searchPattern, Matcher.quoteReplacement(replacement)));
    }
    
    public static String getReplacedString(String id) {
    	return stringMap.get(id);
    }

    public static void endReplace(String id) {
    	stringMap.remove(id);
    }

    public synchronized static String getSomTemplate(String id) throws FIFException {
    	if (id.equals("null")) return "";
    	logger.info("Reading SOM-Template: " + id);
    	if (!somTemplatesLoaded)
    		loadSomTemplates();
    	if (somTemplates.containsKey(id))
    		return somTemplates.get(id);
    	else
    		throw new FIFException("SOM-Template " + id	+ " doesn't exist in reference data.");
    }

    public synchronized static String getSomSubTemplate(String id) throws FIFException {
    	if (id.equals("null")) return "";
    	logger.info("Reading SOM-Subtemplate: " + id);
    	if (!somTemplatesLoaded)
    		loadSomTemplates();
    	if (somSubTemplates.containsKey(id))
    		return somSubTemplates.get(id);
    	else
    		throw new FIFException("SOM-Subtemplate " + id	+ " doesn't exist in reference data.");
    }

	private static void loadSomTemplates() throws FIFException {				
		logger.info("Loading SOM Templates.");
		SomTemplateDataAccess stda = new SomTemplateDataAccess(
				ClientConfig.getSetting("messagecreator.ReferenceDataDBAlias")); 
		ArrayList<SomTemplate> somTemplatesList = stda.fetchSomTemplates();
		for (SomTemplate somTemplate : somTemplatesList) {
			if (somTemplate.isSubTemplate())
				somSubTemplates.put(somTemplate.getSomTemplateID(), somTemplate.getSomTemplate());
			else
				somTemplates.put(somTemplate.getSomTemplateID(), somTemplate.getSomTemplate());
		}
		somTemplatesLoaded = true;
	}

    public synchronized static String getDataTypeForServiceCharCode(String serviceCharCode) throws FIFException {
		String dataType = null;
		
		if(configServCharDataType.containsKey(serviceCharCode))
			dataType = configServCharDataType.get(serviceCharCode);
		else {
			PSMDataAccess psmda = new PSMDataAccess(
					ClientConfig.getSetting("messagecreator.PSMDBAlias"));
			dataType = psmda.getDataTypeForServiceCharCode(serviceCharCode);
			if(dataType == null) {
	    		dataType = "NOT_FOUND";
				logger.info("DateUtils::getDataTypeForServiceCharCode could not find dataType for " + serviceCharCode + ".");
			}
			configServCharDataType.put(serviceCharCode, dataType);
		}
		return dataType;
    }

}