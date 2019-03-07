/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/FileUtils.java-arc   1.2   Aug 02 2004 15:26:16   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/FileUtils.java-arc  $
 * 
 *    Rev 1.2   Aug 02 2004 15:26:16   goethalo
 * SPN-FIF-000024410: Oracle 9i and Java 1.4 migration.
 * 
 *    Rev 1.1   Mar 02 2004 11:18:44   goethalo
 * SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;

/**
 * This class contains utility methods in the file area.
 * It contains convenience methods for writing objects to a file.
 * @author goethalo
 */
public class FileUtils {

    /*------------------*
     * MEMBER VARIABLES *
     *------------------*/

    /**
     * The date format to use for appending the date to the output files.
     */
    private static SimpleDateFormat dateFormat =
        new SimpleDateFormat("-yyyy.MM.dd.HH.mm.ss.SSS");

    /*---------*
     * METHODS *
     *---------*/

    /**
     * Writes a <code>String</code> to an output file.
     * @param text            the text to write to the output file.
     * @param path            the path of the directory tro put the output
     *                        file in.
     * @param fileNamePrefix  the file name prefix to use for the file.
     *                        (e.g. <code>action<code>).
     * @param fileNameSuffix  the file name suffix to use for the file.
     *                        (e.g. <code>.xml</code>).
     * @param addTimeStamp    indicates whether a time stamp should be added
     *                        between the prefix and the suffix.
     * @return the fully qualified name of the written file.
     * @throws FIFException if the file could not be written
     */
    public static String writeToOutputFile(
        String text,
        String path,
        String fileNamePrefix,
        String fileNameSuffix,
        boolean addTimeStamp)
        throws FIFException {
        String fileName = null;
        File file = null;

        // Get the time stamp, if needed
        String timeStamp = null;
        if (addTimeStamp) {
            synchronized (dateFormat) {
                timeStamp = dateFormat.format(new Date());
            }
        }

        try {
            // Create the file name and make sure that the
            // file does not exist already
            int suffix = 1;
            do {
                StringBuffer name = new StringBuffer();
                name.append(path);
                name.append(fileNamePrefix);
                if (addTimeStamp) {
                    name.append(timeStamp);
                }
                if (suffix != 1) {
                    name.append("-");
                    name.append(suffix);
                }
                name.append(fileNameSuffix);
                fileName = name.toString();
                file = new File(fileName);
                suffix++;
            } while (file.exists());

            // Write the message to the output file
            BufferedWriter out = new BufferedWriter(new FileWriter(file));
            out.write(text);
            out.close();
        } catch (IOException ioe) {
            throw new FIFException("Cannot write to file " + fileName, ioe);
        }

        return fileName;
    }

    /**
     * Reads the properties contained in a property file.
     * @param fileName  the fully qualified name of the property file to read.
     * @return the Properties contained in the file.
     * @throws FIFException if the properties could not be read.
     */
    public static Properties readPropertyFile(String fileName)
        throws FIFException {
        Properties props = new Properties();
        try {
            File file = new File(fileName);
            InputStream input =
                new BufferedInputStream(new FileInputStream(file));
            props.load(input);
        } catch (FileNotFoundException fnfe) {
            throw new FIFException(
                "Cannot find property file: " + fileName,
                fnfe);
        } catch (IOException ioe) {
            throw new FIFException(
                "Error while reading from property file: " + fileName,
                ioe);
        }
        return props;
    }
}
