package net.arcor.fif.messagecreator.somtofif;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;

import net.arcor.fif.messagecreator.somtofif.description.FIFRequestConstants;
import net.arcor.fif.messagecreator.somtofif.description.SOMToFIFRepositoryConstants;
import net.arcor.fif.messagecreator.somtofif.element.mapping.FifParameterMapping;
import net.arcor.fif.messagecreator.somtofif.element.template.RPListItemTemplate;
import net.arcor.fif.messagecreator.somtofif.element.template.RPListTemplate;
import net.arcor.fif.messagecreator.somtofif.element.template.RequestListTemplate;
import net.arcor.fif.messagecreator.somtofif.element.template.RequestTemplate;

import org.w3c.dom.Element;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import de.arcor.kba.om.datatransformer.server.AbstractTransformationProvider;
import de.arcor.kba.om.datatransformer.server.exception.TransformationDescriptionInitialisationException;
import de.arcor.kba.om.datatransformer.server.transformationelements.AbstractDescriptionElement;
import de.arcor.kba.om.datatransformer.server.transformationelements.conditions.AndComposite;
import de.arcor.kba.om.datatransformer.server.transformationelements.conditions.NotComposite;
import de.arcor.kba.om.datatransformer.server.transformationelements.conditions.OrComposite;
import de.arcor.kba.om.datatransformer.server.transformationelements.formatter.DateFormatter;
import de.arcor.kba.om.datatransformer.server.transformationelements.formatter.IFormatter;
import de.arcor.kba.om.datatransformer.server.transformationelements.templates.BaseTransformationTemplate;

/**
 * SOMToFIFTransformationProvider for the SOM2FIF transformation.
 * 
 * @author Jean-Daniel Schlüter
 * @since 1.29 (IT-23360)
 */
public class SOMToFIFTransformationProvider extends AbstractTransformationProvider {

    private static final String TRANSFORMATIONDESCRIPTION_PATH = "description/";
    private static final String TRANSFORMATION_SCHEMA = "SOMToFIFTransformationSchema.xsd";

    private static SOMToFIFTransformationProvider instance;

    private String repositoryName;
    
    private static HashMap<String, SOMToFIFTransformationProvider> providerMap = 
    	new HashMap<String, SOMToFIFTransformationProvider>();


    public static SOMToFIFTransformationProvider getInstance(String repositoryName) {
        if (providerMap.containsKey(repositoryName))
        	return providerMap.get(repositoryName);
        else {
        	SOMToFIFTransformationProvider provider = new SOMToFIFTransformationProvider(repositoryName);
        	providerMap.put(repositoryName, provider);
        	return provider;
        }
    }

    

    /**
     * This constructor is only for testing purposes - the
     * {@link SOMToFIFTransformationProviderMock} NEEDS TO EXTEND this object. NOTE: Do not use it!
     */
    protected SOMToFIFTransformationProvider() {
        this.repositoryName = "SOMToFIFRepository_wf1.xml";
    }

    protected SOMToFIFTransformationProvider(String repositoryName) {
        this.repositoryName = repositoryName;
    }

    @Override
    public String getCacheKey() {
        // We use the repositoryName as well as key for the cache
        return repositoryName;
    }

    public static SOMToFIFTransformationProvider getInstance() {
        if (instance == null) {
            instance = new SOMToFIFTransformationProvider();
        }
        return instance;
    }

    // since IT-24000
    public static SOMToFIFTransformationProvider getInstance(Long workflowId) {
        SOMToFIFTransformationProvider provider = providerMap.get(workflowId);
        if (provider == null) {
            throw new IllegalArgumentException(
                    "could not found SOMToFIFTransformationProvider for workflowId=" + workflowId);
        }
        return provider;
    }

