/*
 * $ Header: $
 *
 * $ Log: $
 */
package net.arcor.fif.common;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;

import org.apache.log4j.Logger;

/**
 * Class for reading CSM files.
 * @author makuier
 */
public class CSMReader {
	
	
	
	
	

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/
	// Key = column name
	// value = start position , end position , split pattern, field number, desired value, Format , prefix
	
	
	final static HashMap<String , String[]> columnMapping = new HashMap<String , String[]>() {
		private static final long serialVersionUID = 1L;
		{ 			
			
			put("actionFD",new String[] {"141","227",null,null,"FINAL DEACTIVATION",null,null});
		    put("actionSS",new String[] {"141","227",null,null,"SUSPEND SUBSCRIPTION",null,null});
			put("actionCCD",new String[] {"141","227",null,null,"CHANGE CARRIER DATA",null,null});	
			put("actionRS",new String[] {"141","227",null,null,"RESUME SUBSCRIPTION",null,null});
			put("accessNumber",new String[] {"641","687","\\D+","1",null,null,"49"});
			put("desiredDate",new String[]  {"241","255",null,null,null,"DATE",null});
			//-	orderType
		    put("orderType",new String[] {"141","227",null,null,"CSM Order Type",null,null});
			//This parameter will return action name equal to the CSM Order Type (ìAuftragsartî) from the CSM file: FINAL DEACTIVATION, RESUME SUBSCRIPTION, SUSPEND SUBSCRIPTION, CHANGE CARRIER DATA.
			//	Name
		   
		}
	}; 
	
	// Extra line mapping for  CHANGE CARRIER DATA
	// Key = column name
	// value = start position , end position , split pattern, field number, desired value, Format , prefix
	
	final static HashMap<String , String[]> columnMappingExtraLine = new HashMap<String , String[]>() {
		private static final long serialVersionUID = 1L;
		{ 			
			//	Name
		    put("name",new String[]  {"160","219",null,null,null,"Nachname",null});
			//	First Name
			put("firstName",new String[]  {"220","250",null,null,null,"Vorname",null});
			//Company Name
			put("companyName",new String[]  {"300","360",null,null,null,"Firmenname",null});
			//Street Name
			put("streetName",new String[]  {"510","549",null,null,null,"Straﬂe",null});
			//Street Number
			put("streetNumber",new String[]  {"550","569",null,null,null,"Hausnummer",null});
			//Postal Code
			put("postalCode",new String[]  {"570","578",null,null,null,"PLZ",null});
			//City Name
			put("cityName",new String[]  {"579","619",null,null,null,"Ort",null});		
			
			
		}
	}; 
	
	
    private BufferedReader reader = null;

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(CSMReader.class);

    /**
     * The column names.
     */
    private HashMap<String,String> columns = null;

     /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the array containing the column names.
     * @return an array containing the column names.
     */
    public HashMap<String,String> getColumns() {
        return columns;
    }

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @throws FIFException 
     */
    public CSMReader(String fileName) throws FIFException {
        try {
			reader = new BufferedReader(new FileReader(fileName));
		} catch (FileNotFoundException e) {
            throw new FIFException("Error while CSM reading file.", e);
		}
    }

    /*---------*
     * METHODS *
     *---------*/


    /**
     * Parses the columns from a passed in string.
     * @param line  the String representing a line from the CSM file.
     * @return a HashMap containing a value for each column.
     */
    public HashMap<String,String> parseColumnsExtraLine(String line) throws FIFException {
        HashMap<String,String> columns = new HashMap<String,String>();

        logger.debug("Reading columns Ex...");

        if (line.equals("")) {
            return null;
        };
        logger.debug("columnMappingExtraLine)########"+columnMappingExtraLine);
        Set<String> keys = columnMappingExtraLine.keySet();
		Iterator<String> keyiter = keys.iterator();
		while (keyiter.hasNext()){
			String key = keyiter.next();
			logger.debug("current key########"+key);
			String[] mapping = columnMappingExtraLine.get(key);
			/*for(int i=0;i<mapping.length;i++){
				logger.debug("mapping"+mapping[i]);
			}*/
			int startPos = Integer.valueOf(mapping[0]);
			int endPos = Integer.valueOf(mapping[1]);
			if (endPos>line.length())
				endPos=line.length();
			String rawValue = line.substring(startPos, endPos);
			logger.debug("rawvalue########"+rawValue);
			if (rawValue!=null)
				rawValue=rawValue.trim();
			
			logger.debug("4th"+mapping[4]);
			
			if (mapping[4]!=null && !mapping[4].equals(rawValue) && !mapping[4].equals("Nachname")&&!mapping[4].equals("Vorname")&& !mapping[4].equals("Firmenname")&&!mapping[4].equals("Straﬂe") && !mapping[4].equals("Hausnummer")&&!mapping[4].equals("PLZ")&& !mapping[4].equals("Ort"))
				continue;
			
			columns.put(key, rawValue);
		}
      
        logger.debug("Read columns for Extraline: " + columns);
        return columns;
    }
    public HashMap<String,String> parseColumns(String line) throws FIFException {
        HashMap<String,String> columns = new HashMap<String,String>();

        logger.debug("Reading columns...");

        if (line.equals("")) {
            return null;
        };
        logger.debug("columnMapping########"+columnMapping);
        Set<String> keys = columnMapping.keySet();
		Iterator<String> keyiter = keys.iterator();
		while (keyiter.hasNext()){
			String key = keyiter.next();
			logger.debug("current key########"+key);
			String[] mapping = columnMapping.get(key);
			/*for(int i=0;i<mapping.length;i++){
				logger.debug("mapping"+mapping[i]);
			}*/
			int startPos = Integer.valueOf(mapping[0]);
			int endPos = Integer.valueOf(mapping[1]);
			if (endPos>line.length())
				endPos=line.length();
			String rawValue = line.substring(startPos, endPos);
			logger.debug("rawvalue########"+rawValue);
			if (rawValue!=null)
				rawValue=rawValue.trim();
			if (mapping[2]!=null && mapping[3]!=null){
				String[] fields = rawValue.split(mapping[2]);
				int fieldNum = Integer.valueOf(mapping[3]);
				if (fieldNum<fields.length)
					rawValue=fields[fieldNum];
			}
			logger.debug("4th"+mapping[4]);
			
			if (mapping[4]!=null && !mapping[4].equals(rawValue) && !mapping[4].equals("CSM Order Type") && !mapping[4].equals("Nachname")&&!mapping[4].equals("Vorname")&& !mapping[4].equals("Firmenname")&&!mapping[4].equals("Straﬂe") && !mapping[4].equals("Hausnummer")&&!mapping[4].equals("PLZ")&& !mapping[4].equals("Ort"))
				continue;
			
			if (mapping[5]!=null&&mapping[5].equals("DATE"))
				rawValue=convertToCCBDate(rawValue);
			if (mapping[6]!=null)
				rawValue=mapping[6]+rawValue;
			columns.put(key, rawValue);
		}
      
        logger.debug("Read columns: " + columns);
        return columns;
    }

	private String convertToCCBDate(String rawValue) {
		String retVal=null;
		try {
			String year = rawValue.substring(0, 4);
			String month = rawValue.substring(4, 6);
			String day = rawValue.substring(6, 8);
			retVal = year + "." + month + "." + day + " 00:00:00";
		} catch (IndexOutOfBoundsException e) {
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd 00:00:00");
			return sdf.format(new Date());
		}
		return retVal;
	}

	public BufferedReader getReader() {
		return reader;
	}

	public void setReader(BufferedReader reader) {
		this.reader = reader;
	}

}
