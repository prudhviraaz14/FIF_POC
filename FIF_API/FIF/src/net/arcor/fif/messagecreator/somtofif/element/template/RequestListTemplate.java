package net.arcor.fif.messagecreator.somtofif.element.template;

import javax.xml.transform.TransformerException;

import net.arcor.fif.messagecreator.somtofif.description.FIFRequestConstants;
import net.arcor.fif.messagecreator.somtofif.element.mapping.FifParameterMapping;

import org.apache.xpath.XPathAPI;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.IHierarchicalDataModel;
import de.arcor.kba.om.datatransformer.server.transformationelements.AbstractTransformationElement;
import de.arcor.kba.om.datatransformer.server.transformationelements.templates.BaseTransformationTemplate;
import de.arcor.kba.om.datatransformer.server.util.XMLUtil;

/**
 * RequestListTemplate.
 * 
 * @author Jean-Daniel Schlueter
 * @since 1.29 (IT-23360)
 */
public class RequestListTemplate extends BaseTransformationTemplate {
    private static final String XPATH_EXP_RETRIEVEFIRSTREQUESTSACTIONNAME = "requests/request[1]/action-name";

    @Override
    public void renderOutput(Node currentNode, IHierarchicalDataModel<?> inputData)
            throws TransformationException {
        XMLUtil.assertNodeType(currentNode, Node.DOCUMENT_NODE);

        // genereate base element <request-list>
        Element rootElement = createAndAppendElement(currentNode, FIFRequestConstants.REQUEST_LIST);
        // generate <request-list-name> element
        Element requestListNameElement = createAndAppendElement(rootElement,
                FIFRequestConstants.REQUEST_LIST_NAME);
        // generate request list id element
        createAndAppendElement(rootElement, FIFRequestConstants.REQUEST_LIST_ID);

        // Bracket for RLPMappings.
        Element requestListParamsElement = createAndAppendElement(rootElement,
                FIFRequestConstants.REQUEST_LIST_PARAMS);

        // Bracket for all the requests.
        Element requestsElement = createAndAppendElement(rootElement, FIFRequestConstants.REQUESTS);

        for (AbstractTransformationElement current : nestedTransformationElements) {
            if (current instanceof FifParameterMapping) {
                current.transform(requestListParamsElement, inputData);
            } else if (current instanceof RequestTemplate) {
                current.transform(requestsElement, inputData);
            } else {
                // Elements which appear here shouldn't produce any output. E.g. DataBufferWriter
                current.transform(rootElement, inputData);
            }
        }

        // set the request list name
        try {
            requestListNameElement.setTextContent(getRequestListName(rootElement));
        } catch (TransformerException e) {
            throw new TransformationException("Error retrieving first erquests action-name.", e);
        }
    }

    /**
     * This method retrieves the action-name of the first fif-request.
     * 
     * @param node the root element of a fif request-list.
     * @return action name of first request.
     * @throws TransformerException
     */
    private String getRequestListName(Node node) throws TransformerException {
        Node firstRequestsActionNameNode = XPathAPI.selectSingleNode(node,
                XPATH_EXP_RETRIEVEFIRSTREQUESTSACTIONNAME);
        if (firstRequestsActionNameNode != null) {
            return firstRequestsActionNameNode.getTextContent();
        }
        return null;
    }
}
