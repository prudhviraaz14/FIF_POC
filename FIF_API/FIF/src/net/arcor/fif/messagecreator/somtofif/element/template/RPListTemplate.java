package net.arcor.fif.messagecreator.somtofif.element.template;

import net.arcor.fif.messagecreator.somtofif.description.FIFRequestConstants;
import net.arcor.fif.messagecreator.somtofif.description.SOMToFIFRepositoryConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.IHierarchicalDataModel;
import de.arcor.kba.om.datatransformer.server.transformationelements.templates.BaseTransformationTemplate;
import de.arcor.kba.om.datatransformer.server.util.XMLUtil;

/**
 * This is the bracket-template for complex request-param-list elements.<br/>
 * See the following example:<br/>
 * <br/>
 * 
 * <pre>
 * &lt;font color=&quot;green&quot;&gt;Configuration within Transformation-Description-File:&lt;/font&gt;
 * &lt;b&gt;&lt;font color=&quot;blue&quot;&gt;&lt;RPListTemplate listName=&quot;patternDocTemplateNameList&quot;&gt;&lt;/font&gt;&lt;/b&gt;
 *   &lt;RequestParamListItemTemplate sourceWorkingPath=&quot;/order/orderPosition/function/voice&quot;&gt;
 *     &lt;TemplateConditions&gt;
 *       &lt;base:IsMember values=&quot;true&quot; sourceAttrName=&quot;terminated&quot;/&gt;
 *     &lt;/TemplateConditions&gt;
 *     &lt;RPMapping sourceAttrName=&quot;somePathFromSOM&quot; targetName=&quot;patternDocTemplateName&quot;/&gt;
 *     &lt;RPMapping sourceAttrName=&quot;anyOtherPathFromSOM&quot; targetName=&quot;docPatternOutputDevice&quot;/&gt;
 *   &lt;/RequestParamListItemTemplate&gt;
 * &lt;b&gt;&lt;font color=&quot;blue&quot;&gt;&lt;/RPListTemplate&gt;&lt;/font&gt;&lt;/b&gt;
 * </pre>
 * 
 * <pre>
 * &lt;font color=&quot;green&quot;&gt;Produces the following output:&lt;/font&gt;
 * &lt;b&gt;&lt;font color=&quot;blue&quot;&gt;&lt;request-param-list name=&quot;patternDocTemplateNameList&quot;&gt;&lt;/font&gt;&lt;/b&gt;
 *   &lt;request-param-list-item&gt;
 *     &lt;request-param name=&quot;patternDocTemplateName&quot;&gt;Privatkunden EVN&lt;/request-param&gt;
 *     &lt;request-param name=&quot;docPatternOutputDevice&quot;&gt;PRINTER&lt;/request-param&gt;
 *   &lt;/request-param-list-item&gt;
 *   &lt;request-param-list-item&gt;
 *     &lt;request-param name=&quot;patternDocTemplateName&quot;&gt;Privatkunden EVN&lt;/request-param&gt;
 *     &lt;request-param name=&quot;docPatternOutputDevice&quot;&gt;PRINTER&lt;/request-param&gt;
 *   &lt;/request-param-list-item&gt;
 * &lt;b&gt;&lt;font color=&quot;blue&quot;&gt;&lt;/request-param-list&gt;&lt;/font&gt;&lt;/b&gt;
 * </pre>
 * 
 * Only the <b><font color="blue">blue & bold</font></b> parts are handled respectively generated
 * through this class. <br/>
 * <br/>
 * Each RPListTemplate must have exactly one RPListItemTemplate as nested Template to generate the
 * output between these brackets. This is not ensured by this Java-Implementation. It's ensured by
 * the description-schema.<br/>
 * see also {@link RPListItemTemplate} <br/>
 * <br/>
 * 
 * @author J. Mrkonjic
 * @since 1.29 (IT-23360)
 */
public class RPListTemplate extends BaseTransformationTemplate {
    @Override
    public void renderOutput(Node currentOutputNode, IHierarchicalDataModel<?> inputData)
            throws TransformationException {
        XMLUtil.assertNodeType(currentOutputNode, Node.ELEMENT_NODE);
        //
        Element requestParamListElement = createAndAppendElement(currentOutputNode,
                FIFRequestConstants.REQUEST_PARAM_LIST);
        requestParamListElement.setAttribute(FIFRequestConstants.NAME, attributes
                .get(SOMToFIFRepositoryConstants.LIST_NAME));
        super.renderOutput(requestParamListElement, inputData);
        if (XMLUtil.getChildElements(requestParamListElement).size() == 0) {
            // remove request-param-list-item-element if it doesn't contain anything.
            currentOutputNode.removeChild(requestParamListElement);
        }
    }
}