    /**
     * Creates an object due to the element given as parameter.
     * 
     * @see de.arcor.kba.om.datatransformer.server.AbstractTransformationProvider#createRepositoryElement(org.w3c.dom.Element)
     */
    @Override
    public AbstractDescriptionElement createRepositoryElement(Element element)
            throws TransformationDescriptionInitialisationException {
        String elementName = element.getNodeName();
        if (SOMToFIFRepositoryConstants.ABSTRACT_TRANSFORMATION_TEMPLATE.equals(elementName)) {
            return new BaseTransformationTemplate();
        } else if (SOMToFIFRepositoryConstants.BASE_TRANSFORMATION_TEMPLATE.equals(elementName)) {
            return new BaseTransformationTemplate();
        } else if (SOMToFIFRepositoryConstants.REQUEST_LIST_TEMPLATE.equals(elementName)) {
            return new RequestListTemplate();
        } else if (SOMToFIFRepositoryConstants.REQUEST_TEMPLATE.equals(elementName)) {
            return new RequestTemplate();
        } else if (SOMToFIFRepositoryConstants.RLP_MAPPING.equals(elementName)) {
            return new FifParameterMapping(FIFRequestConstants.REQUEST_LIST_PARAM);
        } else if (SOMToFIFRepositoryConstants.RP_MAPPING.equals(elementName)) {
            return new FifParameterMapping(FIFRequestConstants.REQUEST_PARAM);
        } else if (SOMToFIFRepositoryConstants.RP_LIST_TEMPLATE.equals(elementName)) {
            return new RPListTemplate();
        } else if (SOMToFIFRepositoryConstants.RP_LIST_ITEM_TEMPLATE.equals(elementName)) {
            return new RPListItemTemplate();
        } else if (SOMToFIFRepositoryConstants.CONDITION_ELEMENTNAME_ANDCOMPOSITE
                .equals(elementName)) {
            return new AndComposite();
        } else if (SOMToFIFRepositoryConstants.CONDITION_ELEMENTNAME_ORCOMPOSITE
                .equals(elementName)) {
            return new OrComposite();
        } else if (SOMToFIFRepositoryConstants.CONDITION_ELEMENTNAME_NOTCOMPOSITE
                .equals(elementName)) {
            return new NotComposite();
        } else {
            return super.createRepositoryElement(element);
        }
    }

    /**
     * Creates a formatter due to the given parameter. If no there is no defined formatter, the base
     * class will be called for standard behaviour.
     * 
     * @see de.arcor.kba.om.datatransformer.server.AbstractTransformationProvider#createFormatter(java.lang.String)
     */
    @Override
    public IFormatter createFormatter(String formatterName)
            throws TransformationDescriptionInitialisationException {
        if (SOMToFIFRepositoryConstants.SOM_TO_CCB_DATE_FORMATER.equals(formatterName)) {
            return new DateFormatter(SOMToFIFRepositoryConstants.SOM_DATE_FORMAT,
                    SOMToFIFRepositoryConstants.CCB_DATE_FORMAT);
        }
        return super.createFormatter(formatterName);
    }

    /**
     * Calls the parent to get an {@link InputStream} for the transformation repository.
     * 
     * @see de.arcor.kba.om.datatransformer.server.AbstractTransformationProvider#getTransformationDescription()
     */
    @Override
    public InputSource getTransformationDescription() {
        InputStream descriptionAsInputStream = getResourceInputStream(TRANSFORMATIONDESCRIPTION_PATH
                + repositoryName);
        return new InputSource(descriptionAsInputStream);
    }

    @Override
    public InputSource resolveEntity(String publicId, String systemId) throws SAXException,
            IOException {
        String entityName = systemId.substring(systemId.lastIndexOf("/") + 1);
        if (TRANSFORMATION_SCHEMA.equals(entityName)) {
            URL url = this.getClass().getResource(TRANSFORMATIONDESCRIPTION_PATH + entityName);
            if (url == null) {
                throw new IOException("Can't get Resource: " + entityName);
            }
            return loadEntity(url);
        }
        return super.resolveEntity(publicId, systemId);
    }

    @Override
    public String toString() {
        return this.repositoryName;
    }
}
