package net.arcor.fif.messagecreator.somtofif.element.template;

import net.arcor.fif.messagecreator.somtofif.description.FIFRequestConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.IHierarchicalDataModel;
import de.arcor.kba.om.datatransformer.server.transformationelements.templates.BaseTransformationTemplate;
import de.arcor.kba.om.datatransformer.server.util.XMLUtil;

/**
 * This is the inner-template for complex request-param-list elements.<br/>
 * See the following example:<br/>
 * <br/>
 * <br/>
 * <font color="green">Configuration within Transformation-Description-File:</font><br/>
 * <br/>
 * <code>
 * &lt;RPListTemplate listName=&quot;patternDocTemplateNameList&quot;&gt;<br/>
 * &nbsp;&nbsp;<b><font color="blue">&lt;RPListItemTemplate sourceWorkingPath=&quot;/order/orderPosition/function/voice&quot;&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;TemplateConditions&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;base:IsMember values=&quot;true&quot; sourceAttrName=&quot;terminated&quot;/&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;/TemplateConditions&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;RPMapping sourceAttrName=&quot;somePathFromSOM&quot; targetName=&quot;patternDocTemplateName&quot;/&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;RPMapping sourceAttrName=&quot;anyOtherPathFromSOM&quot; targetName=&quot;docPatternOutputDevice&quot;/&gt;<br/>
 * &nbsp;&nbsp;&lt;/RPListItemTemplate&gt;</font></b><br/>
 * &lt;/RPListTemplate&gt;
 * 
 * </code> <br/>
 * <br/>
 * <font color="green">Produces the following output:</font><br/>
 * <br/>
 * <code>
 * &lt;request-param-list name=&quot;patternDocTemplateNameList&quot;&gt;<br/>
 * &nbsp;&nbsp;<b><font color="blue">&lt;request-param-list-item&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;request-param name=&quot;patternDocTemplateName&quot;&gt;Privatkunden EVN&lt;/request-param&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;request-param name=&quot;docPatternOutputDevice&quot;&gt;PRINTER&lt;/request-param&gt;<br/>
 * &nbsp;&nbsp;&lt;/request-param-list-item&gt;<br/>
 * &nbsp;&nbsp;&lt;request-param-list-item&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;request-param name=&quot;patternDocTemplateName&quot;&gt;Privatkunden EVN_2&lt;/request-param&gt;<br/>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;request-param name=&quot;docPatternOutputDevice&quot;&gt;PRINTER_2&lt;/request-param&gt;<br/>
 * &nbsp;&nbsp;&lt;/request-param-list-item&gt;</font></b><br/>
 * &lt;/request-param-list&gt;<br/>
 * </code><br/>
 * <br/>
 * Only the <b><font color="blue">blue & bold</font></b> parts are handled respectively generated
 * through this class. <br/>
 * <br/>
 * Each RPListItemTemplate must be nested within an enclosing RPListTemplate. This is not ensured by
 * this Java-Implementation. It's ensured by the description-schema.<br/>
 * see also {@link RPListTemplate} <br/>
 * <br/>
 * 
 * @author J. Mrkonjic
 * @since 1.29 (IT-23360)
 */
public class RPListItemTemplate extends BaseTransformationTemplate {
    @Override
    public void renderOutput(Node currentOutputNode, IHierarchicalDataModel<?> inputData)
            throws TransformationException {
        XMLUtil.assertNodeType(currentOutputNode, Node.ELEMENT_NODE);
        //
        Element requestParamListItemElement = createAndAppendElement(currentOutputNode,
                FIFRequestConstants.REQUEST_PARAM_LIST_ITEM);
        super.renderOutput(requestParamListItemElement, inputData);
        if (XMLUtil.getChildElements(requestParamListItemElement).size() == 0) {
            // remove request-param-list-item-element if it doesn't contain anything.
            currentOutputNode.removeChild(requestParamListItemElement);
        }
    }
}
