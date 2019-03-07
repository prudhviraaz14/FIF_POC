/*
    $Header:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/FormatXML.java-arc   1.0   Apr 09 2003 09:34:26   goethalo  $

    $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/src/net/arcor/fif/apps/FormatXML.java-arc  $
 * 
 *    Rev 1.0   Apr 09 2003 09:34:26   goethalo
 * Initial revision.
*/
package net.arcor.fif.apps;

import java.io.File;
import java.io.IOException;

import net.arcor.fif.common.DOMSerializer;

import org.apache.xerces.parsers.DOMParser;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

/**
 * Application that formats a passed in XML file to a pretty format.
 *
 * @author goethalo
 */
public class FormatXML {

    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println("FormatXML: Formats an XML file.");
            System.err.println("\nUsage: FormatXML <fileName>\n");
            System.exit(0);
        }

        try {
            // Create a DOM parser
            DOMParser parser = new DOMParser();

            // Parse the XML metadata file
            parser.parse(args[0]);

            // Get the document
            Document doc = parser.getDocument();

            // Format the document
            DOMSerializer serializer = new DOMSerializer();
            serializer.serialize(doc, new File(args[0]));

            System.err.println("Successfully formatted " + args[0]);
        } catch (SAXException e) {
            System.err.println("Caught Exception");
            e.printStackTrace();
        } catch (IOException e) {
            System.err.println("Caught Exception");
            e.printStackTrace();
        }

    }
}
