package net.arcor.fif.messagecreator.somtofif.element.mapping;

import net.arcor.fif.messagecreator.somtofif.description.FIFRequestConstants;
import net.arcor.fif.messagecreator.somtofif.description.SOMToFIFRepositoryConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.IHierarchicalDataModel;
import de.arcor.kba.om.datatransformer.server.transformationelements.mappings.BaseMapping;
import de.arcor.kba.om.datatransformer.server.util.XMLUtil;

/**
 * Mapping for the request parameter.
 * 
 * @author Jean-Daniel Schlueter
 * @author Jadranko Mrkonjic
 * @since 1.29 (IT-23360)
 */
public class RPListMapping extends BaseMapping {

    @Override
    public void renderOutput(Node currentNode, IHierarchicalDataModel<?> inputData)
            throws TransformationException {
        XMLUtil.assertNodeType(currentNode, Node.ELEMENT_NODE);

        Element rootElement = createAndAppendElement(currentNode,
                FIFRequestConstants.REQUEST_PARAM_LIST);
        rootElement.setAttribute(FIFRequestConstants.NAME, attributes
                .get(SOMToFIFRepositoryConstants.LIST_NAME));

        Node[] nodes = (Node[]) inputData.getNodes(attributes
                .get(SOMToFIFRepositoryConstants.SOURCE_ATTR_NAME));
        Element requestParamListItem;
        Element requestParam;
        for (int i = 0; i < nodes.length; i++) {
            requestParamListItem = createAndAppendElement(rootElement,
                    FIFRequestConstants.REQUEST_PARAM_LIST_ITEM);
            requestParam = createAndAppendElement(requestParamListItem,
                    FIFRequestConstants.REQUEST_PARAM, nodes[i].getTextContent(),
                    Node.CDATA_SECTION_NODE);
            requestParam.setAttribute(FIFRequestConstants.NAME, attributes
                    .get(SOMToFIFRepositoryConstants.LIST_ITEM_NAME));
        }
    }

}
