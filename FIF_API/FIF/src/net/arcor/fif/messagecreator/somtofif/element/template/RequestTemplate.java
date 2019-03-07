package net.arcor.fif.messagecreator.somtofif.element.template;

import net.arcor.fif.messagecreator.somtofif.description.FIFRequestConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.IHierarchicalDataModel;
import de.arcor.kba.om.datatransformer.server.transformationelements.templates.BaseTransformationTemplate;
import de.arcor.kba.om.datatransformer.server.util.XMLUtil;

/**
 * RequestTemplate.
 * 
 * @author Jean-Daniel Schlueter
 * @since 1.29 (IT-23360)
 */
public class RequestTemplate extends BaseTransformationTemplate {

    @Override
    public void renderOutput(Node currentNode, IHierarchicalDataModel<?> inputData)
            throws TransformationException {
        XMLUtil.assertNodeType(currentNode, Node.ELEMENT_NODE);
        // create the <request> element and add it to the currentNode-Element.
        Element rootElement = createAndAppendElement(currentNode, FIFRequestConstants.REQUEST);
        // create the <action-name> element and add it to the <request>-Element.
        createAndAppendElement(rootElement, FIFRequestConstants.ACTION_NAME, attributes
                .get(FIFRequestConstants.FIF_REQUEST_NAME), Node.TEXT_NODE);
        // create the <request-params> element and call super.renderOutput to
        // fill the params.
        Element requestParamsElement = createAndAppendElement(rootElement,
                FIFRequestConstants.REQUEST_PARAMS);
        super.renderOutput(requestParamsElement, inputData);
        if (XMLUtil.getChildElements(requestParamsElement).size() == 0) {
            // remove request-params-element if it doesn't contain anything.
            rootElement.removeChild(requestParamsElement);
        }
    }
}
