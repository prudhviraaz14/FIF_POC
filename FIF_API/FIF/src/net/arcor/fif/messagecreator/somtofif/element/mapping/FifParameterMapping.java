package net.arcor.fif.messagecreator.somtofif.element.mapping;

import net.arcor.fif.messagecreator.somtofif.description.SOMToFIFRepositoryConstants;

import org.w3c.dom.Element;
import org.w3c.dom.Node;

import de.arcor.kba.om.datatransformer.server.AbstractTransformationProvider;
import de.arcor.kba.om.datatransformer.server.exception.TransformationDescriptionInitialisationException;
import de.arcor.kba.om.datatransformer.server.exception.TransformationException;
import de.arcor.kba.om.datatransformer.server.model.IHierarchicalDataModel;
import de.arcor.kba.om.datatransformer.server.transformationelements.mappings.ElementMapping;

public class FifParameterMapping extends ElementMapping {
    private static final String EXISTING = "/existing";
    private static final String CONFIGURED = "/configured";

    /**
     * This variable holds the element-name of the fif-parameter "request-list-param" or
     * "request-param"
     */
    private String parameterElementName;

    /**
     * This is the parameter name. This means the value of the "name"-attribute within an
     * fif-parameter.
     */
    private String parameterName;

    public FifParameterMapping(String parameterElementName) {
        this.parameterElementName = parameterElementName;
    }

    @Override
    protected void processAttribute(String attributeName, String attributeValue,
            AbstractTransformationProvider transformationProvider)
            throws TransformationDescriptionInitialisationException {
        if (SOMToFIFRepositoryConstants.TARGET_NAME.equals(attributeName)) {
            parameterName = attributeValue;
            super.processAttribute(attributeName, parameterElementName, transformationProvider);
        } else {
            super.processAttribute(attributeName, attributeValue, transformationProvider);
        }
    }

    @Override
    protected String retrieveValue(IHierarchicalDataModel<?> inputData)
            throws TransformationException {
        String method = attributes.get(SOMToFIFRepositoryConstants.MAPPING_METHOD);
        if (SOMToFIFRepositoryConstants.MAPPING_METHOD_TYPE_CONFEXISTING.equals(method)) {
            String sourceAttrName = getSourceAttributeName();
            // Check whether a configured value exists.
            String value = inputData.getNodeValue(sourceAttrName + CONFIGURED);
            if (value == null || value.length() == 0) {
                // Ok. no configured value seems to exist. Check for existing one.
                value = inputData.getNodeValue(sourceAttrName + EXISTING);
                if (value == null || value.length() == 0) {
                    // value is still empty. Check for default value.
                    String defaultValue = getDefaultValue();
                    if (defaultValue != null) {
                        value = defaultValue;
                    }
                }
            }
            return value;
        }
        return super.retrieveValue(inputData);
    }

    @Override
    protected void validate() throws TransformationDescriptionInitialisationException {
        super.validate();

        // sourceAttrName must be set when method is set to 'configuredExisting'
        String method = attributes.get(SOMToFIFRepositoryConstants.MAPPING_METHOD);
        if (SOMToFIFRepositoryConstants.MAPPING_METHOD_TYPE_CONFEXISTING.equals(method)) {
            String sourceAttrName = getSourceAttributeName();
            if (sourceAttrName == null) {
                throw new TransformationDescriptionInitialisationException(
                        "it's not allowed to use method 'configuredExisting' without sourceAttrName.");
            }
        }
    }

    @Override
    protected void generateTargetNodes(Node currentOutputNode, String value,
            IHierarchicalDataModel<?> inputData) throws TransformationException {
        Element parameterElement = createAndAppendElement(currentOutputNode, getTargetName(),
                value, Node.CDATA_SECTION_NODE);
        parameterElement.setAttribute("name", parameterName);
    }

}
