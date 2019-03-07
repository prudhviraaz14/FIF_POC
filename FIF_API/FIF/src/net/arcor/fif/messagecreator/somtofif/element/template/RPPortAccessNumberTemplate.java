package net.arcor.fif.messagecreator.somtofif.element.template;

import net.arcor.fif.messagecreator.somtofif.description.FIFRequestConstants;
import net.arcor.fif.messagecreator.somtofif.description.SOMOrderConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.DefaultXMLAdapter;
import de.arcor.kba.om.datatransformer.server.model.IHierarchicalDataModel;
import de.arcor.kba.om.datatransformer.server.transformationelements.templates.BaseCounterTransformationTemplate;
import de.arcor.kba.om.datatransformer.server.util.XMLUtil;

/**
 * RPPortAccessNumberMapping.
 * 
 * @author Jean-Daniel Schlueter
 * @since 1.29 (IT-23360)
 */
public class RPPortAccessNumberTemplate extends BaseCounterTransformationTemplate {

    @Override
    public void renderOutput(Node currentNode, IHierarchicalDataModel<?> inputData, int counter)
            throws TransformationException {
        XMLUtil.assertNodeType(currentNode, Node.ELEMENT_NODE);
        super.renderOutput(currentNode, inputData, counter);

        boolean existsRange = ((DefaultXMLAdapter) inputData)
                .existsPath(SOMOrderConstants.EXISTING_START_RANGE_PATH);
        String targetParameterName = null;
        if (existsRange) {
            targetParameterName = SOMOrderConstants.PORT_ACCESS_NUMBER_RANGE;
        } else {
            targetParameterName = SOMOrderConstants.PORT_ACCESS_NUMBER;
        }
        String targetParameterNameWithCount = targetParameterName + (counter + 1);
        //
        Document doc = currentNode.getOwnerDocument();
        Element paramElement = doc.createElement(FIFRequestConstants.REQUEST_PARAM);
        paramElement.setAttribute(SOMOrderConstants.NAME, targetParameterNameWithCount);
        boolean existsPath = ((DefaultXMLAdapter) inputData)
                .existsPath(SOMOrderConstants.CONFIGURED);
        paramElement.appendChild(doc.createCDATASection(existsPath ? SOMOrderConstants.JA
                : SOMOrderConstants.NEIN));
        currentNode.appendChild(paramElement);
    }

}
