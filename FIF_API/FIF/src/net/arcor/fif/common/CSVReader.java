/*
 * $ Header: $
 *
 * $ Log: $
 */
package net.arcor.fif.common;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.log4j.Logger;

/**
 * Class for reading CSV files.
 * @author goethalo
 */
public class CSVReader {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    private BufferedReader reader = null;

    /**
     * The log4j logger.
     */
    private static Logger logger = Logger.getLogger(CSVReader.class);

    /**
     * The column names.
     */
    private ArrayList<String> columnNames = null;

    /**
     * The lines in the CSV file.
     */
    private ArrayList<ArrayList<String>> lines = null;

    /**
     * The number of columns.
     */
    private int columnCount = 0;

    /**
     * The file to read from.
     */
    private String fileName = null;

    /**
     * The line separator.
     */
    private String separator = null;

    /**
     * Indicates, if the first line of the file is ignored.
     */
    private boolean ignoreFirstLine = false;

    /**
     * Indicates, if the last line of the file is ignored.
     */
    private boolean ignoreLastLine = false;

    /*---------------------*
     * GETTERS AND SETTERS *
     *---------------------*/

    /**
     * Gets the number of columns.
     * @return the number of columns.
     */
    public int getColumnCount() {
        return columnCount;
    }

    /**
     * Gets the column separator.
     * @return the column separator.
     */
    public String getSeparator() {
        return separator;
    }

    /**
     * Gets the line count.
     * @return the number of lines.
     */
    public int getLineCount() {
        return lines.size();
    }

    /**
     * Gets the array list containing the lines.
     * @return an array containing the lines.
     */
    public ArrayList<ArrayList<String>> getLines() {
        return lines;
    }

    /**
     * Gets the array containing the column names.
     * @return an array containing the column names.
     */
    public ArrayList<String> getColumnNames() {
        return columnNames;
    }

    /*--------------*
     * CONSTRUCTORS *
     *--------------*/

    /**
     * Constructor.
     * @throws FIFException 
     */
    public CSVReader(String fileName, boolean ignoreFirstLine, boolean ignoreLastLine) throws FIFException {
        this.fileName = fileName;
        this.ignoreFirstLine = ignoreFirstLine;    
        this.ignoreLastLine = ignoreLastLine;
        try {
			reader = new BufferedReader(new FileReader(fileName));
		} catch (FileNotFoundException e) {
            throw new FIFException("Error while CSV reading file.", e);
		}
    }

    /**
     * Constructor.
     * @throws FIFException 
     */
    public CSVReader(String fileName) throws FIFException {
        this.fileName = fileName;
        try {
			reader = new BufferedReader(new FileReader(fileName));
		} catch (FileNotFoundException e) {
            throw new FIFException("Error while CSV reading file.", e);
		}
    }

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Reads the CSV file.
     * @throws FIFException
     */
    public void read(String aSeparator, String columnNames) throws FIFException {

        BufferedReader reader = null;

        try {
            reader = new BufferedReader(new FileReader(fileName));
            readColumnNames(reader,aSeparator,columnNames);
           	readLines(reader);
            reader.close();
        } catch (IOException ioe) {
            throw new FIFException("Error while CSV reading file.", ioe);
        }
    }

