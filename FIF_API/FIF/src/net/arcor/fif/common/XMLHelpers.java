package net.arcor.fif.common;

import javax.xml.transform.TransformerException;

import org.apache.xpath.XPathAPI;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class XMLHelpers {

    /**
     * Gets the text contained in an element.
     *
     * @param element  the element to take the text from
     * @return a <code>String</code> containing the text of the element,
     * null if the element contains no text.
     */
    public static String getElementText(Element element) {
        if (element == null) {
            return null;
        }
        Node child = element.getFirstChild();
        if (child != null) {
            return (child.getNodeValue());
        } else {
            return null;
        }
    }

	public static String getTextElement(Document doc, String string) {
		NodeList elements = doc.getElementsByTagName(string);
        if ((elements == null) || (elements.getLength() < 1))
            return null;
        return getElementText((Element) elements.item(0));
	}

	public static String getTextElement(Element element, String string) {
		NodeList elements = element.getElementsByTagName(string);
        if ((elements == null) || (elements.getLength() < 1))
            return null;
        return getElementText((Element) elements.item(0));
	}

	public static String serializeElement(Element orderElement) {
		// TODO Auto-generated method stub
		return null;
	}
	
}
