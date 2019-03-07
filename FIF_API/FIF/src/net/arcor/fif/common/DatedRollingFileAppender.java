/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/DatedRollingFileAppender.java-arc   1.0   Apr 09 2003 09:34:32   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/DatedRollingFileAppender.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.io.IOException;
import java.io.Writer;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.log4j.FileAppender;
import org.apache.log4j.Layout;
import org.apache.log4j.helpers.OptionConverter;
import org.apache.log4j.helpers.LogLog;
import org.apache.log4j.helpers.CountingQuietWriter;
import org.apache.log4j.spi.LoggingEvent;

/**
 * Extension of the log4j RollingFileAppender that appends the date to the
 * name of the renamed files.
 * For more information refer to: www.apache.org.
 * @author goethalo
 */
public class DatedRollingFileAppender extends FileAppender {

    /**
     * The date format to use for appending the rollover date to the
     * backup file.  The format should follow the
     * java.text.SimpleDateFormat convention.
     * The default format is <code>.yyyy.MM.dd.HH.mm.ss</code>
     *
     * @see java.text.SimpleDateFormat
     */
    protected String dateFormat = ".yyyy.MM.dd.HH.mm.ss";

    /**
     * The default maximum file size is 10MB.
     */
    protected long maxFileSize = 10 * 1024 * 1024;

    /**
     * The default constructor simply calls its {@link FileAppender#FileAppender parents constructor}.
     */
    public DatedRollingFileAppender() {
        super();
    }

    /**
     * Instantiate a FileAppender and open the file designated by
     * <code>filename</code>. The opened filename will become the output
     * destination for this appender.<p>The file will be appended to.
     */
    public DatedRollingFileAppender(Layout layout, String filename)
        throws IOException {
        super(layout, filename);
    }

    /**
     * Instantiate a DateRollingFileAppender and open the file designated by
     * <code>filename</code>. The opened filename will become the ouput
     * destination for this appender.<p>If the <code>append</code> parameter
     * is true, the file will be appended to. Otherwise, the file desginated
     * by <code>filename</code> will be truncated before being opened.
     */
    public DatedRollingFileAppender(
        Layout layout,
        String filename,
        boolean append)
        throws IOException {
        super(layout, filename, append);
    }
    /**
     * @return String
     */
    public String getDateFormat() {
        return dateFormat;
    }

    /**
     * Get the maximum size that the output file is allowed to reach
     * before being rolled over to backup files.
     */
    public long getMaximumFileSize() {
        return maxFileSize;
    }

    /**
     * Implements the usual roll over behaviour.
     *
     * Moreover, <code>File</code> is renamed to <code>File.<i>date</i></code>
     * and closed, where <code><i>date</i></code> is the date format to use for
     * the time where this file is rolled over.  The format should follow the
     * <code>java.text.SimpleDateFormat</code> format.
     * A new <code>File</code> is created to receive further log output.
     *
     * @see java.text.SimpleDateFormat
     */
    public void rollOver() {
        File target;
        File file;

        // Rename fileName to fileName+dateFormat
        SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
        target = new File(fileName + sdf.format(new Date()));

        // Close this file
        this.closeFile();

        // Create a new file
        file = new File(fileName);

        // Rename the backup file
        file.renameTo(target);

        try {
            // This will also close the file. This is OK since multiple
            // close operations are safe.
            this.setFile(fileName, false, bufferedIO, bufferSize);
        } catch (IOException e) {
            LogLog.error("setFile(" + fileName + ", false) call failed.", e);
        }
    }

    /**
     * Sets the dateFormat.
     * @param dateFormat The dateFormat to set
     */
    public void setDateFormat(String dateFormat) {
        this.dateFormat = dateFormat;
    }

    /**
     * Sets the file to log to.
     * @see org.apache.log4j.FileAppender#setFile(String, boolean, boolean, int)
     */
    public synchronized void setFile(
        String fileName,
        boolean append,
        boolean bufferedIO,
        int bufferSize)
        throws IOException {
        super.setFile(fileName, append, this.bufferedIO, this.bufferSize);
        if (append) {
            File f = new File(fileName);
            ((CountingQuietWriter) qw).setCount(f.length());
        }
    }

    /**
     * Set the maximum size that the output file is allowed to reach
     * before being rolled over to backup files.
     *
     * <p>In configuration files, the <b>MaxFileSize</b> option takes an
     * long integer in the range 0 - 2^63. You can specify the value
     * with the suffixes "KB", "MB" or "GB" so that the integer is
     * interpreted being expressed respectively in kilobytes, megabytes
     * or gigabytes. For example, the value "10KB" will be interpreted
     * as 10240.
     */
    public void setMaxFileSize(String value) {
        maxFileSize = OptionConverter.toFileSize(value, maxFileSize + 1);
    }

    /**
     * Set the maximum size that the output file is allowed to reach before
     * being rolled over to backup files.
     *
     * <p>This method is equivalent to {@link #setMaxFileSize} except
     * that it is required for differentiating the setter taking a
     *  <code>long</code> argument from the setter taking a
     *  <code>String</code> argument by the JavaBeans
     * @see #setMaxFileSize(String)
     */
    public void setMaximumFileSize(long maxFileSize) {
        this.maxFileSize = maxFileSize;
    }

    protected void setQWForFiles(Writer writer) {
        this.qw = new CountingQuietWriter(writer, errorHandler);
    }

    /**
     * This method differentiates RollingFileAppender from its super class.
     */
    protected void subAppend(LoggingEvent event) {
        super.subAppend(event);
        if ((fileName != null)
            && ((CountingQuietWriter) qw).getCount() >= maxFileSize)
            this.rollOver();
    }

}