    /**
     * Reads the column names from the file.
     * @param reader  the reader to get the columns from
     * @throws FIFException if the column names could not be read.
     */
    public void readColumnNames(BufferedReader reader,String aSeparator,String configColumnNames) throws FIFException {
        try {
            String columnNameString = null;
            if (configColumnNames == null)
            	columnNameString = reader.readLine();
            else
            	columnNameString = configColumnNames;

            if (columnNameString == null) {
                throw new FIFException("CSV file is empty.");
            }

            // Try to determine the separator
            logger.debug("Determining separator.");
            if (aSeparator != null) {
                this.separator = aSeparator;
           } else if (columnNameString.indexOf(";") != -1) {
                this.separator = ";";
            } else if (columnNameString.indexOf(",") != -1) {
                this.separator = ",";
            } else if (columnNameString.indexOf("\t") != -1) {
                this.separator = "\t";
            } else {
                this.separator = "";
            }
            if (separator.equals("")) {
                logger.debug(
                    "No column separator found.  Assuming only one column.");
            } else {
                logger.debug("Separator is " + separator);
            }

            // Read the column names
            logger.debug("Reading column names.");
            columnNames = new ArrayList<String>();
            if (separator.equals("")) {
                columnNames.add(columnNameString);
            } else {
                int lastIndex = 0;
                int sepPos = columnNameString.indexOf(separator, lastIndex);
                while (sepPos != -1) {
                    columnNames.add(
                        columnNameString.substring(lastIndex, sepPos));
                    lastIndex = sepPos + 1;
                    sepPos = columnNameString.indexOf(separator, lastIndex);
                }
                if (lastIndex != 0) {
                    columnNames.add(columnNameString.substring(lastIndex));
                }
            }
            this.columnCount = columnNames.size();
            logger.debug("Read " + columnCount + " columns: " + columnNames);
        } catch (IOException ioe) {
            throw new FIFException("Cannot read column names.", ioe);
        }
    }

    /**
     * Reads the lines from the CSV file.
     * @param reader  the reader to get the lines from.
     * @throws FIFException if the lines cannot be read.
     */
    private void readLines(BufferedReader reader) throws FIFException {
        int lineNumber = 1;
        try {
            logger.debug("Reading lines...");
            lines = new ArrayList<ArrayList<String>>();
            String lineString = reader.readLine();
            while (lineString != null) {
            	String nextLine = reader.readLine();
            	if ((lineNumber != 1 || !ignoreFirstLine) &&
            		(nextLine != null || !ignoreLastLine))
            	{	
	                ArrayList<String> line = parseColumns(lineString);
	                if (line != null) {
	                    if (line.size() != columnCount) {
	                        throw new FIFException(
	                            "Invalid column count for line number: "
	                                + lineNumber);
	                    }
	                    lines.add(line);
	                }
            	}
                lineString = nextLine;
                lineNumber++;
            }
            logger.debug("Read " + lines.size() + " lines.");
        } catch (IOException ioe) {
            throw new FIFException(
                "Cannot read CSV file. Error on line number: " + lineNumber,
                ioe);
        }
    }


    /**
     * Parses the columns from a passed in string.
     * @param line  the String representing a line from the CSV file.
     * @return an ArrayList containing a String for each column.
     */
    public ArrayList<String> parseColumns(String line) throws FIFException {
        ArrayList<String> columns = new ArrayList<String>();
        int startIndex = 0;

        logger.debug("Reading columns...");

        if (line.equals("")) {
            return null;
        };

        while ((startIndex != -1) && (startIndex < line.length())) {
            String column = null;
            // Is the current column quoted?
            if (line.charAt(startIndex) == '"') {
                int endQuote = line.indexOf("\"", startIndex + 1);
                if (endQuote != -1) {
                    column = line.substring(startIndex + 1, endQuote);
                    startIndex = endQuote + 2;
                } else {
                    throw new FIFException(
                        "Column not properly quoted. Column: "
                            + line.substring(startIndex));
                }
            } else {
                int sep = -1;
                if (columnCount != 1) {
                    sep = line.indexOf(this.separator, startIndex);
                }
                if (sep != -1) {
                    column = line.substring(startIndex, sep);
                    startIndex = sep + 1;
                } else {
                    column = line.substring(startIndex);
                    startIndex = -1;
                }
            }

            if (column != null) {
                columns.add(column);

                if (startIndex == line.length()) {
                    columns.add(new String());
                }
            }
        }
        logger.debug("Read columns: " + columns);
        return columns;
    }

	public BufferedReader getReader() {
		return reader;
	}

	public void setReader(BufferedReader reader) {
		this.reader = reader;
	}

}
