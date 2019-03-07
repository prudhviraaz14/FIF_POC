/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/DOMSerializer.java-arc   1.1   Jun 14 2004 15:43:04   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/common/DOMSerializer.java-arc  $
 * 
 *    Rev 1.1   Jun 14 2004 15:43:04   goethalo
 * IT-12538: KBA Tarif Change - Phase I
 * 
 *    Rev 1.0   Apr 09 2003 09:34:32   goethalo
 * Initial revision.
*/
package net.arcor.fif.common;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.w3c.dom.Document;

/**
 * Class that serializes a DOM tree to a String representation.
 * Using the Xerces XMLSerializer classes.
 * @author goethalo
 */
public class DOMSerializer {

    /**
     * Initializes the needed settings.
     */
    public DOMSerializer() {
    }

    /**
     * Serializes a DOM tree to the supplied <code>OutputStream</code>.
     * @param doc  the DOM tree to serialize.
     * @param out  the <code>OutputStream</code> to write to.
     */
    public void serialize(Document doc, OutputStream out) throws IOException {
        Writer writer = new OutputStreamWriter(out);
        serialize(doc, writer);
    }

    /**
     * Serializes a DOM tree to the supplied <code>File</code>.
     * @param doc   the DOM tree to serialize.
     * @param file  the <code>File</code> to write to.
     */
    public void serialize(Document doc, File file) throws IOException {

        Writer writer = new FileWriter(file);
        serialize(doc, writer);
    }

    /**
     * Serializes a DOM tree to the supplied <code>Writer</code>.
     * @param doc     the DOM tree to serialize.
     * @param writer  the <code>Writer</code> to write to.
     */
    public void serialize(Document doc, Writer writer) throws IOException {
        serialize(doc, writer, true);
    }

    /**
     * Serializes a DOM tree to the supplied <code>Writer</code>.
     * @param doc       the DOM tree to serialize.
     * @param writer    the <code>Writer</code> to write to.
     * @param beautify  indicates whether the document should be indented.
     */
    public void serialize(Document doc, Writer writer, boolean beautify)
        throws IOException {
        OutputFormat format = new OutputFormat(doc);
        if (beautify) {
            format.setIndenting(true);
            format.setIndent(2);
        } else {
            format.setPreserveEmptyAttributes(true);
            format.setPreserveSpace(true);
        }
        format.setEncoding("ISO-8859-1");
        XMLSerializer serializer = new XMLSerializer(writer, format);
        serializer.serialize(doc);
    }

}
