package net.arcor.fif.messagecreator.somtofif.description;

import java.text.SimpleDateFormat;

/**
 * Constants for the {@link SOMToFIFRepository}.
 * 
 * @author Jean-Daniel Schlueter
 * @since 1.29 (IT-23360)
 */
public interface SOMToFIFRepositoryConstants {

    // Known Conditions
    String CONDITION_ELEMENTNAME_ANDCOMPOSITE = "AndComposite";
    String CONDITION_ELEMENTNAME_ORCOMPOSITE = "OrComposite";
    String CONDITION_ELEMENTNAME_NOTCOMPOSITE = "Not";

    public static final String RLP_MAPPING = "RLPMapping";

    public static final String RP_MAPPING = "RPMapping";
    public static final String MAPPING_METHOD = "method";

    public static final String MAPPING_METHOD_TYPE_CONFEXISTING = "configuredExisting";
    public static final String MAPPING_METHOD_TYPE_DEFAULT = "default";

    public static final String RP_LIST_TEMPLATE = "RPListTemplate";
    public static final String RP_LIST_ITEM_TEMPLATE = "RPListItemTemplate";

    public static final String REQUEST_TEMPLATE = "RequestTemplate";

    public static final String BASE_TRANSFORMATION_TEMPLATE = "TransformationTemplate";

    public static final String REQUEST_LIST_TEMPLATE = "RequestListTemplate";

    public static final String ABSTRACT_TRANSFORMATION_TEMPLATE = "AbstractTransformationTemplate";

    public static final String SOURCE_WORKING_PATH = "sourceWorkingPath";

    public static final String SOURCE_ATTR_NAME = "sourceAttrName";

    public static final String TARGET_NAME = "targetName";

    public static final String LIST_NAME = "listName";

    public static final String LIST_ITEM_NAME = "listItemName";

    public static final String VALUE = "value";

    public static final String ORDER_ID_PATH = "orderIdPath";

    public static final String SOM_TO_CCB_DATE_FORMATER = "SOMToCCBDateFormatter";

    public static final SimpleDateFormat SOM_DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");

    public static final SimpleDateFormat CCB_DATE_FORMAT = new SimpleDateFormat(
            "yyyy.MM.dd 00:00:00");

    public static final String ORDER_ID = "orderID";

}
